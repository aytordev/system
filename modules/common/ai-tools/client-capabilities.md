# Client Capabilities: OpenCode and Pi

Task T01 evidence for [ADR 0015](../../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md)
and the [implementation plan](implementation-plan.md). This file records what the
**shipped, pinned** clients can actually do. It is not a wish list and not a
statement that this repository already projects every capability.

Local baseline revision: `3752d5c43840671467487e9805ef867c2816f5b8`.

## 1. Pinned versions

| Client | Version | Source of truth |
| --- | --- | --- |
| OpenCode | 1.18.30 | `pkgs.opencode.version` from nixpkgs `/nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source`; package expression `pkgs/by-name/op/opencode/package.nix`; realized output `/nix/store/r2i721jwxnnz76im5p0cx6d3gaj1fdrg-opencode-1.18.30` |
| Pi (`pi-coding-agent`) | 0.85.1 | `pkgs.pi-coding-agent.version` from the same nixpkgs path; package expression `pkgs/by-name/pi/pi-coding-agent/package.nix`; nixpkgs eval build `/nix/store/f4ysgsnclgz9qjfiinjb7lgiammgwff9-pi-coding-agent-0.85.1`; profile-resolved on this host `/nix/store/k666ghkkwxbvvzfw67ix6hmvyhsn6ll0-pi-coding-agent-0.85.1` |
| Home Manager OpenCode module (option authority) | pinned flake input | `nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.home-manager.outPath'` -> `/nix/store/1rcg4bnfbagmgzx5qlzy8ypc9m271mxr-source`; file `modules/programs/opencode.nix` |

The OpenCode binary is Bun-compiled, so its JavaScript is embedded as a string
table. Extracted snippets below are from that shipped binary, not from a blog
post or from current web documentation. The Pi package ships its real `dist/`
JavaScript and `docs/`, so Pi statements cite the shipped paths.

## 2. Capability matrix

`Status` is the aggregate across both clients (weakest link). Per-client columns
carry the per-client verdict.

| Capability | OpenCode | Pi | Status | Evidence |
| --- | --- | --- | --- | --- |
| Named-argument expansion | supported | supported | supported | OC-E1, OC-E10, PI-E2, PI-E3, PI-E11 |
| Per-agent model override | supported | unsupported | partial | OC-E2, PI-E4 |
| Subagent delegation (caller picks the subagent) | supported | unsupported | partial | OC-E3, PI-E1 |
| Delegation with async/background | partial | unsupported | partial | OC-E3, OC-E4, PI-E1 |
| Cancellation | supported | supported | supported | OC-E5, PI-E5 |
| Permission enforcement: file | supported | unverified | partial | OC-E6, PI-E7 |
| Permission enforcement: shell | supported | unverified | partial | OC-E6, PI-E7 |
| Permission enforcement: MCP | partial | unsupported | partial | OC-E6, PI-E1, PI-E8 |
| MCP server connection | supported | unsupported | partial | OC-E7, PI-E1, PI-E8 |
| Skill discovery | supported | supported | supported | OC-E8, PI-E9 |
| Session recovery | supported | supported | supported | OC-E9, PI-E10 |

## 3. Evidence

Evidence IDs are keyed to the matrix rows above.

### Verified against pinned OpenCode 1.18.30 (source: shipped binary and schema)

