use strict;
use warnings;
use Test::More tests => 2;
use Alien::Install::Example::Libfoo::Installer;

is ref(Alien::Install::Example::Libfoo::Installer->system_requires), 'HASH', 'system_requires';

is_deeply(
  Alien::Install::Example::Libfoo::Installer->system_requires,
  { 'ExtUtils::CBuilder' => 0 },
  'content',
);
