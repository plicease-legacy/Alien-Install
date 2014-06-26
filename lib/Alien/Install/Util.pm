package Alien::Install::Util;

use strict;
use warnings;
use File::Spec;
use base qw( Exporter );

# ABSTRACT: Common utilities for Alien::Install roles and classes
# VERSION

our @EXPORT_OK = qw( catfile catdir register_build_requires );
our @EXPORT    = @EXPORT_OK;

sub catfile (@)
{
  my $name = File::Spec->catfile(@_);
  $name =~ s{\\}{/}g if $^O eq 'MSWin32';
  $name;
}

sub catdir (@)
{
  my $name = File::Spec->catdir(@_);
  $name =~ s{\\}{/}g if $^O eq 'MSWin32';
  $name;
}

our %build_requires;

sub register_build_requires (@)
{
  use Carp qw( confess );
  confess if @_ % 2;
  my %new = @_;
  my $class = caller;
  while(my($mod,$ver) = each %new)
  {
    $build_requires{$class}->{$mod} = $ver;
  }
}

our %system_requires;

sub register_system_requires (@)
{
  use Carp qw( confess );
  confess if @_ % 2;
  my %new = @_;
  my $class = caller;
  while(my($mod,$ver) = each %new)
  {
    $system_requires{$class}->{$mod} = $ver;
  }
}

1;
