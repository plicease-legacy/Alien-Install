package Alien::Install::Example::Libfoo::Installer;

use strict;
use warnings;
use Role::Tiny::With;
use Alien::Install::Util;

# ABSTRACT: Example installer for libfoo
# VERSION

config
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
;

with qw(
  Alien::Install::Role::Installer
  Alien::Install::Role::HTTP
  Alien::Install::Role::Tar 
  Alien::Install::Role::Autoconf
  Alien::Install::Role::TestCompileRun
  Alien::Install::Role::TestFFI
);

sub system_install
{
  die 'todo';
}

sub dlls
{
  die 'todo';
}

sub test_ffi_signature
{
  require FFI::Raw;
  ('foo_version_string', FFI::Raw::str());
}


sub test_ffi_version
{
  my(undef, $function) = @_;
  $function->();
}


1;
