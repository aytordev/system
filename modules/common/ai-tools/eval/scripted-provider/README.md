# Scripted-provider evaluation (T16)

Deterministic, bounded, no-paid-call evaluation of the real OpenCode and Pi
command/delegation/transport paths. A loopback **OpenAI-compatible** fixture
answers every model request with a fixed `aytordev.sdd-result/v1` envelope, so
the harness proves the clients actually reached a provider and forwarded the
expected input, without depending on a live model.

Evidence record: [verification-report.md](../../../../../docs/ai-tools/verification-report.md).

## What it proves

| Scenario | Path exercised |
| --- | --- |
| `pi-direct` | real `pi --print --mode json` → custom `openai-completions` provider → fixture → scripted envelope in stdout |
| `pi-workflow-delegation` | real Pi SDD workflow extension `BoundedWorkers.dispatch` → real `pi` child worker (`--sdd-role`, injected phase envelope) → fixture → parsed envelope |
| `opencode-direct` | real `opencode run -m scripted/scripted-model` → custom `@ai-sdk/openai-compatible` provider → fixture → scripted envelope in stdout |

The fixture logs every request body it receives; each scenario asserts that its
own request arrived and carried the expected prompt (`Reply with the scripted
envelope.` or `# SDD phase: sdd-design`).

## Run

Requires Node ≥ 22.18 (TypeScript type-stripping, used to import the real
workflow module) and `pi` / `opencode` on `PATH` or via `PI_BIN` /
`OPENCODE_BIN`.

```sh
node modules/common/ai-tools/eval/scripted-provider/run.mjs --out /tmp/scripted-provider.json
```

Success prints `SCRIPTED-PROVIDER OK` and exits 0.

## Why this is not a `nix flake check`

The aarch64-darwin Nix build sandbox (`sandbox = relaxed`) denies binding a
loopback socket. The fixture cannot start inside a derivation:

```text
Error: listen EPERM: operation not permitted 127.0.0.1
  code: 'EPERM', syscall: 'listen'
```

So this stays a developer/evaluation harness. The deterministic suite instead
covers the same surfaces without sockets: `integration-ai-tools-pi-workflow`
(adapter dispatch with a fake worker) and `integration-ai-tools-roles` /
`integration-ai-tools-contract` (rendered command/role configuration).
