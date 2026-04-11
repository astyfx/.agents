#!/usr/bin/env perl
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;

my $repo_dir = dirname(dirname(abs_path(__FILE__)));
my $results_dir = File::Spec->catdir($repo_dir, 'evals', 'results');

sub parse_result {
    my ($path) = @_;
    my %data;

    open my $fh, '<', $path or die "Failed to read $path: $!";
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^#/;
        next if $line !~ /^([A-Za-z0-9_]+):\s*(.*)$/;
        $data{$1} = $2;
    }
    close $fh;

    return \%data;
}

sub avg {
    my ($values) = @_;
    return '-' if !@{$values};

    my $sum = 0;
    $sum += $_ for @{$values};
    return sprintf '%.2f', $sum / @{$values};
}

sub trim {
    my ($value) = @_;
    $value //= q{};
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    return $value;
}

opendir my $dh, $results_dir or die "Failed to read $results_dir: $!";
my @files = sort grep { /\.md\z/ && -f File::Spec->catfile($results_dir, $_) } readdir $dh;
closedir $dh;

if (!@files) {
    print "No eval results found.\n";
    exit 0;
}

my %by_agent;
my %by_type;
my $contextualized_runs = 0;
my $decision_linked_runs = 0;
for my $filename (@files) {
    my $path = File::Spec->catfile($results_dir, $filename);
    my $parsed = parse_result($path);
    my $agent = $parsed->{agent} // 'unknown';
    push @{$by_agent{$agent}}, $parsed;

    my $eval_type = trim($parsed->{eval_type});
    $by_type{$eval_type}++ if $eval_type ne q{};

    my $change_under_test = trim($parsed->{change_under_test});
    my $decision_target = trim($parsed->{decision_target});
    $contextualized_runs++ if $eval_type ne q{} || $change_under_test ne q{} || $decision_target ne q{};
    $decision_linked_runs++ if $decision_target ne q{};
}

print 'Eval results found: ' . scalar(@files) . "\n\n";
print "| Agent | Runs | Pass | Partial | Fail | Avg Rework | Verify Yes | Policy Yes |\n";
print "|---|---:|---:|---:|---:|---:|---:|---:|\n";

for my $agent (sort keys %by_agent) {
    my @runs = @{$by_agent{$agent}};
    my %pass_counts = (
        yes => 0,
        partial => 0,
        no => 0,
    );
    my $verify_yes = 0;
    my $policy_yes = 0;
    my @rework_values;

    for my $run (@runs) {
        my $pass = lc($run->{pass} // q{});
        $pass_counts{$pass}++ if exists $pass_counts{$pass};

        $verify_yes++ if lc($run->{verification_quality} // q{}) eq 'yes';
        $policy_yes++ if lc($run->{policy_compliance} // q{}) eq 'yes';

        my $value = $run->{rework_count} // q{};
        push @rework_values, $value + 0 if $value =~ /^\d+$/;
    }

    print '| ' . $agent
      . ' | ' . scalar(@runs)
      . ' | ' . $pass_counts{yes}
      . ' | ' . $pass_counts{partial}
      . ' | ' . $pass_counts{no}
      . ' | ' . avg(\@rework_values)
      . ' | ' . $verify_yes
      . ' | ' . $policy_yes
      . " |\n";
}

print "\n";
print 'Contextualized runs: ' . $contextualized_runs . ' / ' . scalar(@files) . "\n";
print 'Decision-linked runs: ' . $decision_linked_runs . ' / ' . scalar(@files) . "\n";

if (%by_type) {
    print "\n| Eval Type | Runs |\n";
    print "|---|---:|\n";
    for my $eval_type (sort keys %by_type) {
        print '| ' . $eval_type . ' | ' . $by_type{$eval_type} . " |\n";
    }
}

exit 0;
