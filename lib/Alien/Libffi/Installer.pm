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
  test_compile_run_program => do { local $/; <DATA> },
  test_ffi_signature => ['ffi_call', 'void', 'ptr', 'ptr', 'ptr', 'ptr'],
  test_ffi_version => sub { 'unknown' }, 
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

register_hook pre_instantiate => sub {
  my($class, $flags) = @_;
  my $libdir = catdir $flags->{prefix}, 'lib';
  if(-d $libdir)
  {
    my $dh;
    opendir $dh, $libdir;
    my($inc) = grep { -d }
               map { catdir $flags->{prefix}, 'lib', $_, 'include' } 
               grep /^libffi/, 
               readdir $dh;
    closedir $dh;
    unshift @{ $flags->{cflags} }, "-I$inc";
  }
};

1;

__DATA__
#include <ffi.h>
#include <stdio.h>

signed int
foo(int argument)
{
  return argument * 2;
}

int
main(int argc, char *argv[])
{
  ffi_cif  cif;
  ffi_type *arg_types[1];
  signed int result;
  signed int c;
  void *arguments[1];
  ffi_status status;

  arg_types[0] = &ffi_type_sint;

  status = ffi_prep_cif(
    &cif,
    FFI_DEFAULT_ABI,
    1,
    &ffi_type_sint,
    arg_types
  );

  if(status != FFI_OK)
  {
    printf("calling ffi_prep_cif failed\n");
    return 2;
  }

  c = 42;
  arguments[0] = &c;

  ffi_call(&cif, (void*)foo, &result, arguments);

  if(result == 84)
  {
    printf("version = 'unknown'\n");
    return 0;
  }
  else
  {
    printf("bad result %d\n", result);
    return 2;
  }
}
