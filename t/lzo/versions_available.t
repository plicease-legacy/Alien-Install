use strict;
use warnings;
use Alien::LZO::Installer;
use Test::More tests => 1;

ok scalar Alien::LZO::Installer->versions_available > 0, 'versions_Available';

note $_ for Alien::LZO::Installer->versions_available;
