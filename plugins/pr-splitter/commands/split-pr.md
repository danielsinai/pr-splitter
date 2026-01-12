# Split PR

$ARGUMENTS

---

Split your current changes into multiple atomic PRs.

## Workflow

**This is a two-phase process:**

1. **I analyze and propose slices** - You'll see file groupings
2. **You provide branch names** - Reply with names like `1: my-types`
3. **I create the branches** - Using your provided names

---

## Quick Reference

```bash
# Get changed files
bash .claude/skills/pr-splitter/tools/get-diff.sh main

# Analyze imports (supports TS/JS, Python, Go)
bash .claude/skills/pr-splitter/tools/show-imports.sh src/

# Create slice (after you provide names)
bash .claude/skills/pr-splitter/tools/create-slice.sh <num> <your-name> <base> <files...>

# List slices
bash .claude/skills/pr-splitter/tools/list-slices.sh
```

---

## Use Skill

Use **pr-splitter** skill for the complete workflow.
