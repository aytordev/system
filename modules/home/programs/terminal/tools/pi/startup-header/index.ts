/**
 * Custom Pi startup header.
 *
 * Owns exactly one thing: the startup header (shown above the chat) in TUI
 * sessions. It renders the bundled art as a centered kitty image followed by a
 * centered, animated status panel. It deliberately does NOT touch the footer,
 * widgets, editor, settings, models, or any other Pi profile file — those have
 * other owners.
 *
 * Why the `setHeader` delay: `pi-tui` keeps a SINGLE custom-header slot and the
 * last writer wins. gentle-pi's own banner asserts its header at roughly 50 ms,
 * so we assert ours at 120 ms to win the slot without a race.
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
import { existsSync, readFileSync } from "node:fs";
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
	deleteKittyImage,
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
}

const DEFAULT_CONFIG: StartupHeaderConfig = {
	maxWidthCells: 44,
	maxHeightCells: 20,
	cadence: "quality",
	art: "pink-monster.png",
};

/** Interval per cadence; `null` disables the animation loop entirely. */
const CADENCE_MS: Record<Cadence, number | null> = {
	quality: 80,
	performance: 250,
	off: null,
};

/** Delay before claiming the single custom-header slot. gentle-pi asserts at ~50 ms. */
const HEADER_ASSERT_DELAY_MS = 120;

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
	private readonly artBase64: string | undefined;
	private readonly imageDimensions: ImageDimensions | undefined;
	private readonly imageId: number | undefined;
	private cachedImage: CachedImage | undefined;

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
	) {
		this.pi = pi;
		this.ctx = ctx;
		this.tui = tui;
		this.theme = theme;
		this.config = config;
		this.profile = loadActiveProfile();

		// Only load the art when the terminal actually speaks kitty. Any other
		// capability renders the panel alone rather than a broken sequence.
		const kitty = getCapabilities().images === "kitty";
		const art = kitty ? loadArtBase64(config.art) : null;
		this.artBase64 = art?.base64;
		this.imageDimensions = art?.dimensions ?? undefined;
		this.imageId = art ? allocateImageId() : undefined;

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
			this.tui.requestRender();
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
		if (this.artBase64 === undefined || this.imageDimensions === undefined) return [];
		const cached = this.cachedImage;
		if (cached !== undefined && cached.width === width) {
			return placeImage(cached.sequence, cached.columns, cached.rows, width);
		}
		// Clamp the configured cap to the live terminal width: `renderImage` uses
		// `maxWidthCells` as given and applies no internal width guard, so this is
		// the only thing keeping the placement inside the terminal. Centering then
		// uses the footprint `renderImage` reports, not the requested cap.
		const maxWidthCells = Math.max(1, Math.min(width - 2, this.config.maxWidthCells));
		const result = renderImage(this.artBase64, this.imageDimensions, {
			maxWidthCells,
			maxHeightCells: this.config.maxHeightCells,
			imageId: this.imageId,
			moveCursor: false,
		});
		if (!result) {
			const label = imageFallback("image/png", this.imageDimensions, this.config.art);
			return [truncateToWidth(this.theme.fg("dim", label), width)];
		}
		this.cachedImage = {
			width,
			sequence: result.sequence,
			columns: result.columns,
			rows: result.rows,
		};
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
		const imageId = this.imageId;
		if (imageId !== undefined) {
			try {
				this.tui.terminal.write(deleteKittyImage(imageId));
			} catch {
				// Terminal already gone; nothing to clean up.
			}
		}
	}
}

export default function (pi: ExtensionAPI): void {
	const config = loadConfig();
	const pendingTimers = new Set<ReturnType<typeof setTimeout>>();
	let active: StartupHeaderComponent | undefined;

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		// Assert after gentle-pi's banner so we own the single header slot.
		const timer = setTimeout(() => {
			pendingTimers.delete(timer);
			try {
				ctx.ui.setHeader((tui, theme) => {
					active = new StartupHeaderComponent(pi, ctx, tui, theme, config);
					return active;
				});
			} catch {
				// Never crash the session if header installation fails.
			}
		}, HEADER_ASSERT_DELAY_MS);
		pendingTimers.add(timer);
	});

	pi.on("session_shutdown", () => {
		for (const timer of pendingTimers) clearTimeout(timer);
		pendingTimers.clear();
		active?.dispose();
		active = undefined;
	});
}
