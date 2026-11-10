---
title: Keep One Workspace per Topic
impact: CRITICAL
impactDescription: Prevents split or duplicated learning artifacts
tags: teach-me, persistence, records
---

## Keep One Workspace per Topic

**Impact: CRITICAL**

Every artifact for a topic lives in that topic's single workspace directory.
Never split artifacts across locations, and never invent a second slug for the
same topic: if existing progress is found, that directory and slug win, and all
new artifacts go beside it. If progress somehow exists in two locations, ask
which is canonical and consolidate before teaching.

**Location:** use a repository-declared location when one exists. Otherwise
suggest `learning/[topic-slug]/plan.md` for project-local work and ask where
general or cross-project material should persist. Writing outside the active
repository requires explicit authorization; never assume a provider-specific
home directory.

```
learning/[topic-slug]/
├── plan.md              # Mission + learning plan with session outline and progress
├── resources.md         # Curated high-trust sources and communities
├── glossary.md          # Canonical terminology — created lazily, grows with mastery
├── cheat-sheet.md       # Reference card, updated as learning progresses
├── session-log.md       # Timestamped log: topics, performance, gaps, learning records
├── lessons/             # Self-contained HTML lessons, one per session
│   ├── 0001-[slug].html
│   └── 0002-[slug].html
└── course/              # Optional: generated course materials
```

### Glossary

`glossary.md` is the canonical language for the topic. Add a term only when the
learner has *demonstrated* they understand it — the glossary records compressed
knowledge, it is not a dictionary to study from. Definitions are one or two
tight sentences; when several words exist for a concept, pick the best and list
the rest as aliases to avoid. Once a term is in the glossary, use it
consistently in every session, lesson, and cheat sheet. Have the learner draft
definitions, then refine together — compressing a concept is itself a
comprehension check.

### Learning records

Learning records are the teaching equivalent of architectural decision records:
short, decision-grade insights appended to `session-log.md` that steer what to
teach next. Write one when the learner demonstrates genuine understanding of
something non-trivial, discloses prior knowledge ("I already know X"), has a
misconception corrected, or when the mission shifts. Mere coverage does not
qualify — wait for evidence. Format and rules are in
`references/session-management.md`.

### Progress tracking

Track in `session-log.md` after each session: date and estimated duration;
topics covered with Bloom's level reached; questions asked (correct, struggled,
missed); confidence calibration (self-rated vs actual); gaps identified and
tagged for spaced review; items due for spaced repetition review and when.

### Optional memory integration

When the host provides memory and the learner wants it used, save or update one
entry: user type for learning preferences and calibration patterns; project
type for current topic, level reached, gaps, next session focus, and spaced
review schedule. Update an existing entry rather than creating duplicates.
Workspace files remain the portable source of continuity; memory is an optional
index, not a replacement.

### Cheat sheet

When asked, generate a dense, scannable reference card: group related concepts
under clear headings; use tables, bullets, and code snippets — no prose; include
the most important 20%, not everything; design for fast lookup, not learning.
Save to `learning/[topic]/cheat-sheet.md` and update it as the learner
progresses.

### Wisdom: beyond the tutor

When the learner asks a question that needs real-world judgment (which tool the
industry actually uses, what is normal in practice), attempt an answer — but
delegate to a community: a high-reputation forum, meetup, or local group where
the learner can interact with practitioners. Record recommended communities in
`resources.md` under a Wisdom section. If the learner declines communities,
note the preference and stop suggesting them.
