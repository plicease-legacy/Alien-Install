use strict;
use warnings;
use Test::More;
use Alien::bz2::Installer;

BEGIN {
  plan skip_all => 'test requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1 };
}

plan skip_all => 'requires bz2 already installed'
  unless check_lib( lib => 'bz2' );

plan tests => 2;

my $type = eval { require FFI::Raw } ? 'both' : 'compile';

note "type = $type";

my $installer = Alien::bz2::Installer->system_install( test => $type );
isa_ok $installer, 'Alien::bz2::Installer';
my $version = eval { $installer->version };
diag $@ if $@;
ok $version, "version = $version\n";
