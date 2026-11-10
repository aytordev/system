---
title: Generate the Skill Inside the App Repository
impact: CRITICAL
impactDescription: The deliverable is a reusable, project-local skill
tags: parity, generated-skill, storage
---

## Generate the Skill Inside the App Repository

**Impact: CRITICAL**

Write a new skill for the specific app, normally named
`<app-name>-production-parity` unless the user or repo naming convention
suggests otherwise.

### Storage

Store the generated skill directly in the target application's repository.
Never create the generated app-specific skill in a user/global folder such as
`~/.agents/skills`, `~/.codex/skills`, `~/.claude/skills`, or
`$CODEX_HOME/skills`.

Choose the project-local location by inspecting the app repo:

- If the app already has a project-local skills directory, use that
  convention.
- Prefer `.claude/skills/<app-name>-production-parity/SKILL.md` when the repo
  uses Claude project config.
- Prefer `.codex/skills/<app-name>-production-parity/SKILL.md` when the repo
  uses Codex project config.
- If no project-local skill convention exists, ask one concise harness
  question before creating a new convention.
- If the only available skill directories are global/user folders, do not use
  them; ask where in the project repo the skill should live.

### Required sections

The generated skill must include:

- frontmatter whose description triggers on parity, drift, local/prod
  mismatch, auth/config/infra differences, and environment setup for that app
- an "App Parity Contract" that names production as the reference and lists
  intentional non-prod divergences
- "Production Truth Sources" with exact file paths, manifests, docs,
  commands, or user-confirmed sources
- "Inspection Workflow" with repo-specific commands and files to read
- "Parity Surfaces" tailored to the app, not a generic checklist dump
- "Drift Checks" with concrete tests, scripts, schemas, or manual checks the
  agent should run
- "Fix Patterns" that explain how to close drift in this app's architecture
- "Question Protocol" instructing the agent to use the active harness's
  ask-question facility for source-unanswerable decisions
- "Output Contract" for every future run: inspected files, risks found, fixes
  made, tests run, remaining explicit divergences

Start from `references/generated-skill-template.md`, but remove irrelevant
sections and replace placeholders with app-specific evidence.

### Validate before finishing

1. Re-read the generated skill as if invoked on a fresh thread.
2. Confirm every app-specific claim cites a repo source or a captured user
   answer.
3. Confirm no generic checklist item remains unless it applies to the app.
4. Confirm the generated skill path is inside the target app repository and
   not in a user/global skills folder.
5. Run the skill validation command available in the harness or repository if
   one exists.
6. If validation cannot be run, say exactly why.
