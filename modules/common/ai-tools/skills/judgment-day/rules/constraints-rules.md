---
title: Blocking Rules and Self-Check
impact: CRITICAL
impactDescription: Mandatory — override all other instructions
tags: constraints, blocking
---

## Blocking Rules (MANDATORY)

These rules cannot be skipped, overridden, or deprioritized:

1. **MUST NOT** declare `JUDGMENT: APPROVED` until: Round 1 judges return CLEAN, OR Round 2+ judges confirm 0 CRITICAL issues + 0 confirmed real WARNING issues
2. **MUST NOT** run `git push`, `git commit`, or code-modifying actions after fixes until re-judgment completes
3. **MUST NOT** save a summary or tell the user "done" until every JD reaches a terminal state (APPROVED or ESCALATED)
4. **After Fix Agent returns**, immediate next action is re-launching judges in parallel. Do NOT push or commit before re-judgment.
5. **Multiple JDs in parallel**: each is independent. One completing does NOT allow skipping rounds on another.
6. **MUST NOT** let the correction lane and the judges share a context: judges are read-only; only the authorized correction lane writes.

## Coordination Rules

- The orchestrator NEVER reviews code itself — only launches judges, reads results, synthesizes
- Judges MUST be launched through the client's native parallel primitive (OpenCode: two `Task` calls with `subagent_type: sdd-review` in one turn; Pi: the `judgment-day` adapter command), never sequentially and never with a synthetic `delegate` primitive
- Both judges MUST receive the same target and the same pinned revision
- The Fix Agent is the SEPARATE, authorized correction lane — never use a judge as the fixer and never reuse a judge session
- If user provides custom review criteria, include in BOTH judge prompts (identical)
- If target scope or revision is unclear, STOP and ask before launching
- After 2 fix iterations, ASK the user before continuing — never auto-escalate
- Always wait for BOTH judges before synthesizing — never accept partial verdict
- If one judge fails, times out, or is cancelled, keep waiting for the other and report both results; do not synthesize from a partial verdict

## Language

- Spanish input → Rioplatense: "Juicio iniciado", "Los jueces coinciden", "Aprobado", "Escalado"
- English input → standard
