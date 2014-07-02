package Alien::Install::Role::TestFFI;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;

# ABSTRACT: Test ffi alien role
# VERSION

requires '_config_test_ffi_signature';
requires '_config_test_ffi_version';

sub test_ffi
{
  my($self) = @_;
  require FFI::Raw;
  delete $self->{error};
  
  my($name, $ret, @args) = @{ $self->_config_test_ffi_signature };

  my @sig = ($name, map { my $val = eval qq{FFI::Raw::$_()}; $@ ? die $@ : $val } ($ret, @args));
  
  foreach my $dll ($self->dlls)
  {
    my $function = eval {
      FFI::Raw->new(
        $dll,
        @sig,
      );
    };
    next if $@;
    my $version = $self->_config_test_ffi_version->($self, $function);
    return $self->{version} = $version if defined $version;
  }
  $self->{error} = "could not find $sig[0]";
  return;
}

1;
