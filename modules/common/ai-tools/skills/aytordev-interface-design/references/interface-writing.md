# Interface Writing

Adapted from the pinned Krehel corpus; pins, license, and corrections:
`provenance.md`. Recon the product's existing copy first: its voice, terms,
and localization conventions outrank generic advice.

- One voice, flexible tone: warm for success and empty states, neutral for
  routine actions, calm and plain for errors and destructive confirmations.
- Address the reader directly; avoid deflection such as "we're having
  trouble" when a direct status and next step exist.
- Plain words over clever ones; no idioms or humor that will not translate.
- Button labels start with a verb naming the specific action. Consequential
  confirmations repeat the consequence ("Delete project"), never bare
  "Yes"/"OK".
- One vocabulary per flow: pick "Continue" or "Next" and keep it.
- Links describe their destination; screen-reader users navigate by link list.
- One capitalization policy per element type; sentence case is the safe
  default.
- Toggle labels describe the ON state ("Send read receipts").
- Errors say how to fix the problem, next to where it broke, without blame:
  "Choose a password with at least 8 characters", not "Invalid name". If the
  same error keeps firing, propose redesigning the interaction instead of
  rewording it.
- Empty states orient and point forward: what this place is, one clear next
  action; search empty states name the query and offer an exit.
- Placeholders show the expected format; a visible label always accompanies
  them.
- Build sentences from full templated strings with proper pluralization; never
  concatenate fragments around variables, because word order changes per
  language.
