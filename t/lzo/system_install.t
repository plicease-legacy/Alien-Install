use strict;
use warnings;
use Test::More;
use Alien::LZO::Installer;

BEGIN {
  plan skip_all => 'test requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1 };
}

plan skip_all => 'requires LZO already installed'
  unless check_lib( lib => 'lzo2' );

plan tests => 2;

my $type = eval { require FFI::Raw } ? 'both' : 'compile';

note "type = $type";

my $installer = Alien::LZO::Installer->system_install( test => $type );
isa_ok $installer, 'Alien::LZO::Installer';
my $version = eval { $installer->version };
diag $@ if $@;
ok $version, "version = $version\n";
