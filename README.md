# Alien::MSYS [![Build Status](https://secure.travis-ci.org/plicease/Alien-MSYS.png)](http://travis-ci.org/plicease/Alien-MSYS)

Tools required for GNU style configure scripts on Windows

# SYNOPSIS

from Perl:

    use Alien::MSYS;
    # runs uname from MSYS
    my $uname = msys { `uname` };

From Prompt/Makefile

    C:\> perl -MAlien::MSYS -e msys_run uname

# DESCRIPTION

MSYS provides minimal shell and POSIX tools on Windows to enable GNU style configure 
scripts to run (the type usually generated by `autoconf`). This module aims to 
provide an interface for using MSYS on Windows and act as a no-op on Unix like 
operating systems which already have that capability.  If you use this module, I 
recommend that you list this as a prerequisite only during MSWin32 installs.

When installing, this distribution will look for an existing `MSYS` using the following
methods in this order:

- environment variable `PERL_ALIEN_MSYS_BIN`

    If set, this environment variable should be set to the root of `MSYS` (NOT `MinGW`).
    For example, if you have `MinGW` / `MSYS` installed on `D:` you might use this:

        C:\> set PERL_ALIEN_MSYS_BIN=D:\MinGW\msys\1.0\bin

    Keep in mind that this environment variable is consulted during both install and at run-time,
    so it is advisable to set this in the System Properties control panel.

- search `PATH` for `mingw-get.exe`

    Second, [Alien::MSYS](https://metacpan.org/pod/Alien::MSYS) searches the `PATH` environment variable for the `mingw-get.exe`
    program, which is a common method for installing `MinGW` and `MSYS`.  From there
    if it can deduce the location of `MSYS` it will use that.

- try `C:\MinGW\msys\1.0\bin`

    Next, [Alien::MSYS](https://metacpan.org/pod/Alien::MSYS) tries the default install location.

- Use desktop shortcut for `MinGW Installer`

    Finally, [Alien::MSYS](https://metacpan.org/pod/Alien::MSYS) will try to find `MSYS` from the desktop shortcut created
    by the GUI installer for `MinGW`.  This method only works if you already have
    [Win32::Shortcut](https://metacpan.org/pod/Win32::Shortcut) installed, as it is an optional dependency.

If `MSYS` cannot be found using any of these methods, then it will download and install
`MSYS` in this distribution's share directory (via [File::ShareDir](https://metacpan.org/pod/File::ShareDir)).

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

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
