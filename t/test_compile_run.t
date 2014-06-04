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

plan tests => 1;

my $installer = Alien::Libarchive::Installer->new;

my $version = $installer->test_compile_run(extra_linker_flags => '-larchive');
like $version, qr{^[1-9][0-9]*(\.[0-9]+){2}$}, "version = $version";
