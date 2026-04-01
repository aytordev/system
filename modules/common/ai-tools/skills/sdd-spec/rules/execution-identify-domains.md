## Identify Domains from Proposal

**Impact: CRITICAL**

Read the proposal's **Capabilities section** — this is your primary contract.

### Primary: Capabilities Section

```
FOR EACH entry under "New Capabilities":
├── This becomes a NEW full spec (not a delta)
└── Domain name = the capability kebab-case name

FOR EACH entry under "Modified Capabilities":
├── This becomes a DELTA spec
├── Read existing spec for that capability first
└── Your delta modifies the existing spec
```

### Fallback: Affected Areas

If the proposal has no Capabilities section (older format), fall back to inferring from "Affected Areas":
1. Read the proposal's "Affected Areas" section
2. Group related changes by logical domain
3. Each domain should be cohesive (changes that belong together)
4. Prefer 2-5 domains per change

Always prefer the explicit Capabilities mapping when present.

### Output

Produce a list of domains with their type:

```
Domains identified:
- user-auth (NEW — from New Capabilities)
- session-management (MODIFIED — from Modified Capabilities)
```
