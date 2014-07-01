use strict;
use warnings;
use Test::More tests => 2;
use Alien::Install::Example::Libfoo::Installer;

is ref(Alien::Install::Example::Libfoo::Installer->build_requires), 'HASH', 'build_requires';

my %req = %{ Alien::Install::Example::Libfoo::Installer->build_requires };
foreach my $module (sort keys %req)
{
  note "$module=$req{$module}";
}

is_deeply(
  Alien::Install::Example::Libfoo::Installer->build_requires,
  { 'Archive::Tar' => 0, 'ExtUtils::CBuilder' => 0, 'HTTP::Tiny' => 0 },
  'content',
);
