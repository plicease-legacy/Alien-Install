package Alien::Libarchive::Installer;

use strict;
use warnings;
use Role::Tiny::With;
use Alien::Install::Util;
use Carp qw( carp );

# ABSTRACT: Installer for libarchive
# VERSION

config
  name             => 'archive',
  versions_url     => 'http://www.libarchive.org/downloads/',
  versions_process => sub {
    my($content) = @_;
    my @versions;
    push @versions, "$1.$2.$3" while $content =~ /libarchive-([1-9][0-9]*)\.([0-9]+)\.([0-9]+)\.tar.gz/g;
    @versions;
  },
  versions_sort    => sub {
    shift; # $class
    map { join '.', @$_ } 
    sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] || $a->[2] <=> $b->[2] } 
    map { [split /\./, $_] }
    @_;
  },
  fetch_url        => sub {
    my(undef, $version) = @_;
    "http://www.libarchive.org/downloads/libarchive-$version.tar.gz";
  },
  test_compile_run_program => join ("\n",
    "#include <archive.h>",
    "#include <archive_entry.h>",
    "#include <stdio.h>",
    "int",
    "main(int argc, char *argv[])",
    "{",
    "  printf(\"version = '%s'\\n\", archive_version_string());",
    "  return 0;",
    "}",
    "",
  ),
  test_compile_run_match => qr{version = 'libarchive (.*?)'},
  test_ffi_signature     => [ 'archive_version_number', 'int' ],
  test_ffi_version       => sub {
    my(undef, $function) = @_;
    return join '.', map { int } $1, $2, $3 if $function->() =~ /^([0-9]+)([0-9]{3})([0-9]{3})/;
    return;
  },
;

register_hook 'pre_instantiate' => sub {
  my($class, $flags) = @_;
  my $pkg_config_dir = catdir $flags->{prefix}, 'lib', 'pkgconfig';
  push @{ $flags->{cflags} }, @{ _try_pkg_config($pkg_config_dir, 'cflags', '', '--static') };
  push @{ $flags->{cflags} }, '-DLIBARCHIVE_STATIC' if $^O =~ /^(cygwin|MSWin32)$/;
  push @{ $flags->{libs} }, @{ _try_pkg_config($pkg_config_dir, 'libs',   '-larchive', '--static') };
};

if($^O eq 'MSWin32' && do { require Config; $Config::Config{cc} =~ /cl(\.exe)?$/i })
{
  with qw(
    Alien::Install::Role::Installer
    Alien::Install::Role::HTTP
    Alien::Install::Role::Tar 
    Alien::Install::Role::CMake
    Alien::Install::Role::TestCompileRun
    Alien::Install::Role::TestFFI
  );
}
else
{
  with qw(
    Alien::Install::Role::Installer
    Alien::Install::Role::HTTP
    Alien::Install::Role::Tar 
    Alien::Install::Role::Autoconf
    Alien::Install::Role::TestCompileRun
    Alien::Install::Role::TestFFI
  );
  
  register_build_requires 'PkgConfig'   => '0.07620' if $^O eq 'MSWin32';
}

=head1 SYNOPSIS

Build.PL

 # as an optional dep
 use Alien::Libarchive::Installer;
 use Module::Build;
 
 my %build_args;
 
 my $installer = eval { Alien::Libarchive::Installer->system_install };
 if($installer)
 {
   $build_args{extra_compiler_flags} = $installer->cflags;
   $build_args{extra_linker_flags}   = $installer->libs;
 }
 
 my $build = Module::Build->new(%build_args);
 $build->create_build_script;

Build.PL

 # require 3.0
 use Alien::Libarchive::Installer;
 use Module::Build;
 
 my $installer = eval {
   my $system_installer = Alien::Libarchive::Installer->system_install;
   die "we require 3.0.x or better"
     if $system->version !~ /^([0-9]+)\./ && $1 >= 3;
   $system_installer;
      # reasonably assumes that build_install will never download
      # a version older that 3.0
 } || Alien::Libarchive::Installer->build_install("dir");
 
 my $build = Module::Build->new(
   extra_compiler_flags => $installer->cflags,
   extra_linker_flags   => $installer->libs,
 );
 $build->create_build_script;

