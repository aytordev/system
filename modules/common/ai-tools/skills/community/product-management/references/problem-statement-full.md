# Problem Statement — Full Framework

## Purpose

The problem statement frames a customer problem with enough specificity to align
stakeholders before any solution discussion begins. It prevents the most expensive
failure mode in product work: building the right solution to the wrong problem.
Use it as the mandatory first section of a PRD, discovery synthesis, or any
document that proposes a product investment.

## Five-Part Format

```
I am [persona — role and context]
trying to [goal — specific job they are attempting]
but [barrier — concrete obstacle blocking the goal]
because [root cause — why the barrier exists]
which makes me feel [emotional impact — the human consequence]
```

Every part is required. Omitting the emotional impact makes the statement
feel abstract and strips the team of empathy. Omitting the root cause
allows solutions to treat symptoms instead of causes.

## Field-by-Field Guidance

**I am [persona]**
Name the specific persona experiencing the problem. Include their role, company
context, and relevant experience level. This is not a demographic — it is a
behavioral archetype grounded in research.

Good: "a newly hired revenue operations analyst at a Series B SaaS company"
Bad: "a user" or "a customer"

**Trying to [goal]**
State the specific job they are trying to accomplish — the outcome they want,
not the feature they're using to get there. Use the Jobs-to-be-Done framing:
this is a functional goal with a time horizon.

Good: "get my first monthly pipeline report out within my first two weeks on the job"
Bad: "use the reporting tool" or "access analytics"

**But [barrier]**
Name the concrete, specific obstacle that blocks the goal. This is observable
behavior — something you saw or heard in research. Do not describe a product
gap; describe what the person cannot do.

Good: "I cannot connect our CRM data to the reporting tool without IT help"
Bad: "the product doesn't have a good integration workflow"

**Because [root cause]**
Explain why the barrier exists. This is the causal mechanism. Getting this right
is what separates solutions that fix the problem from solutions that move the
obstacle one step downstream.

Good: "the integration requires admin credentials I'm not authorized to have"
Bad: "the product is hard to use" or "it's a technical limitation"

**Which makes me feel [emotional impact]**
State the emotional consequence in the person's own words if possible. This is
what makes the problem real to engineers and executives who are not close to
the customer. Omitting this turns a human problem into a process diagram.

Good: "like I'm failing at a basic part of my job before I've even started"
Bad: "frustrated" (too generic — go one level deeper)

## Complete Worked Example

```
I am a newly hired revenue operations analyst
trying to get my first monthly pipeline report out within my first two weeks
but I cannot connect our CRM data to the reporting tool without IT help
because the integration requires admin credentials I'm not authorized to have,
which makes me feel like I'm failing at a basic part of my job before I've even started.

Source: 6/8 onboarding interview participants described a version of this barrier.
Direct quote: "I spent three days on what I thought would take an hour." — P4
```

## Evidence Requirements

Every component must be traceable to research. Do not synthesize a problem
statement from assumptions or internal opinions. Each field should have a source:

- **Persona:** Proto-persona or validated persona document
- **Goal:** Job-to-be-done interview or contextual observation
- **Barrier:** Direct observation or verbatim quote from interview
- **Root cause:** Follow-up "why" question from interview; technical audit
- **Emotional impact:** Direct quote from participant, not inferred

If evidence is missing, note the gap explicitly and flag it as an assumption.

## Quality Checklist

- [ ] Persona is specific (role + context), not generic ("user")
- [ ] Goal is a functional outcome, not a feature usage description
- [ ] Barrier is observable behavior, not a product critique
- [ ] Root cause goes one level deeper than the barrier
- [ ] Emotional impact is specific; not just "frustrated" or "annoyed"
- [ ] All five parts traceable to research data or direct quotes
- [ ] No solution language present anywhere in the statement
- [ ] Stakeholders read it and agree this is the problem worth solving

## Common Failure Modes

| Failure Mode            | Example                                          | Fix                                              |
|-------------------------|--------------------------------------------------|--------------------------------------------------|
| Solution-framed barrier | "but our app doesn't have bulk export"           | Describe what the user cannot do, not the gap    |
| Persona is a segment    | "I am a mid-market finance team"                 | Use one person, one role, one context            |
| Aspirational goal       | "trying to become more data-driven"              | Name the specific task they are attempting now   |
| Shallow root cause      | "because it's technically complicated"           | Keep asking why until you reach the real cause   |
| Missing evidence        | No sources cited                                 | Flag every unsourced component as an assumption  |
| Multiple problems       | Statement contains "and" or "also"               | Split into separate statements; one problem each |

## Relationship to Other Frameworks

The problem statement is the foundation. Build on it in this order:

1. Problem Statement (this document) — defines the problem and who has it
2. Positioning Statement — positions the solution against this problem
3. PRD Problem Statement section — the same statement, source-cited, in the PRD
4. Press Release problem paragraph — customer-voice version of this statement
5. User Stories — each story's "so that" clause should trace back to this statement
