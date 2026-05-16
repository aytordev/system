# Feature Request Template

Template: `.github/ISSUE_TEMPLATE/feature_request.yml`
Auto-labels: `enhancement`, `status:needs-review`

## Required Fields

| Field | Description |
|-------|-------------|
| **Pre-flight Checks** | No duplicate + understands approval workflow |
| **Problem Description** | The pain point this feature solves |
| **Proposed Solution** | How it should work from the user's perspective |
| **Affected Area** | Scripts, Skills, Examples, Documentation, CI/Workflows, Other |

## Optional Fields

| Field | Description |
|-------|-------------|
| **Alternatives Considered** | Other approaches or workarounds |
| **Additional Context** | Mockups, examples, references |

## CLI Example

```bash
gh issue create --template "feature_request.yml" \
  --title "feat(scripts): add Codex support to setup.sh" \
  --body "
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Problem Description
The setup script only configures Claude Code, Gemini CLI, and OpenCode.
Codex users have to manually copy skills.

### Proposed Solution
Add a Codex option to setup.sh that links skills to the .codex/ directory.

Example:
\`\`\`bash
./scripts/setup.sh --agent codex
\`\`\`

### Affected Area
Scripts (setup, installation)

### Alternatives Considered
Manually symlinking, but that defeats the purpose of the setup script.
"
```
