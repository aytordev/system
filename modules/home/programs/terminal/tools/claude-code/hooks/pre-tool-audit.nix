_: {
  PreToolUse = [
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
              umask 077

              audit_dir="$XDG_DATA_HOME/claude-code/audit"
              audit_log="$audit_dir/pre-tool.jsonl"
              mkdir -p "$audit_dir"
              chmod 700 "$audit_dir"
              touch "$audit_log"
              chmod 600 "$audit_log"

              input=$(cat)
              timestamp=$(date -Iseconds)

              printf '%s' "$input" | jq -c \
                --arg ts "$timestamp" \
                '{timestamp: $ts, session: .session_id, tool: .tool_name, cwd: .cwd}' \
                >> "$audit_log"

              if [ "$(wc -l < "$audit_log")" -gt 1000 ]; then
                temporary=$(mktemp "$audit_dir/.pre-tool.XXXXXX")
                tail -n 1000 "$audit_log" > "$temporary"
                chmod 600 "$temporary"
                mv "$temporary" "$audit_log"
              fi

              exit 0
            '';
        }
      ];
    }
  ];
}
