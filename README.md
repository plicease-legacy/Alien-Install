# Alien::Libarchive::Installer

Installer for libarchive

# SYNOPSIS

Build.PL

    # as an optional dep
    use Alien::Libarchive::Installer;
    use Module::Build;
    
    my %build_args;
    
    my $installer = eval { Alien::Libarchive::Installer->system_install };
    if($installer)
    {
      $build_args{extra_compiler_flags} = $installer->cflags,
      $build_args{extra_linker_flags}   = $installer->libs,
    }
    
    my $build = Module::Build->new(%build_args);
    $build->create_build_script;

Build.PL

    # require 3.0
    use Alien::Libarchive::Installer;
    use Module::Build;
    
    my $installer = eval {
      my $system_installer = Alien::Libarchive::Installer->system_install;
      die "we require 3.0.x or better"
        if $system->version !~ /^(\[0-9]+)\./ && $1 >= 3;
      $system_installer;
         # reasonably assumes that build_install will never download
         # a version older that 3.0
    } || Alien::Libarchive::Installer->build_install("dir");
    
    my $build = Module::Build->new(
      extra_compiler_flags => $installer->cflags,
      extra_linker_flags   => $installer->libs,
    );
    $build->create_build_script;

# DESCRIPTION

This distribution contains the logic for finding existing libarchive
installs, and building new ones.  If you do not care much about the
version of libarchive that you use, and libarchive is not an optional
requirement, then you are probably more interested in using
[Alien::Libarchive](https://metacpan.org/pod/Alien::Libarchive).

Where [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer) is useful is when you have
specific version requirements (say you require 3.0.x but 2.7.x
will not do), but would still like to use the system libarchive
if it is available.

# CLASS METHODS

Class methods can be executed without creating an instance of
[Alien::libarchive::Installer](https://metacpan.org/pod/Alien::libarchive::Installer), and generally used to query
status of libarchive availability (either via the system or the
internet).  Methods that discover a system libarchive or build
a one from source code on the Internet will generally return
an instance of [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer) which can be
queried to retrieve the settings needed to interact with 
libarchive via XS or [FFI::Raw](https://metacpan.org/pod/FFI::Raw).

## versions\_available

    my @versions = Alien::Libarchive::Installer->versions_available;
    my $latest_version = $versions[-1];

Return the list of versions of libarchive available on the Internet.
Will throw an exception if the libarchive.org website is unreachable.
Versions will be sorted from oldest (smallest) to newest (largest).

## fetch

    my($location, $version) = Alien::Libarchive::Installer->fetch(%options);
    my $location = Alien::Libarchive::Installer->fetch(%options);

**NOTE:** using this method may (and probably does) require modules
returned by the [build\_requires](https://metacpan.org/pod/Alien::Libarchive::Installer)
method.

Download libarchive source from the internet.  By default it will
download the latest version to a temporary directory which will
be removed when Perl exits.  Will throw an exception on
failure.  Options include:

- dir

    Directory to download to

- version

    Version to download

## build\_requires

    my $prereqs = Alien::Libarchive::Installer->build_requires;
    while(my($module, $version) = each %$prereqs)
    {
      ...
    }

Returns a hash reference of the build requirements.  The
keys are the module names and the values are the versions.

The requirements may be different depending on your
platform.

## system\_requires

This is like [build\_requires](https://metacpan.org/pod/Alien::Libarchive::Installer#build_requires),
except it is used when using the libarchive that comes with the operating
system.

## system\_install

    my $installer = Alien::Libarchive::Installer->system_install;

**NOTE:** using this method may require modules returned by the
[system\_requires](https://metacpan.org/pod/Alien::Libarchive::Installer) method.

## build\_install

    my $installer = Alien::Libarchive::Installer->build_install( '/usr/local', %options );

**NOTE:** using this method may (and probably does) require modules
returned by the [build\_requires](https://metacpan.org/pod/Alien::Libarchive::Installer)
method.

Build and install libarchive into the given directory.  If there
is an error an exception will be thrown.  On a successful build, an
instance of [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer) will be returned.

These options may be passed into build\_install:

- tar

    Filename where the libarchive source tar is located.
    If not specified the latest version will be downloaded
    from the Internet.

- dir

    Empty directory to be used to extract the libarchive
    source and to build from.

# ATTRIBUTES

Attributes of an [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer) provide the
information needed to use an existing libarchive (which may
either be provided by the system, or have just been built
using [build\_install](https://metacpan.org/pod/Alien::Libarchive::Installer#build_install).

## cflags

The compiler flags required to use libarchive.

## libs

The linker flags and libraries required to use libarchive.

## version

The version of libarchive

# INSTANCE METHODS

## test\_compile\_run

    if($installer->test_compile_run(%options))
    {
      # You have a working Alien::Libarchive as
      # specified by %options
    }
    else
    {
      die $installer->error;
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

## error

Returns the error from the previous call to [test\_compile\_run](https://metacpan.org/pod/Alien::Libarchive::Installer#test_compile_run).

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
