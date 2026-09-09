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

`themes/kanagawa.json` is a custom Kanagawa palette re-mapping of the pi theme
roles (the rose/champagne palette from gentle-pi's `themes/Gentle*.json` is
replaced). It follows the same pi theme schema (`vars` / `colors` / `export`).

## Local patches (fork from upstream)

`extensions/startup-banner.ts` is patched: upstream defaults to `showRose: true`
with a hardcoded `pink` (`[255,118,195]`) palette (the rose flower). We set
`showRose: false`, added a `kanagawa` palette (accent `#7e9cd8`, heading
`#c8c093`, text `#dcd7ba`, `bg_gutter` `#2a2a37`), added it to `BannerColor`
and `BANNER_COLORS`, and made it the default `color`. Re-derive this hunk when
re-vendoring a newer gentle-pi.
