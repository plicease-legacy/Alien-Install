package Alien::Install;

use strict;
use warnings;

# ABSTRACT: Install your aliens
# VERSION

=head1 DESCRIPTION

I'm working on abstracting out all the generic bits out of
L<Alien::Libarchive::Installer> to eventually make a
L<Alien::Install> distribution.  For a few development
releases, L<Alien::Install> and other modules under it will
be bundled with L<Alien::Libarchive::Installer>.  The next
production release of L<Alien::Libarchive::Installer> will
not have this code bundled with it.

=head1 WHY

This distribution is intended as an alternative to L<Alien::Base>
as a framework to write Alien modules.  Alien modules are intended
for specifying dependencies in CPAN for things which are not
native to CPAN, such as C libraries.  They should either find
existing system libraries that fit their specification or download
and build the libraries from the internet.

L<Alien::Base> was intended as a framework to make it easier to
write Alien modules.  When I used L<Alien::Base> to write my first
implementation of L<Alien::Libarchive> all seemed well.  It worked
well with Linux.  Then I discovered a number of corner cases, and
because I wanted it to work in various environments I ended up
having to subclass a lot.  In the end I felt like I was writing
more work arounds than I was actually using L<Alien::Base> itself.
Listed here are some of the problems that I had with L<Alien::Base>.

For this discussion, 

=over 4

=item C<libfoo>

Is a C library that may be available from your operating system
vendor, or it may be downloaded and installed from the Internet.

=item C<Alien::Foo>

Is an L<Alien::Base> module that makes C<libfoo> available.
In some discussions, C<Alien::Foo> may use L<Alien::Install>
instead.

=item C<Foo::XS>

Is an XS module that uses C<Alien::Foo> to determine the compiler
and linker flags for C<libfoo>.

=item C<Foo::FFI>

Is a FFI module that uses C<Alien::Foo> to find the dynamic libraries
for C<libfoo>.

=back

=head2 No way to force building from source

L<Alien::Base> provides no provision for forcing it to download
the source for the target library, even if the system library is
available.  This can be a problem if the system is very old,
has bugs or security issues.

=head2 No way to specify specific version

L<Alien::Base> provides no provision requesting a specific
version.  That means if C<Alien::Foo> decides to use the 
system C<libfoo> which is version 1.00, but you really need
C<libfoo> version 2.00 then you are out of luck.

If C<Alien::Foo> was installed a long time ago from source
when the latest version was 1.00 you are also out of luck.

=head2 No way to upgrade without reinstalling

Related to the last point, if C<Alien::Foo> is building C<libfoo>
from source, there is no way to upgrade C<libfoo> unless you
force a reinstall of C<Alien::Foo>, or if the author of C<Alien::Foo>
uploads a new version and you specify that newer version.

=head2 Fragile upgrades

Because L<Alien::Base> builds and links against shared libraries
you need to use L<Alien::Foo> during the runtime of L<Foo::XS>
which uses it.  In addition, upgrades become extremely fragile.
Installing the system version of C<libfoo> after C<Alien::Foo>
or upgrading C<Alien::Foo> can break already installed and
previously working versions of C<Foo::XS>.

Some of the issues were discussed, but not acted on in this
thread:

L<https://github.com/Perl5-Alien/Alien-Base/pull/30>

=head2 Depends on pkg-config for system libraries

C<pkg-config> is a common tool for getting the compiler and linker
flags for a library.  Though common, it is certainly not ubiquitous.
Many systems to not come with it installed by default, it is rarely
available under Windows.  Even if it is available for your platform,
many packages do not provide a C<.pc> file which contains the
information necessary to use C<pkg-config>.

Some packages provide a C<.pc> file on some platforms but not others.
C<libarchive>, for example, provides a C<libarchive.pc> on most
platforms, but not on FreeBSD, where C<libarchive> is considered part
of the operating system.

=head2 Does not work with Windows with dynamic libraries

When using L<Alien::Base> to alienize a C<libfoo> that uses C<autoconf>
for windows you have to do a lot of work yourself.  Briefly, the problem
is that on C<MSWin32> you need C<MSYS> (my solution was to create
L<Alien::MSYS>), and on both C<MSWin32> and C<cygwin> the DLLs need
to be added to the path used by DynaLoader.  The problem is that on
both C<MSWin32> and C<cygwin>, the DLLs are in the C<PATH>, not the C<lib>
directory.

I was told that this was not necessary and was pointed to two examples
that do not work on C<MSWin32> or C<cygwin>.  Also both examples do not
use produce dynamic libraries on C<MSWin32>.

L<https://github.com/Perl5-Alien/Alien-Base/pull/32>

=cut

1;
