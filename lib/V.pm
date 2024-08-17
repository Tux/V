package V;

require 5.010000;

use strict;
use warnings;

use vars qw( $VERSION $NO_EXIT );
$VERSION  = "0.20";

$NO_EXIT ||= 0; # prevent import() from exit()ing and fall of the edge

our $DEBUG;
    $DEBUG ||= $ENV{PERL_V_DEBUG} || 0;

=encoding utf-8

=head1 NAME

V - Print version of the specified module(s).

=head1 SYNOPSIS

    $ perl -MV=V

or if you want more than one

    $ perl -MV=CPAN,V

Can now also be used as a light-weight module for getting versions of
modules without loading them:

    require V;
    printf "%s has version '%s'\n", "V", V::get_version ("V");

Starting with version B<0.17>, V will show all C<package>s or C<class>es in a
file that have a version. If one wants to see all packages/classes from that
file, set the environment variable C<PERL_V_SHOW_ALL> to a I<true> value.

If you want all available files/versions from C<@INC>:

    require V;
    my @all_V = V::Module::Info->all_installed ("V");
    printf "%s:\n", $all_V[0]->name;
    for my $file (@all_V) {
        my ($versions) = $file->version; # Must be list context
        if (@$versions > 1) {
            say "\t", $file->name;
            print "\t    %-30s: %s\n", $_->{pkg}, $_->{version} for @versions;
            }
        else {
            printf "\t%-50s - %s\n", $file->file, $versions->[0]{version};
            }
        }

Each element in that array isa C<V::Module::Info> object with 3 attributes and a method:

=over

=item I<attribute> B<name>

The package name.

=item I<attribute> B<file>

Full filename with directory.

=item I<attribute> B<dir>

The base directory (from C<@INC>) where the package-file was found.

=item I<method> B<version>

This method will look through the file to see if it can find a version
assignment in the file and uses that to determine the version. As of version
B<0.13_01>, all versions found are passed through the L<version> module.

As of version B<0.16_03> we look for all types of version declaration:

    package Foo;
    our $VERSION = 0.42;

and

    package Foo 0.42;

and

    package Foo 0.42 { ... }

Not only do we look for the C<package> keyword, but also for C<class>.
In list context this method will return an arrayref to a list of structures:

=over 8

=item I<pkg>

The name of the C<package>/C<class>.

=item I<version>

The version for that C<package>/C<class>. (Can be absent if C<$PERL_V_SHOW_ALL>
is true.)

=item I<ord>

The ordinal number of occurrence in the file.

=back

=back

=head1 DESCRIPTION

This module uses stolen code from L<Module::Info> to find the location
and version of the specified module(s). It prints them and exit()s.

It defines C<import ()> and is based on an idea from Michael Schwern
on the perl5-porters list. See the discussion:

  https://www.nntp.perl.org/group/perl.perl5.porters/2002/01/msg51007.html

=head2 V::get_version($pkg)

Returns the version of the first available file for this package as found by
following C<@INC>.

=head3 Arguments

=over

=item 1. $pkg

The name of the package for which one wants to know the version.

=back

=head3 Response

This C<V::get_version ()> returns the version of the file that was first found
for this package by following C<@INC> or C<undef> if no file was found.

=begin implementation

=head2 report_pkg

This sub prints the results for a package.

=head3 Arguments

=over

=item 1. $pkg

The name of the package that was probed for versions

=item 2. @versions

An array of Module-objects with full path and version.

=back

=end implementation

=head1 SEE ALSO

There are numerous module on CPAN that (try to) extract the VERSION
from modules. L<ExtUtils::MakeMaker> maybe being th most important
inspiration. L<Module::Info> was used to copy code from.

=head1 AUTHOR

Abe Timmerman -- 2002 - 2024 (✝ 2024-08-15 😢)
H.Merijn Brand C<< <hmbrand@cpan.org> >>.

=head1 COPYRIGHT AND LICENSE

Copyright 2024-2024 H.Merijn Brand, All Rights Reserved.
Copyright 2002-2024 Abe Timmerman,  All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANT-ABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

sub report_pkg ($@) {
    my $pkg = shift;

    print "$pkg\n";
    @_ or print "\tNot found\n";
    foreach my $module (@_) {
	my ($versions) = $module->version;
	if (@$versions > 1) {
	    printf "\t%s:\n", $module->file;
	    printf "\t    %s: %s\n", $_->{pkg}, $_->{version} || '' for @$versions;
	    }
	else {
	    printf "\t%s: %s\n", $module->file, $versions->[0]{version} || '?';
	    }
	}
    } # report_pkg

sub import {
    shift;
    @_ or push @_ => 'V';

    for my $pkg (@_) {
	my @modules = V::Module::Info->all_installed ($pkg);
	report_pkg $pkg, @modules;
	}
    $NO_EXIT or exit ();
    } # import

sub get_version {
    my ($pkg)   = @_;
    my ($first) = V::Module::Info->all_installed ($pkg);
    return $first ? $first->version : undef;
    } # get_version

caller or V->import (@ARGV);

1;

# Okay I did the AUTOLOAD bit, but this is a Copy 'n Paste job.
# Thank you Michael Schwern for Module::Info! This one is mostly that!

