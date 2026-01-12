#!/bin/bash
# Remove all slice worktrees and optionally branches
# Usage: cleanup-slices.sh [--branches]

DELETE_BRANCHES=false
if [ "$1" = "--branches" ]; then
    DELETE_BRANCHES=true
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREES_DIR="${REPO_ROOT}/.claude/worktrees"

echo "=== Removing Worktrees ==="

# Find and remove slice worktrees
for worktree in $(git worktree list | grep "${WORKTREES_DIR}/slice-" | awk '{print $1}'); do
    echo "Removing: $worktree"
    git worktree remove "$worktree" --force 2>/dev/null || true
done

# Clean up directory
if [ -d "$WORKTREES_DIR" ]; then
    rm -rf "$WORKTREES_DIR"
    echo "✓ Removed worktrees directory"
fi

# Prune stale worktree refs
git worktree prune

echo "✓ Worktrees removed"

if [ "$DELETE_BRANCHES" = true ]; then
    echo ""
    echo "=== Removing Branches ==="
    # Remove both pr-split-* branches
    for branch in $(git branch | grep -E "^\s*pr-split-" | tr -d ' *'); do
        echo "Deleting: $branch"
        git branch -D "$branch" 2>/dev/null || true
    done
    echo "✓ Branches removed"
fi

echo ""
echo "Done! Run 'git worktree list' to verify."
