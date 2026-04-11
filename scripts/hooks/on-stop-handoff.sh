#!/usr/bin/env bash
# on-stop-handoff.sh — Stop hook that writes a session snapshot when Claude stops.
# NOTE: intentionally no set -e — this hook must never block the stop event.

SNAPSHOT_DIR="${HOME}/.agents/claude/session-snapshots"
mkdir -p "${SNAPSHOT_DIR}"

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
SNAPSHOT_FILE="${SNAPSHOT_DIR}/${TIMESTAMP}.md"

CURRENT_PWD="$(pwd)"
GIT_STATUS="$(git status --short 2>/dev/null || echo "not a git repo")"
WORK_HANDOFF_FILE="${CURRENT_PWD}/work-handoff.md"
STATE_FILE=""
TRACKING_TASK_PATH=""

if [[ -f "${WORK_HANDOFF_FILE}" ]]; then
  STATE_FILE="${WORK_HANDOFF_FILE}"
fi

if [[ -n "${STATE_FILE}" ]]; then
  TRACKING_TASK_PATH="$(perl -0ne '
    if (/^## Active Task Path\s*\n([^\n]+)\s*$/m) {
      print $1;
      exit 0;
    }
  ' "${STATE_FILE}")"
fi

cat > "${SNAPSHOT_FILE}" <<EOF
# Session Snapshot — ${TIMESTAMP}

## Status
stopped

## Working Directory
${CURRENT_PWD}

## Scratch File
${STATE_FILE:-none}

## Active Task Path
${TRACKING_TASK_PATH:-unknown}

## Recent Git Status
${GIT_STATUS}
EOF

if [[ -n "${TRACKING_TASK_PATH}" ]]; then
  HANDOFF_BASE="${TRACKING_TASK_PATH}"
  if [[ "${HANDOFF_BASE}" != /* ]]; then
    HANDOFF_BASE="${CURRENT_PWD}/${HANDOFF_BASE}"
  fi

  if [[ -d "${HANDOFF_BASE}" && -f "${HANDOFF_BASE}/handoff.md" ]]; then
    HANDOFF_FILE="${HANDOFF_BASE}/handoff.md"
    TIMESTAMP="${TIMESTAMP}" \
    CURRENT_PWD="${CURRENT_PWD}" \
    SNAPSHOT_FILE="${SNAPSHOT_FILE}" \
    GIT_STATUS="${GIT_STATUS}" \
      perl - "${HANDOFF_FILE}" <<'PERL'
use strict;
use warnings;

my $handoff_file = shift @ARGV;
exit 0 if !defined $handoff_file || $handoff_file eq q{};

local $/;
open my $fh, '<', $handoff_file or exit 0;
my $text = <$fh>;
close $fh;

my $timestamp = $ENV{TIMESTAMP} // q{};
my $working_dir = $ENV{CURRENT_PWD} // q{};
my $snapshot_file = $ENV{SNAPSHOT_FILE} // q{};
my $git_status = $ENV{GIT_STATUS} // q{};

my $section = <<"EOF";
## Auto Snapshot

- Timestamp: $timestamp
- Working Directory: $working_dir
- Snapshot File: $snapshot_file
- Recent Git Status:
```text
$git_status
```
EOF

my $updated = $text;
if ($updated =~ /^## Auto Snapshot\s*\n.*?(?=^## |\z)/ms) {
    $updated =~ s/^## Auto Snapshot\s*\n.*?(?=^## |\z)/$section\n/ms;
} else {
    $updated =~ s/\s*\z/\n\n/;
    $updated .= $section . "\n";
}

open my $out, '>', $handoff_file or exit 0;
print {$out} $updated;
close $out;
PERL
  fi
fi

exit 0
