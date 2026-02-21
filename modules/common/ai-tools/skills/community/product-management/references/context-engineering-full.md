# Context Engineering for AI Systems — Full Framework

## Purpose

Diagnose whether an AI system is doing context stuffing (dumping everything into
the prompt) versus context engineering (routing the right information to the right
memory tier at the right time). Use this when designing AI-powered product features,
reviewing AI architecture decisions, or debugging systems with high latency, high
cost, or degraded output quality.

Context engineering is not an optimization pass. It is a foundational architectural
decision that defines retrieval strategy, memory taxonomy, and token economics
from the start.

---

## Context Stuffing vs. Context Engineering

| Dimension       | Context Stuffing               | Context Engineering                |
|-----------------|--------------------------------|------------------------------------|
| Mindset         | Volume = quality               | Structure = quality                |
| Approach        | "Add everything just in case"  | "What decision am I making?"       |
| Persistence     | Persist all context            | Retrieve with intent               |
| Agent Chains    | Share everything between agents| Bounded context per agent          |
| Failure Response| Retry until it works           | Fix the structure                  |
| Economic Model  | Context as storage             | Context as attention (scarce)      |

Context stuffing is bringing your entire file cabinet to a meeting. Context
engineering is bringing only the 3 documents relevant to today's decision.

---

## Five Markers of Context Stuffing

Recognize these symptoms to diagnose the problem:

1. **Reflexively expanding context windows.** "Just add more tokens" as the
   default response to quality issues.
2. **Persisting everything "just in case."** No clear retention criteria;
   everything saved permanently.
3. **Chaining agents without boundaries.** Agent A passes full context to
   Agent B to Agent C; context window explodes.
4. **Adding evaluations to mask inconsistency.** Retry loops instead of
   structural fixes.
5. **Normalized retries.** "It works if you run it 3 times" becomes acceptable.

**Why it fails:** Reasoning noise degrades multi-hop logic. Context rot
accumulates dead ends and errors. Models prioritize beginning and end of context,
ignoring the middle (lost-in-the-middle effect). Accuracy drops below 20% when
context exceeds approximately 32k tokens.

---

## Five Foundational Principles

1. Context without shape becomes noise.
2. Structure beats volume.
3. Retrieve with intent, not completeness.
4. Small working contexts (like short-term memory).
5. Context Compaction: maximize density of relevant information per token.

**Quantitative framework:**

```
Efficiency = (Accuracy x Coherence) / (Tokens x Latency)
```

Using RAG with 25% of available tokens preserves 95% accuracy while significantly
reducing latency and cost.

---

## The 5 Diagnostic Questions

Ask these to detect Context Hoarding Disorder:

1. **What specific decision does this support?** If no answer, the context is
   not needed.
2. **Can retrieval replace persistence?** Just-in-time beats always-available.
3. **Who owns the context boundary?** If no one, context grows forever.
4. **What fails if we exclude this?** If nothing breaks, delete it.
5. **Are we fixing structure or avoiding it?** Stuffing context often masks
   bad information architecture.

---

## Memory Architecture: Two-Layer System

### Short-Term (Conversational) Memory

- Immediate interaction history for follow-up questions
- Lifespan: single session
- Management: summarize or truncate older parts to avoid crowding

### Long-Term (Persistent) Memory

- User preferences, core constraints, operational glossary
- Lifespan: persistent across sessions
- Implementation: vector database with semantic retrieval
- Two types:
  - **Declarative Memory:** Facts ("We follow HIPAA regulations")
  - **Procedural Memory:** Behavioral patterns ("Always validate feasibility first")

Models can generate their own memories (LLM-powered ETL): identify signals,
consolidate with existing data, update the database automatically.

---

## Memory Taxonomy Table

| Tier               | Type             | Storage         | Retrieval             | Contents                                    |
|--------------------|------------------|-----------------|-----------------------|---------------------------------------------|
| In-context         | Working memory   | LLM prompt      | Always present        | Current task, last 3 turns, system persona  |
| External (semantic)| Long-term episodic| Vector DB      | RAG: top-k chunks     | User history, past decisions, product docs  |
| External (structured)| Factual state  | SQL / KV store  | Tool call: precise    | Account data, permissions, feature flags    |
| In-weights         | Procedural       | Model fine-tune | Implicit              | Domain tone, task patterns                  |

