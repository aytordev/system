---
name: installation-authorization
impact: CRITICAL
impactDescription: Pinned CLI use, immutable revisions, and scope authorization
---

# Installation Authorization

**Impact: CRITICAL**

## Execution Requires Authorization, Not a Default

Installation changes project or user state. Only install after the user
explicitly authorizes the selected source, the project/global scope, and the
named target agent(s). Do not let a `--yes` flag infer every detected agent.

Resolve and inspect each selected destination first; if an existing
directory's ownership is ambiguous, preserve it and stop rather than letting
the CLI replace it.

## Install From the Reviewed Revision Only

Install from the exact immutable revision that was inspected:

1. Check out the reviewed commit locally.
2. Confirm the checkout still has the reviewed bundle hash.
3. Give that local path to the pinned CLI.

A remote `owner/repo@skill` source is mutable and can change between review
and download, so it is not a reviewed installation even when the report
names a commit.

## The Skills CLI

The Skills CLI is the package manager for the open agent skills ecosystem.
Running an unversioned `npx skills` may download and execute a moving
package, so browsing is the default discovery path. Use the CLI only after
inspecting and authorizing an exact CLI version.

Key commands (all pinned to a reviewed version):

- `npx skills@<reviewed-version> find [query]` — search for skills
  interactively or by keyword.
- `npx skills@<reviewed-version> add <package>` — install a skill from
  GitHub or other sources.
- `npx skills@<reviewed-version> update` — update installed skills to their
  latest versions. There is no read-only "check" command: `check` applies
  updates immediately.

## Install Command Flags

```bash
npx skills@<reviewed-version> add /absolute/path/to/reviewed-checkout --skill <skill> -g --agent <authorized-agent> --copy -y
```

- Repeat `--agent <authorized-agent>` only for each explicitly approved
  target.
- Use `-g` only for an approved user-level install; omit it for
  project-local scope.
- `--copy` avoids the CLI's shared canonical-symlink path, and `-y` skips
  prompts without broadening the explicit agent list.

## Post-Install Verification

Before activation, compare every installed copy with the reviewed checkout
or recorded hash. If any byte differs, do not activate or delete it silently;
preserve the evidence, report the mismatch, and request cleanup authority.

The CLI also offers `init` for scaffolding a new skill. Scaffold only when
the user has authorized creation, and finish the package under the local
skill-authoring workflow rather than trusting the scaffold as complete.