package V::Module::Info;

require File::Spec;

sub new_from_file {
    my ($proto, $file) = @_;
    my $class = ref $proto || $proto;

    -r $file and return bless {
	file => File::Spec->rel2abs ($file),
	dir  => "",
	name => "",
	} => $class;
    } # new_from_file

sub all_installed {
    my ($proto, $name, @inc) = @_;
    my $class = ref $proto || $proto;

    @inc or @inc = @INC;
    my $file = File::Spec->catfile (split m/::/ => $name) . ".pm";

    my @modules;
    foreach my $dir (@inc) {
	# Skip the new code ref in @INC feature.
	ref $dir and next;

	my $filename = File::Spec->catfile ($dir, $file);
	-r $filename or next;

	my $module = $class->new_from_file ($filename);
	$module->{dir}  = File::Spec->rel2abs ($dir);
	$module->{name} = $name;
	push @modules => $module;
	}

    $V::DEBUG and do { print {*STDERR} "# $file: @{[scalar $_->version]}\n" for @modules };
    return @modules;
    } # all_installed

# Once thieved from ExtUtils::MM_Unix 1.12603
sub version {
    my $self = shift;

    my $parsefile = $self->file;

    open my $mod, "<", $parsefile or die "open $parsefile: $!";

    my $inpod = 0;
    local $_;
    my %eval;
    my ($cur_pkg, $cur_ord) = ("main", 0);
    $eval{$cur_pkg} = { ord => $cur_ord };
    while (<$mod>) {
	$inpod = m/^=(?!cut)/ ? 1 : m/^=cut/ ? 0 : $inpod;
	$inpod || m/^\s*#/	and next;
	m/^\s*#/		and next;

	chomp;
	if (m/^\s* (?:package|class) \s+ (\w+(?:::\w+)*) /x) {
	    $cur_pkg = $1;
	    exists $eval{$cur_pkg} or
		$eval{$cur_pkg} = { ord => ++$cur_ord };
	    }

	$cur_pkg =~ m{^V::Module::Info} and next;

	if (m/(?:our)?\s*([\$*])(([\w\:\']*)\bVERSION)\s*\=(?![=~])/) {
	    { local ($1, $2); ($_ = $_) = m/(.*)/; }    # untaint
	    my ($sigil, $name) = ($1, $2);
	    m/\$$name\s*=\s*eval.+\$$name/	and next;
	    m/my\s*\$VERSION\s*=/		and next;
	    $eval{$cur_pkg}{prg} = qq{
                package V::Module::Info::_version_var;
                # $cur_pkg
                no strict;
                local $sigil$name;
                \$$name = undef;
                do { $_
		    # Closing brace needs to be on next line
		    # as toping can haz comment
		    };
                \$$name
		};
	    }
	# perl 5.12.0+
	elsif (m/^\s* (?:package|class) \s+ [^\s]+ \s+ (v?[0-9.]+) \s* [;\{]/x) {
	    my $ver = $1;
	    if ($] >= 5.012000) {
		$eval{$cur_pkg}{prg} = qq{
                    package V::Module::Info::_version_static $ver;
                    # $cur_pkg
                    V::Module::Info::_version_static->VERSION;
		    };
		}
	    else {
		warn "Your perl doesn't understand the version declaration of $cur_pkg\n";
		$eval{$cur_pkg}{prg} = qq{ $ver };
		}
	    }
	}
    close $mod;

    # remove our stuff
    delete $eval{$_} for grep { m/^V::Module::Info/ } keys %eval;

    my @results;
    while (my ($pkg, $dat) = each %eval) {
	my $result;
	if ($dat->{prg}) {
	    $V::DEBUG and warn "# $pkg: $dat->{prg}\n";
	    local $^W = 0;
	    $result = eval $dat->{prg};
	    $V::DEBUG && $@ and warn "Could not eval '$dat->{prg}' in $parsefile: $@";

	    # use the version modulue to deal with v-strings
	    require version;
	    $dat->{ver} = $result = version->parse ($result);
	    }
	push @results => {
	    (exists $dat->{ver} ? (version => $result) : ()),
	    pkg => $pkg,
	    ord => $dat->{ord},
	    };
	}
    $ENV{PERL_V_SHOW_ALL} or
	@results = grep { exists ($_->{version}) } @results;

    @results > 1 and
	@results = grep { $_->{pkg} ne "main" || exists $_->{version} } @results;

    unless (wantarray) {
	foreach my $option (@results) {
	    $option->{pkg} eq $self->name or next;
	    return $option->{version};
	    }
	return;
	}
    return [ sort { $a->{ord} <=> $b->{ord} } @results ];
    } # version

sub accessor {
    my $self  = shift;
    my $field = shift;

    @_ and $self->{$field} = $_[0];
    return $self->{$field};
    } # accessor

sub AUTOLOAD {
    my ($self) = @_;

    use vars qw( $AUTOLOAD );
    my ($method) = $AUTOLOAD =~ m{.+::(.+)$};

    if (exists $self->{$method}) {
	splice @_, 1, 0, $method;
	goto &accessor;
	}
    } # AUTOLOAD

1;
