package
  HTTP::Tiny;

use strict;
use warnings;

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
