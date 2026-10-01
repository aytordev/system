# Pi GUI environment

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
| Published     | Only `GENTLE_PI_AGENTS_PI`, pointing at the absolute `pi` from the configured `package`; never a PATH change or any other variable         |
| Scope         | Future GUI processes only; already-running apps (including an open Pen) keep their current environment until relaunched                    |
| Agent         | One-shot user LaunchAgent (`RunAtLoad`, no `KeepAlive`): runs when loaded and at each login                                                |
| Repair        | Every activation while enabled re-runs the publisher, so a lost login environment or a failed agent run is repaired without waiting        |
| State         | The successfully published value is tracked privately (0700 directory, 0600 files, atomic rename) in `~/.local/state/aytordev/pi-gui-environment/` |
| Updates       | A previously managed value (e.g. after a package change) is reconciled to the new command                                                  |
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
