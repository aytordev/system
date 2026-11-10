---
title: Produce the Structure and Its Rules Together
impact: CRITICAL
impactDescription: Makes every tree proposal auditable and enforceable
tags: structure-codebase, proposal, anti-patterns
---

## Produce the Structure and Its Rules Together

**Impact: CRITICAL**

### Preserve the requested scope

Determine whether the user asked for an audit, proposal, migration plan, or
implementation. Do not move files for a suggestion-only request. Do not broaden
a folder change into a domain redesign without authorization.

### Inspect before naming

Read enough of the actual system to avoid designing from filenames alone:

- Project rules, architecture decisions, glossary, roadmap, and package index.
- Routes, screens, commands, jobs, components, state/data owners, tests,
  public exports, and user-facing language.
- Package manifests, source imports, runtime/deployment units, and provider
  dependencies.
- Framework-required locations, generated code, workspace globs, build/test
  configuration, and boundary tooling.
- Recent changes or ownership signals that reveal which files change together.

Record uncertainty. Candidate bounded contexts and package splits are
hypotheses until language, invariants, ownership, or dependency direction
justify them.

### Every proposal includes

1. The selected shape and the evidence supporting it.
2. An annotated ASCII tree distinguishing grouping directories, real packages,
   and executable hosts. Show only evidence-backed target paths: every new
   directory displayed must own at least one named file, package, or concrete
   responsibility. Collapse unknown candidates into prose; use an ellipsis only
   for an existing unchanged subtree or an explicitly repeated established
   pattern.
3. Placement rules for new files.
4. Allowed and forbidden dependency directions.
5. Proportionate automated enforcement.
6. A staged migration when an existing tree must change.
7. Assumptions, deliberately deferred decisions, and structures intentionally
   not introduced.

### Anti-patterns to reject

- Cosmetic `src/hexagon` inside a package that mixes provider code or permits
  outward imports.
- Global `domain`, `application`, `controllers`, `services`, or
  `repositories` buckets spanning unrelated capabilities.
- A package, bounded context, port, or hexagon for every noun or tiny
  interface.
- Ports that reproduce SQL, HTTP, ORM, or SDK APIs.
- Test adapters and reusable fakes beneath `hexagon/`.
- Business behavior, provider construction, or shared runtime state hidden in
  endpoint handlers.
- HTTP route leaves or CLI command entries buried inside capability or hexagon
  folders instead of the public interface tree (`endpoints/`, `commands/`).
- Production code importing development-only routes or test packages.
- `shared`, `common`, `utils`, `helpers`, or `services` as unowned dumping
  grounds.
- Empty folder skeletons added for symmetry.
- Deep trees that workspace, build, test, coverage, and lint tooling cannot
  discover.
- A big-bang migration that combines behavior changes, dependency inversion,
  and mass file moves.
- Treating every pure formatter or utility as domain policy.
- Fighting required framework locations instead of keeping them thin.
- Global `components`, `hooks`, `stores`, or `api` buckets that obscure
  frontend product ownership.
- Client bundles that can reach server-only modules, secrets, or privileged
  provider code.

### Endpoint access classification (restated locally)

Production BFF endpoints must not be mounted around an informal route catalog
with ad-hoc per-leaf middleware. Each endpoint leaf carries an explicit access
classification, and shared browser/security policy (session, CSRF, Origin) is
installed by construction at a prepared entry-point boundary or registrar, not
chosen separately in every leaf. The entry catalog and its enforcement gates
are derived from that classification rather than hand-maintained twice.
