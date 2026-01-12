#!/bin/bash
# List all PR slice branches and worktrees
# Usage: list-slices.sh

REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREES_DIR="${REPO_ROOT}/.claude/worktrees"

echo "=== Slice Worktrees ==="
if [ -d "$WORKTREES_DIR" ]; then
    for slice_dir in "$WORKTREES_DIR"/slice-*; do
        if [ -d "$slice_dir" ]; then
            SLICE_NAME=$(basename "$slice_dir")
            BRANCH=$(cd "$slice_dir" && git branch --show-current 2>/dev/null || echo "unknown")
            FILES=$(cd "$slice_dir" && git diff --name-only HEAD~1..HEAD 2>/dev/null | wc -l | tr -d ' ')
            echo "  ${SLICE_NAME}: ${BRANCH} (${FILES} files)"
        fi
    done
else
    echo "  No slice worktrees found"
fi

echo ""
echo "=== Slice Branches (local) ==="
BRANCHES=$(git branch | grep -E "^\s*pr-split-" | tr -d ' *')
if [ -n "$BRANCHES" ]; then
    for branch in $BRANCHES; do
        COMMIT=$(git log -1 --oneline "$branch" 2>/dev/null || echo 'N/A')
        echo "  ${branch}: ${COMMIT}"
    done
else
    echo "  No slice branches found"
fi
