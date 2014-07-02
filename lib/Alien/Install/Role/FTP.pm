package Alien::Install::Role::FTP;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;
use Carp qw( croak );

# ABSTRACT: Installer role for downloading via FTP
# VERSION

requires 'alien_config_ftp';
requires 'alien_config_name';

# host dir match

sub versions
{
  my($class) = @_;
  require Net::FTP;
  
  my $config = $class->alien_config_ftp;
  
  $config->{user}     ||= 'anonymous';
  $config->{password} ||= 'anonymous@';
  $config->{dir}      ||= '/';
  
  $config->{host}  || croak "requires config.ftp.host";
  $config->{match} ||= do {
    my $name = $class->alien_config_name;
    qr{^lib$name-([0-9]+(\.[0-9]+)+)\.tar\.gz$},
  };
  
  my $match = $config->{match};
  
  my $ftp = Net::FTP->new($config->{host}) || die "unable to connect to " . $config->{host};
  $ftp->login($config->{user}, $config->{password}) || die "unable to login to " . $config->{host};
  $ftp->cwd($config->{dir}) || die "unable to change to " . $config->{dir};
  
  my @list = 
    map { $_ =~ $match; $1 }
    grep { $_ =~ $match } $ftp->ls;
  
  $ftp->quit;

  # TODO: needs to be sorted  
  @list;
}

sub fetch
{

=pod
  
  my($class, %options) = @_;
  
  my $dir = $options{dir} || eval { require File::Temp; File::Temp::tempdir( CLEANUP => 1 ) };
  
  my $version = $options{version} || do {
    my @versions = $class->versions;
    die "unable to determine latest version from listing"
      unless @versions > 0;
    $versions[-1];
  };

  require Net::FTP;  

=cut
  
  require Net::FTP;
  die 'todo';
}

register_build_requires 'Net::FTP' => 0;

1;
