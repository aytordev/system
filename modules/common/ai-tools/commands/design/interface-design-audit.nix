let
  commandName = "interface-design-audit";
  description = "Check existing code against your design system for spacing, depth, color, and pattern violations.";
  allowedTools = "Read, Grep, Glob";
  argumentHint = "[path] [--spacing] [--depth] [--colors] [--patterns]";
  prompt = ''
    Check existing code against your design system.

    **If `.interface-design/system.md` exists:**

    1. **Spacing violations** — Find spacing values not on the defined grid
    2. **Depth violations** — borders-only system → flag shadows; subtle system → flag layered
    3. **Color violations** — If palette defined → flag colors not in palette
    4. **Pattern drift** — Find components not matching documented patterns

    **Report format:**

    ```
    Audit Results: [path]

    Violations:
      file:line - description (expected → found)

    Suggestions:
      - Fix description
    ```

    **If no system.md:**

    ```
    No design system to audit against.

    Create a system first:
    1. Build UI with /interface-design:init → establish system automatically
    2. Run /interface-design:extract → create system from existing code
    ```

    **Implementation:**
    1. Check for `.interface-design/system.md`
    2. Parse system rules (spacing base, depth strategy, palette, patterns)
    3. Read target files (tsx, jsx, css, scss, vue, svelte)
    4. Compare against rules
    5. Report violations with suggestions
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
