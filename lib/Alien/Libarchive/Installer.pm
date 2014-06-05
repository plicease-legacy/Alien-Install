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

 my %options = ( extra_linker_flags = '-larchive' );
 if($installer->test_compile_run(%options)
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

=head2 versions_available

 my @versions = $installer->versions_available;

Return the list of versions of libarchive available on the Internet.
Will throw an exception if the libarchive.org website is unreachable.

=cut

sub versions_available
{
  require HTTP::Tiny;
  my $url = "http://www.libarchive.org/downloads/";
  my $response = HTTP::Tiny->new->get($url);
  
  die sprintf("%s %s %s", $response->{status}, $response->{reason}, $url)
    unless $response->{success};

  my @versions;
  push @versions, [$1,$2,$3] while $response->{content} =~ /libarchive-([1-9][0-9]*)\.([0-9]+)\.([0-9]+)\.tar.gz/g;
  @versions = map { join '.', @$_ } sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] || $a->[2] <=> $b->[2] } @versions;
}

=head2 fetch

 my($location, $version) = $installer->fetch(%options);
 my $location = $installer->fetch(%options);

B<NOTE:> using this method may (and probably does) require modules
returned by the L<build_requires|Alien::Libarchive::Installer>
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

=cut

sub fetch
{
  my($self, %options) = @_;
  
  my $dir = $options{dir} || eval { require File::Temp; File::Temp::tempdir( CLEANUP => 1 ) };

  require HTTP::Tiny;  
  my $version = $options{version} || do {
    my @versions = $self->versions_available;
    die "unable to determine latest version from listing"
      unless @versions > 0;
    $versions[-1];
  };

  if(defined $ENV{ALIEN_LIBARCHIVE_INSTALL_MIRROR})
  {
    my $fn = File::Spec->catfile($ENV{ALIEN_LIBARCHIVE_INSTALL_MIRROR}, "libarchive-$version.tar.gz");
    return wantarray ? ($fn, $version) : $fn;
  }

  my $url = "http://www.libarchive.org/downloads/libarchive-$version.tar.gz";
  
  my $response = HTTP::Tiny->new->get($url);
  
  die sprintf("%s %s %s", $response->{status}, $response->{reason}, $url)
    unless $response->{success};
  
  require File::Spec;
  
  my $fn = File::Spec->catfile($dir, "libarchive-$version.tar.gz");
  
  open my $fh, '>', $fn;
  binmode $fh;
  print $fh $response->{content};
  close $fh;
  
  wantarray ? ($fn, $version) : $fn;
}

=head2 build_install

 my %build = $installer->build_install( '/usr/local', %options );

B<NOTE:> using this method may (and probably does) require modules
returned by the L<build_requires|Alien::Libarchive::Installer>
method.

Build and install libarchive into the given directory.  If there
is an error an exception will be thrown.  A hash with these fields
will be returned on success:

=over 4

=item version

=item extra_compiler_flags

=item extra_linker_flags

=back

These options may be passed into build_install:

=over 4

=item tar

Filename where the libarchive source tar is located.
If not specified the latest version will be downloaded
from the Internet.

=item dir

Empty directory to be used to extract the libarchive
source and to build from.

=back

=cut

sub _try_pkg_config
{
  my($dir, $field, $guess) = @_;
  
  require Config;
  local $ENV{PKG_CONFIG_PATH} = join $Config::Config{path_sep}, $dir, split /$Config::Config{path_sep}/, ($ENV{PKG_CONFIG_PATH}||'');

  my $value = eval {
    # you probably think I am crazy...
    eval q{ use PkgConfig 0.07620 };
    die $@ if $@;
    my $value = `$^X $INC{'PkgConfig.pm'} libarchive --$field`;
    die if $?;
    $value;
  };

  unless(defined $value) {
    $value = `pkg-config libarchive --static --$field`;
    return $guess if $?;
  }
  
  chomp $value;
  require Text::ParseWords;
  [Text::ParseWords::shellwords($value)];
}

sub _msys
{
  my($sub) = @_;
  require Config;
  if($^O eq 'MSWin32')
  {
    if($Config::Config{cc} !~ /cl(\.exe)?$/i)
    {
      require Alien::MSYS;
      return Alien::MSYS::msys(sub{ $sub->('make') });
    }
  }
  $sub->($Config::Config{make});
}

