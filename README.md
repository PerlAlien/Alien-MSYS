# Alien::MSYS

Tools required for automake scripts in Windows

# SYNOPSIS

from Perl:

    use Alien::MSYS;
    # runs uname from MSYS
    my $uname = mysy { `uname` };

From Prompt/Makefile

    C:\> perl -MAlien::MSYS -e msys_run uname

# DESCRIPTION

MSYS provides minimal shell and POSIX tools on Windows to enable autoconf scripts to run.
This module aims to provide an interface for using MSYS on Windows and act as a no-op on
Unix like operating systems which already have that capability.

Unfortunately, as of this writing it is a PITA to download and install MSYS in an easy
automated way, so this module does not YET attempt that.  It simply looks in obvious
places for it.  This detection is at present pretty naive, so it is recommended that you
set PERL\_ALIEN\_MSYS\_BIN environment variable prior to installing or using this module.

    C:\> set PERL_ALIEN_MSYS_BIN=C:\msys\bin

# FUNCTIONS

## msys

    # get the uname from MSYS
    my $uname = msys { `uanem` };
    
    # run with GNU make from MSYS instead of
    # dmake from Strawberry Perl
    msys { system 'make' };

This function takes a single argument, a code reference, and runs it with the correctly
set environment so that calls to the system function or the qx quote like operator will
use MSYS instead of the default environment.

## msys\_run

    # pass command through @ARGV
    C:\> perl -MAlien::MSYS -e msys_run uname
    
    # pass command through @_
    C:\> perl -MAlien::MSYS -e "msys_run 'make'; msys_run 'make install'"

This function runs a command with the MSYS environment.  It gets the command and arguments
either as passed to it, or if none are passed the the command is expected to be in
@ARGV.

If the command fails then it will [exit](https://metacpan.org/pod/perlfunc#exit) with a non-zero error code.  This
is useful, in the second example above if either `make` or `make install` fails, then
the whole command will fail, also `make install` will not be attempted unless `make`
succeeds.

## msys\_path

This function returns the full path to the MSYS bin directory.

# CAVEATS

As mentioned above, this doesn't actually install MSYS yet, so it is of limited
use.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
