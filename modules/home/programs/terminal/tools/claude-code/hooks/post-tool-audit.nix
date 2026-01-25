_: {
  PostToolUse = [
    {
      matcher = "*";
      hooks = [
        {
          type = "command";
          timeout = 10;
          command =
            /*
            Bash
            */
            ''
              mkdir -p "$XDG_DATA_HOME/claude-code/audit"
              input=$(cat)

              # Extract fields for logging
              timestamp=$(date -Iseconds)

              # Create compact JSON log entry (exclude potentially large tool_output)
              echo "$input" | jq -c \
                --arg ts "$timestamp" \
                '{timestamp: $ts, session: .session_id, tool: .tool_name, cwd: .cwd, success: true}' \
                >> "$XDG_DATA_HOME/claude-code/audit/post-tool.jsonl"

              exit 0
            '';
        }
      ];
    }
  ];
}
