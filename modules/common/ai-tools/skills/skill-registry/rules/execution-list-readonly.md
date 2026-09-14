---
title: Read-Only Listing
impact: HIGH
impactDescription: Lists the index without writing anything
tags: listing, read-only
---

## Read-Only Listing

**Impact: HIGH**

When the user asks to **list** or **show** skills, print the index to the conversation and stop. Listing is read-only in every persistence mode.

- Do NOT create or modify `.atl/`.
- Do NOT edit `.gitignore`.
- Do NOT save to Engram.
- Do NOT modify any project file.

The listing prints the same fields as the index: `Name | Description | Scope | Path | Freshness`, plus the `Shadowed / Ambiguous` entries and the invocation-eligibility note when relevant.

Refresh (writing or saving the index) is a separate action; see `rules/execution-persist.md`.
