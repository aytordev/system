# Optional Knowledge Selection

Use the neutral collection or host-provided skill discovery. An explicitly requested local index can help
select knowledge; it never controls a workflow or requires delegation.

## Index contract

Record name, full frontmatter description, project/global scope, exact absolute
`SKILL.md` path, and content freshness (SHA-256, or size plus modification time).
Read selected originals and relevant supporting files; summaries are not authority.
Follow supported filesystem links and collapse aliases of the same original file.
Prefer project scope over global scope and
surface ambiguous same-scope duplicates instead of silently choosing one.

Use a session index by default. Only consult an explicitly selected local file
(`.ai-local/skill-registry.md`) or Engram topic (`aytordev/local-skill-registry`).
Rebuild stale entries from their original files. Never read or overwrite Shell's
generated `.atl/skill-registry.md` as this local collection's persistence target.

## Selection

Match the actual task and code context against full descriptions. Select the
smallest useful set; availability or a keyword alone does not activate a skill.
An indexed workflow skill is not permission to start its lifecycle. Keep project
conventions scoped to the subtree they govern.

When a caller already authorized delegation, supply exact original paths using
the host's native mechanism. `## Skills to load before work` and
`skill_resolution: paths-injected` are conventions some coding clients use, not
universal tool names or a requirement to delegate. This guidance does not require a
shared result envelope, SDD protocol, or always-on registry refresh.
