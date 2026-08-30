# aytordev option docs

This book documents the `aytordev.*` option namespace for the nix-darwin and
Home Manager configurations of this flake.

The pages are generated from a real evaluation of the module tree
(`flake/docs/generate.nix`) with synthetic identity arguments, so no private
`secrets` input is touched:

- [Darwin options](./darwin.md) — nix-darwin system options under `aytordev.*`
- [Home Manager options](./home.md) — user options under `aytordev.*`

Source options are declared in `modules/darwin/` and `modules/home/`.

## Regenerating

```bash
nix build .#aarch64-darwin.docs-options   # markdown + compact index
nix run .#docs-html                       # open this book in the browser
```

The `integration-docs-generation` check keeps the committed option-index
snapshot in sync and builds this book on darwin.