FFI::Raw

 # as an optional dep
 use Alien::Libarchive::Installer;
 use FFI::Raw;
 
 eval {
   my($dll) = Alien::Libarchive::Installer->system_install->dlls;
   FFI::Raw->new($dll, 'archive_read_new', FFI::Raw::ptr);
 };
 if($@)
 {
   # handle it if libarchive is not available
 }

=head1 DESCRIPTION

B<Note>: I am in the process of refactoring this into a more generic
set of roles that can be used for other "installer" classes.  Until
the refactoring process is complete it will be quite messy in here.

This distribution contains the logic for finding existing libarchive
installs, and building new ones.  If you do not care much about the
version of libarchive that you use, and libarchive is not an optional
requirement, then you are probably more interested in using
L<Alien::Libarchive>.

Where L<Alien::Libarchive::Installer> is useful is when you have
specific version requirements (say you require 3.0.x but 2.7.x
will not do), but would still like to use the system libarchive
if it is available.

=head1 CLASS METHODS

Class methods can be executed without creating an instance of
L<Alien::libarchive::Installer>, and generally used to query
status of libarchive availability (either via the system or the
internet).  Methods that discover a system libarchive or build
a one from source code on the Internet will generally return
an instance of L<Alien::Libarchive::Installer> which can be
queried to retrieve the settings needed to interact with 
libarchive via XS or L<FFI::Raw>.

=head2 versions

 my @versions = Alien::Libarchive::Installer->versions;
 my $latest_version = $versions[-1];

Return the list of versions of libarchive available on the Internet.
Will throw an exception if the libarchive.org website is unreachable.
Versions will be sorted from oldest (smallest) to newest (largest).

=head2 fetch

 my($location, $version) = Alien::Libarchive::Installer->fetch(%options);
 my $location = Alien::Libarchive::Installer->fetch(%options);

B<NOTE:> using this method may (and probably does) require modules
returned by the L<build_requires|Alien::Libarchive::Installer#build_requires>
method.

Download libarchive source from the internet.  By default it will
download the latest version to a temporary directory which will
be removed when Perl exits.  Will throw an exception on
failure.  Options include:

=over 4

=item dir

Directory to download to

=item version

Version to download

=back

=head2 build_requires

 my $prereqs = Alien::Libarchive::Installer->build_requires;
 while(my($module, $version) = each %$prereqs)
 {
   ...
 }

Returns a hash reference of the build requirements.  The
keys are the module names and the values are the versions.

The requirements may be different depending on your
platform.

=head2 system_requires

This is like L<build_requires|Alien::Libarchive::Installer#build_requires>,
except it is used when using the libarchive that comes with the operating
system.

=head2 system_install

 my $installer = Alien::Libarchive::Installer->system_install(%options);

B<NOTE:> using this method may require modules returned by the
L<system_requires|Alien::Libarchive::Installer> method.

B<NOTE:> This form will also use the libarchive provided by L<Alien::Libarchive>
if version 0.21 or better is installed.  This makes this method ideal for
finding libarchive as an optional dependency.

Options:

=over 4

=item test

Specifies the test type that should be used to verify the integrity
of the system libarchive.  Generally this should be
set according to the needs of your module.  Should be one of:

=over 4

=item compile

use L<test_compile_run|Alien::Libarchive::Installer#test_compile_run> to verify.
This is the default.

=item ffi

use L<test_ffi|Alien::Libarchive::Installer#test_ffi> to verify

=item both

use both
L<test_compile_run|Alien::Libarchive::Installer#test_compile_run>
and
L<test_ffi|Alien::Libarchive::Installer#test_ffi>
to verify

=back

=item alien

If true (the default) then an existing L<Alien::Libarchive> will be
used if version 0.21 or better is found.  Usually this is what you
want.

=back

=cut

