let
  commandName = "interface-design-init";
  description = "Build UI with craft and consistency. For interface design (dashboards, apps, tools) — not marketing sites.";
  allowedTools = "Read, Write, Glob, Grep, Bash(ls*), Bash(mkdir*)";
  argumentHint = "[component] [--direction=precision|warmth|utility]";
  prompt = ''
    Build interface design with craft and consistency.

    **Required Reading — Do This First:**

    Before writing any code, read this file completely:
    `~/.claude/skills/community/interface-design/SKILL.md` — the foundation, principles, craft knowledge, and checks.

    **Scope:** Dashboards, apps, tools, admin panels. Not landing pages or marketing sites.

    **Intent First — Answer Before Building:**

    Before touching code, answer these out loud:
    - **Who is this human?** Not "users." Where are they? What's on their mind?
    - **What must they accomplish?** Not "use the dashboard." The verb.
    - **What should this feel like?** In words that mean something. "Clean" means nothing.

    If you cannot answer these with specifics, stop and ask the user.

    **Before Writing Each Component — State:**

    ```
    Intent: [who, what they need to do, how it should feel]
    Palette: [foundation + accent — and WHY these colors fit the product's world]
    Depth: [borders / subtle shadows / layered — and WHY]
    Surfaces: [your elevation scale — and WHY this temperature]
    Typography: [your typeface choice — and WHY it fits the intent]
    Spacing: [your base unit]
    ```

    **Flow:**
    1. Read the skill files above
    2. Check if `.interface-design/system.md` exists
    3. **If exists**: Apply established patterns from system.md
    4. **If not**: Explore domain, suggest direction, get confirmation, build
    5. After every task, offer to save patterns to `.interface-design/system.md`

    **Communication:** Be invisible. Don't announce modes. Jump into work. Lead with exploration and recommendation, then confirm direction.
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
