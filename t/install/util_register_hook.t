use strict;
use warnings;
use Test::More tests => 3;

package
  Alien::Install::Role::FooRole1;

use Alien::Install::Util;
use Role::Tiny;

register_hook 'used_hook1' => sub {
  my @arg = @_;
  use Test::More;
  subtest 'Alien::Install::Role::FooRole1#used_hook1' => sub {
    plan tests => 3;
    isa_ok $arg[0], 'Alien::Libfoo::Installer';
    is $arg[1], 'arg1', '$_[1] = arg1';
    is $arg[0]->{count}, 0, 'role called first';
  };
  $arg[0]->{count}++;
};

package
  Alien::Install::Role::FooRole2;

use Alien::Install::Util;
use Role::Tiny;

sub method1
{
  my($self) = @_;
  $self->call_hooks('unused_hook');
  $self->call_hooks('used_hook1', 'arg1');
}

package
  Alien::Libfoo::Installer;

use Alien::Install::Util;
use Role::Tiny::With;

with qw(
  Alien::Install::Role::FooRole1
  Alien::Install::Role::FooRole2
  Alien::Install::Role::Installer
);

register_hook 'used_hook1' => sub {
  my @arg = @_;
  use Test::More;
  subtest 'Alien::Libfoo::Installer#used_hook1' => sub {
    plan tests => 3;
    isa_ok $arg[0], 'Alien::Libfoo::Installer';
    is $arg[1], 'arg1', '$_[1] = arg1';
    is $arg[0]->{count}, 1, 'class called second';
  };
  $arg[0]->{count}++;
};

sub versions {}
sub fetch {}
sub extract {}
sub chdir_source {}
sub test_compile_run {}
sub test_ffi {}

sub new
{
  bless { count => 0 }, 'Alien::Libfoo::Installer';
}

package
  main;

my $installer = Alien::Libfoo::Installer->new;
isa_ok $installer, 'Alien::Libfoo::Installer';

$installer->method1;
