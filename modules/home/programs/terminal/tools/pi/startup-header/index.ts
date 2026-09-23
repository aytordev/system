/**
 * Custom Pi startup header.
 *
 * Owns exactly one thing: the startup header (shown above the chat) in TUI
 * sessions. It renders the bundled art as a centered kitty image followed by a
 * centered, animated status panel. It deliberately does NOT touch the footer,
 * widgets, editor, models, or any other Pi profile file. The single exception is
 * the `!startup-banner.ts` filter on the gentle-pi entry (bare
 * `npm:gentle-pi` or a version-pinned variant such as `npm:gentle-pi@<version>`) of
 * `~/.pi/agent/settings.json`: Home Manager merges it during activation and this
 * extension re-applies it when another writer drops it.
 *
 * Why claiming the slot takes three pieces: `pi-tui` keeps a SINGLE
 * custom-header slot and the last writer wins. gentle-pi's own banner asserts at
 * roughly 50 ms on EVERY `session_start`, so (1) we assert ours at 120 ms to win
 * each emission, (2) we install immediately from `session_shutdown` while our
 * delayed assert is still pending, because a session replaced inside that 120 ms
 * window would otherwise hand the slot to a banner that already asserted, and
 * (3) a bounded watchdog re-claims the header when our component stops being
 * painted, which is the only available signal that a later writer took it back.
 *
 * Why `renderImage()` is called once per width instead of once per frame: every
 * call that passes an `imageId` re-registers kitty metadata, which bumps
 * `kittyTransmissionGeneration` and makes the renderer treat that frame as a
 * fresh upload, re-sending the whole base64 payload. Caching the result keeps
 * the generation stable, so the renderer substitutes a cheap place-only (`a=p`)
 * command on every later frame.
 *
 * Why the payload is built directly instead of through the exported `Image`
 * component: `Image` does not expose the cell footprint, and centering needs it.
 * `calculateImageCellSize` and `isImageLine` are not part of the package's public
 * exports, so the footprint is taken from `renderImage()`'s own return value.
 */

