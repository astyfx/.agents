#!/usr/bin/env bash
# post-write-format.sh — PostToolUse hook for Write and Edit tools
# Auto-formats files after they are written or edited.
# Reads hook payload from stdin as JSON.
# NOTE: intentionally no set -e — formatters may fail and that is acceptable.

INPUT="$(cat)"

FILE_PATH="$(perl -MJSON::PP - "$INPUT" <<'PERL'
use strict;
use warnings;
use JSON::PP qw(decode_json);

my $payload_str = shift @ARGV // q{};
my $payload = eval { decode_json($payload_str) };
if ($payload && ref($payload) eq 'HASH' && ref($payload->{tool_input}) eq 'HASH') {
    my $tool_input = $payload->{tool_input};
    my $file_path = $tool_input->{file_path} // $tool_input->{path} // q{};
    print $file_path;
}
PERL
)"

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

case "$EXT" in
  ts|tsx|js|jsx|json|css)
    if command -v bunx &>/dev/null; then
      bunx prettier --write "$FILE_PATH" 2>/dev/null || true
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
