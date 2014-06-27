package inc::InstallerBeta;

use strict;
use warnings;
use Moose;

with qw( Dist::Zilla::Role::FileMunger );

sub munge_files
{
  my($self) = @_;
  $self->munge_file_install($_) for grep { $_->name =~ m{^lib/Alien/Install} } @{ $self->zilla->files };
  $self->munge_file_bz2($_) for grep { $_->name =~ m{^lib/Alien/bz2} } @{ $self->zilla->files };
}

sub munge_file_install
{
  my($self, $file) = @_;
  $self->log("file = " . $file->name);
  my $content = $file->content;
  $content =~ s/^.*# VERSION/our \$VERSION = '0.01_01'; # VERSION/m;
  $file->content($content);
}

sub munge_file_bz2
{
  my($self, $file) = @_;
  $self->log("file = " . $file->name);
  my $content = $file->content;
  $content =~ s/^.*# VERSION/our \$VERSION = '0.03_01'; # VERSION/m;
  $file->content($content);
}

1;
