use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::LZO::Installer;
use DynaLoader;

plan skip_all => 'test requires FFI::Raw'
  unless eval { require FFI::Raw };
plan skip_all => 'test requires dynamic LZO'
  unless defined DynaLoader::dl_findfile('-llzo2');

plan tests => 1;

my $installer = bless { clfags => [], libs => ['-llzo2'] }, 'Alien::LZO::Installer';

my $version = $installer->test_ffi;
ok $version, "version = $version";
