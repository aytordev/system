# Skill Authoring Workflow — Full Framework

## Purpose

Turn raw PM content — workshop notes, prompt dumps, research frameworks — into a
compliant, publish-ready skill that passes validation and belongs in the
repository. This is the meta-skill: the process for creating new PM skills
within the framework itself.

Use it when you want to ship a new skill without "looks good to me" roulette.
The workflow enforces structural compliance, prevents duplicate work, and ensures
documentation stays in sync.

## When to Use

- Creating a new skill from scratch or from existing source material
- Converting workshop notes, research, or prompt collections into structured skills
- Updating an existing skill to meet current compliance standards
- Onboarding a contributor who wants to add a skill to the repository

## When NOT to Use

- For minor edits to an existing, compliant skill (just edit and validate)
- When the content does not fit the skill format (consider a research doc instead)
- Before you have enough substance to fill the required sections (gather more
  material first)

## Skill Types

Choose the correct type before starting. Getting this wrong creates structural
problems that are expensive to fix later.

| Type        | Use When                                              | Structure                            |
|-------------|-------------------------------------------------------|--------------------------------------|
| Component   | One artifact or template (e.g., problem statement)    | Template + guidance + examples       |
| Interactive | 3-5 adaptive questions with numbered options           | Question flow + decision logic       |
| Workflow    | Multi-phase orchestration (e.g., this skill)          | Phases + gates + validation steps    |

**Common mistake:** Choosing "workflow" when the task is really a component
template. If the output is a single document, it is a component.

## The 6-Phase Process

### Phase 1: Preflight — Avoid Duplicate Work

Search for overlapping skills before creating anything:

```bash
./scripts/find-a-skill.sh --keyword "<topic>"
```

If a related skill exists, decide whether to extend it or create a new one.
Duplicate skills fragment the catalog and confuse users.

### Phase 2: Generate Draft

**If you have source material** (research notes, workshop output, prompt):

```bash
./scripts/add-a-skill.sh research/your-framework.md
```

This ingests the content and generates a SKILL.md scaffold with the correct
frontmatter and section structure.

**If you want guided prompts** (starting from an idea, not finished prose):

```bash
./scripts/build-a-skill.sh
```

This walks through interactive questions to build the skill step by step.

**If editing an existing skill** (manual tightening):

Edit the SKILL.md directly, then validate in Phase 4.

### Phase 3: Tighten the Skill

Review the draft against these criteria:

- **Clear "when to use" guidance:** Reader knows immediately if this skill applies
- **At least one concrete example:** Not abstract — a real worked scenario
- **At least one explicit anti-pattern:** What this skill is NOT
- **No filler:** Remove vague consultant-speak, padding, and hand-waving
- **Actionable templates:** Every template should be fill-in-the-blank ready

### Phase 4: Validate Hard

Run strict checks before thinking about commit:

```bash
# Structural validation
./scripts/test-a-skill.sh --skill <skill-name> --smoke

# Metadata compliance
python3 scripts/check-skill-metadata.py skills/<skill-name>/SKILL.md
```

### Phase 5: Integrate with Repo Docs

If this is a new skill (not an update to an existing one):

1. Add it to the correct README category table
2. Update skill totals and category counts
3. Verify all link paths resolve

Forgetting this step is the single most common contributor mistake. The skill
works but the catalog does not list it, so no one finds it.

### Phase 6: Optional Packaging

For distribution as a Claude custom skill:

```bash
# Single skill
./scripts/zip-a-skill.sh --skill <skill-name>

# One category
./scripts/zip-a-skill.sh --type component --output dist/skill-zips

# Curated starter preset
./scripts/zip-a-skill.sh --preset core-pm --output dist/skill-zips
```

## Definition of Done

A skill is done only when ALL of these are true:

