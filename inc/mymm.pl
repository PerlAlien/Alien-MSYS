package mymm;

use strict;
use warnings;

if($^O eq 'MSWin32')
{
  my $ver;
  my $err;
  {
    local $@;
    $err = $@ || 'Error' unless eval {
      require Win32;
      $ver = (Win32::GetOSVersion())[1];
    };
  }
  if($err || $ver < 6)
  {
    print "Please upgrade to Windows 7 or better (ideally Windows 10).\n";
    print "The native crypto libraries used by mingw-gwt no longer work\n";
    print "with sourceforge.\n";
    exit;
  }
  else
  {
    print "Windows major version $ver ok.\n";
  }
}


1;
