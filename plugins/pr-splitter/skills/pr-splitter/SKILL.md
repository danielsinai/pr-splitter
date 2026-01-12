---
name: pr-splitter
description: Split large changes into atomic PRs using git worktree. Uses bash tools for git operations. Supports TypeScript/JavaScript, Python, and Go.
---

# PR Splitter Skill

Split a large set of changes into atomic, dependency-ordered PRs.

## Available Tools

| Tool | Purpose |
|------|---------|
| `tools/get-diff.sh [base]` | Show changed files vs base branch |
| `tools/show-imports.sh <path>` | Analyze imports in files (TS/JS, Python, Go) |
| `tools/create-slice.sh <num> <name> <base> <files...>` | Create a slice worktree |
| `tools/list-slices.sh` | List all slices and their status |
| `tools/sync-slice.sh <num> <upstream>` | Sync a slice with upstream |
| `tools/cleanup-slices.sh [--branches]` | Remove all worktrees |

---

## IMPORTANT: Branch Naming Convention

**Check your repository's branch naming rules FIRST.** Many repositories require specific prefixes.

Common patterns:
- `task_*` - Required by some repositories
- `feature/*` - Feature branches
- `fix/*` - Bug fixes

**The default `pr-split-*` prefix may be rejected.** When pushing, if you see branch name validation errors, you'll need to rename branches before pushing.

---

## Workflow (Two-Phase)

### Phase 1: Propose Slices (STOP and wait for user)

#### Step 1: Get Changed Files

```bash
bash .claude/skills/pr-splitter/tools/get-diff.sh main
```

#### Step 2: Analyze Dependencies

```bash
bash .claude/skills/pr-splitter/tools/show-imports.sh src/
```

#### Step 3: Propose Slices to User

**IMPORTANT: Do NOT suggest branch names. Only show file groupings.**

Present the plan and ASK user for branch names:

```
I'll create 3 slices:

**Slice 1** (2 files):
- src/types/user.ts
- src/types/order.ts

**Slice 2** (2 files) - depends on Slice 1:
- src/services/user.service.ts
- src/services/order.service.ts

**Slice 3** (1 file) - depends on Slice 2:
- src/api/routes.ts

Please provide branch names for each slice in this format:
1: <name>
2: <name>
3: <name>
```

**STOP HERE. Wait for user to provide branch names before proceeding.**

---

### Phase 2: Execute (After user provides names)

User will respond with branch names like:
```
1: user-types
2: user-services
3: user-api
```

#### Step 4: Create Slices with User-Provided Names

**IMPORTANT: All slices should be based on `main` (or the target branch) for independent PRs.**

```bash
# Slice 1 - based on main
bash .claude/skills/pr-splitter/tools/create-slice.sh 1 user-types main \
  src/types/user.ts \
  src/types/order.ts

# Slice 2 - ALSO based on main for independent PR
bash .claude/skills/pr-splitter/tools/create-slice.sh 2 user-services main \
  src/services/user.service.ts \
  src/services/order.service.ts

# Slice 3 - ALSO based on main for independent PR
bash .claude/skills/pr-splitter/tools/create-slice.sh 3 user-api main \
  src/api/routes.ts
```

#### Step 5: Verify

```bash
bash .claude/skills/pr-splitter/tools/list-slices.sh
```

#### Step 6: Push and Create PRs

For each slice, push and create PR:
```bash
# Navigate to each worktree and push
cd .claude/worktrees/slice-1
git push -u origin pr-split-1-<name>

# Create PR (if gh cli available)
gh pr create --title "..." --body "..." --base main
```

#### Step 7: Cleanup (REQUIRED)

**After all PRs are created, clean up worktrees:**

```bash
bash .claude/skills/pr-splitter/tools/cleanup-slices.sh
```

Or to also delete local branches:
```bash
bash .claude/skills/pr-splitter/tools/cleanup-slices.sh --branches
```

---

## Dependency Rules

1. **Types before implementations** - interfaces/types go in earlier slices
2. **If A imports B, B comes first** - never put a file before its dependencies
3. **Tests last** - test files depend on everything else
4. **Config can be early or late** - depends on what uses it

---

## Supported Languages

The import analysis tool supports:
- **TypeScript/JavaScript**: `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`
- **Python**: `.py`
- **Go**: `.go`

---

## Common Issues & Solutions

### Branch name rejected by repository rules
**Problem**: `push declined due to repository rule violations`
**Solution**: Rename branches before pushing:
```bash
cd .claude/worktrees/slice-1
git branch -m pr-split-1-<name> task_<name>
git push -u origin task_<name>
```

### File not found in worktree
**Problem**: Files not copied to worktree
**Solution**: The script copies from your current working directory. Make sure:
- You're running from the repo root
- The files exist in your working directory

### Worktree already exists
**Problem**: `fatal: 'path' already exists`
**Solution**: The script now auto-removes existing worktrees, but you can manually clean:
```bash
bash .claude/skills/pr-splitter/tools/cleanup-slices.sh
```

---

## Output

Report when complete:

```
## PR Splitting Complete

Created 3 slices:
1. pr-split-1-<user-name> (2 files) - PR #XXX
2. pr-split-2-<user-name> (2 files) - PR #XXX
3. pr-split-3-<user-name> (1 file) - PR #XXX

✓ Worktrees cleaned up
```