sub build_install
{
  my($self, $prefix, %options) = @_;
  
  die "need an install prefix" unless $prefix;
  
  $prefix =~ s{\\}{/}g;
  
  my $dir = $options{dir} || do { require File::Temp; File::Temp::tempdir( CLEANUP => 1 ) };
  
  require Archive::Tar;
  my $tar = Archive::Tar->new;
  $tar->read($options{tar} || $self->fetch);
  
  require Cwd;
  my $save = Cwd::getcwd();
  
  chdir $dir;  
  my $build = eval {
  
    $tar->extract;

    chdir do {
      opendir my $dh, '.';
      my(@list) = grep !/^\./,readdir $dh;
      close $dh;
      die "unable to find source in build root" if @list == 0;
      die "confused by multiple entries in the build root" if @list > 1;
      $list[0];
    };
  
    _msys(sub {
      my($make) = @_;
      system 'sh', 'configure', "--prefix=$prefix", '--with-pic';
      die "configure failed" if $?;
      system $make, 'all';
      die "make all failed" if $?;
      system $make, 'install';
      die "make install failed" if $?;
    });

    require File::Spec;

    foreach my $name ($^O =~ /^(MSWin32|cygwin)$/ ? ('bin','lib') : ('lib'))
    {
      do {
        my $static_dir = File::Spec->catdir($prefix, $name);
        my $dll_dir    = File::Spec->catdir($prefix, 'dll');
        require File::Path;
        File::Path::mkpath($dll_dir, 0, 0755);
        my $dh;
        opendir $dh, $static_dir;
        my @list = readdir $dh;
        @list = grep { /\.so/ || /\.(dylib|la|dll|dll\.a)$/} grep !/^\./, @list;
        closedir $dh;
        foreach my $basename (@list)
        {
          require File::Copy;
          File::Copy::move(
            File::Spec->catfile($static_dir, $basename),
            File::Spec->catfile($dll_dir,    $basename),
          );
        }
      };
    }

    my $pkg_config_dir = File::Spec->catdir($prefix, 'lib', 'pkgconfig');
    
    my $pcfile = File::Spec->catfile($pkg_config_dir, 'libarchive.pc');
    
    do {
      open my $fh, '<', $pcfile;
      my @content = map { s{$prefix}{'${pcfiledir}/../..'}eg; $_ } do { <$fh> };
      close $fh;
      my($version) = map { /^Version:\s*(.*)$/; $1 } grep /^Version: /, @content;
      
      # older versions apparently didn't include the necessary -I and -L flags
      if($version =~ /^[12]\./)
      {
        for(@content)
        {
          s/^Libs: /Libs: -L\${libdir} /;
        }
        push @content, "Cflags: -I\${includedir}\n";
      }
      
      open $fh, '>', $pcfile;
      print $fh @content;
      close $fh;
    };
    
    my $build = {};
    
    $build->{extra_compiler_flags} = _try_pkg_config($pkg_config_dir, 'cflags', '-I' . File::Spec->catdir($prefix, 'include'));
    $build->{extra_linker_flags}   = _try_pkg_config($pkg_config_dir, 'libs',   '-L' . File::Spec->catdir($prefix, 'lib'));
    
    if($^O eq 'cygwin' || $^O eq 'MSWin32')
    {
      unshift @{ $build->{extra_compiler_flags} }, '-DLIBARCHIVE_STATIC';
    }

    require ExtUtils::CBuilder;
    my $cbuilder = ExtUtils::CBuilder->new;
    $build->{version} = $self->test_compile_run(
      cbuilder => $cbuilder,
      %$build,
    ) || die $self->error;
    $build;
  };
  
  my $error = $@;
  chdir $save;
  die $error if $error;
  $build;
}

=head2 build_requires

 my $prereqs = $installer->build_requires;
 while(my($module, $version) = each %$prereqs)
 {
   ...
 }

Returns a hash reference of the build requirements.  The
keys are the module names and the values are the versions.

The requirements may be different depending on your
platform.

=cut

sub build_requires
{
  my %prereqs = {
    'HTTP::Tiny' =>   0,
    'Archive::Tar' => 0,
  };
  
  if($^O eq 'MSWin32')
  {
    require Config;
    if($Config::Config{cc} =~ /cl(\.exe)?$/i)
    {
      $prereqs{'Alien::CMake'} = '0.05';
    }
    else
    {
      $prereqs{'Alien::MSYS'} = '0,07';
      $prereqs{'PkgConfig'}   = '0.07620';
    }
  }
  
  \%prereqs;
}

1;
