/**
 * Custom Pi startup header.
 *
 * Owns exactly one thing: the startup header (shown above the chat) in TUI
 * sessions. It renders the bundled art through the exported `Image` component
 * (which caches the kitty transmission per width) followed by a small animated
 * status panel. It deliberately does NOT touch the footer, widgets, editor,
 * settings, models, or any other Pi profile file — those have other owners.
 *
 * Why the `setHeader` delay: `pi-tui` keeps a SINGLE custom-header slot and the
 * last writer wins. gentle-pi's own banner asserts its header at roughly 50 ms,
 * so we assert ours at 120 ms to win the slot without a race.
 *
 * Why the exported `Image` component instead of `renderImage()`: calling
 * `renderImage()` from `render()` re-registers kitty metadata on every frame,
 * which bumps `kittyTransmissionGeneration` and forces a full base64
 * re-transmission every tick. `Image` caches by width and allocates a stable
 * kitty image id, so the payload is transmitted once per width.
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
	deleteKittyImage,
	getCapabilities,
	getPngDimensions,
	Image,
	truncateToWidth,
	visibleWidth,
	type ImageDimensions,
	type ImageOptions,
	type ImageTheme,
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

/**
 * The header component: the art (when the terminal speaks kitty) followed by a
 * status panel. Every panel line is truncated to `width`; the image lines are
 * passed through untouched because they carry escape sequences that must not be
 * sliced.
 */
class StartupHeaderComponent {
	private readonly pi: ExtensionAPI;
	private readonly ctx: ExtensionContext;
	private readonly tui: TUI;
	private readonly theme: Theme;
	private readonly config: StartupHeaderConfig;
	private readonly image: Image | undefined;
	private readonly options: ImageOptions;
	private readonly imageTheme: ImageTheme;

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

		this.options = {
			maxWidthCells: config.maxWidthCells,
			maxHeightCells: config.maxHeightCells,
			filename: config.art,
		};
		this.imageTheme = {fallbackColor: (s: string) => theme.fg("dim", s)};

		// Only build the image when the terminal actually speaks kitty. Any other
		// capability renders the panel alone rather than a broken/fallback line.
		const kitty = getCapabilities().images === "kitty";
		const art = kitty ? loadArtBase64(config.art) : null;
		this.image = art
			? new Image(art.base64, "image/png", this.imageTheme, this.options, art.dimensions ?? undefined)
			: undefined;

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
		const painted = this.theme.fg("muted", `  ${label.padEnd(8)}`);
		return `${painted}${value}`;
	}

	/** Build the panel lines with color re-applied per line (styles do not cross lines). */
	private panelLines(): string[] {
		const theme = this.theme;
		const accent = (s: string) => theme.fg("accent", s);
		const text = (s: string) => theme.fg("text", s);
		const dim = (s: string) => theme.fg("dim", s);

		const frame = SPINNER_FRAMES[this.tick % SPINNER_FRAMES.length];
		const title = `${accent(frame)} ${theme.fg("muted", "pink-monster")}`;
		const rule = dim("  " + "─".repeat(Math.max(0, this.config.maxWidthCells - 2)));

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
			title,
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
			const lines: string[] = [];
			// Image lines carry kitty escape sequences; never truncate them.
			if (this.image) lines.push(...this.image.render(width));
			for (const line of this.panelLines()) {
				lines.push(visibleWidth(line) > width ? truncateToWidth(line, width) : line);
			}
			return lines;
		} catch {
			// A header must never take down the session.
			return [truncateToWidth(this.theme.fg("dim", "pink-monster"), width)];
		}
	}

	invalidate(): void {
		this.image?.invalidate();
	}

	dispose(): void {
		if (this.disposed) return;
		this.disposed = true;
		if (this.interval !== undefined) {
			clearInterval(this.interval);
			this.interval = undefined;
		}
		const imageId = this.image?.getImageId();
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
