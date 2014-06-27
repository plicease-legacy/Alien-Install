use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use File::Spec;
use Config;

BEGIN {
  plan skip_all => "set ALIEN_LZO_INSTALLER_EXTRA_TESTS to run test"
    unless $ENV{TRAVIS_JOB_ID} || $ENV{ALIEN_LZO_INSTALLER_EXTRA_TESTS};
  plan skip_all => "test requires HTTP::Tiny"
    unless eval q{ use HTTP::Tiny; 1 };
  plan skip_all => "test requires AnyEvent::Open3::Simple"
    unless eval q{ use AE; use AnyEvent::Open3::Simple; 1 };
}

BEGIN {
  if($^O eq 'MSWin32')
  {
    *CORE::GLOBAL::system = sub {
      note "% @_";
      CORE::system(@_);
    };
  }
  else
  {
    *CORE::GLOBAL::system = sub {
      my $done = AE::cv;
      my $ipc = AnyEvent::Open3::Simple->new(
        on_stdout => sub {
          my($proc,$line) = @_;
          note("stdout: $line");
        },
        on_stderr => sub {
          my($proc,$line) = @_;
          note "stderr: $line";
        },
        on_exit => sub {
          my($proc,$exit,$sig) = @_;
          $done->send($exit << 8 | $sig);
        },
        on_error => sub {
          $done->send(-1);
        },
      );
      note "% @_";
      $ipc->run(@_);
      $? = $done->recv;
    };
  }
}

use Alien::LZO::Installer;

plan tests => 1;

my $prefix = tempdir( CLEANUP => 1 );

my $type = eval { require FFI::Raw } ? 'both' : 'compile';
note "type = $type";

foreach my $version ('2.06')
{
  subtest "build version $version" => sub {
    plan tests => 5;
    my $tar = Alien::LZO::Installer->fetch( version => $version );
    my $installer = eval { Alien::LZO::Installer->build_install( File::Spec->catdir($prefix, $version), tar => $tar, test => $type ) };
    is $@, '', 'no error';
    SKIP: {
      skip "can't test \$installer without a sucessful build", 4 if $@ ne '';
      is $installer->version, $version,  "version = $version";
      ok $installer->{libs},  "libs = ". join(' ', @{ $installer->libs });
      ok $installer->{cflags}, "cflags = ". join(' ', @{ $installer->cflags });
      my $inc = File::Spec->catfile($prefix, $version, 'include', 'lzo');
      ok -r $inc, "created directory $inc";
    };
  };
}
