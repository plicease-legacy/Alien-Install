use strict;
use warnings;
use Test::More;
use Alien::Libffi::Installer;

plan skip_all => "set ALIEN_LIBFFI_INSTALLER_EXTRA_TESTS to run test"
  unless $ENV{TRAVIS_JOB_ID} || $ENV{ALIEN_LIBFFI_INSTALLER_EXTRA_TESTS} || $ENV{ALIEN_INSTALL_EXTRA_TESTS};
plan skip_all => 'test requires Net::FTP'
  unless eval { require Net::FTP };

plan tests => 1;

my @versions = eval { Alien::Libffi::Installer->versions };
diag $@ if $@;
ok @versions > 0, 'some versions';
note $_ for @versions;
