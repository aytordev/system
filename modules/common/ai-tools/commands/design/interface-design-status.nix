let
  commandName = "interface-design-status";
  description = "Show current design system state including direction, tokens, and patterns.";
  allowedTools = "Read, Glob";
  argumentHint = "";
  prompt = ''
    Show current design system state.

    **If `.interface-design/system.md` exists:**

    Display:
    ```
    Design System: [Project Name]

    Direction: [Precision & Density / Warmth / etc]
    Foundation: [Cool slate / Warm stone / etc]
    Depth: [Borders-only / Subtle shadows / Layered]

    Tokens:
    - Spacing base: Xpx
    - Radius scale: values
    - Colors: [count] defined

    Patterns:
    - Button Primary (height, padding, radius)
    - Card Default (border, padding)
    - [other patterns...]

    Last updated: [date]
    ```

    **If no system.md:**

    ```
    No design system found.

    Options:
    1. Build UI with /interface-design:init → system will be established automatically
    2. Run /interface-design:extract → pull patterns from existing code
    ```

    Read `.interface-design/system.md`, parse direction, tokens, and patterns, and format the output.
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
