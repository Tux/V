#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
GetOptions (
    "c|check"		=> \ my $check,
    "u|update!"		=> \ my $update,
    "v|verbose:1"	=> \(my $opt_v = 0),
    ) or die "usage: $0 [--check]\n";

use lib "sandbox";
use genMETA;
my $meta = genMETA->new (
    from    => "lib/V.pm",
    verbose => $opt_v,
    );

$meta->from_data (<DATA>);
$meta->security_md ($update);
$meta->gen_cpanfile ();

if ($check) {
    $meta->check_encoding ();
    $meta->check_required ();
    $meta->check_minimum ();
    $meta->done_testing ();
    }
elsif ($opt_v) {
    $meta->print_yaml ();
    }
else {
    $meta->fix_meta ();
    }

__END__
--- #YAML:1.0
name:                    V
version:                 VERSION
abstract:                Print version of the specified module(s)
license:                 perl
author:
    - H.Merijn Brand <perl5@tux.freedom.nl>
    - Abe Timmerman
generated_by:            Author
distribution_type:       module
provides:
    V:
        file:            lib/V.pm
        version:         VERSION
requires:
    perl:                5.014000
    File::Spec:          0
configure_requires:
    ExtUtils::MakeMaker: 0
configure_recommends:
    ExtUtils::MakeMaker: 7.78
test_requires:
    Test::Simple:        0.88
    Test::Fatal:         0
    Test:Warnings:       0
test_recommends:
    Test::Simple:        1.302224
resources:
    license:             http://dev.perl.org/licenses/
    repository:          https://github.com/Tux/V
    homepage:            https://metacpan.org/pod/V
    bugtracker:          https://github.com/Tux/V/issues
    IRC:                 irc://irc.perl.org/#csv
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
