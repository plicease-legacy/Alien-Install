use strict;
use warnings;
use Test::More tests => 1;
use Alien::Libarchive::Installer;

is ref(Alien::Libarchive::Installer->system_requires), 'HASH', 'system_requires';
