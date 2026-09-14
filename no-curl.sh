#!/bin/bash
# Claude Code PreToolUse hook for Bash. Denies any command mentioning curl.
# Agents use `get` instead (GET only). Matches the word anywhere, so a
# "curl" inside a string is a false positive; the message says what to do.
# A nudge, not enforcement: it's trivially bypassed.

get="$(dirname "$(readlink -f "$0")")/get"

COMMAND=$(jq -r '.tool_input.command // ""')

echo "$COMMAND" | grep -qwF curl || exit 0

jq -n --arg get "$get" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "curl is blocked. Use `get <url>` (GET only)."
  },
  systemMessage: "**curl blocked.** Use `get <url>` instead. It only makes GET requests. If `get` cannot do what you need, do not work around it: tell the user what you need and why, and propose the one-line edit to \($get). Then wait. If this was a false positive (the word curl in a string or commit message), tell the user and ask them to run the command themselves."
}'
