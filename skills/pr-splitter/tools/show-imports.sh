#!/bin/bash
# Show imports for TypeScript/JavaScript, Python, and Go files to help analyze dependencies
# Usage: show-imports.sh <file-or-directory>

TARGET="${1:-.}"

echo "=== Import Analysis ==="

analyze_file() {
    local file="$1"
    local ext="${file##*.}"
    local imports=""
    
    case "$ext" in
        ts|tsx|js|jsx|mjs|cjs)
            # TypeScript/JavaScript imports
            imports=$(grep -E "^import.*from|^export.*from|^const.*=.*require\(|^import\s+['\"]" "$file" 2>/dev/null)
            ;;
        py)
            # Python imports
            imports=$(grep -E "^import\s+|^from\s+.*\s+import" "$file" 2>/dev/null)
            ;;
        go)
            # Go imports - handles both single and multi-line import blocks
            imports=$(awk '
                /^import\s*\(/ { in_block=1; next }
                /^\)/ { in_block=0; next }
                in_block { gsub(/^[[:space:]]+/, ""); if ($0 != "") print "import " $0 }
                /^import\s+"/ { print }
            ' "$file" 2>/dev/null)
            ;;
    esac
    
    if [ -n "$imports" ]; then
        echo "$imports"
    fi
}

if [ -f "$TARGET" ]; then
    # Single file
    echo "File: $TARGET"
    echo "Imports:"
    analyze_file "$TARGET" | sed 's/^/  /'
else
    # Directory - show all imports
    find "$TARGET" \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.py" -o -name "*.go" \) -type f | while read -r file; do
        imports=$(analyze_file "$file")
        if [ -n "$imports" ]; then
            echo ""
            echo "=== $file ==="
            echo "$imports" | sed 's/^/  /'
        fi
    done
fi
