---
name: comment-writer
description: "Write warm, direct collaboration comments. Trigger: PR feedback, issue replies, reviews, Slack messages, or GitHub comments."
---

## When to Use

Load this skill whenever you write a comment that another human will read:

- GitHub PR or issue comments
- Review feedback and requested changes
- Maintainer replies
- Slack, Discord, or async project updates

## Voice Rules

| Rule | Requirement |
|------|-------------|
| Be useful fast | Start with the actionable point. Do not recap the whole PR before feedback. |
| Be warm and direct | Sound like a thoughtful teammate, not a corporate bot. |
| Keep it short | Prefer 1 to 3 short paragraphs or a tight bullet list. |
| Explain why | Give the technical reason when asking for a change. |
| Avoid pile-ons | Comment on the highest-value issue, not every tiny preference. |
| Match thread language | Write in the thread/user language. If writing in Spanish, use Rioplatense Spanish/voseo: `podés`, `tenés`, `fijate`, `dale`. |
| No em dashes | Use commas, periods, or parentheses instead. |

## Comment Formula

```text
<Direct observation or request>

<Why it matters, only if needed>

<Concrete next action>
```

## Commands

```bash
gh pr view <PR_NUMBER> --json title,body,additions,deletions,changedFiles
```

## References

- [references/examples.md](references/examples.md) — request change, approval, and split examples
