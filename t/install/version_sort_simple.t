use strict;
use warnings;
use Test::More tests => 1;

package
  Foo;

use Role::Tiny::With;

with 'Alien::Install::Role::VersionSortSimple';

my @versions = ('0.00', '1.22', '1.3', '1.003');

sub versions { @versions }

package
  main;

is_deeply [Foo->versions], [qw( 0.00 1.003 1.22 1.3 )], 'sorted correctly';
