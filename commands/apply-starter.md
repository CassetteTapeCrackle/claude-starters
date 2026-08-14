---
description: Apply a language starter (git-ignored CLAUDE.md + framework lock) to the current project
argument-hint: <stack> [--framework <name>]
allowed-tools: Bash(*/claude-starters/bin/apply-starter.sh:*)
---

Run the applier for the current working directory:

!`~/claude-starters/bin/apply-starter.sh $ARGUMENTS`

Then confirm to the user what was applied and remind them the framework is now locked in the project CLAUDE.md.
