use strict;
use warnings;
use Test::More tests => 1;
use Alien::Libarchive::Installer;

my @versions = eval { Alien::Libarchive::Installer->versions_available };
diag $@ if $@;
ok @versions > 0, 'some versions';
note $_ for @versions;
