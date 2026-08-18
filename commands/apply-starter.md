---
description: Apply a language starter (git-ignored CLAUDE.md + framework lock) to the current project
argument-hint: <stack> [--framework <name>] [--path <subdir>]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/apply-starter.sh:*)
---

Run the applier for the current working directory:

!`${CLAUDE_PLUGIN_ROOT}/bin/apply-starter.sh $ARGUMENTS`

Then confirm to the user what was applied and remind them the framework is now locked in the project CLAUDE.md.
