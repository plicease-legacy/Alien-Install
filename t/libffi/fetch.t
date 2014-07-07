use strict;
use warnings;
use Alien::Libffi::Installer;
use Test::More;

plan skip_all => 'set ALIEN_LIBFFI_INSTALLER_EXTRA_TESTS to run test'
  unless $ENV{TRAVIS_JOB_ID} || $ENV{ALIEN_LIBFFI_INSTALLER_EXTRA_TESTS} || $ENV{ALIEN_INSTALL_EXTRA_TESTS};
plan skip_all => 'test requires HTTP::Tiny'
  unless eval q{ use HTTP::Tiny; 1 };

plan tests => 1;

subtest 'latest version' => sub {
  plan tests => 2;
  my($location, $version) = eval { Alien::Libffi::Installer->fetch };
  diag $@ if $@;
  ok -r $location, 'downloaded latest';
  like $version, qr{^[0-9]+(\.[0-9]+)*$}, "version = $version";
};
