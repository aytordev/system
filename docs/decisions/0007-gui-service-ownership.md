# ADR 0007: Give GUI Services One Owner

Status: Accepted

## Decision

Home Manager owns user GUI service lifecycle through its generated launchd or
systemd units. A window manager may send events to another service, but must not
start a second instance during its own startup.

System modules own only services that require system privileges. Suites enable
the chosen owner; they do not add alternate startup paths.

For Sketchybar, Home Manager owns the LaunchAgent and AeroSpace only sends
workspace, focus, and mode events.

## Consequences

- Login produces one service instance.
- Restart and failure behavior has one authoritative unit.
- Window-manager restarts do not duplicate unrelated GUI services.
