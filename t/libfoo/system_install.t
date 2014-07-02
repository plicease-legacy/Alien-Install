use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::Install::Example::Libfoo::Installer;

my $prefix = $ENV{ALIEN_LIBFOO_PREFIX} || tempdir( CLEANUP => 1);

BEGIN {
  plan skip_all => 'test  requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1};
}

my $inc = File::Spec->catdir($prefix, 'include');
my $lib = File::Spec->catdir($prefix, 'lib');

$ENV{LD_LIBRARY_PATH} = $lib;

plan skip_all => 'requires libfoo already installed'
  unless check_lib( incpath => $inc, libpath => $lib, lib => 'foo' );

plan tests => 2;

my $type = eval { require FFI::Raw } ? 'both' : 'compile';

note "type = $type";

my $installer = Alien::Install::Example::Libfoo::Installer->system_install( test => $type );
isa_ok $installer, 'Alien::Install::Example::Libfoo::Installer';
like $installer->version, qr{^[1-9][0-9]*\.[0-9]{2}$}, "version = " . $installer->version;
