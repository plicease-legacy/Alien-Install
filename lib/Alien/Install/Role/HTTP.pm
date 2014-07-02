package Alien::Install::Role::HTTP;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;

# ABSTRACT: Installer role for downloading via HTTP
# VERSION

requires 'alien_config_versions_url';
requires 'alien_config_versions_process';

sub _version_sort
{
  shift; # $class
  sort { $a <=> $b } @_;
}

sub versions
{
  my($class) = @_;
  require HTTP::Tiny;
  my $url = $class->alien_config_versions_url;
  my $response = HTTP::Tiny->new->get($url);
  
  die sprintf("%s %s %s", $response->{status}, $response->{reason}, $url)
    unless $response->{success};

  my $process = $class->alien_config_versions_process;
  
  my $sort = eval { $class->alien_config_versions_sort } || \&_version_sort;
  
  if(ref($process) eq 'CODE')
  {
    return $sort->($class, $process->($response->{content}));
  }
  elsif(ref($process) eq 'Regexp')
  {
    my %versions;
    $versions{$1} = 1 while $response->{content} =~ /$process/g;
    return $sort->($class, keys %versions);
    
  }
}

requires 'alien_config_fetch_url';

sub fetch
{
  my($class, %options) = @_;
  
  my $dir = $options{dir} || eval { require File::Temp; File::Temp::tempdir( CLEANUP => 1 ) };

  my $version = $options{version} || do {
    my @versions = $class->versions;
    die "unable to determine latest version from listing"
      unless @versions > 0;
    $versions[-1];
  };
  
  my $url = $class->alien_config_fetch_url->($class, $version);
  
  require HTTP::Tiny;  
  my $response = HTTP::Tiny->new->get($url);
  
  die sprintf("%s %s %s", $response->{status}, $response->{reason}, $url)
    unless $response->{success};
  
  my $fn = $url;
  $fn =~ s{^.*/}{};
  $fn = "tarball.tar.gz" unless $fn;    
  $fn = catfile($dir, $fn);
  
  open my $fh, '>', $fn;
  binmode $fh;
  print $fh $response->{content};
  close $fh;
  
  wantarray ? ($fn, $version) : $fn;
}

register_build_requires 'HTTP::Tiny' => 0;

1;
