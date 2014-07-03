package Alien::Libffi::Installer;

use strict;
use warnings;
use Role::Tiny::With;
use Alien::Install::Util;

# ABSTRACT: Alien installer for libffi
# VERSION

config
  name => 'ffi',
  ftp  => {
    host  => 'sourceware.org',
    dir   => '/pub/libffi',
  },
  test_compile_run_program => join("\n",
    "#include <ffi.h>",
    "int",
    "main(int argc, char *argv[])",
    "{",
    # TODO: libffi doesn't seem to provide the
    # version as part of its API.
    # so will need to parse it out of the ffi.h
    # or libffi.pc file
    "  return 0;",
    "}",
    "",
  ),
  test_ffi_signature => [], # TODO
  test_ffi_version => sub {}, # TODO
;

with qw(
  Alien::Install::Role::Installer
  Alien::Install::Role::FTP
  Alien::Install::Role::Tar
  Alien::Install::Role::Autoconf
  Alien::Install::Role::TestCompileRun
  Alien::Install::Role::TestFFI
  Alien::Install::Role::VersionSortMultiple
);

1;
