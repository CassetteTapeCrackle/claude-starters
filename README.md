# claude-starters

Token-lean project starters for Claude Code. On a chosen stack+framework,
`/apply-starter` writes a git-ignored project `CLAUDE.md` (framework locked)
and enables the stack's tooling.

## Install
    bash install.sh

## Use (greenfield)
After brainstorming settles on a language + framework:
    /apply-starter python --framework fastapi

## Test
    for t in tests/*.test.sh; do bash "$t"; done
