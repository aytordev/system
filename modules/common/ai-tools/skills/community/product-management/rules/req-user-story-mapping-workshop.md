---
title: User Story Mapping Workshop
impact: HIGH
impactDescription: Unstructured mapping sessions produce incomplete backbones and no agreed release slices
tags: workshop, story mapping, facilitation, jeff patton, release planning
---

## User Story Mapping Workshop

**Impact: HIGH (Unstructured mapping sessions produce incomplete backbones and no agreed release slices)**

Run a guided workshop to build a story map collaboratively using adaptive questions: start with user activities (what are the big things users do?), decompose into tasks (what steps make up each activity?), then add story cards below each task ordered by priority. Close the session by drawing release slice lines. Use this when a team is starting a new product area or planning a major release. Do not run this workshop without a clear user persona anchoring the map — without it, participants argue about whose workflow to prioritize.

**Incorrect (workshop produces a feature list, no backbone or release slices):**

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

**Correct (workshop produces backbone, tasks, stories, and release slices):**

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

Reference: [Full framework](../references/user-story-mapping-workshop-full.md)
