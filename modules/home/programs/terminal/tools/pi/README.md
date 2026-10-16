# Pi theme and GUI environment

## Model profiles

The bundled agent-model profiles are `opensource`,
`openai-subscription-complex`, and `hybrid-nan-openai`. The hybrid profile keeps
nan's DeepSeek/GLM/Qwen routes and uses `openai-codex/gpt-6.1-sol` and
`openai-codex/gpt-6-astra` for ChatGPT/Codex subscription-backed roles, following
the existing subscription profile. It does not configure OpenAI API keys or
perform login; the corresponding provider must already be authenticated in Pi.

Adding a profile does not activate it: `opensource` remains the default.
To select the hybrid profile declaratively, set
`aytordev.programs.terminal.tools.pi.agent-profiles.active = "hybrid-nan-openai"`
and rebuild. `/gentle:profiles` can also select it at runtime; with
`agent-profiles.materialize = true`, the next activation restores the declared
active profile. Set `materialize = false` to leave routing selection to the TUI.

### Role vocabulary

Every profile routes exactly the roles gentle-pi ships: the ten agent
definitions `gentle-ai-explore`, `gentle-ai-verify`, `gentle-ai-worker`,
`jd-fix-agent`, `jd-judge-a`, `jd-judge-b`, `review-readability`,
`review-reliability`, `review-resilience` and `review-risk`, plus the
`orchestrator` keys. The two provider review roles, `review-refuter` and
`review-validator`, are also declared: the review relay reads them from
`models.json` and they never become `subagents.json` entries
(`PROVIDER_REVIEW_ROLES`). No other role belongs in a profile. The retired
`sdd-*` family is not routed: those agents no longer exist, so their entries
were dead configuration.

`checks/gentle-ai-engine` asserts the vocabulary in both directions
(`agentRoleVocabulary`, `agentRoleCoverage`), so a role that is not shipped and
a shipped agent left unrouted both fail `nix flake check`. The routing files are
runtime-owned and the activation merge is additive: removing a role from a
profile stops it being re-asserted but does not delete an existing entry, which
must be cleaned once by hand.

## Theme

Enabling Pi publishes `~/.pi/agent/themes/aytordev.json` from the active
`aytordev.theme` palette. The stable `aytordev` name follows the repository's
generated-theme convention; it contains Sora colors when the global family is
Sora, not an upstream Sora resource. The role structure follows Gentle's themes,
with neutral tool/card surfaces so Gentle Shell does not tint its header,
sidebar and editor green. Success/error indicators and diffs retain their
semantic colors.

Home Manager owns only this theme file, not the themes directory or the native
Gentle themes. Activation inserts `"theme": "aytordev"` only when the key is
absent; existing selections (including `Sora`, `system` or `null`) are preserved.
Malformed settings are reported and left untouched. The mutable `settings.json`
is never linked into the Nix store.

After rebuilding, run `/reload` and select **aytordev** in `/settings` → **Theme**
if you already had a selection. In particular, the standalone `Sora.json` created
before this integration is not removed or silently selected over. Subsequent
rebuilds update the generated colors, not your theme preference. Disabling Pi
removes the managed theme but leaves the selection alone; choose another theme
if you keep running Pi outside Home Manager. Activation is not serialized with
Pi's runtime settings writers: avoid changing settings while rebuilding.

## GUI environment

Publishes Gentle Pi's subagent command override (`GENTLE_PI_AGENTS_PI`) into
the user's GUI login launchd context, so subagents spawned by GUI hosts (e.g.
Pen) can resolve the Nix-installed `pi` executable even though GUI processes do
not inherit the shell profile's PATH.

## Quick path

1. Enable `aytordev.programs.terminal.tools.pi.guiEnvironment.enable` (Pi must
   be enabled; Darwin only; Home Manager launchd must be enabled).
2. Rebuild the home (`just darwin-switch <host>`); user activation/restart is
   still required.
