package
  HTTP::Tiny;

use strict;
use warnings;
use FindBin ();
use File::Spec;

sub new
{
  bless {}, 'HTTP::Tiny';
}

my $listing;

sub get
{
  my($self, $url) = @_;
  
  if($url eq 'http://dist.wdlabs.com/')
  {
    $listing = do { local $/; <DATA> } unless defined $listing;
    return {
      success => 1,
      content => $listing,
    };
  }
  
  if($url =~ m{^http://dist.wdlabs.com/(.*?)$})
  {
    my $fn = $1;
    if($fn eq 'libfoo-1.00.tar.gz')
    {
      my $fh;
      open($fh, '<', File::Spec->catfile($FindBin::Bin, $fn));
      binmode $fh;
      my $content = do { local $/; <$fh> };
      close $fh;
      return {
        success => 1,
        content => $content,
      };
    }
    else
    {
      return {
        success => '',
        content => "Not Found",
        reason  => "Not Found",
        status  => 404,
        url     => $url,
      };
    }
  }
  
  die "unimplemented for $url";
}

1;

__DATA__
<html>
  <head>
    <title>This is a directory listing</title>
  </head>
  <body>
    <ul>
      <li><a href="http://dist.wdlabs.com/libfoo-0.98.tar.gz">libfoo-0.98.tar.gz</a></li>
      <li><a href="http://dist.wdlabs.com/libfoo-0.99.tar.gz">libfoo-0.99.tar.gz</a></li>
      <li><a href="http://dist.wdlabs.com/libfoo-1.00.tar.gz">libfoo-1.00.tar.gz</a></li>
    </ul>
  </body>
</html>

