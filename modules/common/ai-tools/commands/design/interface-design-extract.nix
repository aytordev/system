let
  commandName = "interface-design-extract";
  description = "Extract design patterns from existing code to create a system.md file.";
  allowedTools = "Read, Write, Grep, Glob";
  argumentHint = "[path]";
  prompt = ''
    Extract design patterns from existing code to create a system.

    **Scan UI files (tsx, jsx, vue, svelte, css, scss) for:**

    1. **Repeated spacing values** — Find all spacing values and their frequency
    2. **Repeated radius values** — Identify the radius scale in use
    3. **Button patterns** — Heights, padding, radius, font size across all buttons
    4. **Card patterns** — Border, padding, radius, shadow across all cards
    5. **Depth strategy** — Count box-shadow vs border usage to determine approach
    6. **Color values** — Extract all unique colors and group by usage

    **Then prompt the user:**

    ```
    Extracted patterns:

    Spacing:
      Base: Xpx
      Scale: [values]

    Depth: [strategy] (N borders, N shadows)

    Patterns:
      Button: [height, padding, radius]
      Card: [border, padding]

    Create .interface-design/system.md with these? (y/n/customize)
    ```

    **Implementation:**
    1. Glob for UI files
    2. Read and parse for repeated values
    3. Identify common patterns by frequency
    4. Suggest system based on most common values
    5. Offer to create `.interface-design/system.md`
    6. Let user customize before saving
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
