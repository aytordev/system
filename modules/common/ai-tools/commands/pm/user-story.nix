let
  commandName = "user-story";
  description = "Write user stories with acceptance criteria";
  allowedTools = "Read, Write, Grep, Glob";
  argumentHint = "[feature or capability description]";
  prompt = ''
    Write user stories using the product-management skill frameworks.

    ## Process

    1. Read the user story reference at `~/.claude/skills/community/product-management/references/user-story-full.md`
    2. Gather context about the feature or capability
    3. Write stories using Mike Cohn's format: "As a [role] I want [capability] so that [benefit]"
    4. Add Gherkin acceptance criteria (Given/When/Then) for each story
    5. Validate each story against INVEST criteria
    6. If stories are too large, apply splitting patterns from the reference

    ## Output

    Present the stories in a structured format. For each story include:
    - Story statement (As a / I want / So that)
    - Acceptance criteria (Given / When / Then scenarios)
    - INVEST validation (brief check)
    - Estimated complexity (S/M/L)

    ## Quality Criteria

    - Stories are user-facing, not technical tasks
    - Each story is independently shippable
    - Acceptance criteria are testable with clear pass/fail
    - No story is larger than one sprint of work
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
