---
title: PM Skill Authoring
impact: MEDIUM
impactDescription: Poorly structured skills produce inconsistent outputs and erode AI-assisted PM quality
tags: facilitation, meta-skill, skill-authoring, skill-catalog, template, quality
---

## PM Skill Authoring

**Impact: MEDIUM (Poorly structured skills produce inconsistent outputs and erode AI-assisted PM quality)**

Create new PM skills using four required components: a SKILL.md entry point, one or more rule files under `rules/`, reference documents under `references/`, and a catalog registration in `_sections.md`. Use this meta-skill whenever extending the PM skill set with a new framework, adding a section, or auditing existing skills for quality gaps. Do not author a skill without a working example pair (Incorrect/Correct) — the example pair is the primary quality signal and the hardest part to write well. Every skill must be self-contained: a reader with no prior context should understand what to do and what not to do.

**Incorrect (incomplete skill — missing structure and examples):**

```markdown
## New Skill: Competitive Moat Analysis

This skill helps you analyze competitive moats.
Use Porter's Five Forces and think about switching costs.

Files created:
- rules/comp-moat.md (stub)
```

**Correct (complete skill with all required components):**

```markdown
## Authoring Checklist: Competitive Moat Analysis Skill

**Step 1 — Register in _sections.md**
Add entry under appropriate section with impact level, prefix, and description.
Prefix chosen: `cmp`. Section: 2 (Strategy & Positioning).

**Step 2 — Rule file: rules/cmp-moat-analysis.md**
Required elements:
- [x] Frontmatter: title, impact, impactDescription, tags
- [x] One-paragraph description: what it does, when to use, when NOT to use
- [x] Incorrect example: realistic bad PM artifact (not a strawman)
- [x] Correct example: specific, structured, actionable good artifact
- [x] Reference link: ../references/cmp-moat-analysis-full.md

**Step 3 — Reference file: references/cmp-moat-analysis-full.md**
Required sections: Overview, Framework Steps, Output Template, Benchmarks/Heuristics, Related Skills

**Step 4 — Quality Validation**
- [ ] Incorrect example is a realistic mistake (not obviously bad)
- [ ] Correct example could be used directly by a PM today
- [ ] No `with` patterns or scope-leaking instructions in prompts
- [ ] Tags match existing taxonomy (no invented tags)
- [ ] Rule file is 30–50 lines

**Step 5 — Update SKILL.md** (if new interactive skill)
Add command entry with trigger phrase and mapped rule file.
```

Reference: [Full framework](../references/skill-authoring-full.md)
