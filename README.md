# get

A read-only `curl` for coding agents. It only makes GET requests, so it's safe to allow-list.

It is not a network sandbox. A GET can still reach localhost or a cloud metadata endpoint, and can carry data out in the query string. `get` narrows what the agent can send, not where it can go.

Anything it doesn't do, it refuses, and the refusal tells the agent to ask for the change instead of working around it. Run `get --help` for what it does today.

`no-curl.sh` is the matching Claude Code hook. It denies bare `curl` and points the agent at `get`.

`./test` checks both.
