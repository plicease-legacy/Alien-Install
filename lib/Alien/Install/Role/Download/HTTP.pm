package Alien::Install::Role::Download::HTTP;

use strict;
use warnings;
use Role::Tiny;

# ABSTRACT: Installer role for downloading via HTTP

requires 'versions_url';
requires 'versions_process';
requires 'versions_sort';

sub versions
{
  my($class) = @_;
  require HTTP::Tiny;
  my $url = $class->versions_url;
  my $response = HTTP::Tiny->new->get($url);
  
  die sprintf("%s %s %s", $response->{status}, $response->{reason}, $url)
    unless $response->{success};

  my $process = $class->versions_process;
  
  if(ref($process) eq 'CODE')
  {
    return $class->versions_sort($process->($response->{content}));
  }
  elsif(ref($process) eq 'Regexp')
  {
    my @versions;
    push @versions, [$1,$2,$3] while $response->{content} =~ $process;
    return $class->versions_sort(@versions);
    
  }
}

1;
