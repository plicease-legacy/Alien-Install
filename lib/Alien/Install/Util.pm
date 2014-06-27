package Alien::Install::Util;

use strict;
use warnings;
use File::Spec;
use Carp qw( croak );
use base qw( Exporter );

# ABSTRACT: Common utilities for Alien::Install roles and classes
# VERSION

our @EXPORT_OK = qw( 
  catfile catdir catpath splitpath splitdir rootdir 
  spew 
  register_build_requires register_system_requires register_hook 
  config
);
our @EXPORT    = @EXPORT_OK;

=head2 catfile

=cut

sub catfile (@)
{
  my $name = File::Spec->catfile(@_);
  $name =~ s{\\}{/}g if $^O eq 'MSWin32';
  $name;
}

=head2 catdir

=cut

sub catdir (@)
{
  my $name = File::Spec->catdir(@_);
  $name =~ s{\\}{/}g if $^O eq 'MSWin32';
  $name;
}

=head2 catpath

=cut

sub catpath ($$;$)
{
  my $name = File::Spec->catpath(@_);
  $name =~ s{\\}{/}g if $^O eq 'MSWin32';
  $name;
}

=head2 splitpath

=cut

sub splitpath ($;$)
{
  my($path, $no_file) = @_;
  File::Spec->splitpath($path, $no_file);
}

=head2 splitdir

=cut

sub splitdir ($)
{
  my($dirs) = @_;
  File::Spec->splitdir($dirs);
}

=head2 rootdir

These functions work just like their L<File::Spec>
equivalent, except they are functions instead of
class members, and on windows they use C</> instead
of C<\> (the latter can sometimes cause problems
as it is also used as an escaping character).

=cut

sub rootdir ()
{
  my $name = File::Spec->rootdir;
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

our %hooks;

sub register_hook ($$)
{
  my($name, $sub) = @_;
  my $class = caller;
  push @{ $hooks{$class}->{$name} }, $sub;
}

sub spew ($$)
{
  my($filename, $content) = @_;
  open my $fh, '>', $filename;
  print $fh $content;
  close $fh;
}

sub config (@)
{
  croak "requires even number of argumens"
    if @_ % 2;
  
  my $caller = caller;
  
  while(@_ > 0)
  {
    my $key  = shift;
    my $value = shift;
    my $name = "_config_$key";
    do {
      no strict 'refs';
      *{"$caller\::$name"} = sub ($) { $value };
    };
  }
}

1;
