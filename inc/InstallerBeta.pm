package inc::InstallerBeta;

use strict;
use warnings;
use Moose;

with qw( Dist::Zilla::Role::FileMunger );

sub munge_files
{
  my($self) = @_;
  $self->munge_file($_) for grep { $_->name =~ m{^lib/Alien/Install} } @{ $self->zilla->files };
}

sub munge_file
{
  my($self, $file) = @_;
  $self->log("file = " . $file->name);
  my $content = $file->content;
  $content =~ s/^.*# VERSION/our \$VERSION = '0.01_01'; # VERSION/m;
  $file->content($content);
}

1;
