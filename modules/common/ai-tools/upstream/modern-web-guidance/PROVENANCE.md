# GoogleChrome Modern Web Guidance

The catalog pins Google's npm artifact `modern-web-guidance@1.0.2` by its
published SHA-512 integrity. Its registry `gitHead` identifies
`GoogleChrome/modern-web-guidance-src` at the catalog's `sourceRevision`;
`distributionRevision` is the `Release v1.0.2` commit in the separate
[`GoogleChrome/modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance)
repository, not the npm tarball's SHA-1. The tarball's two `SKILL.md` files and
`LICENSE` match that distribution commit. The registry tarball also includes
`THIRD_PARTY_NOTICES`; the distribution commit does not contain that file.

The npm manifest declares Apache-2.0. Preparation checks both legal files'
SHA-256 digests and copies their original bytes to both skill directories so
an independent export retains the notices. The tarball is fetched by Nix; no
npm installation or lifecycle is involved.

Local changes are applied at build time by `prepare.py`:

- Use the pinned PATH CLI in the skill, guide cross-references, and search
  chunk text. Keep the upstream search algorithm, semantic index vectors, and
  retrieval data and project gates. Feature-gate guidance does not propose
  package-runner or configuration-writing commands.
- Install only the offline CLI (`search`, `list`, `retrieve`, version/help)
  and its required assets. Exclude the upstream scanner, installer and updater,
  telemetry watchdog, plugin manifests, and permission policies. No runtime
  download or profile management is provided. The wrapper forces telemetry
  and file logging off.
- Replace Chrome Extensions examples that run supplied code or weaken CSP with
  advice to keep strict CSP, isolate untrusted content, and validate sender,
  origin, and message shape. Retain the surrounding extension guidance.

Check the release's provenance and re-review the package, its instructions, the
selection of executable files, and the package/skill regressions on any manual
update. No runtime tracking or updater is configured.
