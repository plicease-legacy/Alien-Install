use strict;
use warnings;
use Test::More tests => 1;
use Alien::Libarchive::Installer;

my $installer = Alien::Libarchive::Installer->new;
isa_ok $installer, 'Alien::Libarchive::Installer';

