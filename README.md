# Alien::MSYS [![Build Status](https://secure.travis-ci.org/plicease/Alien-MSYS.png)](http://travis-ci.org/plicease/Alien-MSYS)

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
Unix like operating systems which already have that capability.  If you use this module,
I recommend that you list this as a prerequisite only during MSWin32 installs.

When installing, this distribution looks in the default location for an existing MSYS
install, which is `C:\MinGW\msys\1.0\bin`, if it cannot find it there, then it will
download and install MSYS in this distribution's share directory (via [File::ShareDir](https://metacpan.org/pod/File::ShareDir)).
You can override this logic and specify your own location for MSYS using the 
PERL\_ALIEN\_MSYS\_BIN environment variable.  This should point to the directory containing
the MSYS executables:

    C:\> set PERL_ALIEN_MSYS_BIN=D:\MinGW\msys\bin

Keep in mind that this environment variable is consulted during both install and at run-time,
so it is advisable to set this in the System Properties control panel.

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

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
