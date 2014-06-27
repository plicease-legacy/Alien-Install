use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::LZO::Installer;

BEGIN {
  plan skip_all => 'test requires Devel::CheckLib'
    unless eval q{ use Devel::CheckLib; 1 };
}

plan skip_all => 'test requires LZO already installed'
  unless check_lib( lib => 'lzo2' );

plan tests => 1;

my $installer = bless { cflags => [], libs => ['-llzo2'] }, 'Alien::LZO::Installer';

my $version = $installer->test_compile_run;
ok $version, "version = $version";

