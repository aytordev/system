# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/bff-entry-points/` |
| Imported revision | `fd017e2008465b8ba4d95a0312c112150c836116` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus five of its six reference documents: endpoint
protection, hexagonal auth boundaries, realtime entry points, browser session
coordination, and enforcement and testing. The full source list inside those
documents (OWASP cheat sheets, ASVS 5.0, RFC 9110/9457/9700/6455/6750,
draft-ietf-oauth-browser-based-apps, web.dev Fetch Metadata, PortSwigger,
OpenAPI 3.1 semantics, WHATWG specs) was imported with them.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (access classification, prepared
  registrar, authorization boundaries), with the five upstream deep-dive
  references kept.
- Dropped `agents/openai.yaml` (client-specific agent metadata); its display
  role is covered by `SKILL.md` frontmatter and `metadata.json`.
- Dropped the upstream Hono reference implementation document (a concrete
  framework binding of the registrar model, not portable instruction
  material); the framework-neutral decisions it encoded (exhaustive
  classification switch, chain ordering, sealed finalize, runtime route
  enumeration for gate 5, sibling upgrade registrar, the framework mapping
  responsibilities) are restated as rules in `rules/prepared-registrar.md` and
  in the endpoint-protection reference, and the concrete binding is left as a
  per-project exercise. No code is vendored and no upstream script path is
  referenced.
- Converted the upstream pointer to
  `../functional/resources/effect-runtime.md` (a relative link leaving the
  folder) into an inline note: Effect-based handler composition is a separate
  functional-programming concern and is not bundled here.
- Converted upstream cross-skill routing (bff-design, structure-codebase,
  hexagonal-architecture, api-design, secure-oauth-oidc, codebase-design,
  testing, tdd, front-end-testing) into bounded local notes: each rule is
  restated inline, the published companions are named only as optional, and
  unpublished concerns (BFF adoption and upstream identity, external API
  contract shape, OAuth/OIDC protocol workflow, ports-and-adapters placement)
  are described without skill names, so this folder works alone.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path above.

## MIT notice

```text
MIT License

Copyright (c) 2024 Paul Hammond

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
