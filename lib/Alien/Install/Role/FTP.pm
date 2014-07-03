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
register_build_requires 'Net::FTP' => 0;

sub _ftp
{
  my($config) = @_;
  require Net::FTP;
  
  $config->{user}     ||= 'anonymous';
  $config->{password} ||= 'anonymous@';
  $config->{dir}      ||= '/';
  
  $config->{host}  || croak "requires config.ftp.host";
  
  my $ftp = Net::FTP->new($config->{host}) || die "unable to connect to " . $config->{host};
  $ftp->login($config->{user}, $config->{password}) || die "unable to login to " . $config->{host};
  $ftp->binary;
  $ftp->cwd($config->{dir}) || die "unable to change to " . $config->{dir};
  $ftp;
}

sub versions
{
  my($class) = @_;

  my $ftp = _ftp($class->alien_config_ftp);

  my $match = $class->alien_config_ftp->{match} || do {
    my $name = $class->alien_config_name;
    qr{^lib$name-([0-9]+(\.[0-9]+)+)\.tar\.gz$},
  };

  my @list = 
    map { $_ =~ $match; $1 }
    grep { $_ =~ $match } $ftp->ls;
  
  $ftp->quit;

  @list;
}

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

  my $ftp = _ftp($class->alien_config_ftp);
  
  my $filename = "lib" . $class->alien_config_name . "-$version.tar.gz";
  
  $ftp->get($filename, catfile($dir, $filename)) || die "unable to get $filename";
  
  $filename = catfile($dir, $filename);
  
  $ftp->quit;

  wantarray ? ($filename, $version) : $filename;
}

1;
