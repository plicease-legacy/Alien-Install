use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::Libarchive::Installer;

BEGIN {
  plan skip_all => 'test  requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1};
}

plan skip_all => 'requires libarchive already installed'
  unless check_lib( lib => 'archive' );

plan tests => 2;

my $installer = Alien::Libarchive::Installer->system_install;
isa_ok $installer, 'Alien::Libarchive::Installer';
like $installer->version, qr{^[1-9][0-9]*(\.[0-9]+){2}$}, "version = " . $installer->version;
