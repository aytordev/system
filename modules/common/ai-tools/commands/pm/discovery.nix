let
  commandName = "discovery";
  description = "Run a structured product discovery process";
  allowedTools = "Read, Write, Grep, Glob";
  argumentHint = "[problem space or product area]";
  prompt = ''
    Run a structured discovery process using the product-management skill frameworks.

    ## Process

    1. Read the discovery process reference at `~/.claude/skills/community/product-management/references/discovery-process-full.md`
    2. Follow the facilitation protocol from `~/.claude/skills/community/product-management/references/workshop-facilitation-full.md`
    3. Guide through 4 phases:
       - **Frame**: Define the problem space, assumptions, and what we know vs. don't know
       - **Research**: Plan interview questions (Mom Test style), identify target segments
       - **Synthesize**: Organize findings into themes, identify patterns and opportunities
       - **Validate**: Define experiments to test key assumptions

    ## Interaction Style

    Use the workshop facilitation protocol:
    - Give a session heads-up at the start
    - Ask one question at a time with numbered options
    - Show progress labels [N/Total]
    - Present numbered recommendations at decision points

    ## Output

    Produce a discovery brief document with:
    - Problem statement (5-part format)
    - Key assumptions to validate
    - Research plan with interview guide
    - Synthesis of findings (if research data is available)
    - Recommended validation experiments (PoL probes)
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
