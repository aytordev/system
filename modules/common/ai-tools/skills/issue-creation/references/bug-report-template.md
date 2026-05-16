# Bug Report Template

Template: `.github/ISSUE_TEMPLATE/bug_report.yml`
Auto-labels: `bug`, `status:needs-review`

## Required Fields

| Field | Description |
|-------|-------------|
| **Pre-flight Checks** | No duplicate + understands approval workflow |
| **Bug Description** | Clear description of the bug |
| **Steps to Reproduce** | Numbered steps |
| **Expected Behavior** | What should have happened |
| **Actual Behavior** | What happened instead (include errors/logs) |
| **Operating System** | macOS, Linux variants, Windows, WSL |
| **Agent / Client** | Claude Code, OpenCode, Gemini CLI, Cursor, Windsurf, Codex, Other |
| **Shell** | bash, zsh, fish, Other |

## Optional Fields

| Field | Description |
|-------|-------------|
| **Relevant Logs** | Log output (auto-formatted as code block) |
| **Additional Context** | Screenshots, workarounds, extra info |

## CLI Example

```bash
gh issue create --template "bug_report.yml" \
  --title "fix(scripts): setup.sh fails on zsh with glob error" \
  --body "
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
Running setup.sh on zsh throws a glob error when no matching files exist.

### Steps to Reproduce
1. Clone the repo
2. Run \`./scripts/setup.sh\` in zsh
3. See error: \`zsh: no matches found: skills/*\`

### Expected Behavior
The script should handle missing glob matches gracefully.

### Actual Behavior
Script crashes with glob error.

### Operating System
macOS

### Agent / Client
Claude Code

### Shell
zsh

### Relevant Logs
\`\`\`
zsh: no matches found: skills/*
\`\`\`
"
```
