# Alien::Libarchive::Installer

Installer for libarchive

# METHODS

## new

    my $installer = Alien::Libarchive::Installer->new;

Create a new instance of Alien::Libarchive::Installer.

## test\_compile\_run

    if($installer->test_compile_run(%options))
    {
      # You have a working Alien::Libarchive as
      # specified by %options
    }

Tests the compiler to see if you can build and run
a simple libarchive program.  On success it will 
return the libarchive version.  Other options include

- cbuilder

    The [ExtUtils::CBuilder](https://metacpan.org/pod/ExtUtils::CBuilder) instance that you want
    to use.  If not specified, then a new one will
    be created.

- dir

    Directory to use for building the executable.
    If not specified, a temporary directory will be
    created and removed when Perl terminates.

- extra\_compiler\_flags

    Extra flags to pass to `$cbuilder` during the
    compile step.  Should be either a list reference
    or string, see [ExtUtils::CBuilder#compile](https://metacpan.org/pod/ExtUtils::CBuilder#compile).

- extra\_linker\_flags

    Extra flags to pass to `$cbuilder` during the
    link step.  Should be either a list reference
    or string, see [ExtUtils::CBuilder#link](https://metacpan.org/pod/ExtUtils::CBuilder#link).

## error

Returns the error from the previous call to [test\_compile\_run](https://metacpan.org/pod/Alien::Libarchive::Installer#test_compile_run).

## build\_requires

    my $prereqs = $installer->build_requires;
    while(my($module, $version) = each %$prereqs)
    {
      ...
    }

Returns a hash reference of the build requirements.  The
keys are the module names and the values are the versions.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
