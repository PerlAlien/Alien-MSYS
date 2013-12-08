package Alien::MSYS;

use strict;
use warnings;
use base qw( Exporter );

our @EXPORT    = qw( msys msys_run );
our @EXPORT_OK = qw( msys msys_run msys_path );

# ABSTRACT: Tools required for automake scripts in Windows
# VERSION

=head1 SYNOPSIS

from Perl:

 use Alien::MSYS;
 # runs uname from MSYS
 my $uname = mysy { `uname` };

From Prompt/Makefile

 C:\> perl -MAlien::MSYS -e msys_run uname

=head1 DESCRIPTION

MSYS provides minimal shell and POSIX tools on Windows to enable autoconf scripts to run.
This module aims to provide an interface for using MSYS on Windows and act as a no-op on
Unix like operating systems which already have that capability.

Unfortunately, as of this writing it is a PITA to download and install MSYS in an easy
automated way, so this module does not YET attempt that.  It simply looks in obvious
places for it.  This detection is at present pretty naive, so it is recommended that you
set PERL_ALIEN_MSYS_BIN environment variable prior to installing or using this module.

 C:\> set PERL_ALIEN_MSYS_BIN=C:\msys\bin

=head1 FUNCTIONS

=head2 msys

 # get the uname from MSYS
 my $uname = msys { `uanem` };
 
 # run with GNU make from MSYS instead of
 # dmake from Strawberry Perl
 msys { system 'make' };

This function takes a single argument, a code reference, and runs it with the correctly
set environment so that calls to the system function or the qx quote like operator will
use MSYS instead of the default environment.

=cut

sub msys (&)
{
  local $ENV{PATH} = $^O eq 'MSWin32' ? msys_path().";$ENV{PATH}" : $ENV{PATH};
  $_[0]->();
}

=head2 msys_run

 # pass command through @ARGV
 C:\> perl -MAlien::MSYS -e msys_run uname
 
 # pass command through @_
 C:\> perl -MAlien::MSYS -e "msys_run 'make'; msys_run 'make install'"

This function runs a command with the MSYS environment.  It gets the command and arguments
either as passed to it, or if none are passed the the command is expected to be in
@ARGV.

If the command fails then it will L<exit|perlfunc#exit> with a non-zero error code.  This
is useful, in the second example above if either C<make> or C<make install> fails, then
the whole command will fail, also C<make install> will not be attempted unless C<make>
succeeds.

=cut

sub msys_run
{
  my $cmd = \@_;
  $cmd = \@ARGV unless @$cmd > 0;
  msys { system @$cmd };
  # child did an exit(0), or "success"
  return if $? == 0;
  # child wasn't able to exit (-1) or died with signal
  exit 2 if $? == -1 || $? & 127;
  # child exited with non zero
  exit $?;
}

=head2 msys_path

This function returns the full path to the MSYS bin directory.

=cut

sub msys_path ()
{
  return undef unless  $^O eq 'MSWin32';
  return $ENV{PERL_ALIEN_MSYS_BIN} if defined $ENV{PERL_ALIEN_MSYS_BIN};
  foreach my $try (qw( C:\MinGW\msys\1.0\bin D:\MinGW\msys\1.0\bin ))
  {
    return $try if -d $try;
  }
  return undef;
}

1;

=head1 CAVEATS

As mentioned above, this doesn't actually install MSYS yet, so it is of limited
use.

=cut
