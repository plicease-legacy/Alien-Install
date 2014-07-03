use strict;
use warnings;
use Test::More tests => 1;

package
  Foo;

use Role::Tiny::With;

with 'Alien::Install::Role::VersionSortMultiple';

my @versions = ('0.0.0', '0.1.0', '0.001.0002', '0.0.1');

sub versions { @versions }

package
  main;

note $_ for Foo->versions;

is_deeply [Foo->versions], [qw( 0.0.0 0.0.1 0.1.0 0.001.0002 )], 'sorted correctly';
