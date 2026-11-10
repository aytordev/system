---
name: embedding-safety
impact: CRITICAL
impactDescription: Iframe sandboxing, CSP, and formatter safety
---

# Embedding Safety and Formatter Safety

**Impact: CRITICAL**

## Treat every mock and URL as untrusted

Even when content lives in the repository, treat it as untrusted input.

- Prefer relative, reviewed, repository-owned targets.
- Never embed credential-bearing URLs or private third-party pages.
- Give each iframe a `sandbox` attribute with only the capabilities the mock
  demonstrably needs. Static mocks need no tokens; interactive mocks commonly
  need `allow-scripts`, but same-origin untrusted content must never receive
  both `allow-scripts` and `allow-same-origin`. If that combination is
  genuinely required, serve it from an isolated origin or use the static
  fallback.
- Add a restrictive Content Security Policy to the storyboard itself —
  normally self-hosted frames, images, and styles only, plus the minimum
  locally justified exceptions.
- Never add `allow-top-navigation`, popups, forms, downloads, camera,
  microphone, or clipboard access merely to make a mock work.
- If sandboxing or CSP prevents faithful rendering, label the limitation and
  use a static authority rather than weakening the review page silently.

## Formatter safety

Three rules learned the hard way:

1. **Always wrap ASCII / multi-line preformatted content in `<pre>`.**
   Formatters reformat HTML inside `<div class="whitespace-pre">` and destroy
   the layout. `<pre>` is immune.
2. **Do not fight table column widths.** Write the markdown/HTML table; let
   the formatter realign it; commit the realigned version.
3. **Run the project's formatter on the storyboard file before committing.**
   If the repository has a pre-commit hook it catches this anyway, but it is
   faster to format up-front.
