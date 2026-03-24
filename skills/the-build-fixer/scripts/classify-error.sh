#!/usr/bin/env bash
# classify-error.sh — classify build/compiler error output from stdin
# Usage: cat error.log | bash classify-error.sh
# Returns a classification label to stdout

INPUT="$(cat)"

if echo "$INPUT" | grep -qE 'TS[0-9]{4}:|is not assignable|does not exist on type|Object is possibly'; then
  echo "typescript-type-error"
elif echo "$INPUT" | grep -qE 'Cannot find module|Module not found|package not found|Cannot resolve'; then
  echo "missing-dependency"
elif echo "$INPUT" | grep -qE 'command not found|ENOENT|No such file|version.*required'; then
  echo "environment-mismatch"
elif echo "$INPUT" | grep -qE 'AssertionError|Expected.*toBe|FAIL|✗|× '; then
  echo "test-failure"
elif echo "$INPUT" | grep -qE 'no-unused|no-explicit-any|@typescript-eslint|eslint|biome'; then
  echo "lint-error"
elif echo "$INPUT" | grep -qE 'SyntaxError|Unexpected token|Invalid configuration|vite\.config|tsconfig'; then
  echo "build-config"
else
  echo "runtime-or-unknown"
fi