### Routing Rules

- User asks about their account: tool call to structured store (never RAG)
- User references a past conversation: semantic retrieval, top-3 chunks
- General product question: RAG over docs, max 1,500 tokens injected

---

## The Research-Plan-Reset-Implement Cycle

This cycle prevents context rot — the accumulation of dead ends, errors, and
noise that degrades agent performance over time.

**Phase 1: Research.** Agent gathers data. Context window grows large and messy.
Dead ends and noise accumulate. This is expected.

**Phase 2: Plan.** Agent synthesizes research into a high-density SPEC.md or
PLAN.md. This becomes the Source of Truth for implementation. Include: decision
made, evidence supporting it, constraints applied, sequenced next steps.

**Phase 3: Reset.** Clear the entire context window. Delete all research
artifacts, dead ends, and errors. This prevents context rot from poisoning
implementation.

**Phase 4: Implement.** Start a fresh session with only the high-density plan
as context. Agent has clean, focused attention on execution.

---

## Context Manifest Template

```markdown
# Context Manifest: [Product/Feature Name]

## Always Persisted (Core Context)
- Product constraints (technical, regulatory)
- User preferences (role, permissions)
- Operational glossary (20 key terms)

## Retrieved On-Demand (Episodic Context)
- Historical PRDs (semantic search)
- User interview transcripts (relevant quotes only)
- Competitive analysis (when explicitly needed)

## Excluded (Out of Scope)
- Meeting notes older than 30 days
- Full codebase (use code search instead)
- Marketing materials (not decision-relevant)

## Boundary Owner: [Name]
## Last Reviewed: [Date]
## Next Review: [Date + 90 days]
```

---

## Persist vs. Retrieve Decision Rule

- **Persist:** Information referenced in 80%+ of interactions
- **Retrieve:** Information referenced in less than 20% of interactions
- **Gray zone (20-80%):** Depends on retrieval latency vs. context window cost

---

## Falsification Protocol

For each piece of context, complete this statement:

> "If I exclude [context element], then [specific failure] will occur in
> [specific scenario]."

Good: "If I exclude GDPR constraints, AI will recommend features that violate
EU privacy law."

Bad: "If I exclude this PRD, AI might not fully understand the product." (Vague,
unfalsifiable — delete the context.)

---

## Worked Example: Solo PM (Context Stuffing to Engineering)

**Before:** Pasting entire 20-page PRDs and 50 user interview transcripts into
every prompt. Getting vague, inconsistent responses. Retrying 4+ times.

**Diagnosis:** Active Context Hoarding Disorder. Cannot identify concrete
failure for most included context. No retrieval strategy.

**Intervention:**
1. Apply falsification test: keeps 20% of original context
2. Build constraints registry (10 technical, 5 strategic)
3. Create operational glossary (25 terms)
4. Implement Research-Plan-Reset-Implement for next PRD

**After:** Token usage down 70%. Responses crisp and actionable. No retries.

---

## Common Pitfalls

**Believing "infinite context" marketing.** One million token windows do not mean
you should use all of them. Accuracy degrades past approximately 32k tokens.
Treat tokens as scarce.

**Retrying instead of restructuring.** "It works if I run it 3 times" masks
broken context structure. Fix the architecture, do not add retry loops.

**No context boundary owner.** Without explicit ownership, context grows
unbounded. Assign ownership and schedule quarterly audits.

**Mixing always-needed with episodic.** Persisting historical data that should
be retrieved on-demand crowds the context window and dilutes attention.

**Skipping the Reset phase.** Never clearing context during the Research-Plan-
Implement cycle allows context rot to accumulate and goal drift to occur.

---

## Related Frameworks

- AI-Shaped Readiness: Context Design is Competency #1
- Problem Statement: evidence-based framing requires context engineering
- Epic Hypothesis: testable hypotheses depend on clear constraints
- PoL Probe: validation experiments benefit from engineered context
- Workshop Facilitation Protocol: interaction protocol for guided sessions
