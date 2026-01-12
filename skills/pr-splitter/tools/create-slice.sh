#!/bin/bash
# Create a worktree for a PR slice
# Usage: create-slice.sh <slice-num> <slice-name> <base-branch> <file1> [file2] ...

SLICE_NUM="$1"
SLICE_NAME="$2"
BASE_BRANCH="$3"
shift 3
FILES=("$@")

if [ -z "$SLICE_NUM" ] || [ -z "$SLICE_NAME" ] || [ -z "$BASE_BRANCH" ] || [ ${#FILES[@]} -eq 0 ]; then
    echo "Usage: create-slice.sh <slice-num> <slice-name> <base-branch> <file1> [file2] ..."
    echo "Example: create-slice.sh 1 types main src/types/user.ts src/types/order.ts"
    exit 1
fi

# Use absolute paths to avoid confusion
REPO_ROOT="$(git rev-parse --show-toplevel)"
BRANCH_NAME="pr-split-${SLICE_NUM}-${SLICE_NAME}"
WORKTREE_PATH="${REPO_ROOT}/.claude/worktrees/slice-${SLICE_NUM}"

echo "Creating slice ${SLICE_NUM}: ${SLICE_NAME}"
echo "  Branch: ${BRANCH_NAME}"
echo "  Worktree: ${WORKTREE_PATH}"
echo "  Base: ${BASE_BRANCH}"
echo "  Files: ${FILES[*]}"

# Remove existing worktree if present
if [ -d "$WORKTREE_PATH" ]; then
    echo "  Removing existing worktree..."
    git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true
fi

# Remove existing branch if present
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    echo "  Removing existing branch..."
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
fi

# Create worktree directory
mkdir -p "$(dirname "$WORKTREE_PATH")"

# Create worktree with new branch
if ! git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_BRANCH" 2>&1; then
    echo "ERROR: Failed to create worktree"
    exit 1
fi

# Copy files from current working directory (handles both modified AND new files)
COPIED=0
SKIPPED=0
for FILE in "${FILES[@]}"; do
    SOURCE_FILE="${REPO_ROOT}/${FILE}"
    TARGET_FILE="${WORKTREE_PATH}/${FILE}"

    if [ -f "$SOURCE_FILE" ]; then
        mkdir -p "$(dirname "$TARGET_FILE")"
        cp "$SOURCE_FILE" "$TARGET_FILE"
        COPIED=$((COPIED + 1))
        echo "  ✓ Copied: $FILE"
    else
        SKIPPED=$((SKIPPED + 1))
        echo "  ⚠ Skipped (not found): $FILE"
    fi
done

if [ $COPIED -eq 0 ]; then
    echo "ERROR: No files were copied"
    exit 1
fi

# Stage and commit in worktree
cd "$WORKTREE_PATH" || exit 1
git add -A
git commit -m "[Slice ${SLICE_NUM}] ${SLICE_NAME}"

echo ""
echo "✓ Created slice ${SLICE_NUM}"
echo "  Branch: ${BRANCH_NAME}"
echo "  Path: ${WORKTREE_PATH}"
echo "  Files: ${COPIED} copied, ${SKIPPED} skipped"
