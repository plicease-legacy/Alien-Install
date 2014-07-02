package Alien::Install::Example::Libfoo::Installer;

use strict;
use warnings;
use Role::Tiny::With;
use Alien::Install::Util;

# ABSTRACT: Example installer for libfoo
# VERSION

=head1 SYNOPSIS

Build.PL

 # as an optional dep
 use Alien::Install::Example::Libfoo::Installer;
 use Module::Build;
 
 my %build_args;
 
 my $installer = eval { Alien::Install::Example::Libfoo::Installer };
 if($installer)
 {
   $build_args{extra_compiler_flags} = $installer->cflags;
   $build_args{extra_linker_flags}   = $installer->libs;
 }
 
 my $build = Module::Build->new(%build_args);
 $build->create_build_script;

=head1 DESCRIPTION

This module provides an example installer for C<libfoo>.
It is used in testing L<Alien::Install>.

=head1 SEE ALSO

=over 4

=item L<Alien::Install>

=back

=cut

config
  name             => 'foo',
  versions_url     => 'http://dist.wdlabs.com/',
  versions_process => qr{libfoo-([0-9]+\.[0-9]{2})\.tar\.gz},
  fetch_url        => sub {
    my(undef, $version) = @_;
    "http://dist.wdlabs.com/libfoo-$version.tar.gz";
  },
  test_compile_run_program => join("\n",
    "#include <foo.h>",
    "#include <stdio.h>",
    "int",
    "main(int argc, char *argv[])",
    "{",
    "  printf(\"version = '%s'\\n\", foo_version_string());",
    "  return 0;",
    "}",
  ),
  test_ffi_signature => ['foo_version_string', 'str'],
  test_ffi_version   => sub {
    my(undef, $function) = @_;
    $function->();
  },
;

with qw(
  Alien::Install::Role::Installer
  Alien::Install::Role::HTTP
  Alien::Install::Role::Tar 
  Alien::Install::Role::Autoconf
  Alien::Install::Role::TestCompileRun
  Alien::Install::Role::TestFFI
);

register_hook
  system_install_flags_guess => sub {
    my(undef, $build) = @_;
    my $prefix = $ENV{ALIEN_LIBFOO_PREFIX};
    if(defined $prefix)
    {
      unshift @{ $build->{cflags} }, "-I$prefix/include";
      unshift @{ $build->{libs}   }, "-L$prefix/lib";
    }
  }
;

register_hook
  system_install_search_list => sub {
    my(undef, $list) = @_;
    my $prefix = $ENV{ALIEN_LIBFOO_PREFIX};
    if(defined $prefix)
    {
      unshift @$list, catdir($prefix, 'bin');
      unshift @$list, catdir($prefix, 'lib');
    }
  }
;

1;
