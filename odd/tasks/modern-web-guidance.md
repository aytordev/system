# Modern web guidance
Publish two pinned GoogleChrome skills through the existing Pi skill catalog.
Branch: feat/modern-web-guidance

## Specs
- S1: “Me gustaría implementar las skills de https://github.com/GoogleChrome/modern-web-guidance-src” — “Catálogo Nix para Pi (recomendado)”; “modern-web-guidance, chrome-extensions”.
- S2: “Sí, integrar la versión fijada”: modern-web-guidance@1.0.2, distribution 2b4aa13a72dd47cd135b06ce5abfccd92e19b24f. Verify package and notices; use Nix CLI, no runtime downloads, disable CLI telemetry, test offline search and retrieval. No live profile activation.

## Tasks
- T1 [blocked] S1–S2 — package, publish, document and test both skills; worker; commit pending. Risk: item 5 (new dependency).

## Log
- L1: Me gustaría implementar las skills de https://github.com/GoogleChrome/modern-web-guidance-src
- L2: Selected catalog for Pi, both packs and pinned integration.
- Static verification: Nix parse and Python compile passed. Verified npm digest and exercised search/list/retrieve with an isolated Node wrapper and network/process tripwires. This is not a realized Nix/Home Manager check.
- Fixture-based Nix checks denied by sensitive-path guard before execution. No activation or commit. Resume on a runner authorized to use the synthetic flake input.
- L3: commit PR y merge cuando este en verde
