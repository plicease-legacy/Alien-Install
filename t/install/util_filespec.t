use strict;
use warnings;
use Test::More tests => 17;
use Alien::Install::Util;
use File::Temp qw( tempdir );

my $tmp = tempdir( CLEANUP => 1);

my $file = catfile $tmp, 'foo.txt';
unlike $file, qr{\\}, "does not contain backslash $file";
spew $file, 'this is a test of the emergency File::Spec system';
ok -r $file, "readable $file"; 
is slurp $file, 'this is a test of the emergency File::Spec system', "content matches $file";

my $dir = catdir $tmp, 'bar';
unlike $dir, qr{\\}, "does not contain backslash $dir";
mkdir $dir;
ok -d $dir, "is a directory";

my @file_path = splitpath $file;
note "file_path:";
note "  $_" for @file_path;
is scalar @file_path, 3, 'splitpath returns exactly three items for a file';
ok -r &catpath(@file_path), "readable @file_path";
is slurp(&catpath(@file_path)), 'this is a test of the emergency File::Spec system', "content matches @file_path";
unlike &catpath(@file_path), qr{\\}, "does not contain backslash @file_path";

my @dir_path = splitpath $dir, 1;
note "dir_path:";
note "  $_" for @dir_path;
is scalar @dir_path, 3, 'splitpath returns exactly three items for a dir';
is $dir_path[2], '', 'file part for dir is empty string';
unlike &catpath(@dir_path), qr{\\}, "does not contain backslash @dir_path";

my $file2 = catpath($file_path[0], catdir('', splitdir($file_path[1])), $file_path[2]);
unlike $file2, qr{\\}, "does not contain backslash: $file2";
ok -r $file2, "is readable $file2";
is slurp $file2, 'this is a test of the emergency File::Spec system', "content matches $file2";

my $root = rootdir;
ok -d $root, "root is a directory ($root)";
unlike $root, qr{\\}, "root does not contain backslash";
