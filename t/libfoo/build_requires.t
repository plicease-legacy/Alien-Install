use strict;
use warnings;
use Test::More tests => 4;
use Alien::Install::Example::Libfoo::Installer;

my $req = Alien::Install::Example::Libfoo::Installer->build_requires;

is ref($req), 'HASH', 'build_requires';

my %req = %{ Alien::Install::Example::Libfoo::Installer->build_requires };
foreach my $module (sort keys %req)
{
  note "$module=$req{$module}";
}

is $req{'Archive::Tar'},       0, "Archive::Tar       = 0";
is $req{'ExtUtils::CBuilder'}, 0, "ExtUtils::CBuilder = 0";
is $req{'HTTP::Tiny'},         0, "HTTP::Tiny         = 0";

