let
  commandName = "prd";
  description = "Generate a structured Product Requirements Document";
  allowedTools = "Read, Write, Grep, Glob";
  argumentHint = "[product or feature description]";
  prompt = ''
    Generate a structured PRD using the product-management skill frameworks.

    ## Process

    1. Read the PRD development reference at `~/.claude/skills/community/product-management/references/prd-development-full.md`
    2. Follow the 8-phase structure: Executive Summary, Problem Statement, Target Users,
       Strategic Context, Solution Overview, Success Metrics, User Stories, Out of Scope
    3. For each section, apply the relevant component framework:
       - Problem Statement: use the 5-part problem framing format
       - Target Users: create proto-personas
       - User Stories: use Mike Cohn format with INVEST + Gherkin AC
    4. Output a complete, filled-in PRD document — not an empty template

    ## Output

    Write the PRD to a file named `prd-[feature-name].md` in the current directory.

    ## Quality Criteria

    - Every section has concrete content, not placeholder text
    - Problem is framed before solution
    - Success metrics are measurable with baselines and targets
    - User stories follow INVEST criteria
    - Scope boundaries are explicit (what's IN and what's OUT)
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
