# Alien::Install

Install your aliens

# DESCRIPTION

I'm working on abstracting out all the generic bits out of
[Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer) to eventually make a
[Alien::Install](https://metacpan.org/pod/Alien::Install) distribution.  For a few development
releases, [Alien::Install](https://metacpan.org/pod/Alien::Install) and other modules under it will
be bundled with [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer).  The next
production release of [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer) will
not have this code bundled with it.

# WHY

This distribution is intended as an alternative to [Alien::Base](https://metacpan.org/pod/Alien::Base)
as a framework to write Alien modules.  Alien modules are intended
for specifying dependencies in CPAN for things which are not
native to CPAN, such as C libraries.  They should either find
existing system libraries that fit their specification or download
and build the libraries from the internet.

[Alien::Base](https://metacpan.org/pod/Alien::Base) was intended as a framework to make it easier to
write Alien modules.  When I used [Alien::Base](https://metacpan.org/pod/Alien::Base) to write my first
implementation of [Alien::Libarchive](https://metacpan.org/pod/Alien::Libarchive) all seemed well.  It worked
well with Linux.  Then I discovered a number of corner cases, and
because I wanted it to work in various environments I ended up
having to subclass a lot.  In the end I felt like I was writing
more work arounds than I was actually using [Alien::Base](https://metacpan.org/pod/Alien::Base) itself.
Listed here are some of the problems that I had with [Alien::Base](https://metacpan.org/pod/Alien::Base).

For this discussion, 

- `libfoo`

    Is a C library that may be available from your operating system
    vendor, or it may be downloaded and installed from the Internet.

- `Alien::Foo`

    Is an [Alien::Base](https://metacpan.org/pod/Alien::Base) module that makes `libfoo` available.
    In some discussions, `Alien::Foo` may use [Alien::Install](https://metacpan.org/pod/Alien::Install)
    instead.

- `Foo::XS`

    Is an XS module that uses `Alien::Foo` to determine the compiler
    and linker flags for `libfoo`.

- `Foo::FFI`

    Is a FFI module that uses `Alien::Foo` to find the dynamic libraries
    for `libfoo`.

## No way to force building from source

[Alien::Base](https://metacpan.org/pod/Alien::Base) provides no provision for forcing it to download
the source for the target library, even if the system library is
available.  This can be a problem if the system is very old,
has bugs or security issues.

## No way to specify specific version

[Alien::Base](https://metacpan.org/pod/Alien::Base) provides no provision requesting a specific
version.  That means if `Alien::Foo` decides to use the 
system `libfoo` which is version 1.00, but you really need
`libfoo` version 2.00 then you are out of luck.

If `Alien::Foo` was installed a long time ago from source
when the latest version was 1.00 you are also out of luck.

## No way to upgrade without reinstalling

Related to the last point, if `Alien::Foo` is building `libfoo`
from source, there is no way to upgrade `libfoo` unless you
force a reinstall of `Alien::Foo`, or if the author of `Alien::Foo`
uploads a new version and you specify that newer version.

## Fragile upgrades

Because [Alien::Base](https://metacpan.org/pod/Alien::Base) builds and links against shared libraries
you need to use [Alien::Foo](https://metacpan.org/pod/Alien::Foo) during the runtime of [Foo::XS](https://metacpan.org/pod/Foo::XS)
which uses it.  In addition, upgrades become extremely fragile.
Installing the system version of `libfoo` after `Alien::Foo`
or upgrading `Alien::Foo` can break already installed and
previously working versions of `Foo::XS`.

Some of the issues were discussed, but not acted on in this
thread:

[https://github.com/Perl5-Alien/Alien-Base/pull/30](https://github.com/Perl5-Alien/Alien-Base/pull/30)

## Depends on pkg-config for system libraries

`pkg-config` is a common tool for getting the compiler and linker
flags for a library.  Though common, it is certainly not ubiquitous.
Many systems to not come with it installed by default, it is rarely
available under Windows.  Even if it is available for your platform,
many packages do not provide a `.pc` file which contains the
information necessary to use `pkg-config`.

Some packages provide a `.pc` file on some platforms but not others.
`libarchive`, for example, provides a `libarchive.pc` on most
platforms, but not on FreeBSD, where `libarchive` is considered part
of the operating system.

## Does not work with Windows with dynamic libraries

When using [Alien::Base](https://metacpan.org/pod/Alien::Base) to alienize a `libfoo` that uses `autoconf`
for windows you have to do a lot of work yourself.  Briefly, the problem
is that on `MSWin32` you need `MSYS` (my solution was to create
[Alien::MSYS](https://metacpan.org/pod/Alien::MSYS)), and on both `MSWin32` and `cygwin` the DLLs need
to be added to the path used by DynaLoader.  The problem is that on
both `MSWin32` and `cygwin`, the DLLs are in the `PATH`, not the `lib`
directory.

I was told that this was not necessary and was pointed to two examples
that do not work on `MSWin32` or `cygwin`.  Also both examples do not
use produce dynamic libraries on `MSWin32`.

[https://github.com/Perl5-Alien/Alien-Base/pull/32](https://github.com/Perl5-Alien/Alien-Base/pull/32)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
