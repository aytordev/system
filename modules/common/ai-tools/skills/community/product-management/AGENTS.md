# Product Management Guidelines

**Version 1.0.0**  
community  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when applying  
> product management frameworks. Humans may also find it useful, but  
> guidance here is optimized for AI-assisted PM workflows.

---

## Abstract

42 battle-tested product management frameworks distilled into actionable rules. Covers the full PM lifecycle from discovery and strategy through requirements, validation, planning, and financial analysis. Based on frameworks by Geoffrey Moore, Jeff Patton, Teresa Torres, Mike Cohn, Jeff Gothelf, and others.

---

## Table of Contents

1. [Discovery & Research](#1-discovery-&-research) — **CRITICAL**
   - 1.1 [Company Research](#11-company-research)
   - 1.2 [Customer Journey Map](#12-customer-journey-map)
   - 1.3 [Customer Journey Mapping Workshop](#13-customer-journey-mapping-workshop)
   - 1.4 [Discovery Interview Prep](#14-discovery-interview-prep)
   - 1.5 [Discovery Process](#15-discovery-process)
   - 1.6 [Jobs to Be Done](#16-jobs-to-be-done)
   - 1.7 [Proto Persona](#17-proto-persona)
2. [Strategy & Positioning](#2-strategy-&-positioning) — **CRITICAL**
   - 2.1 [Positioning Statement](#21-positioning-statement)
   - 2.2 [Positioning Workshop](#22-positioning-workshop)
   - 2.3 [Press Release (Working Backwards)](#23-press-release-working-backwards)
   - 2.4 [Problem Framing Canvas](#24-problem-framing-canvas)
   - 2.5 [Problem Statement](#25-problem-statement)
   - 2.6 [Product Strategy Session](#26-product-strategy-session)
   - 2.7 [TAM SAM SOM Calculator](#27-tam-sam-som-calculator)
3. [Requirements & Stories](#3-requirements-&-stories) — **HIGH**
   - 3.1 [Epic Breakdown Advisor](#31-epic-breakdown-advisor)
   - 3.2 [Epic Hypothesis](#32-epic-hypothesis)
   - 3.3 [PRD Development](#33-prd-development)
   - 3.4 [User Story](#34-user-story)
   - 3.5 [User Story Mapping](#35-user-story-mapping)
   - 3.6 [User Story Mapping Workshop](#36-user-story-mapping-workshop)
   - 3.7 [User Story Splitting](#37-user-story-splitting)
4. [Validation & Experimentation](#4-validation-&-experimentation) — **HIGH**
   - 4.1 [6-Frame User Journey Storyboard](#41-6-frame-user-journey-storyboard)
   - 4.2 [AI Recommendation Canvas](#42-ai-recommendation-canvas)
   - 4.3 [Lean UX Canvas](#43-lean-ux-canvas)
   - 4.4 [Opportunity Solution Tree](#44-opportunity-solution-tree)
   - 4.5 [PoL Probe Type Advisor](#45-pol-probe-type-advisor)
   - 4.6 [Proof of Learning (PoL) Probe](#46-proof-of-learning-pol-probe)
5. [Planning & Roadmapping](#5-planning-&-roadmapping) — **MEDIUM**
   - 5.1 [Acquisition Channel Evaluation](#51-acquisition-channel-evaluation)
   - 5.2 [Feature Investment Analysis](#52-feature-investment-analysis)
   - 5.3 [PESTEL Analysis](#53-pestel-analysis)
   - 5.4 [Prioritization Framework Advisor](#54-prioritization-framework-advisor)
   - 5.5 [Roadmap Planning](#55-roadmap-planning)
6. [Financial Analysis](#6-financial-analysis) — **MEDIUM**
   - 6.1 [Business Health Diagnosis](#61-business-health-diagnosis)
   - 6.2 [Pricing Change Financial Analysis](#62-pricing-change-financial-analysis)
   - 6.3 [SaaS Finance Metrics Reference](#63-saas-finance-metrics-reference)
   - 6.4 [SaaS Revenue Health Metrics](#64-saas-revenue-health-metrics)
   - 6.5 [SaaS Unit Economics & Capital Efficiency](#65-saas-unit-economics--capital-efficiency)
7. [Facilitation & Advisory](#7-facilitation-&-advisory) — **MEDIUM**
   - 7.1 [Context Engineering for AI Systems](#71-context-engineering-for-ai-systems)
   - 7.2 [End-of-Life & Deprecation Communication](#72-end-of-life--deprecation-communication)
   - 7.3 [Organizational AI Readiness Assessment](#73-organizational-ai-readiness-assessment)
   - 7.4 [PM Skill Authoring](#74-pm-skill-authoring)
   - 7.5 [Workshop Facilitation Protocol](#75-workshop-facilitation-protocol)

---

## 1. Discovery & Research

**Impact: CRITICAL**

Frameworks for understanding customers, markets, and problems before building. Includes research methods, journey mapping, interview techniques, and persona development.

### 1.1 Company Research

**Impact: CRITICAL (Missing competitive context leads to positioning blind spots)**

Company research is a structured deep-dive covering business model, market position, product strategy, and competitive dynamics — not a surface-level Wikipedia summary. Use it before entering a new market, evaluating a competitor, or validating strategic direction. Do not use it as a one-time exercise; competitive landscapes shift and research should be refreshed quarterly. The output should reveal the "why" behind a company's moves, not just the "what."

**Incorrect: surface-level, no insight**

```markdown
## Salesforce Competitive Analysis

- CRM software company
- Founded 1999, public company
- Products: Sales Cloud, Service Cloud, Marketing Cloud
- Competitors: HubSpot, Microsoft Dynamics
- Revenue: ~$31B
```

**Correct: business model + strategic dynamics**

```markdown
## Salesforce Competitive Analysis

**Business Model:** Platform lock-in via deep CRM data + AppExchange ecosystem.
Revenue = subscriptions (80%) + professional services (20%). NRR ~115%.

**Market Position:** Enterprise default for complex sales orgs. Losing SMB to HubSpot
on ease-of-use. Defending with Starter Suite (simplified UX) + AI (Einstein).

**Product Strategy:** Acquisitions to extend data surface (Slack, Tableau, MuleSoft).
Bet: AI requires unified data — own the data layer to own AI outcomes.

**Competitive Dynamics:** HubSpot attacks from below on UX/price. Microsoft attacks
from above via M365 bundle. Primary moat is switching cost, not product superiority.

**Strategic Implication for Us:** SMB segment is contested. Competing on simplicity
beats competing on features. Avoid the enterprise segment without differentiated data.
```

Reference: [../references/company-research-full.md](../references/company-research-full.md)

### 1.2 Customer Journey Map

**Impact: CRITICAL (Without journey maps, teams optimize touchpoints instead of experiences)**

A Customer Journey Map visualizes the end-to-end experience a specific persona has while pursuing a goal, using the NNGroup methodology: stages, actions, thoughts, feelings, pain points, and opportunities. Use it to surface cross-functional gaps and emotional low points that no single team owns. Do not use it as a generic process diagram or a one-persona-fits-all artifact — segment by persona and goal. The feelings row is not optional; emotional friction predicts churn better than functional friction.

**Incorrect: missing emotional layer, too generic**

```markdown
## User Journey: Purchase Flow

Stage 1: Awareness → User sees ad
Stage 2: Consideration → User visits website
Stage 3: Purchase → User buys product
Stage 4: Delivery → User receives item

Pain point: Checkout is slow.
```

**Correct: NNGroup structure with emotional truth**

```markdown
## Journey Map: First-Time Buyer | Goal: Purchase a gift under $50

### Stage 1: Awareness
- **Action:** Sees Instagram ad, taps to website
- **Thought:** "Do they have something for my sister?"
- **Feeling:** Curious, slightly skeptical (2/5)
- **Pain Point:** No gift category or occasion filter visible
- **Opportunity:** Add "Shop by Occasion" entry point on landing page

### Stage 2: Browse
- **Action:** Searches "birthday," scans 40+ results
- **Thought:** "How do I know what's good quality?"
- **Feeling:** Overwhelmed, anxious (1/5) — emotional LOW POINT
- **Pain Point:** No social proof at browse level; reviews buried on PDPs
- **Opportunity:** Surface star ratings + "bestseller" tags in grid view

### Stage 3: Purchase
- **Action:** Adds item, begins checkout
- **Thought:** "I hope this arrives in time."
- **Feeling:** Cautiously optimistic (3/5)
- **Pain Point:** Estimated delivery shown only after payment
- **Opportunity:** Show delivery estimate on PDP and cart
```

Reference: [../references/customer-journey-map-full.md](../references/customer-journey-map-full.md)

### 1.3 Customer Journey Mapping Workshop

**Impact: CRITICAL (Facilitation failures produce maps that no one owns or acts on)**

A Customer Journey Mapping Workshop is a guided collaborative session that builds a shared journey map with cross-functional stakeholders using adaptive facilitation — asking the right question at each stage rather than presenting a pre-built map. Use it when teams have siloed views of the customer experience or when a map will require organizational buy-in to act on. Do not use it as a way to validate a map you've already drawn; if the output is predetermined, the workshop erodes trust. Adaptive questions that surface disagreement are more valuable than smooth consensus.

**Incorrect: presenter mode, no real facilitation**

```markdown
## Journey Mapping Workshop Agenda

9:00 — PM presents current journey map to team
9:30 — Team reviews and adds sticky notes
10:00 — PM synthesizes feedback
10:30 — Final map shared in Confluence

Outcome: Updated journey map document
```

**Correct: adaptive facilitation with stage-by-stage questions**

```markdown
## Journey Mapping Workshop | 90 min | Cross-functional team

**Setup (10 min):** Agree on persona + goal. Write it on the board.
"We are mapping [Persona] trying to [Goal]. Not all journeys. This one."

**Stage Excavation (60 min):** For each stage, facilitator asks in order:
1. "What is the customer actually DOING at this point? Physical action?"
2. "What are they thinking — what question is in their head?"
3. "How are they feeling? Give it a number 1–5." (Write it large.)
4. "Where does our team lose the thread here — who owns this moment?"
5. "What would make this a 5/5 moment? Be specific."

**Divergence prompt (if team agrees too fast):**
"That was fast — who sees this stage differently? What did we miss?"

**Synthesis (20 min):** Circle the two lowest emotional scores.
"These are our design targets. What do we commit to testing first?"

**Output:** Jointly owned map + 2 prioritized pain points with named owners.
```

Reference: [../references/customer-journey-workshop-full.md](../references/customer-journey-workshop-full.md)

### 1.4 Discovery Interview Prep

**Impact: CRITICAL (Leading questions produce false signal that drives wrong product decisions)**

Discovery Interview Prep applies Mom Test principles to plan customer interviews: ask about past behavior not hypothetical preferences, never pitch the idea, and treat every compliment as a data-quality failure. Use it before any customer conversation where you're testing a problem hypothesis or exploring a job-to-be-done. Do not use it for usability testing or concept validation — those require different question types. The interview guide is not a script; it's a set of anchors that keep you from drifting into confirmation bias.

**Incorrect: leading questions, hypothetical-focused**

```markdown
## Interview Guide: Project Management Tool

1. Would you use a tool that automatically prioritizes your tasks?
2. How important is AI-powered scheduling to you? (1–5)
3. Do you think our dashboard concept would help your team?
4. What features would you want in an ideal tool?
5. Would you pay $20/month for this?
```

**Correct: Mom Test-compliant, behavior-anchored**

```markdown
## Interview Guide: Project Management | Goal: Understand task overload problem

**Opening (set context, not pitch):**
"I'm trying to understand how you manage your work — not sell you anything.
Tell me about last week. What did your Monday morning look like?"

**Behavior questions (specific, past-tense):**
- "Walk me through the last time a deadline caught you off guard. What happened?"
- "When you sit down to start work, how do you decide what to do first?"
- "What did you actually do the last time you felt overwhelmed by your task list?"
- "What tools were open on your screen at that moment?"

**Dig on pain (not validation-seeking):**
- "How often does that happen?" (frequency = severity proxy)
- "What have you tried to fix it?" (existing solutions reveal real motivation)
- "Why didn't that work?" (gaps reveal the actual problem)

**Close:**
"Is there anything I didn't ask that I should have?"

**Do NOT ask:** "Would you use X?" / "What features do you want?" / "Is this a problem?"
```

Reference: [../references/discovery-interview-full.md](../references/discovery-interview-full.md)

### 1.5 Discovery Process

**Impact: CRITICAL (Skipping discovery phases leads to building solutions for unvalidated problems)**

The Discovery Process is a complete 3–4 week cycle structured in four sequential phases: frame the problem, conduct research, synthesize findings, and validate the opportunity. Use it at the start of any significant product investment before committing engineering capacity. Do not compress it into a single sprint or skip the synthesis phase — insights that are not synthesized across participants produce contradictory outputs that stall alignment. Each phase has a defined exit criterion; do not advance until it is met.

**Incorrect: undifferentiated "research sprint," no structure**

```markdown
## Q2 Discovery

Week 1–2: Talk to customers
Week 3: Write up notes
Week 4: Share findings with team

Output: Slide deck with quotes
Next step: Start building the most-requested feature
```

**Correct: phased discovery with exit criteria**

```markdown
## Discovery Process: [Opportunity Name] | 4 weeks

### Phase 1: Frame (Days 1–3)
- Write the problem hypothesis: "We believe [persona] struggles with [problem]
  in [context], which causes [consequence]."
- Define research questions (max 5). What must be true for this to be worth building?
- Identify participant types needed. Recruit 8–12 people.
- **Exit criterion:** Team alignment on problem hypothesis + research questions.

### Phase 2: Research (Days 4–14)
- Run discovery interviews (Mom Test protocol) — 8 minimum.
- Observe in context where possible (1 session = 3 interviews of insight).
- Log raw observations, not interpretations, during sessions.
- **Exit criterion:** No new themes emerging after last 3 interviews (saturation).

### Phase 3: Synthesize (Days 15–17)
- Affinity cluster across all sessions independently, then together.
- Identify patterns: frequency × severity matrix for each pain point.
- Write 3–5 insight statements: "When [context], [persona] [behavior] because [belief]."
- **Exit criterion:** Insights reviewed and challenged by non-research team member.

### Phase 4: Validate (Days 18–21)
- Map top insights to opportunity hypothesis.
- Identify the ONE riskiest assumption. Design a PoL probe to test it.
- Decision gate: proceed / pivot / park — with documented rationale.
- **Exit criterion:** Go/no-go decision made with evidence, not conviction.
```

Reference: [../references/discovery-process-full.md](../references/discovery-process-full.md)

### 1.6 Jobs to Be Done

**Impact: CRITICAL (Feature-first thinking solves the wrong problem at the wrong level)**

Jobs to Be Done (JTBD) reframes product thinking around what customers are trying to accomplish, not what they say they want — covering functional, emotional, and social dimensions of the job. Use it when discovery interviews reveal that customers struggle to articulate needs or when your roadmap keeps filling up with features that don't move retention. Do not treat JTBD as a replacement for personas; they answer different questions — personas describe who, JTBD describes why. The job statement format ("When [situation], I want to [motivation], so I can [outcome]") is the deliverable, not a persona narrative.

**Incorrect: feature-centric, no job context**

```markdown
## Customer Needs Analysis

Users want:
- Better search functionality
- Faster load times
- Dark mode
- Mobile app
- More integrations with Slack and Notion

Priority: Build the most-requested features first.
```

**Correct: JTBD with all three dimensions**

```markdown
## Jobs to Be Done: Project Management for Independent Consultants

**Functional Job:**
"When I'm about to start my week, I want to see exactly what I must deliver
and to whom, so I can protect client relationships without keeping it all in my head."

**Emotional Job:**
"When I'm juggling multiple clients, I want to feel in control (not reactive),
so I can end the day feeling like a competent professional, not someone who's drowning."

**Social Job:**
"When a client asks for a status update, I want to respond immediately with specifics,
so I appear organized and trustworthy — not like I'm scrambling to check notes."

**Job Insight:**
The core job is not 'task management' — it's 'professional credibility maintenance.'
Features that make the consultant look good to clients outrank features that
help them manage tasks internally. Prioritize: client-facing status views, fast
update sharing, professional-looking exports. Deprioritize: internal kanban improvements.
```

Reference: [../references/jobs-to-be-done-full.md](../references/jobs-to-be-done-full.md)

### 1.7 Proto Persona

**Impact: CRITICAL (Building without any persona model guarantees designing for no one)**

A Proto Persona is a hypothesis-driven persona created before conducting full research — capturing name, demographics, behaviors, goals, and frustrations based on team assumptions — so those assumptions can be made explicit and tested. Use it at project kickoff to align the team on who they believe they are building for, then update it with real data as discovery progresses. Do not treat it as a validated persona or use it as a substitute for primary research; the explicit purpose is to surface assumption gaps, not to replace user interviews. Label it clearly as a hypothesis artifact everywhere it appears.

**Incorrect: undocumented assumptions, no hypothesis framing**

```markdown
## Target User

Our target user is a busy professional in their 30s who needs to save time.
They are tech-savvy and frustrated with their current tools.
They want something simple and fast.

We will build for them.
```

**Correct: explicit hypothesis artifact with testable dimensions**

```markdown
## Proto Persona [HYPOTHESIS — not yet validated]

**Name:** Marcus, 34 | Operations Manager, 50-person SaaS company

**Demographics:** 8 years in ops roles. Non-technical but data-literate.
Manages a team of 6. Reports to COO.

**Behaviors (assumed):**
- Lives in spreadsheets and Slack; no dedicated ops tooling
- Spends ~4 hrs/week manually compiling status reports for leadership
- Evaluates new tools alone before proposing to team

**Goals:**
- Surface operational bottlenecks before the COO asks about them
- Reduce time on reporting without losing visibility or accuracy

**Frustrations:**
- Current tools require engineering support to configure
- Data is scattered across 5+ systems with no single source of truth

**Key Assumptions to Test:**
1. Marcus is the buyer AND the primary user (not separate roles)
2. Reporting time (4 hrs/week) is the pain — not the underlying data access
3. He evaluates tools solo before involving others

**Research Questions for Validation:**
- How does he currently compile reports? What's the actual workflow?
- Who else is involved in the tool evaluation/buying decision?
- What has he tried before and why did it fail?
```

Reference: [../references/proto-persona-full.md](../references/proto-persona-full.md)

---

## 2. Strategy & Positioning

**Impact: CRITICAL**

Frameworks for defining product positioning, vision, and strategic direction. Covers positioning statements, press releases, problem framing, market sizing, and multi-week strategy processes.

### 2.1 Positioning Statement

**Impact: CRITICAL (Vague positioning makes every downstream decision arbitrary)**

Use Geoffrey Moore's framework to define exactly who you serve, what problem you solve, and how you differ from alternatives. Apply this before writing any marketing copy, roadmap, or press release — it anchors all downstream decisions. Do not use it as a tagline or elevator pitch; it is an internal alignment tool. The six-part template must be filled with specific, falsifiable claims — not generic superlatives.

**Incorrect: generic and unfalsifiable**

```markdown
For businesses that need better software, our platform is an all-in-one solution
that helps teams work smarter. Unlike competitors, we are faster and easier to use.
```

**Correct: specific, structured, and testable**

```markdown
For mid-market SaaS finance teams (50–500 employees) that struggle to close the
books in under five days, our product is a financial close automation platform
that reduces close time by 40% through automated reconciliation workflows.
Unlike spreadsheet-based processes and legacy ERP modules, we provide real-time
audit trails and one-click variance explanations without requiring IT involvement.
```

Reference: [../references/positioning-statement-full.md](../references/positioning-statement-full.md)

### 2.2 Positioning Workshop

**Impact: CRITICAL (Positioning built in isolation breaks under cross-functional scrutiny)**

Run this as a guided multi-turn session to build positioning collaboratively, surfacing disagreements before they become launch blockers. Use adaptive questions to probe target market clarity, competitive landscape assumptions, and the strength of the differentiator claim. Do not treat this as a one-hour meeting — each phase (target, problem, alternatives, differentiator) requires evidence, not opinion. Stop and probe whenever a stakeholder gives a generic answer.

**Incorrect: skipping discovery phases**

```markdown
Workshop output after 30 minutes:
- Target: "Enterprise companies"
- Problem: "They need efficiency"
- Differentiator: "We're easier to use and have better support"
→ Approved by team. Moving to launch copy.
```

**Correct: evidence-grounded, phase-by-phase**

```markdown
Phase 1 — Target Market:
Q: Who specifically buys today? Who rejects us?
Finding: Primary buyer = VP Finance at Series B SaaS (not IT, not CEO)

Phase 2 — Problem Validation:
Q: What does the buyer say in their own words?
Finding: "I can't trust the numbers my team gives me at month-end"

Phase 3 — Competitive Alternatives:
Q: What do they do today without us?
Finding: Excel + Slack threads + manual Salesforce exports

Phase 4 — Differentiator Test:
Q: Can we prove this claim with data?
Finding: 3 case studies show 40% close-time reduction — claim is defensible
```

Reference: [../references/positioning-workshop-full.md](../references/positioning-workshop-full.md)

### 2.3 Press Release (Working Backwards)

**Impact: CRITICAL (Building before writing the press release causes scope creep and vision drift)**

Amazon's Working Backwards method requires writing a customer-facing press release before a single line of code is written, forcing clarity on what success looks like from the outside. Structure it with: headline, subheadline, launch date, problem paragraph, solution paragraph, internal quote, customer quote, and a clear call to action. Do not use it as actual marketing — it is a decision-forcing document to expose assumption gaps and misaligned expectations before they become expensive. If the team cannot write it, the vision is not clear enough to build.

**Incorrect: feature-focused, no customer outcome**

```markdown
# Acme Corp Launches New Dashboard Feature

Acme Corp today announced the release of version 3.2, which includes an improved
dashboard with 14 new chart types, a redesigned navigation bar, and API rate limit
increases. The engineering team worked for six months on these improvements.
```

**Correct: outcome-focused, customer-centric**

```markdown
# Finance Teams at Mid-Market SaaS Companies Cut Month-End Close from 10 Days to 4

[City, Date] — Starting today, finance teams can eliminate the manual reconciliation
work that eats two weeks every quarter. CloseLoop's automated variance detection
flags discrepancies in real time, so controllers spend hours reviewing instead of
days hunting.

"We used to dread the last week of every month," said Maria Chen, Controller at
Launchpad Analytics. "Now close is just another Tuesday."

Available immediately. Start your free 14-day trial at closeloop.com/start.
```

Reference: [../references/press-release-full.md](../references/press-release-full.md)

### 2.4 Problem Framing Canvas

**Impact: CRITICAL (Solving the wrong problem wastes cycles and erodes team trust)**

Use the MITRE Problem Framing Canvas in three sequential phases before committing to any solution: Look Inward (surface your assumptions and biases about the problem), Look Outward (map stakeholders, constraints, and context), then Reframe (synthesize into an actionable problem statement that challenges the original framing). Do not skip the Look Inward phase — unexamined assumptions are the most common source of misdirected roadmaps. The output is a reframed problem statement, not a solution.

**Incorrect: jumping to solution framing**

```markdown
Problem: Users can't find the export button.
Solution: Move the export button to the top navigation.
→ Team begins design sprint.
```

**Correct: three-phase canvas applied**

```markdown
Look Inward:
- Assumption: Users want to export data
- Bias: Engineering team suggested this based on support tickets, not user research
- Challenge: Are exports the goal, or is sharing data the goal?

Look Outward:
- Stakeholders: End users (analysts), their managers (recipients of exports)
- Context: Analysts export to send to managers via email every Friday
- Constraint: Managers don't have product access

Reframe:
Original: "Users can't find the export button"
Reframed: "Analysts need a reliable way to share live data snapshots with
stakeholders who lack product access — weekly manual exports are a workaround
for a missing collaboration feature"
```

Reference: [../references/problem-framing-canvas-full.md](../references/problem-framing-canvas-full.md)

### 2.5 Problem Statement

**Impact: CRITICAL (Requirements written without a grounded problem statement optimize for the wrong outcome)**

Frame a customer problem using the five-part structure: "I am [persona] trying to [goal] but [barrier] because [root cause] which makes me feel [emotional impact]." This format forces specificity about who experiences the problem, what they are trying to accomplish, and why the current situation fails them — without presupposing a solution. Use it to align stakeholders on the problem before any solution discussion. Do not synthesize without real user evidence; each component must be traceable to research data or direct quotes.

**Incorrect: solution-framed, persona-free**

```markdown
Problem: The app needs a better onboarding flow because users are dropping off.
We should add a tutorial wizard and tooltips.
```

**Correct: evidence-backed, structured format**

```markdown
I am a newly hired revenue operations analyst
trying to get my first monthly pipeline report out within my first two weeks
but I cannot connect our CRM data to the reporting tool without IT help
because the integration requires admin credentials I'm not authorized to have,
which makes me feel like I'm failing at a basic part of my job before I've even started.

Source: 6/8 onboarding interview participants described a version of this barrier.
Direct quote: "I spent three days on what I thought would take an hour." — P4
```

Reference: [../references/problem-statement-full.md](../references/problem-statement-full.md)

### 2.6 Product Strategy Session

**Impact: CRITICAL (Skipping strategy orchestration produces a roadmap without a foundation)**

The Product Strategy Session is a 2–4 week orchestrated process that sequences five component frameworks in order: positioning statement, problem framing, problem statement, market sizing (TAM/SAM/SOM), and roadmap planning. Each phase must complete before the next begins — outputs from earlier phases are inputs to later ones. Use this when starting a new product, pivoting an existing one, or when leadership alignment is visibly broken. Do not run it as a one-day offsite; the inter-phase synthesis is where the strategic clarity emerges.

**Incorrect: phases collapsed into a single session**

```markdown
Strategy Day Agenda (8 hours):
9am  — Brainstorm target customers
10am — Define differentiators
11am — Size the market
1pm  — Build the roadmap
4pm  — Present to leadership

Output: 47-slide deck, no shared written artifacts, three conflicting interpretations
```

**Correct: sequenced, artifact-driven over multiple weeks**

```markdown
Week 1: Positioning
- Run Positioning Workshop → produce signed-off Positioning Statement
- Artifact: "For [target] that [need], we are a [category] that [benefit]..."

Week 2: Problem Clarity
- Run Problem Framing Canvas → produce Reframed Problem Statement
- Run Problem Statement workshop → 3 validated persona-level statements

Week 3: Market Validation
- Run TAM/SAM/SOM Calculator → market size with cited methodology
- Go/no-go gate: Is the SOM large enough to justify the strategy?

Week 4: Roadmap Planning
- Translate validated strategy into 12-month roadmap with sequenced bets
- Each initiative links back to positioning differentiator or problem statement
```

Reference: [../references/product-strategy-session-full.md](../references/product-strategy-session-full.md)

### 2.7 TAM SAM SOM Calculator

**Impact: CRITICAL (Unsourced market size numbers destroy investor and executive credibility)**

Calculate market opportunity in three nested layers: Total Addressable Market (the full global demand if you served everyone), Serviceable Addressable Market (the segment you can realistically reach with your current model), and Serviceable Obtainable Market (your realistic capture in years 1–3 given competition and go-to-market constraints). Every figure must cite a real source — analyst reports, census data, or bottom-up calculations from known unit counts. Do not use top-down TAM figures as your SOM; the gap between TAM and SOM is where strategy lives.

**Incorrect: top-down, uncited, no methodology**

```markdown
Market Sizing:
- TAM: $50B (the global HR software market)
- SAM: $10B (mid-market segment, roughly 20%)
- SOM: $500M (we'll capture 5% in year 3)

Source: "industry reports"
```

**Correct: bottom-up, cited, with methodology**

```markdown
TAM — Bottom-up calculation:
- 180,000 mid-market SaaS companies in the US (source: Crunchbase 2025, companies
  with $10M–$500M ARR)
- Average spend on financial close software: $28,000/yr (source: Gartner MQ 2024)
- TAM = 180,000 × $28,000 = $5.04B

SAM — Segment filter:
- Target: Series B–D SaaS, finance team 3–15 people, using Salesforce CRM
- Estimated count: 22,000 companies (source: LinkedIn Sales Navigator export, Feb 2025)
- SAM = 22,000 × $28,000 = $616M

SOM — Realistic capture:
- Year 1 target: 80 customers (based on current sales capacity of 4 AEs × 20 deals)
- Year 3 target: 600 customers (with planned team expansion)
- SOM = 600 × $24,000 ACV = $14.4M ARR by end of year 3
```

Reference: [../references/tam-sam-som-calculator-full.md](../references/tam-sam-som-calculator-full.md)

---

## 3. Requirements & Stories

**Impact: HIGH**

Frameworks for translating validated needs into implementable work items. Covers user stories, story mapping, epic hypotheses, story splitting patterns, and PRD development.

### 3.1 Epic Breakdown Advisor

**Impact: HIGH (Poorly split epics create stories too large to estimate, test, or ship independently)**

Use Richard Lawrence's 9 splitting patterns to decompose epics into independently deliverable stories. Apply when an epic takes more than one sprint or cannot be estimated with confidence. Do not use this to split by technical layer (front-end / back-end / DB) — that produces stories with no user value. The goal is vertical slices: each story must be deployable and valuable on its own.

**Incorrect: splitting by technical component, not user value**

```markdown
Epic: User can pay for orders

Stories:
- Build payment database schema
- Build payment API endpoint
- Build payment UI form
- Wire up Stripe SDK
```

**Correct: splitting by workflow steps and happy/unhappy paths**

```markdown
Epic: User can pay for orders

Stories:
- User pays with a saved credit card (happy path)
- User pays with a new credit card (data variation)
- User sees an error when payment is declined (unhappy path)
- User pays with PayPal (interface variation)
- Admin refunds an order (operation variation)
```

Reference: [../references/epic-breakdown-advisor-full.md](../references/epic-breakdown-advisor-full.md)

### 3.2 Epic Hypothesis

**Impact: HIGH (Untested assumptions baked into epics waste sprint capacity on the wrong solution)**

Transform vague initiatives into testable hypotheses using the format: "We believe [action] for [audience] will achieve [outcome] as measured by [metric]." Use this before committing an epic to a roadmap to make the success condition explicit and falsifiable. Do not skip the metric — without it, teams cannot determine whether the work succeeded. This is not a solution spec; it is a learning frame that guides what to build and what to measure.

**Incorrect: solution-framed, no measurable outcome**

```markdown
Epic: Build an onboarding flow

We will create a multi-step onboarding wizard for new users
that walks them through setting up their profile and preferences.
```

**Correct: hypothesis-framed with audience, action, outcome, and metric**

```markdown
Epic: Improve new user onboarding

We believe that providing a guided 3-step setup flow
for new users who have not completed their profile
will increase 7-day activation rate
as measured by the percentage of sign-ups who complete
at least one core action within their first week.

Current baseline: 22% | Target: 35%
```

Reference: [../references/epic-hypothesis-full.md](../references/epic-hypothesis-full.md)

### 3.3 PRD Development

**Impact: HIGH (Incomplete PRDs cause scope creep, misaligned engineering effort, and rework)**

A PRD is developed over 2-4 days and must include: executive summary, problem statement, target users, strategic context, solution overview, success metrics, and user stories. Use a PRD when a feature is large enough to require cross-functional alignment before design or engineering begins. Do not use a PRD for small bug fixes or trivial enhancements — a well-written user story suffices. The problem statement must come before the solution section; reversing this order signals a solution looking for a justification.

**Incorrect: solution-first, no target user or success metric**

```markdown
# PRD: Dashboard Redesign

## Overview
We will redesign the dashboard with a new sidebar navigation,
updated color scheme, and drag-and-drop widget support.

## Features
- Sidebar nav
- Dark mode
- Drag-and-drop widgets
```

**Correct: problem-first, structured with target user and measurable success**

```markdown
# PRD: Dashboard Redesign

## Executive Summary
Power users spend 40% of their session time navigating between
reports. This PRD proposes a redesigned dashboard to reduce
navigation time and increase daily active usage.

## Problem Statement
Users with 5+ saved reports cannot find or switch between them
efficiently. Support tickets cite "can't find my reports" as
the #2 complaint (180/month).

## Target Users
Operations analysts at mid-market companies (50–500 employees)
who run 3+ reports per day.

## Success Metrics
- Reduce avg. navigation clicks per session from 8.2 → 4.0
- Increase DAU/MAU ratio from 0.31 → 0.45 within 60 days post-launch

## Solution Overview
Persistent sidebar with pinned reports, keyboard shortcuts,
and recently-viewed history.
```

Reference: [../references/prd-development-full.md](../references/prd-development-full.md)

### 3.4 User Story

**Impact: HIGH (Poorly written stories create ambiguous acceptance criteria and untestable deliverables)**

Write stories using Mike Cohn's format — "As a [role] I want [capability] so that [benefit]" — and validate each against the INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, Testable. Acceptance criteria must be written in Gherkin format (Given / When / Then) so they are unambiguous and directly executable as tests. Do not write stories from the system's perspective ("The system shall...") — this removes user context and makes the business value invisible.

**Incorrect: system-centric, acceptance criteria are prose, not testable**

```markdown
Story: Password reset

The system shall allow users to reset their password via email.
The reset link should expire after some time.
The user should see a confirmation message.
```

**Correct: role-centric, Gherkin AC, INVEST-compliant**

```markdown
Story: Reset forgotten password

As a registered user
I want to reset my password using my email address
So that I can regain access to my account if I forget my credentials

Acceptance Criteria:

Given I am on the login page
When I click "Forgot password" and submit my email
Then I receive a reset link within 2 minutes

Given I click a valid reset link
When I enter and confirm a new password
Then my password is updated and I am redirected to the dashboard

Given a reset link older than 24 hours
When I attempt to use it
Then I see an error message and am prompted to request a new link
```

Reference: [../references/user-story-full.md](../references/user-story-full.md)

### 3.5 User Story Mapping

**Impact: HIGH (Flat backlogs lose the user workflow context needed to sequence work coherently)**

Use Jeff Patton's story mapping method to organize stories along a two-dimensional map: the horizontal backbone represents the user's workflow (activities broken into tasks), and the vertical axis represents priority — stories closer to the top ship first. Apply this when planning a release or identifying MVP scope; the map makes gaps and dependencies visible that a flat backlog hides. Do not use story mapping as a substitute for discovery — the backbone should reflect observed user behavior, not assumed feature categories.

**Incorrect: flat feature list with no workflow context**

```markdown
Backlog:
- Add item to cart
- User registration
- Email confirmation
- Search products
- Checkout
- Order history
- Password reset
- Product detail page
```

**Correct: backbone with activities → tasks, stories tiered by release**

```markdown
Backbone (Activities):  Browse  →  Select  →  Purchase  →  Track

Tasks:
Browse:   Search by keyword | Filter by category | View featured items
Select:   View product detail | Read reviews | Check availability
Purchase: Add to cart | Enter shipping info | Pay | Confirm order
Track:    View order status | Receive email update | Request return

Release 1 (MVP — top row):
Search by keyword | View product detail | Add to cart | Pay | Confirm order

Release 2:
Filter by category | Read reviews | View order status

Release 3:
View featured items | Check availability | Receive email update | Request return
```

Reference: [../references/user-story-mapping-full.md](../references/user-story-mapping-full.md)

### 3.6 User Story Mapping Workshop

**Impact: HIGH (Unstructured mapping sessions produce incomplete backbones and no agreed release slices)**

Run a guided workshop to build a story map collaboratively using adaptive questions: start with user activities (what are the big things users do?), decompose into tasks (what steps make up each activity?), then add story cards below each task ordered by priority. Close the session by drawing release slice lines. Use this when a team is starting a new product area or planning a major release. Do not run this workshop without a clear user persona anchoring the map — without it, participants argue about whose workflow to prioritize.

**Incorrect: workshop produces a feature list, no backbone or release slices**

```markdown
Workshop output:

Team brainstormed features:
- Notifications
- Admin dashboard
- API integration
- Mobile app
- Reporting
- User roles

Next step: engineering to estimate all items.
```

**Correct: workshop produces backbone, tasks, stories, and release slices**

```markdown
Workshop output — Persona: Operations Manager at a logistics company

Backbone Activities:
[Plan shipment] → [Assign driver] → [Track delivery] → [Resolve issues]

Tasks under "Track delivery":
- View real-time map
- See estimated arrival time
- Receive delay alerts
- Share tracking link with customer

Story cards (vertical, priority order):
Top: View real-time map | See estimated arrival time
Mid: Receive delay alerts
Lower: Share tracking link with customer

Release slices agreed:
── Release 1: View map + ETA ──────────────────────────────
── Release 2: Delay alerts ────────────────────────────────
── Release 3: Shareable tracking link ─────────────────────
```

Reference: [../references/user-story-mapping-workshop-full.md](../references/user-story-mapping-workshop-full.md)

### 3.7 User Story Splitting

**Impact: HIGH (Stories too large to complete in a sprint block velocity and make progress invisible)**

Break large stories using 8 proven patterns: workflow steps, business rules, happy/unhappy paths, input variations, data types, operations (CRUD), platforms, and roles. Choose the pattern that produces the smallest independently valuable slice — each resulting story must still deliver user value and meet INVEST criteria. Do not split by technical task (UI / API / DB) — that produces dependent stories with no standalone value. If a split produces a story that cannot be demonstrated to a stakeholder, the split is wrong.

**Incorrect: split by technical layer — stories are dependent and have no standalone value**

```markdown
Original: As a manager I want to export reports so that I can share them with stakeholders

Split:
- Build export API endpoint
- Build export UI button
- Write export to CSV logic
- Add file download handler
```

**Correct: split by data type and operation — each story ships independently**

```markdown
Original: As a manager I want to export reports so that I can share them with stakeholders

Split by data type:
- As a manager I want to export reports as CSV so that I can open them in Excel
- As a manager I want to export reports as PDF so that I can share a formatted document

Split by happy/unhappy path:
- As a manager I want to export a report successfully so that I receive the file
- As a manager I want to see a clear error if the export fails so that I know to retry

Split by operation:
- As a manager I want to export a single report
- As a manager I want to export all reports in a date range (deferred to sprint N+2)
```

Reference: [../references/user-story-splitting-full.md](../references/user-story-splitting-full.md)

---

## 4. Validation & Experimentation

**Impact: HIGH**

Frameworks for testing assumptions before committing to full implementation. Includes proof-of-learning probes, Lean UX canvases, opportunity-solution trees, and storyboards.

### 4.1 6-Frame User Journey Storyboard

**Impact: HIGH (Text-only specs miss the emotional arc of the user experience, leading to technically correct but experientially hollow features)**

A 6-frame storyboard narrates the user journey through a product experience in six sequential frames: Setup (who the user is and their world), Trigger (the moment the problem becomes urgent), Action (how the user finds or engages with the solution), Resolution (the moment the solution works), Outcome (the measurable or felt change in the user's life), and Insight (what the team learned or what must be true for the story to hold). Use storyboards to align cross-functional teams on the human experience before design begins, and to evaluate whether a proposed solution actually addresses the trigger that matters. Do not use storyboards as a substitute for user research — the story should be grounded in real interview data, not invented personas.

**Incorrect: product-centric, no emotional arc, no trigger moment**

```markdown
Story: User opens app → sees dashboard → clicks "Create project" → project is created.
```

**Correct: 6-frame narrative, grounded in user context and emotion**

```markdown
## Storyboard: "The Monday Morning Panic" — Project Onboarding

**Frame 1 — Setup:**
Priya is a team lead at a 40-person SaaS company. She manages 3 active projects
across 6 people. She uses spreadsheets, Slack, and two other tools. Her team
misses context constantly.

**Frame 2 — Trigger:**
Monday 9:05am. A stakeholder pings: "What's the status on the migration?"
Priya has no single source of truth. She spends 20 minutes reconstructing the
answer from 4 different threads. She is embarrassed and frustrated.

**Frame 3 — Action:**
A colleague shares a link: "We moved everything into [Product]. Here's the
workspace." Priya clicks, sees her projects already partially populated
(the PM had imported them from Jira). She spends 8 minutes reviewing.

**Frame 4 — Resolution:**
At 9:35am, the stakeholder pings again. Priya pastes a direct link to the
live status board. No reconstruction needed. The stakeholder says "perfect."

**Frame 5 — Outcome:**
Priya blocks 30 minutes Friday afternoon to keep the board updated.
She tells two other team leads to try it. Monday meetings are now 15 minutes shorter.

**Frame 6 — Insight:**
The trigger is not "lack of a project tool" — it is "stakeholder pressure without
a defensible answer." The product must make Priya look competent to her stakeholders,
not just organized to herself. This reframes the onboarding copy and the share flow.

What must be true: Import from existing tools (Jira, spreadsheets) must work in
< 10 minutes or Priya will not reach Frame 3.
```

Reference: [../references/storyboard-full.md](../references/storyboard-full.md)

### 4.2 AI Recommendation Canvas

**Impact: HIGH (Undocumented AI recommendations become invisible technical debt and unauditable product decisions)**

The AI Recommendation Canvas structures the documentation of any AI-powered recommendation feature — personalization, next-best-action, content ranking, or predictive nudging — across five fields: Context (what the system knows about the user and situation), Approach (the model or algorithm driving the recommendation), Evidence (the data and validation behind the approach), Risks (failure modes, bias vectors, and edge cases), and Next Steps (how the team will monitor and iterate). Use this canvas before shipping any AI-driven recommendation to ensure the logic is auditable and the failure modes are owned. Do not use it to document rule-based recommendations — it is designed for probabilistic systems where explainability is not automatic.

**Incorrect: AI feature shipped with no documentation of logic or risk**

```markdown
Feature: "Recommended for you" section in dashboard.
Engineering: ML model trained on clickstream data.
Ship date: Next sprint.
```

**Correct: five-field canvas, risks and monitoring owned**

```markdown
## AI Recommendation Canvas: "Next Action" Widget

**Context:**
User is a mid-market PM, 14 days post-activation, has created 2 projects but
has not invited teammates. Session frequency: 3x/week. Last action: viewed pricing page.

**Approach:**
Collaborative filtering model trained on behavioral sequences of users who
reached "activated" state (defined as 5+ team members, 3+ projects in 30 days).
Model outputs top-3 recommended next actions ranked by predicted activation probability.

**Evidence:**
- Trained on 90-day cohort of 4,200 users; held-out AUC: 0.74.
- Offline simulation: top-1 recommendation matched actual next action in 41% of cases.
- Qualitative: 8/10 users in usability test found recommendations "relevant or very relevant."

**Risks:**
- Cold start: model underperforms for users with < 5 sessions (affects ~30% of new signups).
  Mitigation: fall back to rule-based recommendations for cold-start users.
- Feedback loop: if users only click recommended actions, model may narrow over time.
  Mitigation: inject 10% diversity actions; monitor recommendation entropy monthly.
- Bias: free-tier users are underrepresented in training data (8% of cohort).
  Mitigation: stratified sampling in next training run; flag free-tier outputs for review.

**Next Steps:**
- Week 1–2: A/B test (50/50 split); primary metric = 30-day activation rate.
- Week 3: Review recommendation distribution for cold-start cohort.
- Month 2: Retrain model with expanded free-tier sample.
- Owner: [PM name] reviews recommendation quality dashboard weekly.
```

Reference: [../references/recommendation-canvas-full.md](../references/recommendation-canvas-full.md)

### 4.3 Lean UX Canvas

**Impact: HIGH (Building without a shared hypothesis locks teams into delivering output instead of learning)**

The Lean UX Canvas v2 (Jeff Gothelf) structures a sprint or initiative around eight fields in two passes: first define the Business Problem, Users, User Outcomes, and Business Outcomes; then generate Solutions, Hypotheses, Minimum Viable Experiments, and Learning Metrics. Complete the left half before the right — generating solutions before naming the desired outcome produces solutions that solve the wrong thing. Use this at the start of any feature initiative or sprint cycle. Do not use it as a backlog grooming tool; it is a shared alignment artifact, not a task list.

**Incorrect: solutions-first, outcomes missing**

```markdown
## Q3 Initiative: Notifications

Solutions:
- Add email digest
- Add in-app badge counter
- Add push notifications

Next step: Hand off to engineering.
```

**Correct: eight-field canvas, outcomes drive solutions**

```markdown
## Lean UX Canvas: Notification Overload

**1. Business Problem:** Users are missing critical updates, causing escalations and churn.
**2. Users:** Power users managing 5+ projects simultaneously.
**3. User Outcomes:** Feel in control; act on the right information at the right time.
**4. Business Outcomes:** Reduce missed-update support tickets by 40%; improve 30-day retention by 5%.

**5. Solutions:** Smart digest (daily summary), priority filters, snooze controls.
**6. Hypotheses:**
  - We believe that a priority-filtered digest for power users
    will reduce missed-update tickets as measured by support volume.
**7. MVP Experiment:** Release digest to 10% of power users for 2 weeks; measure ticket rate vs. control.
**8. Learning Metric:** Support tickets per active user; target ≥ 30% reduction in cohort.
```

Reference: [../references/lean-ux-canvas-full.md](../references/lean-ux-canvas-full.md)

### 4.4 Opportunity Solution Tree

**Impact: HIGH (Jumping from outcome directly to solutions skips the opportunity space and kills discovery)**

Teresa Torres's Opportunity Solution Tree structures product thinking as a four-level hierarchy: Desired Outcome at the root, then Opportunities (unmet needs, pain points, desires surfaced from customers), then Solutions (specific approaches per opportunity), then Experiments (probes that test each solution). Always expand the Opportunity level fully before adding Solutions — PMs who jump from outcome to solution skip the discovery work that reveals which problem is actually worth solving. Do not use OST to document solutions already decided; it is a thinking and communication tool for teams actively doing discovery.

**Incorrect: outcome jumps directly to solutions, no opportunity mapping**

```markdown
Outcome: Increase 30-day retention

Solutions:
- Build onboarding checklist
- Add email drip campaign
- Add progress badges
```

**Correct: four-level tree, opportunities surfaced before solutions**

```markdown
Desired Outcome: Increase 30-day retention by 8 points

Opportunities (from 12 customer interviews):
├── O1: Users don't understand what "done" looks like in week 1
│   ├── Solution A: Onboarding checklist with explicit success milestones
│   │   └── Experiment: Fake-door test — show checklist to 50% of new signups; measure completion rate
│   └── Solution B: Welcome call for high-intent signups
│       └── Experiment: Concierge — manually call 10 users; track 7-day activation
├── O2: Users lose context after returning from multi-day absence
│   └── Solution A: "Pick up where you left off" re-engagement screen
│       └── Experiment: Wizard of Oz — manually send personalized re-entry emails; measure return rate
└── O3: Power features discovered too late to influence habit formation
    └── Solution A: Contextual feature tips triggered at day 3 and day 7
        └── Experiment: A/B test tip timing; measure feature adoption rate

Next: Run experiments for O1 in parallel — highest churn signal.
```

Reference: [../references/opportunity-solution-tree-full.md](../references/opportunity-solution-tree-full.md)

### 4.5 PoL Probe Type Advisor

**Impact: HIGH (Choosing the wrong probe type produces invalid signal and wastes the experiment window)**

The PoL Probe Type Advisor is an interactive decision protocol that recommends one of five probe types based on three inputs: hypothesis type (problem vs. solution), risk level (high vs. low), and available resources (engineering access, customer access, data access). Run through the advisor before designing any experiment — mismatched probe types are the most common cause of inconclusive results. Do not use this as a checklist to justify a probe type already chosen; the point is to select the right instrument before committing to a design.

**Five probe types and their selection triggers:**

| Probe Type | Best When | Avoid When |

|---|---|---|

| Concierge | Testing whether humans value the outcome (do it manually first) | You need to test at scale |

| Wizard of Oz | Solution is complex to build; simulate the experience manually | The "magic" can't be simulated credibly |

| Landing Page | Testing demand signal before any build | You already have active users to observe |

| Fake Door | Testing engagement/intent inside an existing product | No existing product surface to embed the trigger |

| Data Analysis | Hypothesis can be tested with existing instrumentation | Data is sparse, lagged, or not yet collected |

**Incorrect: probe type chosen by familiarity, not fit**

```markdown
Hypothesis: Enterprise users want an audit log feature.
Probe: We'll build a landing page and run Google Ads.

[Problem: existing users are already in-product;
a landing page tests acquisition intent, not feature demand from current users.]
```

**Correct: advisor applied — hypothesis type → risk → resources → probe type**

```markdown
## Probe Type Advisor: Audit Log Feature

**Step 1 — Hypothesis type:** Solution hypothesis (we know the problem; testing whether
this specific solution is wanted).

**Step 2 — Risk level:** High. Engineering cost is 3 sprints; no comparable data exists.

**Step 3 — Available resources:** Existing product surface with enterprise users; no
engineering capacity for a prototype; PM can send targeted in-app messages.

**Advisor output: Fake Door**
Rationale: Solution hypothesis + high risk + existing product surface = fake door.
Place an "Audit Log" menu item in the admin panel. Clicking shows: "Audit log is
in development — notify me when it's ready." Measure click rate among admin users
over 2 weeks. Success bar: ≥ 15% of admin users engage.

**Ruled out:**
- Landing page: audience is existing users, not acquisition prospects.
- Concierge: PM can't manually produce audit logs at enterprise data volumes.
- Wizard of Oz: requires engineering to fake the log output — not available.
```

Reference: [../references/pol-probe-full.md](../references/pol-probe-full.md)

### 4.6 Proof of Learning (PoL) Probe

**Impact: HIGH (Building a full feature to test an assumption wastes weeks when a probe takes days)**

A Proof of Learning probe is a lightweight experiment that tests one critical assumption before committing engineering capacity. Structure each probe with five fields: Hypothesis (the falsifiable belief being tested), Probe Type (concierge, Wizard of Oz, landing page, fake door, or data analysis), Success Criteria (the numeric threshold that confirms or invalidates the hypothesis), Timeline (days, not weeks), and Learning (what the team will do differently based on the result). Use PoL probes when you have a high-risk assumption and low confidence. Do not use them to validate decisions already made — a probe run after the feature ships is a post-mortem, not an experiment.

**Incorrect: full build to learn, no hypothesis, no criteria**

```markdown
Plan: Build the team collaboration feature.
Timeline: 6-week sprint.
Goal: See if users like it.
```

**Correct: probe-first, falsifiable hypothesis, explicit success bar**

```markdown
## PoL Probe: Team Collaboration Demand

**Hypothesis:** Mid-market users (5–50 seats) will invite at least one teammate
within 7 days of activation if a prominent "Invite your team" CTA exists.

**Probe Type:** Fake door
- Add "Invite your team" button to dashboard (no backend built).
- Clicking → modal: "Team features coming soon. Want early access?"
- Record click-through rate and early-access sign-ups.

**Success Criteria:** ≥ 20% of eligible users click within 7 days.
**Timeline:** 5 days to instrument, 2-week measurement window.

**If confirmed (≥ 20%):** Prioritize collaboration feature in next planning cycle.
**If invalidated (< 20%):** Defer feature; explore whether the barrier is awareness
or actual need via 5 follow-up interviews.

**Learning owner:** [PM name] presents findings at next team retrospective.
```

Reference: [../references/pol-probe-full.md](../references/pol-probe-full.md)

---

## 5. Planning & Roadmapping

**Impact: MEDIUM**

Frameworks for sequencing work, prioritizing initiatives, and communicating plans. Covers roadmap planning, prioritization frameworks, channel evaluation, and investment analysis.

### 5.1 Acquisition Channel Evaluation

**Impact: MEDIUM (Investing in channels without unit economics data burns budget on unscalable growth)**

Evaluate each active or candidate acquisition channel using three unit economics metrics: Customer Acquisition Cost (CAC), conversion rate at each funnel stage, and CAC payback period. Assign a scale/test/kill verdict to each channel based on whether the payback period is within your cash runway and whether CAC is below LTV/3. Use this when planning a growth quarter, allocating marketing budget, or auditing why growth has stalled. Do not apply this to brand or community channels where attribution is inherently indirect — those require separate qualitative evaluation.

**Incorrect: channel list with no economics, no verdict**

```markdown
## Q3 Growth Channels

- Google Ads — performing well, keep running
- LinkedIn Ads — expensive but good leads
- Content SEO — slow but building
- Referral program — launched last quarter
- Cold outbound — SDR team is working it

Action: increase budget across the board
```

**Correct: channel-by-channel unit economics with scale/test/kill verdict**

```markdown
## Q3 Acquisition Channel Evaluation

| Channel       | CAC    | Conv. Rate | Payback Period | Verdict |
|---------------|--------|------------|----------------|---------|
| Google Ads    | $420   | 3.2%       | 7 months       | SCALE   |
| LinkedIn Ads  | $1,800 | 1.1%       | 30 months      | KILL    |
| Content SEO   | $210   | 2.8%       | 4 months       | SCALE   |
| Referral      | $95    | 8.4%       | 2 months       | SCALE   |
| Cold outbound | $640   | 0.9%       | 11 months      | TEST    |

Verdicts:
- SCALE: CAC payback < 12 months and conv. rate above category benchmark
- TEST: Payback 12–18 months; run 60-day capped experiment before committing
- KILL: Payback > 18 months or conv. rate below breakeven threshold

Q3 budget reallocation: shift 60% of LinkedIn spend to Referral and SEO.
```

Reference: [../references/acquisition-channel-evaluation-full.md](../references/acquisition-channel-evaluation-full.md)

### 5.2 Feature Investment Analysis

**Impact: MEDIUM (Build decisions without ROI framing lead to feature factories and wasted engineering cycles)**

Evaluate each feature investment on two axes: expected ROI (revenue impact, cost savings, or churn reduction quantified in dollars over 12 months) and strategic value (does it advance the positioning differentiator, expand into a new segment, or close a competitive gap). Size the investment in engineering-weeks and compute the simple ROI ratio before committing. Use this when deciding whether to build something in the next quarter. Do not use it for bugs or tech debt — those have different cost structures and belong in a separate capacity budget.

**Incorrect: vague benefit claim, no investment sizing**

```markdown
## Feature: Advanced Reporting

Why build it:
- Customers have been asking for this
- Competitors have it
- Will help with retention

Decision: Yes, let's build it.
Timeline: Q3
```

**Correct: quantified ROI, strategic value, and explicit build/don't-build verdict**

```markdown
## Feature Investment: Advanced Reporting

### Investment
- Engineering effort: 6 weeks (2 engineers)
- Design effort: 2 weeks
- Total cost (fully-loaded): ~$48,000

### Expected Return (12-month horizon)
- Retention impact: closes reported reason for 18% of churned accounts
  → 12 accounts/yr × $8,400 ACV = $100,800 retained ARR
- Expansion: enables upsell to Analytics tier for 30 existing accounts
  → 30 × $1,200 incremental MRR × 12 = $43,200
- Total 12-month return: ~$144,000

### ROI Ratio: 3.0x (return / investment cost)

### Strategic Value
- Directly supports "data-first operations" positioning differentiator
- Closes primary feature gap vs. Competitor A (cited in 9 loss notes Q1)

### Verdict: BUILD
Threshold for build: ROI > 2x AND supports current positioning.
Both conditions met. Schedule for Q3, cap at 8 weeks total.
```

Reference: [../references/feature-investment-analysis-full.md](../references/feature-investment-analysis-full.md)

### 5.3 PESTEL Analysis

**Impact: MEDIUM (Ignoring macro-environmental factors causes strategy to break on forces the team never modeled)**

A PESTEL analysis maps six external factor categories — Political, Economic, Social, Technological, Environmental, Legal — against each factor's impact level (high/medium/low) and likelihood (certain/probable/possible) to surface threats and opportunities for product strategy. Run it at the start of annual planning, when entering a new market, or after a macro shock. Do not run it as a brainstorm without anchoring each factor to a concrete product or go-to-market decision — factors with no strategic implication should be logged but not acted on.

**Incorrect: factor list with no impact mapping or strategic response**

```markdown
## PESTEL — HR Tech Product

Political: government regulations changing
Economic: recession concerns
Social: remote work trends continuing
Technological: AI is advancing fast
Environmental: sustainability matters more
Legal: GDPR and data privacy rules

Conclusion: lots of external factors to watch
```

**Correct: factor mapped to impact, likelihood, and strategic implication**

```markdown
## PESTEL Analysis — HR Tech Product (Q1 2026)

| Factor        | Specific Force                          | Impact | Likelihood | Strategic Implication                              |
|---------------|-----------------------------------------|--------|------------|----------------------------------------------------|
| Political     | EU AI Act enforcement begins H2 2026    | High   | Certain    | Audit automated decision features before June      |
| Economic      | SMB hiring freeze in core segment       | High   | Probable   | Shift ICP toward enterprise; revisit pricing tiers |
| Social        | 4-day workweek adoption rising in EU    | Medium | Probable   | Add scheduling flexibility to roadmap backlog      |
| Technological | LLM cost dropping 10x every 18 months   | High   | Certain    | Accelerate AI-assisted workflows; revisit build/buy|
| Environmental | ESG reporting now expected by investors | Low    | Probable   | No product action; monitor for enterprise segment  |
| Legal         | GDPR Article 22 on automated decisions  | High   | Certain    | Legal review required before Q3 product launch     |

Prioritized actions:
1. Legal: schedule EU AI Act compliance review (owner: PM + Legal, due May)
2. Economic: update ICP definition and CAC model for enterprise segment (due Q2 planning)
3. Technological: spike on LLM-assisted offer letter generation (2-week timebox)
```

Reference: [../references/pestel-analysis-full.md](../references/pestel-analysis-full.md)

### 5.4 Prioritization Framework Advisor

**Impact: MEDIUM (Applying the wrong prioritization framework generates false confidence in ranking decisions)**

Select a prioritization framework based on three contextual factors: product stage (pre-PMF vs. scaling), data maturity (qualitative signals vs. quantitative metrics), and decision-making context (internal alignment vs. external stakeholder communication). RICE and ICE require reasonably reliable effort and reach estimates — use them at scaling stage with instrumented products. Kano is suited for feature discovery sessions where you need to separate delighters from basics. MoSCoW is a communication tool for scope alignment, not a ranking algorithm. Do not mix frameworks in one backlog; pick one per planning cycle and apply it consistently.

**Incorrect: framework mismatch, mixed signals, no selection rationale**

```markdown
## Q2 Prioritization

We used RICE to score the backlog but estimates were rough guesses.
Also added MoSCoW labels and sorted by Kano category.

Top items:
1. Feature A — RICE: 2,400 (must-have, delighter)
2. Feature B — RICE: 1,800 (should-have, performance)
3. Feature C — RICE: 1,200 (could-have, basic)

Used confidence: 100% for all items.
```

**Correct: framework selected based on context, applied consistently**

```markdown
## Q2 Prioritization — Framework Selection

Context:
- Stage: Post-PMF, scaling (18 months post-launch, product instrumented)
- Data maturity: Quantitative (analytics, NPS, support volume available)
- Decision context: Internal team ranking, not stakeholder communication

Recommended framework: RICE
Rationale: Scaling stage with quantitative data makes Reach and Impact
estimable. Confidence score forces explicit uncertainty acknowledgment.

If context were different:
- Pre-PMF or no analytics → use ICE (faster, less data-dependent)
- Feature discovery with user research → use Kano survey
- Sprint scope negotiation with stakeholders → use MoSCoW

## Q2 RICE Scores

| Feature          | Reach | Impact | Confidence | Effort | RICE  |
|------------------|-------|--------|------------|--------|-------|
| Bulk export      | 4,200 | 2      | 80%        | 3 wks  | 2,240 |
| SSO integration  | 1,800 | 3      | 60%        | 6 wks  | 540   |
| Email digest     | 6,000 | 1      | 90%        | 1 wk   | 5,400 |

Confidence: % based on supporting evidence (interviews, data, analogues).
Do not default to 100% — no estimate deserves it.
```

Reference: [../references/prioritization-advisor-full.md](../references/prioritization-advisor-full.md)

### 5.5 Roadmap Planning

**Impact: MEDIUM (A feature-list timeline masquerading as a roadmap erodes trust when reality diverges from dates)**

Roadmap planning is a 1–2 week process with four sequential phases: gather inputs (strategy, validated problems, stakeholder asks, engineering capacity), define initiatives and epics (outcome-framed, not feature-named), prioritize using a scoring framework, and sequence into Now/Next/Later horizons. The output is a living document that communicates direction and rationale — not a commitment list with fixed dates. Use this at the start of each quarter or after a significant strategy shift. Do not use this process to produce a Gantt chart; if stakeholders need dates, add estimated quarters to Later items only, never to Now.

**Incorrect: feature list with fixed dates, no strategic link**

```markdown
## 2026 Product Roadmap

January: Dark mode
February: Mobile app redesign
March: Zapier integration
April: Advanced search filters
May: Team permissions v2
June: API v3

Note: dates are committed to sales team and on website.
```

**Correct: initiative-level, outcome-framed, Now/Next/Later with rationale**

```markdown
## Q2 2026 Roadmap — Last updated: Feb 21

### Inputs gathered
- Strategy: "data-first operations" positioning (see Positioning Statement v3)
- Validated problems: report navigation friction (#1 support theme, 180 tickets/mo)
- Capacity: 3 engineers × 10 weeks = 30 eng-weeks available
- Stakeholder asks: Sales requests SSO (7 enterprise deals blocked)

### Initiatives

**NOW (this quarter, committed)**
- Initiative: Reduce report navigation friction
  Outcome: avg. navigation clicks per session from 8.2 → 4.0
  Epics: persistent sidebar, keyboard shortcuts, recent history
  Capacity: 12 eng-weeks | Owner: Ana

- Initiative: Unblock enterprise sales via SSO
  Outcome: 7 stalled enterprise deals unblocked, SSO as table-stakes feature
  Epics: SAML 2.0, admin provisioning flow
  Capacity: 8 eng-weeks | Owner: Ben

**NEXT (next quarter, directional)**
- Initiative: Self-serve analytics exports
  Outcome: reduce custom export support tickets by 60%
  Why next: depends on NOW sidebar work; data model changes required first

**LATER (6+ months, intent only)**
- Initiative: Mobile companion app (Q4 estimate)
  Why later: no validated mobile use case yet; discovery planned for Q3

### What is NOT on this roadmap
- Dark mode: low strategic value, no customer problem evidence
- Zapier integration: under evaluation; channel ROI analysis pending
```

Reference: [../references/roadmap-planning-full.md](../references/roadmap-planning-full.md)

---

## 6. Financial Analysis

**Impact: MEDIUM**

Frameworks for evaluating business health, SaaS metrics, pricing decisions, and unit economics. Provides formulas, benchmarks, and diagnostic tools.

### 6.1 Business Health Diagnosis

**Impact: MEDIUM (Treating symptoms instead of root causes delays recovery and wastes capital)**

Diagnose SaaS business health by systematically reading revenue growth, net retention, unit economics, and cash efficiency as a unified picture — not as isolated metrics. Use this when a business is underperforming, preparing for a funding round, or before a strategic pivot. Do not use a single metric (e.g., revenue growth alone) to declare health; a fast-growing business with NRR below 100% and CAC payback above 24 months is burning toward failure. Red flags must be cross-referenced to distinguish structural problems from cyclical noise.

**Incorrect: single-metric verdict**

```markdown
## Q3 Health Check

Revenue grew 35% YoY. Business is healthy.

Recommendation: Accelerate hiring and marketing spend.
```

**Correct: multi-dimensional diagnosis with red flags**

```markdown
## Q3 Health Diagnosis

**Revenue Growth:** 35% YoY — strong, but decelerating from 52% in Q2. Watch for S-curve plateau.

**Retention:** Gross churn 18% annualized, NRR 94% — RED FLAG. Expansion cannot offset losses.
Churn source: SMB segment (>60% of churned logos). Root cause: time-to-value >90 days.

**Unit Economics:** CAC payback 28 months, LTV:CAC 2.1x — below 3x floor. Sales efficiency declining.
Magic number: 0.6 (threshold is 0.75). Every dollar of S&M is underperforming.

**Cash Efficiency:** Burn multiple 2.4x — burning $2.40 to generate $1 of ARR. Unsustainable at scale.

**Priority Actions:**
1. Fix SMB onboarding to reduce time-to-value below 30 days (churn lever)
2. Pause bottom-funnel spend until magic number exceeds 0.75 (efficiency lever)
3. Model runway at current burn — extend to 18+ months before next growth push
```

Reference: [../references/business-health-full.md](../references/business-health-full.md)

### 6.2 Pricing Change Financial Analysis

**Impact: MEDIUM (Unmodeled pricing changes destroy revenue through elasticity and cannibalization)**

Evaluate any pricing change by modeling revenue impact, price elasticity, competitive positioning shift, and cannibalization risk before implementation. Use this whenever changing list prices, introducing a new tier, bundling or unbundling features, or running a promotional discount. Do not skip the cannibalization analysis when adding a lower-priced tier — SMB plans routinely cannibalize mid-market deals when the price gap is too wide. Every pricing decision should be treated as a reversible experiment with measurable success criteria.

**Incorrect: intuition-driven, no model**

```markdown
## Pricing Update Proposal

Our current Pro plan at $99/mo feels too expensive based on sales feedback.
Proposal: Drop Pro to $79/mo to increase conversion.

Expected outcome: More signups, higher revenue.
```

**Correct: impact model with elasticity and risk assessment**

```markdown
## Pricing Change Analysis — Pro Plan: $99 → $79/mo

**Baseline:** 1,200 Pro subscribers × $99 = $118,800 MRR

**Scenario Modeling (price elasticity estimate: 1.4):**
| Scenario | New Subscribers | Churned | Net MRR | Delta |
|---|---|---|---|---|
| Bear (-10% volume gain) | +120 | 0 | $116,280 | -$2,520 (-2%) |
| Base (+18% volume gain) | +216 | 0 | $115,104 | -$3,696 (-3%) |
| Bull (+30% volume gain) | +360 | 0 | $113,880 | -$4,920 (-4%) |

**Finding:** At elasticity 1.4, a 20% price cut requires 28% volume gain just to break even on MRR.
Current conversion bottleneck is onboarding friction, not price — elasticity assumption is unvalidated.

**Cannibalization Risk:** Starter plan at $39/mo. If Pro drops to $79, price gap narrows to 2x.
Risk: ~15% of current Enterprise trials downgrade to Pro. Estimated impact: -$22K MRR.

**Competitive Position:** Pro at $99 is at market median. Cutting to $79 signals value uncertainty,
not competitiveness. Recommend testing friction removal before price reduction.

**Recommendation:** Do not reduce price. Run 60-day onboarding experiment first; re-evaluate if
conversion rate does not improve by ≥20%.

**Success Criteria (if experiment proceeds):** MRR neutral within 90 days, NRR improvement ≥2%.
```

Reference: [../references/finance-pricing-full.md](../references/finance-pricing-full.md)

### 6.3 SaaS Finance Metrics Reference

**Impact: MEDIUM (Misusing metrics in board decks or investment decisions signals PM immaturity)**

A quick-reference for 32+ SaaS finance metrics with formulas, benchmark ranges, and interpretation notes. Use it when building financial models, preparing investor materials, diagnosing business performance, or reviewing a competitor's reported metrics. Do not present metrics without benchmarks — a 120% NRR is exceptional in SMB but table stakes in enterprise. Always state the cohort, time window, and ARR segment when reporting.

**Incorrect: metric without formula or benchmark context**

```markdown
## Our Key Metrics

- MRR: $420K
- Churn: 5%
- LTV: $18K
- CAC: $6K
- Rule of 40: 38

Status: Good
```

**Correct: metric with formula, benchmark, and interpretation**

```markdown
## Key SaaS Metrics — Q3 Snapshot

| Metric | Formula | Value | Benchmark | Signal |
|---|---|---|---|---|
| MRR | Sum of all recurring monthly revenue | $420K | — | Growing 8% MoM |
| ARR | MRR × 12 | $5.04M | — | — |
| Gross Churn | Churned MRR / Beginning MRR | 2.1%/mo (23% ann.) | <5% ann. SMB | RED: above threshold |
| Net Revenue Retention | (Beg. MRR + Expansion − Churn − Contraction) / Beg. MRR | 97% | >100% good, >120% elite | WARN: below 100% |
| CAC | Total S&M spend / New customers acquired | $6,200 | Varies by segment | Blended |
| CAC Payback | CAC / (ARPU × Gross Margin %) | 22 months | <12 best, <18 good | WARN |
| LTV | ARPU × Gross Margin % / Churn Rate | $18K | LTV:CAC >3x target | 2.9x — borderline |
| Rule of 40 | Revenue growth % + Profit margin % | 38 | ≥40 healthy | WARN |
| Magic Number | Net new ARR / S&M spend prior quarter | 0.71 | >0.75 efficient | WARN |
| Burn Multiple | Net burn / Net new ARR | 1.8x | <1x elite, <2x ok | Acceptable |

**Interpretation:** Churn is the dominant risk. All efficiency metrics are borderline because gross retention is dragging NRR below 100%. Fix retention before scaling spend.
```

Reference: [../references/finance-metrics-full.md](../references/finance-metrics-full.md)

### 6.4 SaaS Revenue Health Metrics

**Impact: MEDIUM (Reporting ARR growth without retention metrics misleads investors and leadership)**

Calculate and interpret the full revenue health stack: MRR/ARR growth rate, gross and net churn, Net Revenue Retention, expansion revenue, contraction analysis, and cohort retention curves. Use this for monthly business reviews, investor updates, and when diagnosing revenue deceleration. Do not report ARR growth alone — a company growing ARR 40% YoY with NRR of 85% is a leaky bucket that will stall; one growing 20% with NRR of 125% is compounding. Always decompose MRR movements into new, expansion, contraction, and churn buckets.

**Incorrect: headline metric without retention breakdown**

```markdown
## Revenue Update — Q3

ARR: $6.2M (up 41% YoY). Great quarter.
New logos: 48. Average deal: $129K ACV.

Outlook: On track to hit $8M ARR by year-end.
```

**Correct: full MRR bridge with retention and cohort signal**

```markdown
## Revenue Health — Q3 MRR Bridge

**Beginning MRR:** $483,000

| Movement | Amount | Notes |
|---|---|---|
| New Business | +$52,000 | 48 logos, avg $1,083 MRR |
| Expansion | +$18,400 | Seat additions + plan upgrades |
| Contraction | -$9,200 | Downgrades, seat reductions |
| Churn | -$31,600 | 29 logos lost |
| **Ending MRR** | **$512,600** | +6.1% MoM |

**Gross MRR Churn:** $31,600 / $483,000 = 6.5%/mo — RED (annualized 78%; target <5%/yr)
**Net MRR Churn:** ($31,600 + $9,200 − $18,400) / $483,000 = 4.6%/mo — RED

**NRR (trailing 12 months):** 88% — below 100% floor. Business shrinks without new logos.

**Expansion Rate:** $18,400 / $483,000 = 3.8% — healthy expansion motion; cannot offset gross churn

**Cohort Analysis Signal:** Jan cohort (12 months old) at 61% logo retention, 74% revenue retention.
Expansion partially masking logo churn. Cohorts are NOT improving — Jan vs. Jul cohorts within 2pp.

**Root Cause Hypothesis:** Churn concentrated in <$500 MRR accounts (68% of churned logos).
SMB segment requires self-serve success motion — current high-touch CS model is uneconomic there.

**Priority:** Segment churn analysis by ACV, industry, and onboarding path before Q4 planning.
```

Reference: [../references/saas-revenue-full.md](../references/saas-revenue-full.md)

### 6.5 SaaS Unit Economics & Capital Efficiency

**Impact: MEDIUM (Poor unit economics masked by growth lead to collapse at scale)**

Evaluate unit economics and capital efficiency using CAC payback, LTV:CAC ratio, gross margin, burn rate, Rule of 40, magic number, and net burn multiple as a coherent system. Use this when assessing whether a business can scale profitably, entering fundraising discussions, or deciding whether to accelerate or throttle growth investment. Do not evaluate unit economics in isolation from the growth rate — a 30-month CAC payback is disqualifying at 10% growth but defensible at 150% if NRR exceeds 130%.

**Incorrect: metrics reported without efficiency context**

```markdown
## Unit Economics Summary

- CAC: $8,400
- LTV: $29,000
- LTV:CAC: 3.5x
- Gross margin: 71%

Verdict: Healthy unit economics. Recommend increasing sales headcount.
```

**Correct: system view with thresholds and capital efficiency diagnosis**

```markdown
## Unit Economics & Capital Efficiency Audit

**CAC & Payback**
- Blended CAC: $8,400 (Sales-touch: $14,200 | Self-serve: $1,100)
- CAC Payback: 31 months (Sales-touch) — RED: threshold is <18 months
- CAC Payback: 8 months (Self-serve) — GREEN: excellent
- Implication: Sales-touch channel is capital-inefficient at current close rates

**LTV:CAC**
- LTV: $29,000 | LTV:CAC: 3.5x — borderline (target: >3x; elite: >5x)
- WARNING: LTV is sensitive to 23% gross churn. If churn rises 5pp, LTV drops to $21K → 2.5x

**Gross Margin**
- Current: 71% — approaching acceptable floor (70%). Investigate COGS drivers.
- Benchmark: Best-in-class SaaS 75–85%. Gap suggests hosting or CS cost bloat.

**Capital Efficiency**
- Burn Multiple: 2.2x — burning $2.20 per $1 of net new ARR (target <1.5x)
- Magic Number: 0.68 — below 0.75 efficiency threshold
- Rule of 40: Growth 28% + FCF margin -14% = 14 — FAR below 40 threshold

**Verdict:** Self-serve is the healthy core. Sales-touch is destroying capital efficiency.
Recommend: shift investment to self-serve PLG motion; redesign sales comp to target
≤18-month payback accounts only. Do not scale headcount until magic number exceeds 0.75.
```

Reference: [../references/saas-economics-full.md](../references/saas-economics-full.md)

---

## 7. Facilitation & Advisory

**Impact: MEDIUM**

Protocols for running structured multi-turn interactions, workshop facilitation, and meta-skills for AI-assisted PM work. Includes the canonical facilitation protocol used by interactive skills.

### 7.1 Context Engineering for AI Systems

**Impact: MEDIUM (Context stuffing produces hallucination-prone, expensive, brittle AI systems)**

Diagnose whether an AI system is doing context stuffing (dumping everything into the prompt) versus proper context engineering (routing the right information to the right memory tier at the right time). Use this when designing AI-powered product features, reviewing an AI architecture decision, or debugging a system with high latency, high cost, or degraded output quality. Do not treat context engineering as an optimization pass — it is a foundational architectural decision that defines retrieval strategy, memory taxonomy, and token economics from the start.

**Incorrect: context stuffing — everything in one prompt**

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

**Correct: tiered memory architecture with deliberate routing**

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

Reference: [../references/context-engineering-full.md](../references/context-engineering-full.md)

### 7.2 End-of-Life & Deprecation Communication

**Impact: MEDIUM (Vague or abrupt deprecation announcements damage trust and drive emergency churn)**

Communicate product or feature deprecation by covering five mandatory elements: what is changing, why the decision was made, the timeline with hard dates, the migration path with concrete steps, and the support commitment during transition. Use this for sunsetting features, retiring API versions, or discontinuing a product line. Do not announce EOL without a migration path ready — sending customers into a dead end is worse than delaying the announcement. Lead with customer impact, not internal rationale.

**Incorrect: internal-focused, no migration path**

```markdown
## Deprecation Notice: Legacy Reports Module

We are deprecating the Legacy Reports module on March 1st.
This is part of our platform modernization initiative to reduce technical debt
and align with our new architecture strategy.

Please update your workflows accordingly.
```

**Correct: customer-centered with timeline, migration, and support**

```markdown
## What's Changing: Legacy Reports Module Retirement

**What is changing:** The Legacy Reports module will be retired on June 30, 2026.
After this date, the module will no longer be accessible and saved report configurations
will not transfer automatically.

**Why:** The new Analytics Hub (launched Q1 2025) delivers the same reporting capabilities
with real-time data refresh, custom dimensions, and CSV/API export — features Legacy Reports
cannot support. Maintaining both systems prevents us from improving either.

**Timeline:**
- Now → March 31: Both systems available. New features added to Analytics Hub only.
- April 1 → June 29: Legacy Reports read-only. No new reports can be created.
- June 30: Legacy Reports retired. Data remains accessible via API export for 90 days.

**Migration Path (3 steps, ~30 minutes):**
1. Export your saved Legacy report list: Settings → Reports → Export Config (JSON)
2. Import into Analytics Hub: Analytics Hub → Import Legacy Config → follow wizard
3. Validate outputs match: use our side-by-side comparison guide [link]

**Support Commitment:**
- Dedicated migration office hours: Tuesdays 2–4pm ET through June (sign up [link])
- Migration guide with video walkthrough: [link]
- If you cannot migrate by June 30, contact support for a 60-day extension.

Questions? Reply to this email or open a ticket tagged "legacy-reports-migration".
```

Reference: [../references/eol-message-full.md](../references/eol-message-full.md)

### 7.3 Organizational AI Readiness Assessment

**Impact: MEDIUM (Deploying AI into organizations with immature foundations wastes budget and erodes trust)**

Assess AI readiness across five competencies — data infrastructure, model literacy, workflow integration, governance, and change management — and assign a maturity level (1 Nascent through 4 Leading) to each before recommending AI initiatives. Use this before scoping an AI product feature, advising a client on AI adoption, or evaluating whether an organization can absorb a given AI investment. Do not assess readiness as a single yes/no — a company can have elite data infrastructure and zero governance, creating liability even with strong technical capability.

**Incorrect: binary readiness verdict**

```markdown
## AI Readiness Check

- Has data team: Yes
- Uses some ML tools: Yes
- Leadership is interested in AI: Yes

Verdict: Ready for AI. Proceed with implementation.
```

**Correct: five-competency maturity grid with gaps and sequencing**

```markdown
## AI Readiness Assessment — Acme Corp

| Competency | Level | Evidence | Gap |
|---|---|---|---|
| Data Infrastructure | 3 — Defined | Centralized data warehouse, 80% structured | No real-time pipelines; batch only |
| Model Literacy | 1 — Nascent | Leadership aware of AI; IC teams have no ML exposure | Training needed before deployment |
| Workflow Integration | 2 — Emerging | 2 pilot automations in ops; no PM ownership | No process for AI feature lifecycle |
| Governance | 1 — Nascent | No AI policy; no bias review process | Blocker for any customer-facing AI |
| Change Management | 2 — Emerging | Change comms in place for IT projects | AI-specific change plan absent |

**Overall Maturity: Level 1–2 (Emerging)**

**Blockers Before AI Product Investment:**
1. Governance: Draft AI use policy and bias review checklist (4 weeks)
2. Model Literacy: Run 2-day ML fundamentals workshop for PMs and Eng leads
3. Workflow Integration: Assign AI feature owner before scoping any initiative

**Recommended Entry Point:** Internal productivity AI (low customer risk) while governance matures.
Do not launch customer-facing AI features until governance reaches Level 3.
```

Reference: [../references/ai-readiness-full.md](../references/ai-readiness-full.md)

### 7.4 PM Skill Authoring

**Impact: MEDIUM (Poorly structured skills produce inconsistent outputs and erode AI-assisted PM quality)**

Create new PM skills using four required components: a SKILL.md entry point, one or more rule files under `rules/`, reference documents under `references/`, and a catalog registration in `_sections.md`. Use this meta-skill whenever extending the PM skill set with a new framework, adding a section, or auditing existing skills for quality gaps. Do not author a skill without a working example pair (Incorrect/Correct) — the example pair is the primary quality signal and the hardest part to write well. Every skill must be self-contained: a reader with no prior context should understand what to do and what not to do.

**Incorrect: incomplete skill — missing structure and examples**

```markdown
## New Skill: Competitive Moat Analysis

This skill helps you analyze competitive moats.
Use Porter's Five Forces and think about switching costs.

Files created:
- rules/comp-moat.md (stub)
```

**Correct: complete skill with all required components**

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

Reference: [../references/skill-authoring-full.md](../references/skill-authoring-full.md)

### 7.5 Workshop Facilitation Protocol

**Impact: MEDIUM (Unstructured AI-assisted sessions produce noise instead of actionable PM outputs)**

This is the canonical facilitation protocol for all interactive PM skills. It defines the session heads-up format, three entry modes (Guided, Context dump, Best guess), the one-question-at-a-time discipline, and progress labels. Use this as the base pattern when authoring any skill that involves a multi-turn interactive session. Do not skip the entry mode selection — dropping a user directly into questions without offering a context dump option causes information asymmetry and produces outputs that require two rounds of revision instead of zero.

**Incorrect: no entry mode, no structure, floods user with questions**

```markdown
Let's work on your positioning. Tell me about your product, your users, their
main problems, your competitors, your pricing, your differentiation, your
company stage, your team size, and your key metrics. I'll analyze everything
and give you a positioning statement.
```

**Correct: heads-up + entry mode + one-question-at-a-time + progress labels**

```markdown
## Positioning Workshop

I'll guide you to a complete positioning statement using Geoffrey Moore's framework.
This takes 6–8 questions. You can exit and resume anytime.

**How do you want to start?**

A) **Guided** — I ask one question at a time, build context as we go (recommended if you're
   still forming your thinking)
B) **Context dump** — Paste or describe everything you know; I'll extract what I need and
   fill gaps with targeted questions
C) **Best guess** — Tell me your product in one sentence; I'll draft a positioning statement
   and we'll refine from there

---
*(User selects A — Guided)*

**[1/6] Target Customer**
Who is the primary user of your product? Describe their role, company size, and
the specific context in which they'd use it.

*(Wait for response before asking question 2)*

---
*(After each response, show progress label and acknowledge before proceeding)*

**[2/6] Problem**
*(building on: mid-market finance teams, 50–200 employees)*

What is the specific, painful problem this person faces that your product solves?
Describe it in terms of their daily experience, not your solution.
```

Reference: [../references/workshop-facilitation-full.md](../references/workshop-facilitation-full.md)

---

