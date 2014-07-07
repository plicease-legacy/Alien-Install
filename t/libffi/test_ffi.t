use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::Libffi::Installer;
use DynaLoader;

plan skip_all => 'test requires FFI::Raw'
  unless eval { require FFI::Raw };
plan skip_all => 'test requires dynamic libffi'
  unless defined DynaLoader::dl_findfile('-lffi');

plan tests => 1;

my $installer = bless { cflags => [], libs => ['-lffi'] }, 'Alien::Libffi::Installer';

my $version = $installer->test_ffi;
ok $version, "version = $version";
