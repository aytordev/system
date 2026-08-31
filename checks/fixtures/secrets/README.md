# Secrets Fixture

This directory is a non-sensitive test double for the private `secrets` flake.
It exists only so CI can evaluate production-shaped configurations without
access to the private repository.

## Contract

The fixture must export these non-empty strings:

| Output | Internal field |
| --- | --- |
| `username` | `identity.username` |
| `useremail` | `identity.email` |
| `userfullname` | `identity.fullName` |

`username` remains `aytordev` because configuration discovery uses the
`aytordev@wang-lin` directory name. The email, full name, and all YAML values are
fictional placeholders, not alternate sources of personal data.

Per-user identities live in a `users` map. Each entry exports the same three
non-empty strings for one canonical user (`username`, `useremail`,
`userfullname`). The owner (`aytordev`) may omit a `users` entry because
`identity.fromSecretsFor` falls back to the flat owner fields. These fixtures
must stay in sync with the real `secrets` flake's `users.<username>` entries
used by hosts and homes.

The YAML files must contain every key declared by the production host so
`sops-nix` can validate its activation manifest. They must never contain real
credentials or encrypted production payloads.