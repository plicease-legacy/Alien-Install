use strict;
use warnings;
use Alien::LZO::Installer;
use Test::More;

plan skip_all => "set ALIEN_LZO_INSTALLER_EXTRA_TESTS to run test"
  unless $ENV{TRAVIS_JOB_ID} || $ENV{ALIEN_LZO_INSTALLER_EXTRA_TESTS} || $ENV{ALIEN_INSTALL_EXTRA_TESTS};
plan skip_all => 'test requires HTTP::Tiny'
  unless eval { require HTTP::Tiny };

plan tests => 1;

ok scalar Alien::LZO::Installer->versions_available > 0, 'versions_Available';

note $_ for Alien::LZO::Installer->versions_available;
