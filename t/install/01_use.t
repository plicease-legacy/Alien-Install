use strict;
use warnings;
use Test::More tests => 12;

use_ok 'Alien::Install';
use_ok 'Alien::Install::Util';
use_ok 'Alien::Install::Role::Installer';
use_ok 'Alien::Install::Role::Tar';
use_ok 'Alien::Install::Role::CMake';
use_ok 'Alien::Install::Role::HTTP';
use_ok 'Alien::Install::Role::FTP';
use_ok 'Alien::Install::Role::Autoconf';
use_ok 'Alien::Install::Role::TestCompileRun';
use_ok 'Alien::Install::Role::TestFFI';
use_ok 'Alien::Install::Role::VersionSortSimple';
use_ok 'Alien::Install::Role::VersionSortMultiple';
