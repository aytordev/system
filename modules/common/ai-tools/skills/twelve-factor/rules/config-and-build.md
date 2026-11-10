---
title: Codebase, Config, and Build Stages
impact: CRITICAL
impactDescription: Factors I, III, and V keep deploys identical and config out of the build
tags: twelve-factor, config, build
---

## Codebase, Config, and Build Stages

**Impact: CRITICAL**

### Codebase (Factor I)

One codebase tracked in revision control, many deploys. A codebase can be a
repository or a clearly owned part of a monorepo; do not split repositories
merely to satisfy the label. Share code through an explicit owned package or
module rather than copy-paste. In a monorepo, each service should have its own
entry point, its own deploy pipeline, and its own set of backing-service
connections — a single repo is fine as long as each service deploys
independently.

### Config (Factor III)

Store deploy-varying configuration outside the build. Environment variables are
the Twelve-Factor default; use an equivalent platform-native secret or
configuration injection mechanism when the runtime requires it. Never hardcode
credentials or environment-specific endpoints.

**Rules:**

- Validate config at startup with a schema — fail fast (exit non-zero, clear
  error) if config is invalid.
- Inject config via options objects — never import `process.env` deep in the
  call tree.
- When you introduce or change a config module, move **every** `process.env`
  read in the application into it in the same change — including settings the
  reported problem never named, such as a log level, an output path, or a
  feature toggle. A config module that leaves other env reads scattered through
  request handlers, domain modules and start-up code has relocated the drift,
  not removed it. Finish by grepping the source for `process.env` and
  confirming the only hits are the config module and the process entry points
  that call it.
- Document required configuration for the operator, not only in code. Where
  environment variables are the configuration interface, write or update
  `.env.example` in the **same** change as the schema: one line per setting the
  schema requires, placeholder values only, never a real credential, and never
  a committed `.env`. A validation schema tells the process what is wrong at
  boot; it does not tell a person what to put on the container — ship both.
  Where the platform's own manifest or secret-declaration format is the
  configuration interface, update that instead, by the same rule.

**Config anti-patterns:**

```typescript
const DB_HOST = 'prod-db.internal.example.com';

if (process.env.NODE_ENV === 'production') {
  connectTo('prod-db');
} else {
  connectTo('localhost');
}

const config = require(`./config.${process.env.NODE_ENV}.json`);
```

**Why these are wrong:** Config that varies by deploy belongs outside source
and build artifacts, supplied through the runtime's supported injection
mechanism. Environment-name branching creates combinatorial explosion and
breaks dev/prod parity.

**The fix:** name the thing the branch was actually deciding and make it its
own validated setting — `SECURE_COOKIES=true`, `DATABASE_URL=...` — then delete
the branch. Remove every environment-name comparison in the files you touch,
not only the ones covering the settings you were asked about: two deploys given
identical settings must behave identically, and one surviving `NODE_ENV`
comparison is exactly what breaks that. Flagging such a branch in your summary
instead of removing it leaves the drift in place — fix it, then say you did.

### Build, Release, Run (Factor V)

Strictly separate build and run stages. Config is injected at release/run time,
never baked into the build.

- Prefer the same build artifact across environments.
- Inject deploy-varying config at release/run time. Compile-time configuration
  is a different contract and may be necessary for static frontends.
- Releases are immutable — code changes require a new build, not runtime
  patching.
