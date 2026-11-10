---
title: Page on Symptoms with Burn Rates
impact: CRITICAL
impactDescription: SLO discipline and alert construction
tags: observability, slo, alerting
---

## Page on Symptoms with Burn Rates

**Impact: CRITICAL**

An **SLI** is a carefully defined quantitative measure of service level; an
**SLO** is a target value for that SLI; an **SLA** is an SLO plus
consequences. The **error budget** is 100% minus the SLO — and its purpose is
to *license shipping*: spend the budget on releases instead of chasing a 100%
that users cannot distinguish anyway.

### SLI menus (mnemonics for shopping, not mandates)

- **RED** — Rate, Errors, Duration — per request-driven service; explicitly a
  proxy for user experience.
- **USE** — Utilization, Saturation, Errors — per hardware resource;
  infrastructure-focused.
- **Four Golden Signals** — latency, traffic, errors, saturation — with two
  nuances everyone drops: track latency of *failed* requests separately (a
  slow 500 is a different pathology from a fast 500), and use histograms
  because averages hide the tail — at 1,000 rps averaging 100ms, 1% of
  requests can easily take 5s.

### SLO discipline

Keep few SLOs, each simple enough to explain in a sentence. Define
availability, correctness, and freshness as good events over valid events.
Define latency objectives as the proportion of valid events below an explicit
threshold; use percentiles rather than means when diagnosing latency
distributions. Keep internal targets slightly stricter than published ones.
Do not overachieve — users come to depend on the reliability you deliver, not
the one you promised.

### Alerting: symptoms, pages, burn rates

**Page on symptoms, not causes.** "Do your users care if your MySQL servers
are down? No, they care if their queries are failing." Cause-based data
belongs on dashboards and in tickets, not pages. The rare exception:
imminent, definite causes (quota exhaustion in 4 hours).

**Every page must be:** urgent, actionable, user-visible, and require human
intelligence to handle. If the response to a page could be scripted, script
it and delete the page. Measure false pages, then fix or remove alerts that
repeatedly waste responders' attention.

**The default alert construction is the multiwindow, multi-burn-rate alert.**
Burn rate = how fast you consume error budget relative to the SLO (burn rate
1 = exactly out of budget at period end). For a 99.9% SLO over 30 days:

| Severity | Burn rate | Long window | Short window | Budget consumed |
|----------|-----------|-------------|--------------|-----------------|
| Page | 14.4 | 1 h | 5 m | 2% |
| Page | 6 | 6 h | 30 m | 5% |
| Ticket | 1 | 3 d | 6 h | 10% |

The short window (1/12 of the long) confirms the problem is *still
happening*, which fixes the reset-time failure of naive threshold alerts.
This is the only construction that scores well on precision, recall,
detection time, and reset time simultaneously — the derivation and the
per-SLO threshold tables live in `references/slo-alerting.md`.

**Every page links a runbook** — a concise "what this alert means and current
mitigations", not an exhaustive troubleshooting tree.

Alert rules are code: keep them in the repository, review them like code, and
unit-test them where the stack supports it.
