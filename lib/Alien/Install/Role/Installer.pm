package Alien::Install::Role::Installer;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;

# ABSTRACT: Role for Alien::Install
# VERSION

requires 'versions';
requires 'fetch';

my $build_requires = \%Alien::Install::Util::build_requires;

sub build_requires
{
  my($class) = @_;
  my %requires;
  foreach my $role (keys %$build_requires)
  {
    if($class->isa($role) || $class->does($role))
    {
      while(my($mod,$ver) = each %{ $build_requires->{$role} })
      {
        # TODO check if this is a newer or older
        # than existing $ver
        $requires{$mod} = $ver;
      }
    }
  }
  
  \%requires;
}

my $system_requires = \%Alien::Install::Util::system_requires;

sub system_requires
{
  my($class) = @_;
  my %requires;
  foreach my $role (keys %$system_requires)
  {
    if($class->isa($role) || $class->does($role))
    {
      while(my($mod,$ver) = each %{ $system_requires->{$role} })
      {
        # TODO check if this is a newer or older
        # than existing $ver
        $requires{$mod} = $ver;
      }
    }
  }
  
  \%requires;
}

1;
