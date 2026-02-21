---
title: User Story Mapping
impact: HIGH
impactDescription: Flat backlogs lose the user workflow context needed to sequence work coherently
tags: story mapping, jeff patton, backbone, user journey, backlog
---

## User Story Mapping

**Impact: HIGH (Flat backlogs lose the user workflow context needed to sequence work coherently)**

Use Jeff Patton's story mapping method to organize stories along a two-dimensional map: the horizontal backbone represents the user's workflow (activities broken into tasks), and the vertical axis represents priority — stories closer to the top ship first. Apply this when planning a release or identifying MVP scope; the map makes gaps and dependencies visible that a flat backlog hides. Do not use story mapping as a substitute for discovery — the backbone should reflect observed user behavior, not assumed feature categories.

**Incorrect (flat feature list with no workflow context):**

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

**Correct (backbone with activities → tasks, stories tiered by release):**

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

Reference: [Full framework](../references/user-story-mapping-full.md)
