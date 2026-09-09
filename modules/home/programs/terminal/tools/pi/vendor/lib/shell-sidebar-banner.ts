import { visibleWidth } from "@earendil-works/pi-tui";
import type { ShellBarTheme } from "./shell-bar.ts";

export function renderSidebarBanner(theme: ShellBarTheme, width: number): string[] {
	const label = "✿ aytordev ✿";
	const space = width - visibleWidth(label);
	if (space < 0) return [];
	// Kanagawa accent; title text.
	const title = theme.fg("accent", "✿") + " " + theme.fg("text", "aytordev") + " " + theme.fg("accent", "✿");
	return [" ".repeat(Math.floor(space / 2)) + title + " ".repeat(Math.ceil(space / 2))];
}
