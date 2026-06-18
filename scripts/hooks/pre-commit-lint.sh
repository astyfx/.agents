#!/usr/bin/env bash
set -euo pipefail

# pre-commit-lint.sh — PreToolUse hook for Bash tool
# Blocks git commits with non-Conventional Commits messages.
# Reads hook payload from stdin as JSON.

INPUT="$(cat)"

perl -MJSON::PP - "$INPUT" <<'PERL'
use strict;
use warnings;
use JSON::PP qw(decode_json);

my $payload_str = shift @ARGV // q{};
my $payload = eval { decode_json($payload_str) };
exit 0 if !$payload || ref($payload) ne 'HASH';

my $tool_input = $payload->{tool_input};
exit 0 if ref($tool_input) ne 'HASH';

my $command = $tool_input->{command} // q{};
exit 0 if $command !~ /\bgit\s+commit\b/;

my $msg;
if ($command =~ /-m\s+"\$\(cat\s+<<'?EOF'?\n\s*(.+)/s) {
    $msg = $1;
    $msg =~ s/\n.*//s;
} elsif ($command =~ /-m\s+["']([^"'\n]+)["']/) {
    $msg = $1;
} else {
    exit 0;
}
$msg =~ s/\s+$//;
my $pattern = qr/^(?:feat|fix|refactor|chore|docs|test|perf|ci|build|revert)(?:\(.+\))?: .+/;

if ($msg =~ $pattern) {
    exit 0;
}

# Non-blocking advisory: nudge toward Conventional Commits without blocking the
# commit. Conventional Commits is the preferred convention, not a hard gate, so
# this prints to STDERR and exits 0 instead of failing the tool call.
print STDERR "[pre-commit-lint] Note: commit message is not in Conventional Commits format.\n";
print STDERR "  Got: $msg\n";
print STDERR "  Preferred: <type>(<scope>): <subject>  (feat, fix, refactor, chore, docs, test, perf, ci, build, revert)\n";
exit 0;
PERL
