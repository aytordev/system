# Modern web guidance
Publish two pinned GoogleChrome skills through the existing Pi skill catalog.
Branch: feat/modern-web-guidance

## Specs
- S1: “Me gustaría implementar las skills de https://github.com/GoogleChrome/modern-web-guidance-src” — “Catálogo Nix para Pi (recomendado)”; “modern-web-guidance, chrome-extensions”.
- S2: “Sí, integrar la versión fijada”: modern-web-guidance@1.0.2, distribution 2b4aa13a72dd47cd135b06ce5abfccd92e19b24f. Verify package and notices; use Nix CLI, no runtime downloads, disable CLI telemetry, test offline search and retrieval. No live profile activation.

- S3: “resuelve todos los findings de reliability y de readability”: validate skill-resource links before dereferencing (R2-001); reject unexpected telemetry call-site edits at repin (R2-002); prove CLI enablement is actually asserted (R3-001); test explicit opt-out and opt-in for the same gated guide without changing policy (R3-002).

## Tasks
- T1 [blocked] S1–S2 — package, publish, document and test both skills; b39d6f90; full CI pending. Risk: item 5 (new dependency).

- T2 [verified] S3 — verify and address the four advisory findings in 5fe01580, e7102b5d, and the whole-file digest follow-up.

## Log
- L1: Me gustaría implementar las skills de https://github.com/GoogleChrome/modern-web-guidance-src
- L2: Selected catalog for Pi, both packs and pinned integration.
- Static verification: Nix parse and Python compile passed. Verified npm digest and exercised search/list/retrieve with an isolated Node wrapper and network/process tripwires. This is not a realized Nix/Home Manager check.
- Fixture-based Nix checks denied by sensitive-path guard before execution. No activation or commit. Resume on a runner authorized to use the synthetic flake input.
- L3: commit PR y merge cuando este en verde

- L4: resuelve todos los findings de reliability y de readability

- T2: the isolated pinned CLI passed opt-out/opt-in tests, three telemetry drift tests, and unchanged-package comparison. Canonical external-link rejection passed; each of five enablement mutations failed as expected.
- Independent final proof: missing, extra, reformatted and outside-main calls rejected before output; valid preparation retained 285 identical entries and the original offline-check success line. R3-001 was already evaluated and was not duplicated.
