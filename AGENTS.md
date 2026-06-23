# ggpop Codex Notes

Jorge assigns Codex’s role per task. Do not assume a fixed division
between Codex and other agents.

## Review-Only Mode

If Jorge says `Review only. Do not edit files.`, inspect the current
repo state and report findings without modifying files.

Prioritize bugs, regressions, contract mismatches, missing verification,
unnecessary complexity, and docs that no longer match behavior.

## Codex Cold Start

Read the shared Codex memory-loading protocol, then the project memory
catalog before giving implementation advice:

- `codex/MEMORY_LOADING.md`
- `projects/ggpop/memory/MEMORY.md`

## Edit Discipline

When asked to edit, inspect first, preserve user changes, keep the patch
scoped, and run the smallest meaningful verification command available.
