use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, 'lib');
use Alien::Install::Util qw( catfile slurp );
use Alien::Install::Example::Libfoo::Installer;
use Test::More;

plan tests => 2;

my $expected = slurp catfile $FindBin::Bin, 'libfoo-1.00.tar.gz';

subtest 'specific version' => sub {
  plan tests => 3;
  my($location,$version) = eval { Alien::Install::Example::Libfoo::Installer->fetch(version => '1.00') };
  diag $@ if $@;
  ok -r $location, 'downloaded version 1.00';
  note $location;
  is $version, '1.00', "download version 1.00 is 1.00";
  my $actual = slurp $location;
  ok $actual eq $expected, 'content matches';
};

subtest 'latest version' => sub {
  plan tests => 3;
  my($location,$version) = eval { Alien::Install::Example::Libfoo::Installer->fetch };
  diag $@ if $@;
  ok -r $location, 'downloaded latest';
  note $location;
  is $version, '1.00', "download version latest is 1.00";
  my $actual = slurp $location;
  ok $actual eq $expected, 'content matches';
};
