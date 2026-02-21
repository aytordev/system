# AI-Shaped Readiness Assessment — Full Framework

## Purpose

Assess whether product work is "AI-first" (automating existing tasks faster) or
"AI-shaped" (fundamentally redesigning how teams operate around AI). Score five
competencies, identify the highest-leverage gap, and generate a concrete action
plan for the next 30 days.

Use this before scoping AI initiatives, when leadership asks "how are we using
AI strategically?", or when AI usage exists but delivers no competitive advantage.

Do not use this if the team has zero AI experience (start with basic tools first)
or if the goal is tool selection (this framework addresses organizational design,
not tooling).

---

## AI-First vs. AI-Shaped — The Core Distinction

| Dimension   | AI-First (Efficiency)                      | AI-Shaped (Transformation)                         |
|-------------|--------------------------------------------|----------------------------------------------------|
| Mindset     | Automate existing tasks                    | Redesign how work gets done                        |
| Goal        | Speed up artifact creation                 | Compress learning cycles                           |
| AI Role     | Task assistant                             | Strategic co-intelligence                          |
| Advantage   | Temporary efficiency gains                 | Defensible competitive moat                        |
| Test        | Competitor replicates by adding headcount  | Competitor must redesign entire org to replicate   |

If a competitor can match your AI usage by throwing more people at it, you have
efficiency (table stakes within months), not differentiation.

---

## The Five Competencies

### 1. Context Design

Building a durable "reality layer" that both humans and AI trust.

- Constraints registry (technical, regulatory, strategic)
- Operational glossary (shared definitions, 20-30 terms)
- Evidence standards (what counts as validation)
- Context boundaries (persist vs. retrieve decisions)
- Memory architecture (short-term conversational + long-term persistent)

**Foundational dependency.** Agent Orchestration and Outcome Acceleration
cannot succeed without this. If scored at Level 1-2, this is always priority #1.

### 2. Agent Orchestration

Repeatable, traceable AI workflows — not one-off prompts.

- Defined workflow loops: research, synthesis, critique, decision, log rationale
- Each step shows its work (traceable reasoning)
- Version-controlled prompts and agents
- Consistent outputs from consistent inputs

### 3. Outcome Acceleration

AI compresses learning cycles, not just task completion time.

- Eliminate validation lag (probes in days, not weeks)
- Remove approval delays (AI pre-validates against constraints)
- Cut meeting overhead (async AI synthesis replaces status meetings)
- Measure: cycle time from hypothesis to validated learning

### 4. Team-AI Facilitation

Team systems redesigned so AI operates as co-intelligence, not an
accountability shield.

- Review norms: AI outputs are drafts, not finals
- Evidence standards: AI must cite sources, not hallucinate
- Decision authority: AI recommends, humans decide
- Psychological safety: team can challenge AI without stigma

### 5. Strategic Differentiation

Defensible competitive advantages beyond efficiency.

- New customer capabilities impossible without AI
- Workflow rewiring competitors cannot replicate without full redesign
- Economics competitors cannot match (10x cost advantage)

---

## Maturity Levels (Applied to Each Competency)

| Level | Label          | Description                                       |
|-------|----------------|---------------------------------------------------|
| 1     | AI-First       | Efficiency only; one-off prompts; no structure    |
| 2     | Emerging       | Early capabilities; some repeatable patterns      |
| 3     | Transitioning  | Redesign underway; workflows exist, gaps remain   |
| 4     | AI-Shaped      | Strategic transformation; defensible advantage    |

**Overall scoring:** Average across five competencies.

- 1.0-1.5 average: AI-First
- 2.0-2.5 average: Emerging
- 3.0-3.5 average: Transitioning
- 3.5-4.0 average: AI-Shaped

---

## Assessment Output Template

