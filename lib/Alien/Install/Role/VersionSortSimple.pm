package Alien::Install::Role::VersionSortSimple;

use strict;
use warnings;
use Role::Tiny;

# ABSTRACT: Sort versions that are a simple floating point value
# VERSION

around versions => sub {
  my $orig  = shift;
  my $class = shift;
  my %list = map { $_ => 1 } $orig->($class, @_);
  sort { $a <=> $b } keys %list;
};

1;