3. Verify the launchd table with `launchctl getenv GENTLE_PI_AGENTS_PI`. This
   proves the launchd environment table entry only: it is NOT proof that any
   GUI process inherited it. Confirm real inheritance only by launching a NEW
   GUI process (or a Gentle Pi subagent) after publication.

## Details

| Topic         | Behavior                                                                                                                                 |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Published     | Only `GENTLE_PI_AGENTS_PI`, pointing at the stable Home Manager profile command `<profileDirectory>/bin/pi` for the configured `package`; never a PATH change or any other variable |
| Scope         | Future GUI processes only; already-running apps (including an open Pen) keep their current environment until relaunched                    |
| Agent         | One-shot user LaunchAgent (`RunAtLoad`, no `KeepAlive`): runs when loaded and at each login                                                |
| Repair        | Every activation while enabled re-runs the publisher, so a lost login environment or a failed agent run is repaired without waiting        |
| State         | The successfully published value is tracked privately (0700 directory, 0600 files, atomic rename) in `~/.local/state/aytordev/pi-gui-environment/` |
| Updates       | Version-independent by design: the published value does not change when `package` changes, and the in-place profile re-point reaches every later spawn, so a captured override follows an upgrade with no republish. A pre-existing version-pinned managed value is reconciled to the stable command |
| Ownership     | A live value that matches the desired command but has no managed state is never adopted: it may be a same-valued foreign publication       |
| Overrides     | A live value that is neither empty nor the managed value is a foreign override: it is never clobbered or unset, including on package change |
| Serialization | The agent and the activation repair serialize on a bounded lock (see limitations)                                                           |
| Failures      | Failed `launchctl` or state operations keep the retry state, log visible errors, and are retried; a state-record failure after publication triggers a conditional, best-effort compensation that restores the previous live value when feasible — if the outcome cannot be confirmed, the diagnostic says so explicitly |
| Disabling     | On the next activation (after Home Manager's agent removal), the managed value is unset only if the live value still matches it exactly     |

## Limitations

- `launchctl getenv` reads the launchd-managed GUI environment table; it does
  not read the environment of any existing process. GUI apps launched **after**
  publication (or after their next launch) inherit the value; running apps,
  including an open Pen, do not — until relaunched. Terminal shells usually
  resolve `pi` through their profile instead.
- The published command is the profile indirection, not a pinned package
  build, so an upgrade needs neither a republish nor a relaunch to take
  effect: a long-lived GUI host keeps resolving the current `pi`. A host that
  captured an **older version-pinned** publication (from before this behavior)
  must be relaunched once; no publication can rewrite the environment of an
  already-running process.
- The stable command is correct only because the Pi module puts `cfg.package`
  in `home.packages`, making `<profileDirectory>/bin/pi` the configured `pi`.
  A profile path published without that guarantee would be dangling.
- No startup-order guarantee against applications restored at login; restored
  apps may capture the environment before the agent or repair publishes.
- The lock never steals a held or abandoned lock: a run waits briefly (~5s),
  then fails with a diagnostic naming the lock path. If a publisher crashed
  between lock creation and release, remove `~/.local/state/aytordev/pi-gui-environment/lock`
  manually after verifying no publisher is running.
- The exact-match comparison and unset are not atomic against concurrent
  foreign writers.
- Executable paths containing whitespace are rejected loudly: Gentle Pi's
  override parser splits the value on whitespace.
- Live inheritance and Pen launch success are verified only by an authorized
  activation and app restart; these docs make no claim about live Pen results.
- Whole-module removal is not automatic cleanup: the cleanup activation exists
  only while the adapter is not publishing. Remove the opt-in (or disable the
  option/Pi) and rebuild; only then does the next activation unset the managed
  value.
- Lost managed state is not self-healing: if the state file is deleted while a
  value stays published, the adapter treats the live value as unowned (it may
  be a same-valued foreign publication) and never unsets it automatically.
  Recovery is operator action: inspect `launchctl getenv GENTLE_PI_AGENTS_PI`
  and remove the value manually if desired.
