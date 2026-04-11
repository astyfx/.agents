#!/usr/bin/env bash
set -euo pipefail

# pre-write-secrets.sh — PreToolUse hook for Write/Edit tools
# Blocks writing sensitive content to tracked or likely-to-be-committed files.
# Reads hook payload from stdin as JSON.

INPUT="$(cat)"

perl -MJSON::PP - "$INPUT" <<'PERL'
use strict;
use warnings;
use JSON::PP qw(decode_json);
use File::Basename qw(basename dirname);
use File::Spec;

my $payload_str = shift @ARGV // q{};
my $payload = eval { decode_json($payload_str) };
exit 0 if !$payload || ref($payload) ne 'HASH';

my $tool_input = $payload->{tool_input};
exit 0 if ref($tool_input) ne 'HASH';

my $file_path = $tool_input->{file_path} || $tool_input->{path} || q{};
exit 0 if $file_path eq q{};

my $filename = basename($file_path);
my $content = q{};
for my $key (qw(content text new_string newText replacement)) {
    my $value = $tool_input->{$key};
    next if !defined $value || ref($value) || $value eq q{};
    $content = $value;
    last;
}

sub shell_quote {
    my ($value) = @_;
    $value //= q{};
    $value =~ s/'/'"'"'/g;
    return "'$value'";
}

sub run_git {
    my ($cwd, @args) = @_;
    my $cmd = join q{ }, 'git', '-C', shell_quote($cwd), map { shell_quote($_) } @args;
    my $output = `$cmd 2>/dev/null`;
    my $status = $? >> 8;
    chomp $output;
    return ($status, $output);
}

sub git_repo_root {
    my ($path) = @_;
    my $abs_path = File::Spec->rel2abs($path);
    my $cwd = dirname($abs_path);
    my ($status, $output) = run_git($cwd, 'rev-parse', '--show-toplevel');
    return undef if $status != 0;
    return $output;
}

sub path_is_trackable {
    my ($path) = @_;
    my $repo_root = git_repo_root($path);
    return 0 if !defined $repo_root || $repo_root eq q{};

    my $abs_path = File::Spec->rel2abs($path);
    my $rel_path = File::Spec->abs2rel($abs_path, $repo_root);

    my ($tracked_status) = run_git($repo_root, 'ls-files', '--error-unmatch', '--', $rel_path);
    return 1 if $tracked_status == 0;

    my ($ignored_status) = run_git($repo_root, 'check-ignore', '-q', '--', $rel_path);
    return $ignored_status != 0;
}

sub looks_placeholder {
    my ($value) = @_;
    $value //= q{};
    $value =~ s/^\s+|\s+$//g;
    $value =~ s/^['"]|['"]$//g;

    my $lowered = lc $value;
    return 1 if $lowered eq q{};

    my @placeholder_markers = (
        'example',
        'sample',
        'placeholder',
        'changeme',
        'change-me',
        'set-me',
        'replace-me',
        'replace_with',
        'your-',
        'your_',
        '<',
        '>',
        'dummy',
        'fake',
        'redacted',
        'todo',
        'xxxxx',
        'localhost',
        '127.0.0.1',
    );

    for my $marker (@placeholder_markers) {
        return 1 if index($lowered, $marker) >= 0;
    }

    return 0;
}

sub has_secret_content {
    my ($text) = @_;
    return 0 if !defined $text || $text eq q{};

    my @raw_patterns = (
        qr/-----BEGIN [A-Z ]*PRIVATE KEY-----/,
        qr/\bgh[pousr]_[A-Za-z0-9_]{20,}\b/,
        qr/\bsk-(?:proj|live|test|prod|ant)?-[A-Za-z0-9_-]{10,}\b/,
        qr/\bxox[baprs]-[A-Za-z0-9-]{10,}\b/,
        qr/\bAKIA[0-9A-Z]{16}\b/,
        qr/\bAIza[0-9A-Za-z\-_]{20,}\b/,
    );

    for my $pattern (@raw_patterns) {
        return 1 if $text =~ $pattern;
    }

    while ($text =~ /^\s*(?:[A-Z0-9_]*(?:API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY)[A-Z0-9_]*)\s*=\s*(.+?)\s*$/gim) {
        my $value = $1;
        return 1 if !looks_placeholder($value);
    }

    return 0;
}

my @allowlist_patterns = (
    qr/\.env\.example$/i,
    qr/\.env\.sample$/i,
    qr/\.env\.template$/i,
);
my $is_template_name = 0;
for my $pattern (@allowlist_patterns) {
    if ($filename =~ $pattern) {
        $is_template_name = 1;
        last;
    }
}

my @blocklist_patterns = (
    qr/^\.env$/i,
    qr/\.pem$/i,
    qr/_key[^a-z]?$/i,
    qr/_key\./i,
    qr/_secret/i,
    qr/_token/i,
    qr/credentials/i,
);
my $risky_filename = 0;
for my $pattern (@blocklist_patterns) {
    if ($filename =~ $pattern) {
        $risky_filename = 1;
        last;
    }
}

my $risky_content = has_secret_content($content);
my $trackable = path_is_trackable($file_path);

if ($risky_filename && !$is_template_name) {
    print "[pre-write-secrets] Blocked write to high-risk secret path: $file_path\n";
    print "  Filename '$filename' matches a secret file pattern.\n";
    print "  Use a .example/.sample variant for templates or keep secrets out of tracked files.\n";
    exit 2;
}

if ($risky_content && ($trackable || $is_template_name)) {
    print "[pre-write-secrets] Blocked write of secret-like content: $file_path\n";
    print "  Destination file is tracked or likely to be committed.\n" if $trackable;
    print "  Template/example files must not contain real secret values.\n" if $is_template_name;
    print "  Replace secrets with placeholders or move them to an untracked local file.\n";
    exit 2;
}

if ($risky_filename && !$trackable) {
    print "[pre-write-secrets] Blocked write to potentially sensitive file: $file_path\n";
    print "  Filename '$filename' matches secret file pattern.\n";
    print "  If this is intentional, rename the file or use a .example/.sample variant.\n";
    exit 2;
}

exit 0;
PERL