# TODO: move to Alien::Install::*
sub system_install
{
  my($class, %options) = @_;

  $options{alien} = 1 unless defined $options{alien};
  $options{test} ||= 'compile';
  die "test must be one of compile, ffi or both"
    unless $options{test} =~ /^(compile|ffi|both)$/;

  if($options{alien} && eval q{ use Alien::Libarchive 0.21; 1 })
  {
    my $alien = Alien::Libarchive->new;
    
    my $dir;
    my(@dlls) = map { 
      my($v,$d,$f) = splitpath $_; 
      $dir = [$v,splitdir $d]; 
      $f;
    } $alien->dlls;
    
    my $build = bless {
      cflags  => [$alien->cflags],
      libs    => [$alien->libs],
      dll_dir => $dir,
      dlls    => \@dlls,
      prefix  => rootdir,
    }, $class;
    eval {
      $build->test_compile_run || die $build->error if $options{test} =~ /^(compile|both)$/;
      $build->test_ffi || die $build->error if $options{test} =~ /^(ffi|both)$/;
    };
    return $build unless $@;
  }
  
  my $build = bless {
    cflags => _try_pkg_config(undef, 'cflags', '', ''),
    libs   => _try_pkg_config(undef, 'libs',   '-larchive', ''),
  }, $class;
  
  if($options{test} =~ /^(ffi|both)$/)
  {
    my @dir_search_list;
    
    if($^O eq 'MSWin32')
    {
      # On MSWin32 the entire path is not included in dl_library_path
      # buth that is the most likely place that we will find dlls.
      @dir_search_list = grep { -d $_ } split /;/, $ENV{PATH};
    }
    else
    {
      require DynaLoader;
      @dir_search_list = grep { -d $_ } @DynaLoader::dl_library_path
    }
    
    found_dll: foreach my $dir (@dir_search_list)
    {
      my $dh;
      opendir($dh, $dir) || next;
      # sort by filename length so that libarchive.so.12.0.4
      # is preferred over libarchive.so.12 or libarchive.so
      # if only to make diagnostics point to the more specific
      # version.
      foreach my $file (sort { length $b <=> length $a } readdir $dh)
      {
        if($^O eq 'MSWin32')
        {
          next unless $file =~ /^libarchive-[0-9]+\.dll$/i;
        }
        elsif($^O eq 'cygwin')
        {
          next unless $file =~ /^cygarchive-[0-9]+\.dll$/i;
        }
        else
        {
          next unless $file =~ /^libarchive\.(dylib|so(\.[0-9]+)*)$/;
        }
        my($v,$d) = splitpath $dir, 1;
        $build->{dll_dir} = [splitdir $d];
        $build->{prefix}  = $v;
        $build->{dlls}    = [$file];
        closedir $dh;
        last found_dll;
      }
      closedir $dh;
    }
  }
  
  $build->test_compile_run || die $build->error if $options{test} =~ /^(compile|both)$/;
  $build->test_ffi || die $build->error if $options{test} =~ /^(ffi|both)$/;
  $build;
}

=head2 build_install

 my $installer = Alien::Libarchive::Installer->build_install( '/usr/local', %options );

B<NOTE:> using this method may (and probably does) require modules
returned by the L<build_requires|Alien::Libarchive::Installer>
method.

Build and install libarchive into the given directory.  If there
is an error an exception will be thrown.  On a successful build, an
instance of L<Alien::Libarchive::Installer> will be returned.

These options may be passed into build_install:

=over 4

=item archive

Filename where the libarchive source tarball is located.
If not specified the latest version will be downloaded
from the Internet.

=item dir

Empty directory to be used to extract the libarchive
source and to build from.

=item test

Specifies the test type that should be used to verify the integrity
of the build after it has been installed.  Generally this should be
set according to the needs of your module.  Should be one of:

=over 4

=item compile

use L<test_compile_run|Alien::Libarchive::Installer#test_compile_run> to verify.
This is the default.

=item ffi

use L<test_ffi|Alien::Libarchive::Installer#test_ffi> to verify

=item both

use both
L<test_compile_run|Alien::Libarchive::Installer#test_compile_run>
and
L<test_ffi|Alien::Libarchive::Installer#test_ffi>
to verify

=back

=back

=cut

