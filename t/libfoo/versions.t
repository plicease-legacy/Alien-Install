use strict;
use warnings;
use FindBin ();
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, 'lib');
use Test::More tests => 2;
use Alien::Install::Example::Libfoo::Installer;

my @versions = eval { Alien::Install::Example::Libfoo::Installer->versions };
diag $@ if $@;
ok @versions > 0, 'some versions';
note $_ for @versions;

is_deeply \@versions, [qw( 0.98 0.99 1.00 )], 'versions = 0.98 0.99 1.00';
