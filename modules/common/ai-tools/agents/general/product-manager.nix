{
  product-manager = {
    name = "product-manager";
    description = "Product management specialist for PM frameworks, discovery, strategy, and requirements";
    tools = [
      "Read"
      "Write"
      "Bash"
      "Grep"
      "Glob"
    ];
    model = {
      claude = "opus";
      opencode = "anthropic/claude-opus-4-6";
    };
    permission = {
      edit = "ask";
      bash = "ask";
    };
    content = builtins.readFile ../../skills/community/product-management/AGENTS.md;
  };
}
