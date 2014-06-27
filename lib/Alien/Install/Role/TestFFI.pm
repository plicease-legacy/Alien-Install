package Alien::Install::Role::TestFFI;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;

# ABSTRACT: Test ffi alien role
# VERSION

requires 'test_ffi_signature';
requires 'test_ffi_version';

sub test_ffi
{
  my($self) = @_;
  require FFI::Raw;
  delete $self->{error};
  
  my @sig = $self->test_ffi_signature;
  
  foreach my $dll ($self->dlls)
  {
    my $function = eval {
      FFI::Raw->new(
        $dll,
        @sig,
      );
    };
    next if $@;
    my $version = $self->test_ffi_version($function);
    return $self->{version} = $version if defined $version;
  }
  $self->{error} = "could not find $sig[0]";
  return;
}

1;