- [ ] Frontmatter is valid: `name`, `description`, `type` present and correct
- [ ] `name` is 64 characters or fewer
- [ ] `description` is 200 characters or fewer
- [ ] Section order matches the compliance schema
- [ ] Cross-references to other skills resolve (no broken links)
- [ ] README catalog counts and tables updated (if adding or removing a skill)
- [ ] `test-a-skill.sh --smoke` passes
- [ ] `check-skill-metadata.py` passes
- [ ] At least one concrete example included
- [ ] At least one anti-pattern documented

## Frontmatter Template

```yaml
---
name: my-skill-name
description: One-line description of what the skill does, under 200 characters.
type: component  # or: interactive, workflow
---
```

## Required Section Order

Every SKILL.md must follow this structure:

```markdown
## Purpose
[What this skill does and why it matters]

## Key Concepts
[Core ideas, frameworks, and terminology]

## Application
[Step-by-step process with templates]

## Examples
[At least one concrete worked example]

## Common Pitfalls
[What goes wrong and how to avoid it]

## References
[Related skills, external frameworks, provenance]
```

## Worked Example

**Input:** `research/pricing-workshop-notes.md` — raw notes from a pricing
strategy workshop.

**Process:**

```bash
# Phase 1: Check for duplicates
./scripts/find-a-skill.sh --keyword "pricing"
# Result: finance-based-pricing-advisor exists — this is different (workshop
# format vs. advisor), so proceed with new skill

# Phase 2: Generate draft
./scripts/add-a-skill.sh research/pricing-workshop-notes.md
# Creates skills/pricing-workshop/SKILL.md with scaffold

# Phase 3: Manual tightening
# - Add concrete pricing exercise example
# - Add anti-pattern: "running pricing workshop without customer data"
# - Remove filler paragraphs

# Phase 4: Validate
./scripts/test-a-skill.sh --skill pricing-workshop --smoke
python3 scripts/check-skill-metadata.py skills/pricing-workshop/SKILL.md

# Phase 5: Update README
# - Add row to workshop category table
# - Increment skill count
```

**Expected result:** New skill folder, passes all checks, README updated.

## Common Failure Modes

| Failure Mode                          | Why It Hurts                                    | Fix                                                 |
|---------------------------------------|-------------------------------------------------|-----------------------------------------------------|
| Skipping duplicate search             | Creates overlapping skills that fragment catalog | Always run find-a-skill.sh first                    |
| Wrong type selection                  | Structural mismatch makes skill hard to use     | Component = one artifact; Workflow = multi-phase     |
| Bloated description (>200 chars)      | Fails metadata validation; exceeds upload limits | Ruthlessly edit to under 200 characters             |
| Skipping validation before commit     | Broken references and inconsistent catalog      | Always run both test and metadata checks            |
| Forgetting README updates             | Skill exists but no one can find it              | Update catalog tables and counts every time         |
| Treating generated output as final    | Scaffolds need human review and tightening      | Always manually review Phase 3 criteria             |
| No concrete example                   | Abstract skills do not get used                  | Include at least one fill-in worked scenario        |
| Consultant-speak filler               | Undermines credibility and wastes reader time   | Cut any sentence that does not teach or demonstrate |

## Quality Checklist

- [ ] Duplicate search performed before creation
- [ ] Skill type correctly chosen (component / interactive / workflow)
- [ ] Frontmatter valid: name (<=64 chars), description (<=200 chars), type
- [ ] All required sections present in correct order
- [ ] At least one concrete worked example
- [ ] At least one explicit anti-pattern
- [ ] No filler or vague language
- [ ] `test-a-skill.sh --smoke` passes
- [ ] `check-skill-metadata.py` passes
- [ ] Cross-references resolve
- [ ] README catalog updated (if new skill)

## Relationship to Other Frameworks

- **Workshop Facilitation** — provides the interaction protocol when running
  skill authoring as a guided conversation
- **AGENTS.md / CLAUDE.md** — repo-level configuration that governs how skills
  are discovered and invoked
- **Contributing Guide** — broader contribution standards that complement
  skill-specific validation
