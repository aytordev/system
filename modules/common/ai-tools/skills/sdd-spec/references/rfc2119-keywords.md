# RFC 2119 Keyword Reference

RFC 2119 defines keywords for requirement strength in specifications.

## Keyword Meanings

| Keyword | Meaning |
|---------|---------|
| MUST / SHALL | Absolute requirement — non-negotiable |
| MUST NOT / SHALL NOT | Absolute prohibition — cannot be done |
| SHOULD | Recommended but not required — may ignore with justification |
| SHOULD NOT | Not recommended — may do with justification |
| MAY | Truly optional — implementation choice |

## Usage Examples

**Absolute requirement:**
```markdown
The system MUST validate user credentials before granting access.
```

**Absolute prohibition:**
```markdown
The system MUST NOT store passwords in plain text.
```

**Recommendation:**
```markdown
The system SHOULD log failed authentication attempts.
```

**Optional:**
```markdown
The system MAY provide a "remember me" option.
```

## Why Use RFC 2119?

- **Clarity**: No ambiguity about requirement strength
- **Testability**: Clear pass/fail criteria
- **Prioritization**: Easy to distinguish critical vs nice-to-have
- **Review**: Easier to spot missing requirements

Reference: [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt)
