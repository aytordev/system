---
title: Skill Resolution Before Judging
impact: CRITICAL
impactDescription: Judges review against project standards, not just generic best practices
tags: execution, skill-resolver
---

## Skill Resolution (Pattern 0)

**Impact: CRITICAL**

Follow the **Skill Resolver Protocol** (`_shared/skill-resolver.md`) before launching ANY sub-agent:

1. Obtain the skill index: `mem_search(query: "skill-registry", project: "{project}")` → fallback to `.atl/skill-registry.md` when file persistence was selected
2. Identify target files/scope — what code will the judges review?
3. Match relevant skills from the index descriptions by:
   - **Code context**: file extensions/paths (e.g. `.nix` → nix skill)
   - **Task context**: "review code" → framework/language skills
4. Build a `## Skills to load before work` block listing the exact `SKILL.md` paths
5. Inject this block into BOTH Judge prompts AND the Fix Agent prompt (identical for all)

**If no index exists**: warn the user ("No skill registry found — judges will review without project-specific standards. Run `skill-registry` to fix this.") and proceed with generic review only.
