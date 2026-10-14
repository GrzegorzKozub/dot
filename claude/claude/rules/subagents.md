# Launching subagents

A subagent does not reliably inherit your rules (`~/.claude/rules/`, or `$CLAUDE_CONFIG_DIR/rules/` when that's set) or your user `CLAUDE.md`. **Every** agent prompt you write must restate the rules that the agent's task could touch — copy the concrete values, don't paraphrase or refer to "the conventions".

The same applies to agent teams, workflows, and any skill you invoke that spawns its own agents. The `apsis-guidelines` hook already gives every subagent model selection and attribution, so those don't need restating.
