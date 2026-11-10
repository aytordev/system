---
title: Resolve the Glossary Authority Before Rewording
impact: HIGH
impactDescription: Keeps domain terms inside the context that owns them
tags: wtf, glossary, terminology
---

## Resolve the Glossary Authority Before Rewording

**Impact: HIGH**

When the previous response uses domain terms, do not guess their meaning or
pick synonyms freely.

1. First inspect repository guidance for its declared glossary authority and
   bounded-context scope.
2. If none is declared, check common locations such as `CONTEXT.md`,
   `GLOSSARY.md`, `UBIQUITOUS_LANGUAGE.md`, and `*.glossary.yml` — without
   creating a new convention.
3. Use only the glossary that owns the relevant context to select canonical
   terms and meanings. When contexts differ, the owning context wins; do not
   blend vocabulary across bounded contexts.
4. Do not introduce information from the terminology files that the previous
   response did not contain. The glossary is a translation aid for terms
   already present, never a source of new claims.