import { execFile } from "node:child_process";
import { existsSync, readFileSync, renameSync, statSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import type {
	ExtensionAPI,
	ExtensionContext,
	Theme,
} from "@earendil-works/pi-coding-agent";
import {
	allocateImageId,
	getCapabilities,
	getPngDimensions,
	imageFallback,
	renderImage,
	truncateToWidth,
	visibleWidth,
	type ImageDimensions,
	type TUI,
} from "@earendil-works/pi-tui";

/** Cadence presets; `off` means render once and never schedule a timer. */
type Cadence = "quality" | "performance" | "off";

interface StartupHeaderConfig {
	/** Maximum image width in terminal cells. */
	maxWidthCells: number;
	/** Maximum image height in terminal cells. */
	maxHeightCells: number;
	/** Animation cadence preset. */
	cadence: Cadence;
	/** Base file name of the PNG next to this entry point. */
	art: string;
	/** Re-apply the gentle-pi banner filter when another writer drops it. */
	disableGentlePiBanner: boolean;
}

const DEFAULT_CONFIG: StartupHeaderConfig = {
	maxWidthCells: 44,
	maxHeightCells: 20,
	cadence: "quality",
	art: "pink-monster.png",
	disableGentlePiBanner: true,
};

/** Interval per cadence; `null` disables the animation loop entirely. */
const CADENCE_MS: Record<Cadence, number | null> = {
	quality: 80,
	performance: 250,
	off: null,
};

/** Delay before claiming the single custom-header slot. gentle-pi asserts at ~50 ms. */
const HEADER_ASSERT_DELAY_MS = 120;

/** Watchdog cadence, and how long a live claim may go unpainted before we re-claim. */
const WATCHDOG_INTERVAL_MS = 500;
const HEADER_SILENCE_MS = 2_000;

/** Bounded self-healing: never re-claim more than this many times per session. */
const MAX_RECLAIMS = 8;

/**
 * Anchored matcher for the gentle-pi source: the bare package or any pinned
 * variant (`npm:gentle-pi@<spec>`), never a package whose name merely starts
 * with `gentle-pi` (e.g. `npm:gentle-pi-tools`). Literal pattern, not an
 * interpolation, so future constant churn cannot change the pattern's meaning.
 * Must stay semantically in sync with `isGentlePiEntry` in `startup-header.nix`:
 * the jq side uses Oniguruma's `\z` because jq's `$` also matches immediately
 * before a final newline, which this ECMAScript pattern (no `m` flag) rejects.
 * One residual bound is deliberately left open: Oniguruma's `.` matches a raw
 * CR, U+2028 and U+2029 inside the `@.+` region of a pinned spec, so the
 * activation merge would filter an entry like `npm:gentle-pi@a\rb` that this
 * pattern would skip. Such a `source` cannot be a resolvable Pi package spec,
 * so the divergence is unreachable for any real `settings.json`; do not add
 * exotic escapes to chase it.
 */
const GENTLE_PI_SOURCE_PATTERN = /^npm:gentle-pi(@.+)?$/;

/** Type guard deciding whether a `packages` entry source is gentle-pi. */
function isGentlePiPackage(source: unknown): source is string {
	return typeof source === "string" && GENTLE_PI_SOURCE_PATTERN.test(source);
}

const BANNER_FILTER = "!startup-banner.ts";

/** Deterministic spinner frames indexed by the tick counter. */
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

/** Absolute directory containing this entry point (config + art live as siblings). */
const SCRIPT_DIR = dirname(fileURLToPath(import.meta.url));

/** Fallback directory used when the entry-point-relative lookup cannot be resolved. */
const FALLBACK_DIR = join(
	homedir(),
	".pi/agent/extensions/startup-header",
);

/**
 * Ordered, deduplicated directories searched for both `config.json` and the
 * art: the entry-point-relative directory first, then the installed location.
 * Node realpaths symlinked modules, so `import.meta.url` can resolve to a
 * standalone store file whose sibling directory carries no art; the installed
 * directory is then the reliable fallback.
 */
function candidateDirs(): string[] {
	const dirs = [SCRIPT_DIR, FALLBACK_DIR];
	return dirs.filter((dir, index) => dirs.indexOf(dir) === index);
}

/** Coerce an unknown parsed value into a finite positive integer, else `fallback`. */
function intOr(value: unknown, fallback: number): number {
	return typeof value === "number" && Number.isFinite(value) && value > 0
		? Math.floor(value)
		: fallback;
}

/**
 * Read `config.json` next to the entry point, falling back to the installed
 * location. An absent or unparsable file yields the built-in defaults; this
 * function never throws.
 */
function loadConfig(): StartupHeaderConfig {
	for (const dir of candidateDirs()) {
		const candidate = join(dir, "config.json");
		try {
			if (!existsSync(candidate)) continue;
			const parsed = JSON.parse(readFileSync(candidate, "utf8")) as Record<string, unknown>;
			const cadence =
				parsed.cadence === "quality" ||
				parsed.cadence === "performance" ||
				parsed.cadence === "off"
					? parsed.cadence
					: DEFAULT_CONFIG.cadence;
			return {
				maxWidthCells: intOr(parsed.maxWidthCells, DEFAULT_CONFIG.maxWidthCells),
				maxHeightCells: intOr(parsed.maxHeightCells, DEFAULT_CONFIG.maxHeightCells),
				cadence,
				art: typeof parsed.art === "string" && parsed.art.length > 0 ? parsed.art : DEFAULT_CONFIG.art,
				disableGentlePiBanner: parsed.disableGentlePiBanner !== false,
			};
		} catch {
			// Unparsable config is not fatal: fall through to the next candidate.
		}
	}
	return {...DEFAULT_CONFIG};
}

/**
 * Read and base64-encode the art from the first candidate directory that has
 * it, or `null` when no candidate is readable. This function never throws.
 */
function loadArtBase64(art: string): { base64: string; dimensions: ImageDimensions | null } | null {
	for (const dir of candidateDirs()) {
		const path = join(dir, art);
		try {
			if (!existsSync(path)) continue;
			const base64 = readFileSync(path).toString("base64");
			return {base64, dimensions: getPngDimensions(base64)};
		} catch {
			// Unreadable art is not fatal: fall through to the next candidate.
		}
	}
	return null;
}

/** Timestamp of the last paint of a live header component; the watchdog reads it. */
let lastRenderAt = 0;

/** `ctx.mode` reads through the runner, which throws once the runner is invalidated. */
function isTuiSession(ctx: ExtensionContext): boolean {
	try {
		return ctx.mode === "tui";
	} catch {
		return false;
	}
}

/**
 * Re-apply the `!startup-banner.ts` filter when something rewrote it away.
 *
 * Home Manager owns the declarative merge
 * (`home.activation.piStartupHeaderBannerFilter`), but `settings.json` is a
 * runtime file that Pi, the Gentle AI installer and package installers rewrite.
 * Observed on 2026-09-21: the activation merged the filter at 22:57:33 and a
 * later rewrite of `packages` dropped it, which re-enables gentle-pi's banner
 * for every following start. Healing rewrites only that one entry (the bare or
 * version-pinned `npm:gentle-pi` source, preserving any pin), preserves every
 * other key, and is skipped when the file changed underneath us.
 *
 * Failures are swallowed: the activation merge remains the authoritative repair.
 */
function ensureGentlePiBannerFilter(config: StartupHeaderConfig): void {
	if (!config.disableGentlePiBanner) return;
	const agentDir = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
	const settingsPath = join(agentDir, "settings.json");
	try {
		if (!existsSync(settingsPath)) return;
		const before = statSync(settingsPath);
		const settings = JSON.parse(readFileSync(settingsPath, "utf8")) as {packages?: unknown};
		if (!Array.isArray(settings.packages)) return;

		let changed = false;
		const packages = settings.packages.map((entry: unknown) => {
			if (isGentlePiPackage(entry)) {
				changed = true;
				return {source: entry, extensions: [BANNER_FILTER]};
			}
			if (entry === null || typeof entry !== "object") return entry;
			const record = entry as {source?: unknown; extensions?: unknown};
			if (!isGentlePiPackage(record.source)) return entry;
			const filters = Array.isArray(record.extensions) ? [...record.extensions] : [];
			if (filters.includes(BANNER_FILTER)) return entry;
			changed = true;
			return {...record, extensions: [...filters, BANNER_FILTER]};
		});
		if (!changed) return;

		const after = statSync(settingsPath);
		if (after.mtimeMs !== before.mtimeMs || after.size !== before.size) return;
		const tmp = `${settingsPath}.${process.pid}.tmp`;
		writeFileSync(tmp, `${JSON.stringify({...settings, packages}, null, 2)}\n`, {mode: before.mode & 0o777});
		renameSync(tmp, settingsPath);
	} catch {
		// Best effort: the activation merge still repairs the file on the next switch.
	}
}

/** Read the active agent-model profile from gentle-ai's runtime file, else `-`. */
function loadActiveProfile(): string {
	try {
		const path = join(homedir(), ".pi/gentle-ai/profiles.json");
		if (!existsSync(path)) return "-";
		const parsed = JSON.parse(readFileSync(path, "utf8")) as {active?: unknown};
		return typeof parsed.active === "string" && parsed.active.length > 0 ? parsed.active : "-";
	} catch {
		return "-";
	}
}

/** Compact token count for the context line. */
function fmtTokens(tokens: number | null, fallback: string): string {
	if (tokens === null || !Number.isFinite(tokens)) return fallback;
	if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(1)}M`;
	if (tokens >= 1_000) return `${Math.round(tokens / 1_000)}k`;
	return String(tokens);
}

/** The decoded art and its pixel size, resolved once per process. */
interface ArtState {
	base64: string;
	dimensions: ImageDimensions | null;
}

/** The kitty payload and the cell footprint it occupies, cached per width. */
interface CachedImage {
	width: number;
	sequence: string;
	columns: number;
	rows: number;
}

/** Left padding that centers `columns` cells inside `width`. */
function padFor(width: number, columns: number): number {
	return Math.max(0, Math.floor((width - columns) / 2));
}

/**
 * Center a kitty placement inside `width`, followed by the blank lines the
 * renderer needs to account for the image height. The sequence is never
 * truncated: it carries escape bytes, not printable text, so slicing it would
 * corrupt the command.
 */
function placeImage(sequence: string, columns: number, rows: number, width: number): string[] {
	const pad = padFor(width, columns);
	const lines = pad > 0 ? [" ".repeat(pad) + sequence] : [sequence];
	for (let index = 1; index < rows; index += 1) lines.push("");
	return lines;
}

/**
 * Center a block of styled lines inside `width`, preserving relative alignment.
 * Over-wide lines are truncated to `width` first: fitting is what keeps the
 * header from wrapping, and truncation is safe here because these lines are
 * printable text rather than escape payloads.
 */
function centerLines(lines: string[], width: number): string[] {
	const fitted = lines.map((line) => (visibleWidth(line) > width ? truncateToWidth(line, width) : line));
	let widest = 0;
	for (const line of fitted) widest = Math.max(widest, visibleWidth(line));
	const pad = padFor(width, widest);
	if (pad === 0) return fitted;
	const prefix = " ".repeat(pad);
	return fitted.map((line) => (line.length === 0 ? line : prefix + line));
}

/**
 * The header component: the centered art (when the terminal speaks kitty)
 * followed by a centered status panel.
 *
 * The image payload is produced at most once per terminal width and reused
 * verbatim afterwards, which is what keeps the kitty transmission off the
 * animation path. The panel re-renders every tick because its spinner is the
 * only animated element.
 */
class StartupHeaderComponent {
	private readonly pi: ExtensionAPI;
	private readonly ctx: ExtensionContext;
	private readonly tui: TUI;
	private readonly theme: Theme;
	private readonly config: StartupHeaderConfig;
	private readonly art: ArtState | undefined;
	private readonly imageId: number | undefined;
	private readonly payloadCache: Map<number, CachedImage>;

	private tick = 0;
	private interval: ReturnType<typeof setInterval> | undefined;
	private disposed = false;
	private gitBranch = "(no git)";
	private readonly profile: string;

	constructor(
		pi: ExtensionAPI,
		ctx: ExtensionContext,
		tui: TUI,
		theme: Theme,
		config: StartupHeaderConfig,
		art: ArtState | undefined,
		imageId: number | undefined,
		payloadCache: Map<number, CachedImage>,
	) {
		this.pi = pi;
		this.ctx = ctx;
		this.tui = tui;
		this.theme = theme;
		this.config = config;
		this.art = art;
		this.imageId = imageId;
		this.payloadCache = payloadCache;
		this.profile = loadActiveProfile();

		this.resolveGitBranch();
		this.startAnimation();
	}

	private resolveGitBranch(): void {
		try {
			execFile(
				"git",
				["rev-parse", "--abbrev-ref", "HEAD"],
				{cwd: this.ctx.cwd, timeout: 2_000, windowsHide: true},
				(error, stdout) => {
					if (this.disposed) return;
					this.gitBranch = error ? "not a git repo" : stdout.trim() || "(detached)";
					this.tui.requestRender();
				},
			);
		} catch {
			this.gitBranch = "not a git repo";
		}
	}

	private startAnimation(): void {
		const ms = CADENCE_MS[this.config.cadence];
		if (ms === null) return;
		this.interval = setInterval(() => {
			this.tick = (this.tick + 1) % Number.MAX_SAFE_INTEGER;
			try {
				this.tui.requestRender();
			} catch {
				// The UI is gone; a header must never throw out of a timer.
				this.dispose();
			}
		}, ms);
	}

	private row(label: string, value: string): string {
		// Three leading spaces so the labels line up under the rule, which starts
		// after the spinner frame plus a two-space gap.
		const painted = this.theme.fg("muted", `   ${label.padEnd(8)}`);
		return `${painted}${value}`;
	}

	/** Build the panel lines with color re-applied per line (styles do not cross lines). */
	private panelLines(): string[] {
		const theme = this.theme;
		const accent = (s: string) => theme.fg("accent", s);
		const text = (s: string) => theme.fg("text", s);
		const dim = (s: string) => theme.fg("dim", s);

		const frame = SPINNER_FRAMES[this.tick % SPINNER_FRAMES.length];
		// The spinner opens the panel instead of sitting on its own title line, so
		// the rule aligns with the rows beneath it.
		const rule = `${accent(frame)}${dim("  " + "─".repeat(Math.max(0, this.config.maxWidthCells - 2)))}`;

		const model = this.ctx.model;
		const modelLabel = model ? `${model.provider}/${model.id}` : "(no model)";
		const thinking = this.ctx.thinkingLevel ?? "-";

		const usage = this.ctx.getContextUsage();
		const contextLabel = usage
			? `${usage.percent === null ? "?" : `${usage.percent.toFixed(0)}%`}  ${fmtTokens(usage.tokens, "?")}/${fmtTokens(usage.contextWindow, "?")}`
			: "n/a";

		let skills = 0;
		try {
			skills = this.pi.getCommands().filter((c) => c.source === "skill").length;
		} catch {
			skills = 0;
		}
		let tools = 0;
		try {
			tools = this.pi.getAllTools().length;
		} catch {
			tools = 0;
		}

		return [
			rule,
			this.row("branch", text(this.gitBranch)),
			this.row("model", `${text(modelLabel)}  ${dim(`· ${thinking}`)}`),
			this.row("context", text(contextLabel)),
			this.row("skills", `${text(String(skills))}  ${dim(`· ${tools} tools`)}`),
			this.row("profile", text(this.profile)),
		];
	}

	render(width: number): string[] {
		lastRenderAt = Date.now();
		try {
			const lines = this.imageLines(width);
			lines.push(...centerLines(this.panelLines(), width));
			return lines;
		} catch {
			// A header must never take down the session.
			return [truncateToWidth(this.theme.fg("dim", this.spinnerFrame()), width)];
		}
	}

	/**
	 * The centered image lines, or nothing when there is no usable art. The
	 * payload is produced once per width and reused verbatim on later frames.
	 */
	private imageLines(width: number): string[] {
		const art = this.art;
		if (art === undefined || art.dimensions === null) return [];
		const cached = this.payloadCache.get(width);
		if (cached !== undefined) {
			return placeImage(cached.sequence, cached.columns, cached.rows, width);
		}
		// Clamp the configured cap to the live terminal width: `renderImage` uses
		// `maxWidthCells` as given and applies no internal width guard, so this is
		// the only thing keeping the placement inside the terminal. Centering then
		// uses the footprint `renderImage` reports, not the requested cap.
		const maxWidthCells = Math.max(1, Math.min(width - 2, this.config.maxWidthCells));
		const result = renderImage(art.base64, art.dimensions, {
			maxWidthCells,
			maxHeightCells: this.config.maxHeightCells,
			imageId: this.imageId,
			moveCursor: false,
		});
		if (!result) {
			const label = imageFallback("image/png", art.dimensions, this.config.art);
			return [truncateToWidth(this.theme.fg("dim", label), width)];
		}
		this.payloadCache.set(width, {
			width,
			sequence: result.sequence,
			columns: result.columns,
			rows: result.rows,
		});
		return placeImage(result.sequence, result.columns, result.rows, width);
	}

	private spinnerFrame(): string {
		return SPINNER_FRAMES[this.tick % SPINNER_FRAMES.length];
	}

	invalidate(): void {
		// Deliberately empty. The cached payload depends only on the terminal
		// width, and the panel re-derives its colors from the live theme on every
		// render, so a theme change needs no invalidation. Clearing the cache here
		// would force a needless full kitty re-transmission.
	}

	dispose(): void {
		if (this.disposed) return;
		this.disposed = true;
		if (this.interval !== undefined) {
			clearInterval(this.interval);
			this.interval = undefined;
		}
	}
}

export default function (pi: ExtensionAPI): void {
	const config = loadConfig();
	// One kitty image per process, allocated on the first claim: re-claims then
	// reuse the same id and the same per-width payload, so reclaiming the slot
	// after a later writer steals it costs no re-transmission and repaints
	// byte-identical art.
	let imageId: number | undefined;
	let art: ArtState | null | undefined;
	const payloadCache = new Map<number, CachedImage>();

	let active: StartupHeaderComponent | undefined;
	let sessionCtx: ExtensionContext | undefined;
	let generation = 0;
	let claimedAt = 0;
	let reClaims = 0;
	let pending: ReturnType<typeof setTimeout> | undefined;
	let watchdog: ReturnType<typeof setInterval> | undefined;

	/** Capability detection needs a live terminal, so the art is resolved lazily. */
	const resolveArt = (): ArtState | undefined => {
		if (art === undefined) {
			const resolved = getCapabilities().images === "kitty" ? loadArtBase64(config.art) : null;
			art = resolved ?? null;
		}
		return art ?? undefined;
	};

	/** Install (or reinstall) our header. Never throws, not even on a stale ctx. */
	const claim = (ctx: ExtensionContext): void => {
		claimedAt = Date.now();
		try {
			ctx.ui.setHeader((tui, theme) => {
				const resolved = resolveArt();
				if (imageId === undefined && resolved !== undefined) imageId = allocateImageId();
				const component = new StartupHeaderComponent(pi, ctx, tui, theme, config, resolved, imageId, payloadCache);
				active = component;
				return component;
			});
		} catch {
			// Never crash the session if header installation fails. A ctx whose
			// runner was invalidated by a reload lands here as well.
		}
	};

	const stopWatchdog = (): void => {
		if (watchdog !== undefined) {
			clearInterval(watchdog);
			watchdog = undefined;
		}
	};

	/**
	 * Third piece of the claim. Silence on a live session is the only signal that
	 * another writer took the single header slot, and it is enough: a claim that
	 * stops being painted for longer than the silence window lost it, so we take
	 * it back, bounded per session.
	 */
	const startWatchdog = (mine: number): void => {
		stopWatchdog();
		watchdog = setInterval(() => {
			if (mine !== generation) {
				stopWatchdog();
				return;
			}
			if (Date.now() - Math.max(claimedAt, lastRenderAt) <= HEADER_SILENCE_MS) return;
			if (reClaims >= MAX_RECLAIMS) {
				stopWatchdog();
				return;
			}
			reClaims += 1;
			if (sessionCtx !== undefined) claim(sessionCtx);
		}, WATCHDOG_INTERVAL_MS);
	};

	pi.on("session_start", (_event, ctx) => {
		if (!isTuiSession(ctx)) return;
		generation += 1;
		const mine = generation;
		sessionCtx = ctx;
		reClaims = 0;
		if (pending !== undefined) clearTimeout(pending);
		pending = setTimeout(() => {
			pending = undefined;
			if (mine !== generation) return;
			claim(ctx);
			startWatchdog(mine);
		}, HEADER_ASSERT_DELAY_MS);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (!isTuiSession(ctx)) return;
		if (pending !== undefined) {
			// The delayed assert never ran and the runner is still active inside
			// this shutdown emission, so install now: releasing the slot here is
			// what let a competitor that asserted at ~50 ms keep it.
			clearTimeout(pending);
			pending = undefined;
			claim(ctx);
		}
		stopWatchdog();
		generation += 1;
		active?.dispose();
		active = undefined;
		sessionCtx = undefined;
	});

	ensureGentlePiBannerFilter(config);
}
