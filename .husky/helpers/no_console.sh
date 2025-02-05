echo "Running no console pre-commit hook"

if js_files=$(git diff --cached --name-only | grep -E '^app/javascript/.*\.js$'); then
  if echo "$js_files" | xargs grep -nE 'console\.(log|warn)'; then
    echo "❌ Commit rejected! Remove console statements from JavaScript files."
    exit 1
  fi
fi

exit 0
