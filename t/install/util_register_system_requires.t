use strict;
use warnings;
use Test::More tests => 7;

package
  Alien::Install::Role::FooRole;

use Alien::Install::Util;
use Role::Tiny;

register_system_requires
  'Foo1'  => 0,
  'Foo2'  => '0.01',
  'Foo3'  => '0.22',
  'Foo4'  => 0;

package
  Alien::Libfoo::Installer;

use Alien::Install::Util;
use Role::Tiny::With;

with
  'Alien::Install::Role::FooRole',
  'Alien::Install::Role::Installer';

register_system_requires
  'Foo3'  => 0,
  'Foo4'  => '0.33',
  'Foo5'  => 0,
  'Foo6'  => '1.01';

sub versions {}
sub fetch {}
sub extract {}
sub chdir_source {}
sub test_compile_run {}
sub test_ffi {}

package
  main;

my %r = %{ Alien::Libfoo::Installer->system_requires };

note "system requires:";
note "  $_=$r{$_}" for sort keys %r;

is_deeply [sort keys %r], [qw( Foo1 Foo2 Foo3 Foo4 Foo5 Foo6 )], 'keys match';
is $r{Foo1},      0, 'Foo1 = 0';
is $r{Foo2}, '0.01', 'Foo2 = 0.01';
is $r{Foo3}, '0.22', 'Foo3 = 0.22';
is $r{Foo4}, '0.33', 'Foo4 = 0.33';
is $r{Foo5},      0, 'Foo5 = 0';
is $r{Foo6}, '1.01', 'Foo6 = 1.01';
