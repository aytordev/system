# ADR 0005: Separate Verification Levels

Status: Accepted

## Decision

Flake checks use four visible levels:

| Prefix or name | Purpose |
| --- | --- |
| `unit-*` | Pure functions, parsers, policies, and small contracts |
| `integration-*` | Synthetic module and builder compositions |
| `production-*` | Evaluation and build of discovered real homes and systems |
| `package-builds` | Build every package supported by the current platform |

Formatting remains the standard `treefmt` check. CI runs the complete check set
on x86_64 Linux and aarch64 Darwin.

## Consequences

- Failures identify their architectural scope in the check name.
- Synthetic configurations test reuse without pretending to be production.
- Real configurations and package closures remain release gates.
