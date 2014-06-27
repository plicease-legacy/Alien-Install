use strict;
use warnings;
use Alien::LZO::Installer;
use Test::More;

plan skip_all => 'set ALIEN_LZO_INSTALLER_EXTRA_TESTS to run test'
  unless $ENV{TRAVIS_JOB_ID} || $ENV{ALIEN_LZO_INSTALLER_EXTRA_TESTS};
plan skip_all => 'test requires HTTP::Tiny'
  unless eval q{ use HTTP::Tiny; 1 };

plan tests => 1;

subtest 'latest version' => sub {
  plan tests => 2;
  my($location, $version) = eval { Alien::LZO::Installer->fetch };
  diag $@ if $@;
  ok -r $location, 'downloaded latest';
  like $version, qr{^[1-9][0-9]*(\.[0-9]*)$}, "download version latest is $version";
};
