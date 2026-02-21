---
title: Context Engineering for AI Systems
impact: MEDIUM
impactDescription: Context stuffing produces hallucination-prone, expensive, brittle AI systems
tags: facilitation, context-engineering, memory-architecture, ai-products, llm-design
---

## Context Engineering for AI Systems

**Impact: MEDIUM (Context stuffing produces hallucination-prone, expensive, brittle AI systems)**

Diagnose whether an AI system is doing context stuffing (dumping everything into the prompt) versus proper context engineering (routing the right information to the right memory tier at the right time). Use this when designing AI-powered product features, reviewing an AI architecture decision, or debugging a system with high latency, high cost, or degraded output quality. Do not treat context engineering as an optimization pass — it is a foundational architectural decision that defines retrieval strategy, memory taxonomy, and token economics from the start.

**Incorrect (context stuffing — everything in one prompt):**

```markdown
## AI Feature Design

System prompt includes:
- Full user profile (2,000 tokens)
- Entire conversation history (8,000 tokens)
- All product documentation (12,000 tokens)
- Current session state (1,500 tokens)

Total: ~23,500 tokens per request. Model: GPT-4o.
Cost: $0.047/request. At 50K daily requests = $2,350/day = $858K/year.
Output quality declining as context window fills.
```

**Correct (tiered memory architecture with deliberate routing):**

```markdown
## Context Engineering Architecture

**Memory Taxonomy:**
| Tier | Type | Storage | Retrieval | What Goes Here |
|---|---|---|---|---|
| In-context | Working memory | LLM prompt | Always present | Current task, immediate history (last 3 turns), system persona |
| External (semantic) | Long-term episodic | Vector DB | RAG — top-k relevant chunks | User history, past decisions, product docs |
| External (structured) | Factual state | SQL/KV store | Tool call — precise lookup | Account data, permissions, pricing, feature flags |
| In-weights | Procedural | Model fine-tune | Implicit | Domain tone, task patterns (baked in) |

**Routing Rules:**
- User asks about their account → tool call to structured store (never RAG)
- User references a past conversation → semantic retrieval, top-3 chunks, inject into context
- General product question → RAG over docs, max 1,500 tokens injected

**Result:** Average prompt: 3,200 tokens. Cost: $0.006/request. Quality consistent.
Degradation eliminated — context is always purpose-selected, not bulk-pasted.
```

Reference: [Full framework](../references/context-engineering-full.md)
