#!/usr/bin/perl

use v5.30;

use strict; 
use warnings;
use utf8;

use open ':std', ':encoding(UTF-8)';

use constant VERSION => '2.0.0';

BEGIN {
  $ENV{ANSI_COLORS_DISABLED}  = !(-t STDOUT);
  $ENV{HAS_TEXT_UNIDECODE}    = eval { require Text::Unidecode; 1; };
  $ENV{HAS_UNICODE_NORMALIZE} = eval { require Unicode::Normalize; 1; };
}

use Try::Tiny qw(try catch);

use Getopt::Long;
Getopt::Long::Configure ("bundling");

use File::Basename;

use Encode;
use Encode::Byte;
use Encode::CN;
use Encode::EBCDIC;
use Encode::JP;
use Encode::KR;
use Encode::TW;
use Encode::Unicode;

use Term::ANSIColor qw(:constants);

use if $ENV{HAS_UNICODE_NORMALIZE}, "Unicode::Normalize", 'normalize';
use if $ENV{HAS_TEXT_UNIDECODE},    "Text::Unidecode",    'unidecode';
 
my $help_msg = <<"HELP_MSG";
@{[BOLD]}rename.pl @{[VERSION]} - rename files using Perl expressions@{[RESET]}

@{[BOLD MAGENTA]}USAGE@{[RESET]}
    rename.pl@{[BRIGHT_BLACK]} [@{[RESET]}options@{[BRIGHT_BLACK]}] [@{[RESET]}files@{[BRIGHT_BLACK]}]@{[RESET]}

  @{[BOLD MAGENTA]}Options@{[RESET]}:
      -v | --verbose            Be verbose (repeat for more).
      -q | --quiet              Be quiet.
      --apply                   Apply changes.
      -f | --force              Force overwrite of existing files.
      --ignore-fail             Ignore failure to rename.
      --basename                Modifies only the last element of the path.
      -h | --help               Show this help text.
      -V | --version            Show version.

  @{[BOLD MAGENTA]}Operations@{[RESET]}:
      -e EXPR | --expr=EXPR     Perl expression that operates on \$_.
      --from-charset=CHARSET    Convert names from CHARSET to UTF-8.
      --normalize=FORM          Unicode normalization form (C, D, KC or KD).
      --collapse-whitespace     Collapse whitespace characters.
      --strip-diacritics        Strip diacritics.
      --unidecode               Apply unidecode function (requires Text::Unidecode).
HELP_MSG

$help_msg =~ s/(-[A-Za-z] )([A-Z]+)/$1 . UNDERLINE . $2 . RESET/ge;
$help_msg =~ s/(--[-a-z]+=)([A-Z]+)/$1 . UNDERLINE . $2 . RESET/ge;
$help_msg =~ s/(\s)(-[A-Za-z]|--[-a-z]+)(=|\s)/$1 . BOLD . $2 . RESET . $3/ge;
$help_msg =~ s/\|/BRIGHT_BLACK . '|' . RESET/ge;

my %opts = (
  "verbose"       => 0,
  "from-charset"  => "UTF-8",
  "to-charset"    => "UTF-8",
  "expr"          => [ ]
);

my $result = GetOptions(
  \%opts,
  "verbose|v+",
  "quiet|q",
  "apply",
  "force|f",
  "ignore-fail",
  "basename",
  "help|h"               => sub { print $help_msg; exit(0); },
  "version|V"            => sub { print "rename.pl ", VERSION, "\n"; exit(0); },
  "from-charset=s",
  "expr|e=s"             => \&operation,
  "normalize=s"          => \&operation,
  "strip-diacritics"     => sub { operation("normalize", "KD");
                                  operation("expr", "s/\\pM//g"); },
  "unidecode"            => \&operation,
  "collapse-whitespace"  => sub { operation("expr", "s/^\\s+//g");
                                  operation("expr", "s/\\s+\$//g");
                                  operation("expr", "s/\\s+/ /g");
                                  operation("expr", "s/\\s*\\.\\s*/./g") },
);

sub error_msg {
  if ($opts{'verbose'} < 0) { return; };
  print STDERR BOLD RED if (-t STDERR);
  print STDERR "Error: ";
  print STDERR RESET if (-t STDERR);
  print STDERR @_, "\n";
  exit 1;
}

