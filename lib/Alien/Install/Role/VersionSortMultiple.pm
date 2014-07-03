package Alien::Install::Role::VersionSortMultiple;

use strict;
use warnings;
use Role::Tiny;

# ABSTRACT: Sort versions that are a multiple integers separated by dot
# VERSION

my $cmp = sub {
  my @a = @{$_[0]};
  my @b = @{$_[1]};
  
  while(@a > 0 || @b > 0)
  {
    my($a,$b) = (shift(@a)||0, shift(@b)||0);
    return $a <=> $b if $a <=> $b;
  }
  
  0
};

around versions => sub {
  my $orig  = shift;
  my $class = shift;
  my %list = map { $_ => 1 } @_;
  map { join '.', @$_ }
  sort { $cmp->($a, $b) }
  map { [split /\./] }
  $orig->($class, keys %list);
};

1;
