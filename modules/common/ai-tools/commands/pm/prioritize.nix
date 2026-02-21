let
  commandName = "prioritize";
  description = "Get prioritization advice for features or initiatives";
  allowedTools = "Read, Write, Grep, Glob";
  argumentHint = "[list of items to prioritize or context]";
  prompt = ''
    Help prioritize features or initiatives using the product-management skill frameworks.

    ## Process

    1. Read the prioritization advisor reference at `~/.claude/skills/community/product-management/references/prioritization-advisor-full.md`
    2. Follow the facilitation protocol for interactive skills
    3. Ask adaptive questions to understand context:
       - Product stage (early/growth/mature)
       - Team context (data maturity, decision-making style)
       - Decision-making needs (speed vs. rigor)
       - Available data (quantitative vs. qualitative)
    4. Recommend the right framework (RICE, ICE, Kano, MoSCoW, Value vs. Effort)
    5. Apply the framework to the user's items with scoring

    ## Interaction Style

    Use the workshop facilitation protocol:
    - Give a session heads-up explaining what you'll produce
    - Ask one question at a time with numbered options
    - Show progress labels [1/4], [2/4], etc.
    - Present a numbered recommendation with rationale

    ## Output

    - Recommended framework with selection rationale
    - Scored prioritization table
    - Top 3 priorities with reasoning
    - Alternative framework to consider and when to switch
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
