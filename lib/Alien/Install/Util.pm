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
  spew slurp
  register_build_requires register_system_requires register_hook 
  config
);
our @EXPORT    = @EXPORT_OK;

=head1 DESCRIPTION

This utility module provides some essential tools used by
the various L<Alien::Install> roles and classes.

=head1 FUNCTIONS

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

 my $filename     = catfile $dir, $subdir, $filename;
 my $dirname      = catdir  $dir, $subdir, $dirname;
 my $filepathname = catpath $volume, $directories, $filename;
 my $dirpathname  = catpath $volume, $directories;
 my($volume, $directories, $filename) = splitpath $path;
 my($volume, $directories           ) = splitpath $path,1;
 my @dir          = splitdir $dir;
 my $root         = rootdir;

These functions work just like their L<File::Spec>
equivalent, except they are functions instead of
class members, and on windows they use C</> instead
of C<\> as a path separator (the latter can sometimes 
cause problems as it is also used as an escaping
character).

=cut

sub rootdir ()
{
  my $name = File::Spec->rootdir;
  $name =~ s{\\}{/}g if $^O eq 'MSWin32';
  $name;
}

=head2 spew

 spew $filename, $content;

Write the C<$content> to the file specified by C<$filename>.

=cut

sub spew ($$)
{
  my($filename, $content) = @_;
  open my $fh, '>', $filename;
  binmode $fh;
  print $fh $content;
  close $fh;
}

=head2 slurp

 my $content = slurp $filename;

Read the C<$content> from the file specified by C<$filename>.

=cut

sub slurp ($)
{
  my($filename) = @_;
  open my $fh, '<', $filename;
  binmode $fh;
  local $/;
  my $data = <$fh>;
  close $fh;
  $data;
}

=head2 register_build_requires

 register_build_requires 'Foo::Bar' => 0;
 register_build_requires 'Foo::Baz' => 0.22;

Register a prerequisite for your class or role that
is required for I<building> your library.

This can be used by a L<Module::Build> class to
dynamically add building prerequisites if it
determines the library is not available from the
system.

=cut

our %build_requires;

sub register_build_requires (@)
{
  use Carp qw( confess );
  confess if @_ % 2;
  my %new = @_;
  my $class = caller;
  while(my($mod,$ver) = each %new)
  {
    $build_requires{$class}->{$mod} ||= $ver;
  }
}

=head2 register_system_requires

 register_system_requires 'Foo::Bar' => 0;
 register_system_requires 'Foo::Baz' => 0.22;

Register a prerequisite for your class or role
that is required for I<finding> your library
from the system.

This is similar to
L<register_build_requires|Alien::Install::Util#register_build_requires>
above, though you should keep in mind most of
the time these requirements will need to be
available at I<configure> time, and thus will
need to be static requirements.

=cut

our %system_requires;

sub register_system_requires (@)
{
  use Carp qw( confess );
  confess if @_ % 2;
  my %new = @_;
  my $class = caller;
  while(my($mod,$ver) = each %new)
  {
    $system_requires{$class}->{$mod} ||= $ver;
  }
}

our %hooks;

=head2 register_hook

 register_hook foo_event => sub {
   ...
 };

Register a hook for the given event.  See individual
roles for the events that they trigger.  Generally
hooks provided by roles are executed before hooks
provided by classes.

=cut

sub register_hook ($$)
{
  my($name, $sub) = @_;
  my $class = caller;
  push @{ $hooks{$class}->{$name} }, $sub;
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

=head1 SEE ALSO

=over 4

=item L<Alien::Install>

=back

=cut