```markdown
## AI-Shaped Readiness Profile — [Organization/Team]

| Competency                | Level | Maturity       | Key Evidence                         |
|---------------------------|-------|----------------|--------------------------------------|
| Context Design            |   X   | [Label]        | [One sentence of evidence]           |
| Agent Orchestration       |   X   | [Label]        | [One sentence of evidence]           |
| Outcome Acceleration      |   X   | [Label]        | [One sentence of evidence]           |
| Team-AI Facilitation      |   X   | [Label]        | [One sentence of evidence]           |
| Strategic Differentiation |   X   | [Label]        | [One sentence of evidence]           |

**Overall: [Label] (average: X.X)**

### Priority Competency: [Name]
**Why this first:** [Dependency rationale]

### Blockers Before Advancing
1. [Blocker with estimated effort]
2. [Blocker with estimated effort]

### Recommended Entry Point
[Specific first action with timeline]
```

---

## Priority Selection Logic

Apply this dependency chain when choosing which competency to address first:

1. **Context Design is foundational.** If Level 1-2, always start here. Everything
   else depends on durable context.
2. **Agent Orchestration enables Outcome Acceleration.** If Context Design is
   Level 3+, but Orchestration is Level 1-2, prioritize orchestration.
3. **Team-AI Facilitation is parallel.** Develop alongside other competencies,
   but required for scale. Prioritize if usage is individual-only.
4. **Strategic Differentiation requires Level 3+ elsewhere.** Do not focus here
   until foundational competencies are built.

---

## 30-Day Action Plans by Priority

### Context Design (Weeks 1-4)

- Week 1: Create constraints registry (technical, regulatory, strategic)
- Week 2: Build operational glossary (20-30 terms, no ambiguity)
- Week 3: Establish evidence standards; define context boundaries
- Week 4: Implement two-layer memory architecture; test Research-Plan-Reset-Implement cycle

Success: 20+ constraints documented, glossary shared, AI agents reference context automatically.

### Agent Orchestration (Weeks 1-4)

- Week 1: Map most frequent AI use case end to end
- Week 2: Design orchestrated workflow (research, synthesis, critique, decision, log)
- Week 3: Build and test on 3 past examples; measure consistency
- Week 4: Version-control prompts; train 2 teammates

Success: At least 1 workflow runs consistently; each step is traceable.

### Outcome Acceleration (Weeks 1-4)

- Week 1: Identify slowest step in learning cycle (validation lag, approvals, meetings)
- Week 2: Design AI intervention ("what if this happened overnight?")
- Week 3: Pilot on 1 real initiative; measure before vs. after cycle time
- Week 4: Scale to 3 initiatives if quality maintained

Success: Learning cycle compressed 50%+ on at least 1 initiative.

### Team-AI Facilitation (Weeks 1-4)

- Week 1: Codify review norms (AI outputs are drafts)
- Week 2: Set evidence standards (AI must cite sources)
- Week 3: Define decision authority (AI recommends, humans decide)
- Week 4: Pilot with 3 teams; normalize catching AI errors

Success: Review norms documented and followed; team comfortable challenging AI.

### Strategic Differentiation (Weeks 1-5)

- Week 1: Brainstorm 5 capabilities competitors cannot replicate with headcount
- Week 2: Design top candidate end to end (customer experience, AI role, human judgment)
- Weeks 3-4: Build and test prototype with 5 customers
- Week 5: Validate moat ("how would a competitor replicate this?")

Success: 1 validated AI-enabled capability competitors cannot easily copy.

---

## Common Pitfalls

**Mistaking efficiency for differentiation.** Writing PRDs 2x faster is not
AI-shaped. Ask: "Could a competitor match this by hiring more people?" If yes,
it is table stakes.

**Skipping Context Design.** Building agent workflows without durable context
produces fragile systems that break when context changes.

**Individual usage without team transformation.** One AI-shaped PM cannot scale.
Workflows die when that person is unavailable. Shared norms beat individual
productivity.

**Focusing on tools instead of workflows.** "Should we use Claude or ChatGPT?"
is the wrong question. Tools do not matter; workflow redesign matters.

**Optimizing speed instead of learning.** Shipping faster is worthless if you
ship the wrong thing. Outcome Acceleration means validating hypotheses faster,
not building faster.

---

## Related Frameworks

- Context Engineering: diagnose context stuffing and implement memory architecture
- Workshop Facilitation Protocol: canonical interaction protocol for running
  this as a guided session
- Problem Statement: evidence-based framing (Context Design foundation)
- PoL Probe: compress validation cycles (Outcome Acceleration)
- Positioning Statement: articulate AI-driven differentiation
