let
  commandName = "interface-design-critique";
  description = "Critique your build for craft, then rebuild what defaulted.";
  allowedTools = "Read, Write, Edit, Grep, Glob";
  argumentHint = "[path]";
  prompt = ''
    Critique your build for craft, then rebuild what defaulted.

    Read the critique protocol from `~/.claude/skills/community/interface-design/references/critique.md`.

    **Process:**

    1. Open the file you just built
    2. Walk through each critique area:
       - **Composition** — Does the layout have rhythm? Are proportions doing work? Is there a focal point?
       - **Craft** — Is spacing on the grid? Is typography hierarchy multi-dimensional? Do surfaces whisper hierarchy? Do interactive elements have states?
       - **Content** — Does the screen tell one coherent story? Is content realistic?
       - **Structure** — Are there CSS hacks? Negative margins? Calc workarounds? Absolute positioning escapes?
    3. Identify every place you defaulted instead of decided
    4. Rebuild those parts — from the decision, not from a patch
    5. Do not narrate the critique to the user — do the work, show the result

    **The test:** Ask "If they said this lacks craft, what would they point to?" Fix that thing. Then ask again.
  '';
in {
  ${commandName} = {
    inherit
      commandName
      description
      allowedTools
      argumentHint
      prompt
      ;
  };
}