sub _try_pkg_config
{
  my($dir, $field, $guess, $extra) = @_;
  
  unless(defined $dir)
  {
    require File::Temp;
    $dir = File::Temp::tempdir(CLEANUP => 1);
  }
  
  require Config;
  local $ENV{PKG_CONFIG_PATH} = join $Config::Config{path_sep}, $dir, split /$Config::Config{path_sep}/, ($ENV{PKG_CONFIG_PATH}||'');

  my $value = eval {
    # you probably think I am crazy...
    eval q{ use PkgConfig 0.07620 };
    die $@ if $@;
    my $value = `$^X $INC{'PkgConfig.pm'} libarchive $extra --$field`;
    die if $?;
    $value;
  };

  unless(defined $value) {
    $value = `pkg-config libarchive $extra --$field`;
    return $guess if $?;
  }
  
  chomp $value;
  require Text::ParseWords;
  [Text::ParseWords::shellwords($value)];
}

register_hook post_install => sub {
  my($class, $prefix) = @_;

  my $pkg_config_dir = catdir $prefix, 'lib', 'pkgconfig';
  my $pcfile = catfile $pkg_config_dir, 'libarchive.pc';
    
  my @content;
  require Config;
  if($Config::Config{cc} !~ /cl(\.exe)?$/i)
  {
    open my $fh, '<', $pcfile;
    @content = map { s{$prefix}{'${pcfiledir}/../..'}eg; $_ } do { <$fh> };
    close $fh;
  }
  else
  {
    # TODO: later when we know the version with more
    # certainty, we can update this file with the
    # Version
    @content = join "\n", "prefix=\${pcfiledir}/../..",
                          "exec_prefix=\${prefix}",
                          "libdir=\${exec_prefix}/lib",
                          "includedir=\${prefix}/include",
                          "Name: libarchive",
                          "Description: library that can create and read several streaming archive formats",
                          "Cflags: -I\${includedir}",
                          "Libs: advapi32.lib \${libdir}/archive_static.lib",
                          "Libs.private: ",
                          "";
    require File::Path;
    File::Path::mkpath($pkg_config_dir, 0, 0755);
  }
      
  my($version) = map { /^Version:\s*(.*)$/; $1 } grep /^Version: /, @content;
  # older versions apparently didn't include the necessary -I and -L flags
  if(defined $version && $version =~ /^[12]\./)
  {
    for(@content)
    {
      s/^Libs: /Libs: -L\${libdir} /;
    }
    push @content, "Cflags: -I\${includedir}\n";
  }
      
  open my $fh, '>', $pcfile;
  print $fh @content;
  close $fh;
};

=head1 ATTRIBUTES

Attributes of an L<Alien::Libarchive::Installer> provide the
information needed to use an existing libarchive (which may
either be provided by the system, or have just been built
using L<build_install|Alien::Libarchive::Installer#build_install>.

=head2 cflags

The compiler flags required to use libarchive.

=head2 libs

The linker flags and libraries required to use libarchive.

=head2 dlls

List of DLL or .so (or other dynamic library) files that can
be used by L<FFI::Raw> or similar.

=head2 version

The version of libarchive

=head1 INSTANCE METHODS

=head2 test_compile_run

 if($installer->test_compile_run(%options))
 {
   # You have a working Alien::Libarchive as
   # specified by %options
 }
 else
 {
   die $installer->error;
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

=item quiet

Passed into L<ExtUtils::CBuilder> if you do not
provide your own instance.  The default is true
(unlike L<ExtUtils::CBuilder> itself).

=back

=head2 test_ffi

 if($installer->test_ffi(%options))
 {
   # You have a working Alien::Libarchive as
   # specified by %options
 }
 else
 {
   die $installer->error;
 }

Test libarchive to see if it can be used with L<FFI::Raw>
(or similar).  On success it will return the libarchive
version.

=head2 error

Returns the error from the previous call to L<test_compile_run|Alien::Libarchive::Installer#test_compile_run>
or L<test_ffi|Alien::Libarchive::Installer#test_ffi>.

=cut

1;

=head1 SEE ALSO

=over 4

=item L<Alien::Libarchive>

=item L<Archive::Libarchive::XS>

=item L<Archive::Libarchive::FFI>

=item L<Archive::Libarchive::Any>

=item L<Archive::Ar::Libarchive>

=item L<Archive::Peek::Libarchive>

=item L<Archive::Extract::Libarchive>

=back

=cut
