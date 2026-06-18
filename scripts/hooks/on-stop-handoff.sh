#!/usr/bin/env bash
# on-stop-handoff.sh — Stop hook.
# Only does something when there is an ACTIVE tracked task: it refreshes a small
# "Auto Snapshot" section in that task's handoff.md so a resume has fresh state.
# When there is no active task it is a no-op — it deliberately does NOT spew a
# timestamped snapshot file per stop (that previously accumulated hundreds of
# dead files). NOTE: intentionally no set -e — this hook must never block stop.

CURRENT_PWD="$(pwd)"
WORK_HANDOFF_FILE="${CURRENT_PWD}/work-handoff.md"

# No work-handoff scratch -> nothing to track -> no-op.
[[ -f "${WORK_HANDOFF_FILE}" ]] || exit 0

TRACKING_TASK_PATH="$(perl -0ne '
  if (/^## Active Task Path\s*\n([^\n]+)\s*$/m) {
    print $1;
    exit 0;
  }
' "${WORK_HANDOFF_FILE}")"

# No active task path -> no-op.
[[ -n "${TRACKING_TASK_PATH}" ]] || exit 0

HANDOFF_BASE="${TRACKING_TASK_PATH}"
if [[ "${HANDOFF_BASE}" != /* ]]; then
  HANDOFF_BASE="${CURRENT_PWD}/${HANDOFF_BASE}"
fi

[[ -d "${HANDOFF_BASE}" && -f "${HANDOFF_BASE}/handoff.md" ]] || exit 0

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)" \
CURRENT_PWD="${CURRENT_PWD}" \
GIT_STATUS="$(git status --short 2>/dev/null || echo 'not a git repo')" \
  perl - "${HANDOFF_BASE}/handoff.md" <<'PERL'
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
my $git_status = $ENV{GIT_STATUS} // q{};

my $section = <<"EOF";
## Auto Snapshot

- Timestamp: $timestamp
- Working Directory: $working_dir
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

exit 0
