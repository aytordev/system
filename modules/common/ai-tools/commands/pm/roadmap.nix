let
  commandName = "roadmap";
  description = "Plan a product roadmap with prioritized initiatives";
  allowedTools = "Read, Write, Grep, Glob";
  argumentHint = "[product or time horizon]";
  prompt = ''
    Plan a product roadmap using the product-management skill frameworks.

    ## Process

    1. Read the roadmap planning reference at `~/.claude/skills/community/product-management/references/roadmap-planning-full.md`
    2. Follow the 5-phase process:
       - **Gather Inputs**: Collect strategic goals, customer feedback, competitive intelligence, technical debt
       - **Define Initiatives**: Frame work as outcome-oriented initiatives, not feature lists
       - **Prioritize**: Apply the appropriate framework (RICE, ICE, etc.) based on context
       - **Sequence**: Organize into Now/Next/Later horizons with capacity allocation
       - **Communicate**: Create a stakeholder-ready roadmap document

    ## Output

    Produce a roadmap document with:
    - Strategic context and goals
    - Prioritized initiatives with rationale
    - Now/Next/Later sequencing
    - What is explicitly NOT on the roadmap
    - Key dependencies and risks

    ## Quality Criteria

    - Initiatives are outcome-framed, not feature-framed
    - Prioritization has explicit criteria and scoring
    - No committed dates without capacity analysis
    - Dependencies are identified and sequenced correctly
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
