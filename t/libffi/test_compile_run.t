use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::Libffi::Installer;

BEGIN {
  plan skip_all => 'test  requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1};
}

plan skip_all => 'requires libffi already installed'
  unless check_lib( lib => 'ffi', header => 'ffi.h' );

plan tests => 1;

my $installer = bless { cflags => [], libs => ['-lffi'] }, 'Alien::Libffi::Installer';

my $version = $installer->test_compile_run;
ok $version, "version = $version"
