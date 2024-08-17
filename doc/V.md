# NAME

V - Print version of the specified module(s).

# SYNOPSIS

    $ perl -MV=V

or if you want more than one

    $ perl -MV=CPAN,V

Can now also be used as a light-weight module for getting versions of
modules without loading them:

    require V;
    printf "%s has version '%s'\n", "V", V::get_version ("V");

Starting with version **0.17**, V will show all `package`s or `class`es in a
file that have a version. If one wants to see all packages/classes from that
file, set the environment variable `PERL_V_SHOW_ALL` to a _true_ value.

If you want all available files/versions from `@INC`:

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

Each element in that array isa `V::Module::Info` object with 3 attributes and a method:

- _attribute_ **name**

    The package name.

- _attribute_ **file**

    Full filename with directory.

- _attribute_ **dir**

    The base directory (from `@INC`) where the package-file was found.

- _method_ **version**

    This method will look through the file to see if it can find a version
    assignment in the file and uses that to determine the version. As of version
    **0.13\_01**, all versions found are passed through the [version](https://metacpan.org/pod/version) module.

    As of version **0.16\_03** we look for all types of version declaration:

        package Foo;
        our $VERSION = 0.42;

    and

        package Foo 0.42;

    and

        package Foo 0.42 { ... }

    Not only do we look for the `package` keyword, but also for `class`.
    In list context this method will return an arrayref to a list of structures:

    - _pkg_

        The name of the `package`/`class`.

    - _version_

        The version for that `package`/`class`. (Can be absent if `$PERL_V_SHOW_ALL`
        is true.)

    - _ord_

        The ordinal number of occurrence in the file.

# DESCRIPTION

This module uses stolen code from [Module::Info](https://metacpan.org/pod/Module%3A%3AInfo) to find the location
and version of the specified module(s). It prints them and exit()s.

It defines `import ()` and is based on an idea from Michael Schwern
on the perl5-porters list. See the discussion:

    https://www.nntp.perl.org/group/perl.perl5.porters/2002/01/msg51007.html

## V::get\_version($pkg)

Returns the version of the first available file for this package as found by
following `@INC`.

### Arguments

- 1. $pkg

    The name of the package for which one wants to know the version.

### Response

This `V::get_version ()` returns the version of the file that was first found
for this package by following `@INC` or `undef` if no file was found.

# SEE ALSO

There are numerous module on CPAN that (try to) extract the VERSION
from modules. [ExtUtils::MakeMaker](https://metacpan.org/pod/ExtUtils%3A%3AMakeMaker) maybe being th most important
inspiration. [Module::Info](https://metacpan.org/pod/Module%3A%3AInfo) was used to copy code from.

# AUTHOR

Abe Timmerman -- 2002 - 2024 (✝ 2024-08-15 😢)
H.Merijn Brand `<hmbrand@cpan.org>`.

# COPYRIGHT AND LICENSE

Copyright 2024-2024 H.Merijn Brand, All Rights Reserved.
Copyright 2002-2024 Abe Timmerman,  All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANT-ABILITY or FITNESS FOR A PARTICULAR PURPOSE.
