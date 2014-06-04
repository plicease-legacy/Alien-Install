use strict;
use warnings;
use Test::More tests => 1;
use Alien::Libarchive::Installer;

my $installer = Alien::Libarchive::Installer->new;

my @versions = eval { $installer->versions_available };
diag $@ if $@;
ok @versions > 0, 'some versions';
note $_ for @versions;
