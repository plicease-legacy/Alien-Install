package Alien::Install::Role::Tar;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;

# ABSTRACT: Alien::Install role to extract from tar files

sub extract
{
  my($class, $archive, $dir) = @_;
  
  require Archive::Tar;
  my $tar = Archive::Tar->new;
  $tar->read($archive);
  
  require Cwd;
  my $save = Cwd::getcwd();
  chdir $dir;
  
  eval {
    $tar->extract;
  };
  
  my $error = $@;
  chdir $save;
  die $error if $error;
}

register_build_requires 'Archive::Tar' => 0;

sub chdir_source
{
  my($class, $dir) = @_;
  chdir $dir;
  chdir do {
    opendir my $dh, '.';
    my @list = grep !/^\./, readdir $dh;
    closedir $dh;
    die "unable to find source in build root" if @list == 0;
    die "confused by multiple entries in the build root" if @list > 1;
    $list[0];
  };
}

1;
