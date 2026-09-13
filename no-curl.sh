#!/bin/bash
# Claude Code PreToolUse hook for Bash. Denies any command mentioning curl.
# Agents use `get` instead (GET only). Matches the word anywhere, so a
# "curl" inside a string is a false positive; the message says what to do.

COMMAND=$(jq -r '.tool_input.command // ""')

echo "$COMMAND" | grep -qwF curl || exit 0

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "curl is blocked. Use `get <url>` (read-only, GET only)."
  },
  "systemMessage": "**curl blocked.** Use `get <url>` instead. It only makes GET requests. If `get` can't do what you need, do not work around it: tell the user what you need and why, and propose the one-line edit to ~/Code/personal/get/get. Then wait. If this was a false positive (the word curl in a string or commit message), tell the user and ask them to run the command themselves."
}
EOF
