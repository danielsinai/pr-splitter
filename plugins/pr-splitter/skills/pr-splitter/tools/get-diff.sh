#!/bin/bash
# Get the diff of current changes vs a base branch
# Usage: get-diff.sh [base-branch]

BASE_BRANCH="${1:-main}"

echo "=== Changed Files ==="
git diff --name-status "$BASE_BRANCH"

echo ""
echo "=== Diff Stats ==="
git diff --stat "$BASE_BRANCH"

