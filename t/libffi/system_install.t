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
  unless check_lib( lib => 'ffi' );

plan tests => 2;

my $type = eval { require FFI::Raw } ? 'both' : 'compile';

note "type = $type";

my $installer = Alien::Libffi::Installer->system_install( test => $type );
isa_ok $installer, 'Alien::Libffi::Installer';
ok $installer->version, "version = " . $installer->version;
