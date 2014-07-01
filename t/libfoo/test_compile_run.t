use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::Install::Example::Libfoo::Installer;
use File::Spec;
use File::Temp qw( tempdir );

my $prefix = $ENV{ALIEN_LIBFOO_PREFIX} || tempdir( CLEANUP => 1);

BEGIN {
  plan skip_all => 'test  requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1};
}

my $inc = File::Spec->catdir($prefix, 'include');
my $lib = File::Spec->catdir($prefix, 'lib');

$ENV{LD_LIBRARY_PATH} = $lib;

plan skip_all => 'requires libfoo already installed'
  unless check_lib( libpath => $lib,
                    incpath => $inc,
                    lib => 'foo' );

plan tests => 1;

my $installer = bless { cflags => [ "-I$inc" ], libs => ["-L$lib", '-lfoo'] }, 'Alien::Install::Example::Libfoo::Installer';

my $version = $installer->test_compile_run;
like $version, qr{^[1-9][0-9]*\.[0-9]{2}$}, "version = $version";
