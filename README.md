# PR Splitter

Split large pull requests into atomic, dependency-ordered PRs using **git worktrees**.

## What It Does

When you have a large set of changes that should logically be separate PRs, PR Splitter helps you:

1. **Analyze dependencies** between changed files
2. **Group files** into logical, atomic slices
3. **Create isolated branches** for each slice using git worktrees
4. **Push and create PRs** for each slice independently

## How It Works: Git Worktrees

PR Splitter uses [git worktrees](https://git-scm.com/docs/git-worktree) to manage multiple working directories from a single repository. This allows:

- **Isolated branches** — Each slice gets its own worktree with a dedicated branch
- **No switching** — Work on multiple slices without `git checkout`
- **Clean separation** — Files are copied to isolated directories under `.claude/worktrees/`
- **Easy cleanup** — Remove all worktrees with a single command

```
your-repo/
├── .claude/
│   └── worktrees/
│       ├── slice-1/    # First PR's isolated worktree
│       ├── slice-2/    # Second PR's isolated worktree
│       └── slice-3/    # Third PR's isolated worktree
└── src/                # Your main working directory
```

## Installation

### Via Claude Code Marketplace

Add this repository as a marketplace source, then install the plugin:

```bash
claude mcp add-marketplace danielsinai/pr-splitter
claude plugin install pr-splitter
```

### Manual Installation

Clone this repository and copy the contents to your project's `.claude/` directory:

```bash
git clone https://github.com/danielsinai/pr-splitter.git
cp -r pr-splitter/skills/pr-splitter .claude/skills/
cp -r pr-splitter/commands/* .claude/commands/
```

## Usage

### Quick Start

Run the `/split-pr` command or invoke the `pr-splitter` skill directly.

### Two-Phase Workflow

#### Phase 1: Analysis (Agent proposes, you approve)

1. The agent analyzes your changed files vs the base branch
2. It examines imports to understand dependencies
3. It proposes file groupings for each slice
4. **You provide branch names** for each slice

```
Agent: I'll create 3 slices:

**Slice 1** (2 files):
- src/types/user.ts
- src/types/order.ts

**Slice 2** (2 files) - depends on Slice 1:
- src/services/user.service.ts
- src/services/order.service.ts

Please provide branch names:
1: <name>
2: <name>

You: 
1: user-types
2: user-services
```

#### Phase 2: Execution (Agent creates branches)

The agent creates worktrees and branches using your names:

```bash
# Creates: .claude/worktrees/slice-1 with branch pr-split-1-user-types
# Creates: .claude/worktrees/slice-2 with branch pr-split-2-user-services
```

### Available Tools

| Tool | Description |
|------|-------------|
| `get-diff.sh [base]` | Show changed files vs base branch |
| `show-imports.sh <path>` | Analyze imports (TS/JS, Python, Go) |
| `create-slice.sh <num> <name> <base> <files...>` | Create a slice worktree |
| `list-slices.sh` | List all slices and status |
| `sync-slice.sh <num> <upstream>` | Sync slice with upstream |
| `cleanup-slices.sh [--branches]` | Remove all worktrees |

## Supported Languages

Import analysis works with:

| Language | Extensions |
|----------|------------|
| TypeScript/JavaScript | `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs` |
| Python | `.py` |
| Go | `.go` |

## Example Session

```bash
# 1. See what changed
bash .claude/skills/pr-splitter/tools/get-diff.sh main

# 2. Analyze dependencies
bash .claude/skills/pr-splitter/tools/show-imports.sh src/

# 3. Create slices (after naming)
bash .claude/skills/pr-splitter/tools/create-slice.sh 1 types main \
  src/types/user.ts src/types/order.ts

bash .claude/skills/pr-splitter/tools/create-slice.sh 2 services main \
  src/services/user.service.ts

# 4. Verify
bash .claude/skills/pr-splitter/tools/list-slices.sh

# 5. Push each slice
cd .claude/worktrees/slice-1
git push -u origin pr-split-1-types
gh pr create --title "Add user types" --base main

# 6. Clean up when done
bash .claude/skills/pr-splitter/tools/cleanup-slices.sh --branches
```

## Branch Naming

Default branch pattern: `pr-split-{num}-{name}`

If your repository requires specific prefixes (e.g., `task_*`, `feature/*`), rename before pushing:

```bash
cd .claude/worktrees/slice-1
git branch -m pr-split-1-types feature/user-types
git push -u origin feature/user-types
```

## Best Practices

1. **Types before implementations** — Put interfaces/types in earlier slices
2. **Respect import order** — If A imports B, B goes in an earlier slice
3. **Tests last** — Test files typically depend on implementation
4. **Base on main** — Each slice branches from main for independent PRs
5. **Clean up** — Always run cleanup after PRs are created

## Troubleshooting

### "Worktree already exists"

The script auto-removes existing worktrees, but you can manually clean:

```bash
bash .claude/skills/pr-splitter/tools/cleanup-slices.sh
```

### "Branch name rejected"

Your repository may have branch naming rules. Rename before pushing:

```bash
git branch -m pr-split-1-name task_name
```

### Files not in worktree

Ensure you're running from the repository root and files exist in your working directory.

## License

MIT
