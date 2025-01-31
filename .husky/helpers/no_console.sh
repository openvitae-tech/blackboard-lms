if git diff --cached --name-only | grep -E '^app/javascript/.*\.js$' | xargs grep -nE 'console\.(log|warn|error)'; then
  echo "❌ Commit rejected! Remove console statements from JavaScript files."
  exit 1
fi

exit 0
