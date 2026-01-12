#!/bin/bash
# Sync a slice with its upstream (previous slice or base branch)
# Usage: sync-slice.sh <slice-num> <upstream-branch>

set -e

SLICE_NUM="$1"
UPSTREAM_BRANCH="$2"

if [ -z "$SLICE_NUM" ] || [ -z "$UPSTREAM_BRANCH" ]; then
    echo "Usage: sync-slice.sh <slice-num> <upstream-branch>"
    echo "Example: sync-slice.sh 2 pr-slice-1-types"
    exit 1
fi

WORKTREE_PATH=".claude/worktrees/slice-${SLICE_NUM}"

if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Error: Worktree not found at ${WORKTREE_PATH}"
    exit 1
fi

echo "Syncing slice ${SLICE_NUM} with ${UPSTREAM_BRANCH}"

cd "$WORKTREE_PATH"

# Try merge
if git merge "$UPSTREAM_BRANCH" -m "Merge ${UPSTREAM_BRANCH}"; then
    echo "✓ Merged successfully"
else
    echo ""
    echo "⚠ Conflicts detected. Resolve them in: ${WORKTREE_PATH}"
    echo ""
    echo "Conflicted files:"
    git status --short | grep "^UU\|^AA\|^DD"
    echo ""
    echo "After resolving, run:"
    echo "  cd ${WORKTREE_PATH} && git add -A && git commit"
    exit 1
fi