sub warn_msg {
  if ($opts{'verbose'} < 0) { return; };
  print STDERR BOLD YELLOW if (-t STDERR);
  print STDERR "Warning: ";
  print STDERR RESET if (-t STDERR);
  print STDERR @_, "\n";
}

$opts{"verbose"} = -1 if ($opts{'quiet'});
$opts{"from-charset"} = find_encoding($opts{"from-charset"})->name;

if ((scalar(@{$opts{"expr"}}) == 0
 && $opts{"from-charset"} eq 'utf-8-strict')
 || scalar(@ARGV) == 0) {
  print $help_msg;
  exit(0);
}

sub operation {
  my ($op, $arg) = (@_);
  $arg = decode('UTF-8', $arg);

  error_msg "Module Text::Unidecode not installed."
    if ($op eq 'unidecode' && !$ENV{HAS_TEXT_UNIDECODE});
  error_msg "Module Unicode::Normalize not installed."
    if ($op eq 'normalize' && !$ENV{HAS_UNICODE_NORMALIZE});

  push @{$opts{"expr"}}, sub {
    my ($subject) = (@_);
    return ($op, $arg) if !defined $subject;
    if ($op eq "expr") {
      eval "no strict; $arg" for ($subject);
      die if $@;
    } elsif ($op eq "normalize") {
      $subject = normalize($arg, $subject);
    } elsif ($op eq "strip-diacritics") {
      $subject = normalize('KD', $subject);
      s/\pM//g for ($subject);
    } elsif ($op eq "unidecode") {
      $subject = unidecode($subject);
    }
    return $subject;
  };
}

sub filter {
  sub show_op {
    return if ($opts{"verbose"} < 3);
    my ($op_n, $subject, $op, $arg, $before) = @_;
    my $changed = defined $before && ($subject ne $before);
    print "[", $op_n, "] ", BOLD MAGENTA, $op;
    print " ", $arg if ($arg && $arg ne "1");
    print RESET " ‘", BOLD, $subject, RESET, "’";
    print BRIGHT_BLACK " [changed]", RESET if $changed;
    print "\n";
  }
  my ($filename) = (@_);
  my $op_n = 0;
  for ($filename) {
    my $initial = $_;
    $_ = decode($opts{"from-charset"}, $_);
    show_op $op_n++, $_, "from-charset", $opts{"from-charset"} if $opts{"from-charset"} ne 'utf-8-strict';
    show_op $op_n++, $_, "initial";
    foreach my $expr (@{$opts{"expr"}}) {
      my ($op, $arg) = &{$expr}();
      my $before = $_;
      try {
        $_ = &{$expr}($_);
      } catch {
        if ($op eq 'expr') {
          error_msg "Syntax error in expression ‘", $arg, "’.";
        } elsif ($op eq 'normalize') {
          error_msg "Invalid normalization form ‘", $arg, "’.";
        }
      };
      show_op $op_n++, $_, $op, $arg, $before;
    }
    show_op $op_n++, $_, "final";
  }
  return $filename;
}

foreach my $old_name (@ARGV) {

  my $new_name;
  if ($opts{"basename"}) { $new_name = dirname($old_name) .'/'
                                     . filter(basename($old_name)); }
  else                   { $new_name = filter($old_name); }

  my $old_name_u8 = decode($opts{"from-charset"}, $old_name);
  if (encode('UTF-8', $new_name) ne $old_name) {
    if (!$opts{'force'} && (-e $new_name)) {
      error_msg "File already exists: ‘", $new_name, "’.";
    }
    print "‘", BOLD, $old_name_u8, RESET,
      "’ -> ‘", BOLD, $new_name, RESET,
      "’.\n" if ($opts{"verbose"} >= 0);
    if ($opts{'apply'}) {
      if (!rename $old_name, $new_name) {
        (!$opts{'ignore-fail'} ? \&error_msg : \&warn_msg)->
          ('Unable to rename file ‘', $old_name_u8, '’ to ‘', $new_name, '’: ', $!, '.');
      }
    }
  } elsif ($opts{"verbose"} >= 2) {
    print "‘", BOLD, $old_name_u8, RESET, "’ unchanged.\n";
  }

}
