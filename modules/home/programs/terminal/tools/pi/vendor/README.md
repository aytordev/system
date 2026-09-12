# Gentle-pi vendored assets

The TypeScript extensions and helpers under `extensions/`, `lib/`, and
`scripts/` are vendored, unmodified, from
[`Gentleman-Programming/gentle-pi`](https://github.com/Gentleman-Programming/gentle-pi)
(MIT License), pinned to commit `main` @ gentle-pi v2.5.0.

Only the **aesthetic** extensions are vendored (gentle shell status bar, quiet
tool rendering, startup banner) plus their `lib/` closure and the
`gentle-ai-installer.mjs` script they import. The `@heyhuynhgiabuu/pi-pretty`
extension is deliberately **omitted** because it hard-requires a runtime npm
package; the remaining three resolve entirely from pi + pi-tui + Node builtins.

`themes/kanagawa.json` is a vendored custom Kanagawa palette kept as a
selectable fallback. The default `aytordev` theme is generated at build time
from `aytordev.theme.palette` (see `../theme.nix`) and follows the active theme
family/variant. It uses the same pi theme schema (`vars` / `colors` / `export`).

## Local patches (fork from upstream)

`extensions/startup-banner.ts` is patched: upstream defaults to `showRose: true`
with a hardcoded `pink` (`[255,118,195]`) palette (the rose flower) and a large
`TEXT_LOGO` **wordmark**. We set `showRose: false` **and** `showTextLogo: false`
(so no rose/flower and no big "gentle-pi" wordmark are drawn), added a
`kanagawa` palette (accent `#7e9cd8`, heading `#c8c093`, text `#dcd7ba`,
`bg_gutter` `#2a2a37`), added it to `BannerColor` and `BANNER_COLORS`, and made
it the default `color`. The banner's slash-command description is rebranded to
"aytordev".

Visible branding strings are rebranded to "aytordev" (instead of "gentle-pi"):
- `lib/shell-bar.ts` — `SHELL_BAR_BRAND`.
- `lib/shell-sidebar-banner.ts` — the sidebar header.

Re-derive these hunks when re-vendoring a newer gentle-pi.

## Startup banner palette is a fixed brand asset

`extensions/startup-banner.ts` keeps its own `BANNER_PALETTES` (rose, label,
value, logo-fresh, logo-dim) and defaults to the `kanagawa` preset. This is
**intentional**: the banner is the aytordev brand wordmark, not TUI chrome, so
it deliberately does **not** follow `aytordev.theme`. Only the TUI theme JSON
(`themes/aytordev.json`, generated from the active palette + ANSI table by
`../theme.nix`) tracks the selected family/variant. The banner palette is still
user-controllable at runtime via the `gentle:banner-color` slash command
(persisted to `~/.pi/gentle-ai/banner.json`), so it is never a hidden hardcoded
theme — it is a declared, overridable brand default.
