#!/bin/bash
# Claude Code PreToolUse hook for Bash. Denies any command that runs curl.
# Agents use `get` instead (GET only). Matches `curl` in command position
# (line start, after | ; & ( a quote or whitespace, with or without a path), so
# `cat no-curl.sh` passes but `echo "run curl"` is still a false positive.
# Quotes and backslashes are dropped first, so `cu''rl` and `\curl` don't slip by.
# A nudge, not enforcement: wget, python, or a renamed binary walk right past it.

get="$(dirname "$(readlink -f "$0")")/get"

# Exit 2 blocks the call and shows stderr to the agent. Fail closed rather than wave curl through.
command -v jq >/dev/null || { echo "no-curl hook: jq not found on PATH" >&2; exit 2; }
COMMAND=$(jq -r '.tool_input.command // ""') || { echo "no-curl hook: could not parse hook input as JSON" >&2; exit 2; }

printf '%s\n' "$COMMAND" | tr -d '\\"'"'" | grep -qE $'(^|[[:space:];&|(`"\'])([^[:space:]]*/)?curl([[:space:]]|$|[;&|)`<>"\'])' || exit 0

jq -n --arg get "$get" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "curl is blocked. Use `get <url>` (GET only)."
  },
  systemMessage: "**curl blocked.** Use `get <url>` instead. It only makes GET requests. If `get` cannot do what you need, do not work around it: tell the user what you need and why, and propose the one-line edit to \($get). Then wait. If this was a false positive (the word curl in a string or commit message), tell the user and ask them to run the command themselves."
}'
