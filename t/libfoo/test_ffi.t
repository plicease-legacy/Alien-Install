use strict;
use warnings;
use ExtUtils::CBuilder;
use Test::More;
use Alien::Install::Example::Libfoo::Installer;
use DynaLoader;
use File::Spec;
use File::Temp qw( tempdir );

my $prefix = $ENV{ALIEN_LIBFOO_PREFIX} || tempdir( CLEANUP => 1);

push @DynaLoader::dl_library_path, File::Spec->catdir($prefix, 'lib');

note '@DynaLoader::dl_library_path';
note "  $_" for @DynaLoader::dl_library_path;

plan skip_all => 'test requires FFI::Raw'
  unless eval { require FFI::Raw };
plan skip_all => 'test requires dynamic libfoo'
  unless defined DynaLoader::dl_findfile('-lfoo');

plan tests => 1;

my $installer = bless { cflags => ["-I${prefix}/include"], libs => ["-L${prefix}/lib", '-lfoo'] }, 'Alien::Install::Example::Libfoo::Installer';

my $version = $installer->test_ffi;
like $version, qr{^[0-9]+\.[0-9]{2}$}, "version = $version";
