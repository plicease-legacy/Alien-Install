use strict;
use warnings;
use Test::More tests => 2;

package
  Alien::Libfoo::Installer;

use Alien::Install::Util;

config
  foo  => 'hi there',
  bar  => sub { $_[0] * 2 };

package
  main;

is(Alien::Libfoo::Installer->alien_config_foo, 'hi there', 'value');
is(Alien::Libfoo::Installer->alien_config_bar->(2), 4, 'function');
