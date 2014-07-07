package Alien::Install::Role::Installer;

use strict;
use warnings;
use Role::Tiny;
use Alien::Install::Util;

# ABSTRACT: Role for Alien::Install
# VERSION

requires 'versions';
requires 'fetch';
requires 'extract';
requires 'chdir_source';
requires 'test_compile_run';
requires 'test_ffi';
requires 'alien_config_name';

my $build_requires = \%Alien::Install::Util::build_requires;

sub build_requires
{
  my($class) = @_;
  my %requires;
  foreach my $role (keys %$build_requires)
  {
    if($class->isa($role) || $class->does($role))
    {
      while(my($mod,$ver) = each %{ $build_requires->{$role} })
      {
        # TODO check if this is a newer or older
        # than existing $ver
        $requires{$mod} ||= $ver;
      }
    }
  }
  
  \%requires;
}

my $system_requires = \%Alien::Install::Util::system_requires;

sub system_requires
{
  my($class) = @_;
  my %requires;
  foreach my $role (keys %$system_requires)
  {
    if($class->isa($role) || $class->does($role))
    {
      while(my($mod,$ver) = each %{ $system_requires->{$role} })
      {
        # TODO check if this is a newer or older
        # than existing $ver
        $requires{$mod} ||= $ver;
      }
    }
  }
  
  \%requires;
}

my $hooks = \%Alien::Install::Util::hooks;

sub call_hooks
{
  my($class, $name, @args) = @_;
  # TODO probably could cache the hooks that we need for each class..
  foreach my $role (sort keys %$hooks)
  {
    if($class->does($role))
    {
      if(exists $hooks->{$role}->{$name})
      {
        $_->($class, @args) for @{ $hooks->{$role}->{$name} };
      }
    }
  }
  foreach my $other (sort keys %$hooks)
  {
    if($class->isa($other))
    {
      if(exists $hooks->{$other}->{$name})
      {
        $_->($class, @args) for @{ $hooks->{$other}->{$name} };
      }
    }
  }
}

register_hook 'post_install' => sub {
  my($class, $prefix) = @_;

  foreach my $name ($^O =~ /^(MSWin32|cygwin)$/ ? ('bin','lib') : ('lib'))
  {
    do {
      my $static_dir = catdir($prefix, $name);
      my $dll_dir    = catdir($prefix, 'dll');
      require File::Path;
      File::Path::mkpath($dll_dir, 0, 0755);
      my $dh;
      opendir $dh, $static_dir;
      my @list = readdir $dh;
      @list = grep { /\.so/ || /\.(dylib|la|dll|dll\.a)$/ } grep !/^\./, @list;
      closedir $dh;
      foreach my $basename (@list)
      {
        my $from = catfile($static_dir, $basename);
        my $to   = catfile($dll_dir,    $basename);
        if(-l $from)
        {
          symlink(readlink $from, $to);
          unlink($from);
        }
        else
        {
          require File::Copy;
          File::Copy::move($from, $to);
        }
      }
    };
  }
};

sub error   { shift->{error}   }
sub cflags  { shift->{cflags}  }
sub libs    { shift->{libs}    }
sub version { shift->{version} }

sub dlls
{
  my($self, $prefix) = @_;
  
  my $name = $self->alien_config_name;
  $prefix = $self->{prefix} unless defined $prefix;
  
  unless(defined $self->{dlls} && defined $self->{dll_dir})
  {
    # Question: is this necessary in light of the better
    # dll detection now done in system_install ?
    if($^O eq 'cygwin')
    {
      # /usr/bin/cyg<name>-0.dll
      opendir my $dh, '/usr/bin';
      # the version part of this regex will almost certainly
      # need to be expanded.
      $self->{dlls} = [grep /^cyg$name-[0-9]+.dll$/i, readdir $dh];
      $self->{dll_dir} = [];
      $prefix = '/usr/bin';
      closedir $dh;
    }
    else
    {
      require DynaLoader;
      $self->{libs} = [] unless defined $self->{libs};
      $self->{libs} = [ $self->{libs} ] unless ref $self->{libs};
      my $path = DynaLoader::dl_findfile(@{ $self->libs });
      die "unable to find dynamic library" unless defined $path;
      my($vol, $dirs, $file) = splitpath $path;
      if($^O eq 'openbsd')
      {
        # on openbsd we get the .a file back, so have to scan
        # for .so.#.# as there is no .so symlink
        opendir(my $dh, $dirs);
        $self->{dlls} = [grep /^lib$name.so/, readdir $dh];
        closedir $dh;
      }
      else
      {
        $self->{dlls} = [ $file ];
      }
      $self->{dll_dir} = [];
      $self->{prefix} = $prefix = catpath($vol, $dirs);
    }
  }
  
  map { catfile $prefix, @{ $self->{dll_dir} }, $_  } @{ $self->{dlls} };
}

sub system_install
{
  my($class, %options) = @_;

  $options{alien} = 1 unless defined $options{alien};
  $options{test} ||= 'compile';
  die "test must be one of compile, ffi or both"
    unless $options{test} =~ /^(compile|ffi|both)$/;

  my $name = $class->alien_config_name;
    
  if($options{alien})
  {
    my $alien_class;
    if($class->can('alien_config_alien_class'))
    {
      $alien_class = $class->alien_config_alien_class;
    }
    else
    {
      $alien_class = $class;
      $alien_class =~ s/::Installer$//;
    }
    
    my $try = "use $alien_class";
    $try .= " " . $class->alien_config_alien_version
      if $class->can('alien_config_alien_version');
    $try .= "; 1";
    
    if(eval $try)
    {
      my $alien = $alien_class->new;
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
  }
  
  my %build = (
    cflags => [],
    libs   => [ "-l$name" ],
  );
  
  $class->call_hooks('system_install_flags_guess', \%build);
  
  my $build = bless \%build, $class;
  
  if($options{test} =~ /^(ffi|both)$/)
  {
    my @dir_search_list;
    
    $class->call_hooks('system_install_search_list', \@dir_search_list);
    
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
          next unless $file =~ /^lib$name-[0-9]+\.dll$/i;
        }
        elsif($^O eq 'cygwin')
        {
          next unless $file =~ /^cyg$name-[0-9]+\.dll$/i;
        }
        else
        {
          next unless $file =~ /^lib$name\.(dylib|so(\.[0-9]+)*)$/;
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

1;