- **OC-E1 - command argument expansion (supported).** In the shipped binary,
  `SessionPrompt.command`:
  - resolves positional arguments with the regex `/\$(\d+)/g` and strips quotes
    from each matched argument;
  - detects `$ARGUMENTS` (`C.includes("$ARGUMENTS")`) and replaces it with the
    full argument string;
  - executes shell substitutions `` !`...` `` through the regex
    `/!`([^`]+)`/g`;
  - when the template has no positional placeholder and no `$ARGUMENTS` and the
    user supplied arguments, it appends the raw argument string on a new line.
  Command: `rg -a -U -o '(?s).{200}\$ARGUMENTS.{300}' <binary>`.
- **OC-E10 - current OpenCode command projection drops argument syntax
  (defect, not a capability gap).** Deployed
  `~/.config/opencode/commands/sdd-apply.md` body still contains the literal
  string `{argument}`. `modules/common/ai-tools/commands.nix:50-61` renders only
  `description` and `agent` frontmatter and emits the `prompt` body unchanged
  (it also drops `allowedTools` and `argumentHint`). OpenCode does not expand
  `{argument}`. This is F3.
- **OC-E2 - per-agent model override (supported).** `share/config.json`
  `$defs.AgentConfig.properties.model` is a Model reference, and the effective
  `~/.config/opencode/opencode.json` sets
  `agent.sdd-orchestrator.model = "anthropic/claude-sonnet-4-6"`. The binary's
  `SessionPrompt.createUserMessage` selects `t.model ?? U.model ?? default`
  where `U` is the resolved agent. Command config also supports a `model`
  (`$defs.Config.properties.command.*.model`).
- **OC-E3 - subagent delegation (supported).** The Task tool input struct in the
  binary is
  `{ description, prompt, subagent_type, task_id?, background? }`
  (extraction: `description:p.String.annotate({description:"A short (3-5 words)
  description of the task"...`, `subagent_type:p.String.annotate(...)`,
  `task_id:p.optional(p.String)`, `background:p.optional(p.Boolean)`).
  `handleSubtask` resolves the agent with `l.get(O.agent)`, executes it with
  `bypassAgentCheck:!0`, and `task_id` resumes a prior subagent session. The
  built-in agents include `general` (subagent) and `plan`
  (`name:"general",description:"General-purpose agent for researching complex
  questions and executing multi-step tasks..."`). `$defs.Config.properties.subagent_depth`
  defaults to 1, which prevents nested subagents.
- **OC-E4 - async/background delegation (partial).** The Task tool has a
  `background` boolean whose description reads "Run the agent in the background.
  You will be notified when it completes." The same binary strings include
  `Background mode: background=true launches the subagent asynchronously and
  returns immediately` and
  `Background subagents require OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true`.
  So the path exists but is disabled unless that experimental environment
  variable is set.
- **OC-E5 - cancellation (supported).** `handleSubtask` allocates an
  `AbortController`, passes `abort: L.signal` to the child execution, and on
  interrupt calls `L.abort()` and writes tool state `error:"Cancelled"`.
- **OC-E6 - permission enforcement (file/shell supported, MCP partial).**
  `$defs.PermissionConfig` enumerates `read`, `edit`, `glob`, `grep`, `list`,
  `bash`, `task`, `external_directory`, `webfetch`, `websearch`, `lsp`,
  `skill`, and arbitrary additional tool keys. The binary calls a blocking
  permission service at tool execution:
  `.ask({permission:"edit",patterns:[...]})`,
  `.ask({permission:"bash",patterns:[...]})`, `permission:"glob"`,
  `permission:"grep"`, `permission:"external_directory"`, `permission:"lsp"`,
  `permission:"doom_loop"`. For MCP it gates resource reads with
  `permission:"read", metadata:{server:...}` and filters MCP tools through the
  merged ruleset in `SystemPrompt.mcp` (`de.merge(i.permission,h??[])` and a
  disabled-tool path). MCP tool calls that are not resources were not traced to a
  dedicated `mcp` permission key, hence partial.
- **OC-E7 - MCP server connection (supported).** Schema
  `$defs.McpLocalConfig` (`type`, `command`, `cwd`, `environment`, `enabled`,
  `timeout`) and `$defs.McpRemoteConfig` (`type`, `url`, `headers`, `oauth`,
  `enabled`, `timeout`); top-level `$defs.Config.properties.mcp`. The current
  effective `~/.config/opencode/opencode.json` has only `github` and `socket`,
  both `enabled: false`, consistent with F1.
- **OC-E8 - skill discovery (supported).** The binary contains the doc strings
  `~/.config/opencode/skill(s)/<name>/SKILL.md` (global) and
  `.opencode/skill(s)/<name>/SKILL.md` (project); both singular and plural
  directory names are accepted. Schema `$defs.Config.properties.skills` supports
  `paths` and `urls`. The pinned Home Manager module writes
  `opencode/skills` (`modules/programs/opencode.nix:580-583`), which the
  `skill(s)` form matches.
- **OC-E9 - session recovery (supported).** `opencode --help` lists
  `-c, --continue`, `-s, --session <id>`, `--fork`, `opencode session`,
  `opencode export [sessionID]`, and `opencode import <file>`.

### Verified against pinned Pi 0.85.1 (source: shipped package `dist/` and `docs/`)

- **PI-E1 - no built-in MCP, subagents, permissions, or background (unsupported).**
  `docs/usage.md:309`: "It intentionally does not include built-in MCP,
  sub-agents, permission popups, plan mode, to-dos, or background bash. You can
  build or install those workflows as extensions or packages...".
  `docs/security.md:33`: "Pi does not include a built-in sandbox. Built-in tools
  can read files, write files, edit files, and run shell commands with the
  permissions of the pi process."
- **PI-E2 - prompt-template argument expansion (supported).**
  `docs/prompt-templates.md:65-83` documents `$1`, `$2`, `$@`/`$ARGUMENTS`,
  `${1:-default}`, `${@:-default}`, `${@:N}`, and `${@:N:L}`.
  `argument-hint` frontmatter is autocomplete-only (`docs/prompt-templates.md:33-42`).
- **PI-E3 - extension command arguments (supported).** Extension commands receive
  the raw argument string: `handler: async (args, ctx)` in `docs/extensions.md`
  (registerCommand section, around line 1627). This is not positional expansion;
  positional expansion applies to prompt templates (PI-E2).
- **PI-E4 - no per-agent model override (unsupported).** Pi has no agent
  concept. Model selection is session-level: `setModel(model)` in
  `dist/core/extensions/types.d.ts:1006`, documented at
  `docs/extensions.md:1704-1720`, plus `defaultProvider`/`defaultModel` settings
  (`docs/settings.md:26-33`). A future adapter could set a child session's model
  programmatically, but there is no per-agent configuration field today.
- **PI-E5 - cancellation (supported).** `docs/usage.md:69`: Escape aborts and
  restores queued messages. `docs/extensions.md:1044` exposes
  `ctx.isIdle()`, `ctx.abort()`, and `ctx.hasPendingMessages()`;
  `docs/extensions.md:1019-1029` exposes `ctx.signal` for abort-aware work; and
  `ctx.shutdown()` requests graceful shutdown.
- **PI-E7 - permission enforcement is unverified.** Pi exposes a blocking hook
  (`tool_call` can return `{ block: true, reason, terminate }`,
  `docs/extensions.md:780,792`), but the deployed enforcement is the third-party
  `@gotgenes/pi-permission-system@29.1.0`. `modules/home/programs/terminal/tools/pi/default.nix:181-182`
  adds the package and lines 412-414 write its config; the effective
  `~/.pi/agent/settings.json` lists it, and
  `~/.pi/agent/extensions/pi-permission-system/config.json` is present with
  deny rules. However the package code is not provisioned by Nix
  (`~/.pi/agent/npm/` does not exist), so its actual blocking behavior could not
  be read or exercised. `unverified` is deliberate.
- **PI-E8 - MCP connection (unsupported).** `README.md:499`: "**No MCP.** Build
  CLI tools with READMEs ... or build an extension that adds MCP support."
- **PI-E9 - skill discovery (supported).** `docs/skills.md:20-36` lists global
  `~/.pi/agent/skills/`, `~/.agents/skills/`, project `.pi/skills/` and
  `.agents/skills/`, plus settings and CLI paths; `docs/skills.md:72` describes
  progressive disclosure. The effective `~/.pi/agent/settings.json` has
  `skills: ["/Users/avicente/.pi/agent/skills"]`; `pi/default.nix:408-410`
  symlinks the shared skills tree there.
- **PI-E10 - session recovery (supported).** `docs/sessions.md:5-7` (auto-saved
  JSONL per working directory), `-c`, `-r`, `--session`, `--fork`, `/resume`,
  `/tree`, `/compact`; `pi.appendEntry()` persists extension state.
- **PI-E11 - no Pi command or agent projection (deployment gap).**
  `modules/common/ai-tools/default.nix:5-9` exports only an `opencode` attrset.
  `modules/home/programs/terminal/tools/pi/default.nix` deploys `AGENTS.md` and
  `skills` but no command or agent files. The OpenCode command markdown therefore
  has no Pi equivalent today.

### Documentation-only references (version-agnostic, not the pin)

These were not used to establish any status; the pinned sources above did. They
are listed because the plan names them.

- OpenCode command arguments: <https://opencode.ai/docs/commands/#arguments>
  (version-agnostic documentation).
- OpenCode agents and models: <https://opencode.ai/docs/agents/>
  (version-agnostic documentation).
- OpenCode Task tool upstream source (the ADR links the moving `dev` branch):
  <https://github.com/anomalyco/opencode/blob/dev/packages/opencode/src/tool/task.ts>
  (version-agnostic relative to the 1.18.30 pin).

## 4. Named blockers

These keep dependent implementation work open. None is replaced by a prompt
assertion.

1. **Pi permission enforcement is unverified.** No built-in sandbox or permission
   popups; the configured enforcement is a runtime-installed third-party npm
   extension that Nix does not provision and that could not be executed. T10 must
   not assume Pi blocks unauthorized file or shell writes.
2. **Pi has no native subagent delegation, async/background delegation, or MCP.**
   T05 and T07 must implement these through supported extension APIs
   (`pi.registerTool`, `pi.registerCommand`, `pi.setModel`, `pi.exec`,
   `pi.appendEntry`) and local code; they cannot be claimed from prompt text.
3. **Pi has no per-agent model concept.** T04's role/model routing needs a
   session-level adapter (`pi.setModel`), not an agent-config field.
4. **Pi receives no commands or agents from `ai-tools`.** Only `AGENTS.md` and
   `skills` are projected today. T05 must add Pi command entry points; the
   existing `{argument}` markdown cannot be reused as-is.
5. **OpenCode background delegation is experimental and off by default.** It
   requires `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true`. T05/T10 must not
   depend on it without an explicit decision.
6. **OpenCode command projection is currently broken for arguments.** Templates
   use `{argument}`, which the shipped client does not substitute; `allowedTools`
   and `argumentHint` are dropped. T03 must convert to `$ARGUMENTS`/`$N` and
   project the remaining fields.
7. **OpenCode MCP tool-call permission is only partially traced.** Resource reads
   and tool filtering are gated; arbitrary MCP tool calls were not traced to a
   dedicated key. T07/T10 must verify MCP permission outcomes with a fixture
   rather than assuming.
8. **Neither home enables OpenCode MCP integration.** The pinned Home Manager
   module only projects `programs.mcp.servers` when
   `programs.opencode.enableMcpIntegration` is true
   (`modules/programs/opencode.nix:44-58`); F1 records it as false. T06 owns this.

## 5. T10: role permission intent and enforcement boundaries

Task T10 evidence. Role permission **intent** lives in `roles.nix`; each client
projects it onto whatever it can actually enforce. The shared intent is not a
claim that both clients enforce it.

| Role | Intent (`roles.nix`) | OpenCode projection | Pi projection |
| --- | --- | --- | --- |
| `sdd-orchestrator` | `edit: ask`, `bash: ask` | agent-level `permission` (blocking `ask`) | n/a (orchestration is the session) |
| `sdd-standard` | inherit global (`edit: ask`, shell map) | global `edit: ask` + shell map | global deny rules only |
| `sdd-design` / `sdd-archive` | inherit global | global `edit: ask` + shell map | global deny rules only |
| `sdd-review` | `edit: deny`, `bash: deny` | agent-level deny (hard read-only) | prompt-level read-only only (unverified) |

### OpenCode (verified against the 1.18.30 binary and source)

- Permission is enforced at tool execution (OC-E6): a matching `deny` aborts the
  tool call; `ask` blocks on the user. The effective ruleset is
  `defaults ++ global ++ agent-specific`, evaluated with `findLast`
  (`@opencode-ai/core/util/wildcard`), so the **last** matching rule wins.
- The built-in `defaults` include a catch-all `{permission:"*"; pattern:"*";
  action:"allow"}`, so **unmatched shell commands are allowed**. The global
  `bash` map only gates the patterns it lists; it is a convenience filter, not a
  sandbox.
- Home Manager serializes the `bash` attrset with `builtins.toJSON` (sorted
  keys), so `*` catch-all rules sort before the `-`-prefixed specific read-only
  forms. A broad `allow` (e.g. `git branch*`) would match mutating subcommands
  and win; T10 removed those and added per-subcommand `ask` catch-all rules plus
  specific read-only `allow` forms (`checks/ai-tools-permissions`).
- **`edit: deny` does not constrain shell writes.** A read-only role must also
  deny `bash` (or the writable patterns), which is why `sdd-review` denies both.
- MCP: resource reads are gated through `read` (global `read = "allow"`).
  Arbitrary MCP tool calls are filtered by tool name against the merged
  ruleset; no dedicated `mcp` key was traced (blocker 7), so an MCP tool call
  is not guaranteed read-only for a reviewer.

### Pi (unverified — blocker 1)

- Pi has no built-in permission system (PI-E1). The configured gate is the
  third-party `@gotgenes/pi-permission-system`, whose code Nix does not
  provision and which could not be executed. Its rules are deny-only with a
  fallback `allow`, and were only asserted, never exercised.
- Therefore Pi **cannot** enforce a read-only judge, a per-role boundary, or an
  MCP boundary. `sdd-review` on Pi is advisory: the T05 adapter passes a
  read-only write policy and a denied `bash`, but a determined child can still
  write. Treat a Pi judge write as a policy violation to report, not a blocked
  action. Pi MCP is unsupported (PI-E8).
- Residual risk: any T10 enforcement claim beyond OpenCode is a configuration
  claim plus an explicitly named blocker, not a tested guarantee.

### Independent review in each client

`judgment-day` uses the client's native parallel primitive — no `delegate`
primitive is assumed (F6):

- **OpenCode**: two `Task` calls in one turn, `subagent_type: sdd-review`
  (`edit`/`bash` denied) with `background: false`; distinct child sessions; both
  must finish before synthesis.
- **Pi**: the T05 adapter's `judgment-day` command dispatches two bounded child
  workers with distinct native session ids; one failing judge is recorded
  without suppressing the other, and synthesis is refused on an incomplete
  verdict. Proofs: `checks/ai-tools-pi-workflow` and
  `checks/ai-tools-permissions`.

## 6. Verification log

Commands run for this file and their observed result.

- `nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.home-manager.outPath'`
  -> `/nix/store/1rcg4bnfbagmgzx5qlzy8ypc9m271mxr-source`.
- `nix eval --impure --raw --expr 'let pkgs = import /nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source { system = "aarch64-darwin"; }; in pkgs.opencode.version'`
  -> `1.18.30`.
- `nix eval --impure --raw --expr 'let pkgs = import /nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source { system = "aarch64-darwin"; }; in pkgs.pi-coding-agent.version'`
  -> `0.85.1`.
- `opencode --version` -> `1.18.30`; `pi --version` -> `0.85.1`.
- `readlink -f /etc/profiles/per-user/avicente/bin/opencode` ->
  `/nix/store/r2i721jwxnnz76im5p0cx6d3gaj1fdrg-opencode-1.18.30/bin/opencode`.
- `readlink -f /etc/profiles/per-user/avicente/bin/pi` ->
  `/nix/store/k666ghkkwxbvvzfw67ix6hmvyhsn6ll0-pi-coding-agent-0.85.1/bin/pi`.
- `jq '."$defs".AgentConfig' /nix/store/r2i721.../share/config.json` -> includes
  `model`, `mode`, `permission`, `steps`.
- `jq '."$defs".PermissionConfig' .../share/config.json` -> enumerated permission
  keys.
- `jq '."$defs".McpLocalConfig' .../share/config.json` and `McpRemoteConfig` ->
  local/remote server shapes.
- `jq '."$defs".Config.properties.command' .../share/config.json` -> command
  `template`, `agent`, `model`, `variant`, `subtask`.
- `rg -a -U -o '(?s).{200}\$ARGUMENTS.{300}' <opencode binary>` -> argument
  resolution implementation.
- `rg -a -U -o '(?s)subagent_type:p\.String\.annotate.{0,1200}' <opencode binary>`
  and `rg -a -o 'background:p\.optional(p\.Boolean).annotate(...)' <binary>` ->
  Task tool parameters; no `model` parameter present.
- `rg -a -o 'Background subagents require OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true' <binary>`
  and the matching background-mode description -> experimental gate confirmed.
- `rg -a -U -o '(?s)/.ask\(\{permission:[a-zA-Z_.]{1,30}' <binary>` -> permission
  kinds `edit`, `bash`, `glob`, `grep`, `read`, `external_directory`, `lsp`,
  `doom_loop`.
- `cat ~/.config/opencode/commands/sdd-apply.md` -> body contains `{argument}`.
- `cat ~/.config/opencode/opencode.json` -> `agent.sdd-orchestrator` with
  `model`, `permission`, `prompt`, `tools`, and only disabled `mcp` entries.
- `cat ~/.pi/agent/settings.json` -> `packages`
  `["@gotgenes/pi-permission-system@29.1.0"]`, `skills`, `defaultProvider`,
  `defaultModel`.
- `ls ~/.pi/agent/npm/` -> does not exist; permission extension code is not
  provisioned.
- `cat <pi>/docs/usage.md`, `docs/extensions.md`, `docs/skills.md`,
  `docs/sessions.md`, `docs/prompt-templates.md`, `docs/security.md`,
  `README.md`, and `dist/core/extensions/types.d.ts` -> statements and line
  numbers cited above.
- `git status --short` -> this file is the only addition from this task (plus
  pre-existing modified `modules/common/ai-tools/README.md` and pre-existing
  untracked docs).
