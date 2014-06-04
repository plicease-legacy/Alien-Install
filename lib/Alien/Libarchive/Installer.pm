package Alien::Libarchive::Installer;

use strict;
use warnings;

# ABSTRACT: Installer for libarchive
# VERSION

=head1 METHODS

=head2 new

 my $installer = Alien::Libarchive::Installer->new;

Create a new instance of Alien::Libarchive::Installer.

=cut

sub new
{
  my($class) = @_;
  my $self = bless {}, $class;
  $self;
}

=head2 test_compile_run

 if($installer->test_compile_run(%options))
 {
   # You have a working Alien::Libarchive as
   # specified by %options
 }

Tests the compiler to see if you can build and run
a simple libarchive program.  On success it will 
return the libarchive version.  Other options include

=over 4

=item cbuilder

The L<ExtUtils::CBuilder> instance that you want
to use.  If not specified, then a new one will
be created.

=item dir

Directory to use for building the executable.
If not specified, a temporary directory will be
created and removed when Perl terminates.

=item extra_compiler_flags

Extra flags to pass to C<$cbuilder> during the
compile step.  Should be either a list reference
or string, see L<ExtUtils::CBuilder#compile>.

=item extra_linker_flags

Extra flags to pass to C<$cbuilder> during the
link step.  Should be either a list reference
or string, see L<ExtUtils::CBuilder#link>.

=back

=cut

sub test_compile_run
{
  my($self, %opt) = @_;
  delete $self->{error};
  my $cbuilder = $opt{cbuilder} || do { require ExtUtils::CBuilder; ExtUtils::CBuilder->new(quiet => 1) };
  
  unless($cbuilder->have_compiler)
  {
    $self->{error} = 'no compiler';
    return;
  }
  
  return unless $cbuilder->have_compiler;
  require File::Spec;
  my $dir = $opt{dir} || do { require File::Temp; File::Temp::tempdir( CLEANUP => 1 ) };
  my $fn = File::Spec->catfile($dir, 'test.c');
  do {
    open my $fh, '>', $fn;
    print $fh "#include <archive.h>\n",
              "#include <archive_entry.h>\n",
              "#include <stdio.h>\n",
              "int\n",
              "main(int argc, char *argv[])\n",
              "{\n",
              "  printf(\"version = '%d'\\n\", archive_version_number());\n",
              "  return 0;\n",
              "}\n";
    close $fh;
  };
  
  my $test_object = eval {
    $cbuilder->compile(
      source               => $fn,
      extra_compiler_flags => $opt{extra_compiler_flags} || [],
    );
  };
  
  if(my $error = $@)
  {
    $self->{error} = $error;
    return;
  }
  
  my $test_exe = eval {
    $cbuilder->link_executable(
      objects            => $test_object,
      extra_linker_flags => $opt{extra_linker_flags} || [],
    );
  };
  
  if(my $error = $@)
  {
    $self->{error} = $error;
    return;
  }
  
  if($test_exe =~ /\s/)
  {
    $test_exe = Win32::GetShortPathName($test_exe) if $^O eq 'MSWin32';
    $test_exe = Cygwin::win_to_posix_path(Win32::GetShortPathName(Cygwin::posix_to_win_path($test_exe))) if $^O eq 'cygwin';
  }
  
  my $output = `$test_exe`;
  
  if($? == -1)
  {
    $self->{error} = "failed to execute $!";
    return;
  }
  elsif($? & 127)
  {
    $self->{error} = "child died with siganl " . ($? & 127);
    return;
  }
  elsif($?)
  {
    $self->{error} = "child exited with value " . ($? >> 8);
    return;
  }
  
  if($output =~ /version = '([0-9]+)([0-9]{3})([0-9]{3})'/)
  {
    return join '.', map { int } $1, $2, $3;
  }
  else
  {
    $self->{error} = "unable to retrieve version from output";
    return;
  }
}

=head2 error

Returns the error from the previous call to L<test_compile_run|Alien::Libarchive::Installer#test_compile_run>.

=cut

sub error { shift->{error} }

=head2 build_requires

 my $prereqs = $installer->build_requires;
 while(my($module, $version) = each %$prereqs)
 {
   ...
 }

Returns a hash reference of the build requirements.  The
keys are the module names and the values are the versions.

=cut

sub build_requires
{
  my %prereqs = {
    'HTTP::Tiny' => '0.043',
  };
  
  if($^O eq 'MSWin32')
  {
    require Config;
    if($Config::Config{cc} =~ /cl(\.exe)?$/i || $Config::Config{ld} =~ /link(\.exe)?$/i)
    {
      $prereqs{'Alien::CMake'} = '0.05';
    }
    else
    {
      $prereqs{'Alien::MSYS'} = '0,07';
    }
  }
  
  \%prereqs;
}

1;
