package Alien::MSYS;

use strict;
use warnings;
use base qw( Exporter );
use File::Spec;
use File::Which qw( which );
use File::Basename qw( dirname );

our @EXPORT    = qw( msys msys_run );
our @EXPORT_OK = qw( msys msys_run msys_path );

# ABSTRACT: Tools required for GNU style configure scripts on Windows
# VERSION

=head1 SYNOPSIS

from Perl:

 use Alien::MSYS;
 # runs uname from MSYS
 my $uname = msys { `uname` };

From Prompt/Makefile

 C:\> perl -MAlien::MSYS -e msys_run uname

=head1 DESCRIPTION

MSYS provides minimal shell and POSIX tools on Windows to enable GNU style configure 
scripts to run (the type usually generated by C<autoconf>). This module aims to 
provide an interface for using MSYS on Windows and act as a no-op on Unix like 
operating systems which already have that capability.  If you use this module, I 
recommend that you list this as a prerequisite only during MSWin32 installs.

When installing, this distribution will look for an existing C<MSYS> using the following
methods in this order:

=over 4

=item environment variable C<ALIEN_INSTALL_TYPE> or C<ALIEN_MSYS_INSTALL_TYPE>

If set to C<share> a system install will not be attempted.  If set to C<system>
then a share install will not be attempted.

=item environment variable C<PERL_ALIEN_MSYS_BIN>

If set, this environment variable should be set to the root of C<MSYS> (NOT C<MinGW>).
For example, if you have C<MinGW> / C<MSYS> installed on C<D:> you might use this:

 C:\> set PERL_ALIEN_MSYS_BIN=D:\MinGW\msys\1.0\bin

Keep in mind that this environment variable is consulted during both install and at run-time,
so it is advisable to set this in the System Properties control panel.

=item search C<PATH> for C<mingw-get.exe>

Second, L<Alien::MSYS> searches the C<PATH> environment variable for the C<mingw-get.exe>
program, which is a common method for installing C<MinGW> and C<MSYS>.  From there
if it can deduce the location of C<MSYS> it will use that.

=item try C<C:\MinGW\msys\1.0\bin>

Next, L<Alien::MSYS> tries the default install location.

=item Use desktop shortcut for C<MinGW Installer>

Finally, L<Alien::MSYS> will try to find C<MSYS> from the desktop shortcut created
by the GUI installer for C<MinGW>.  This method only works if you already have
L<Win32::Shortcut> installed, as it is an optional dependency.

=back

If C<MSYS> cannot be found using any of these methods, then it will download and install
C<MSYS> in this distribution's share directory (via L<File::ShareDir>).

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
  
  my $override_type = $ENV{ALIEN_MSYS_INSTALL_TYPE} || $ENV{ALIEN_INSTALL_TYPE} || '';
  
  if($override_type ne 'share')
  {
    return $ENV{PERL_ALIEN_MSYS_BIN}
      if defined $ENV{PERL_ALIEN_MSYS_BIN} && -x File::Spec->catfile($ENV{PERL_ALIEN_MSYS_BIN}, 'sh.exe');

    if(my $uname_exe = which('uname'))
    {
      my $uname = `$uname_exe`;
      if($uname =~ /^(MSYS|MINGW(32|64))_NT/) {
        return dirname($uname_exe);
      }
    }

    require File::Spec;
    foreach my $dir (split /;/, $ENV{PATH})
    {
      my $path = eval {
        my $mingw_get = File::Spec->catfile($dir, 'mingw-get.exe');
        die 'no mingw-get.exe' unless -x $mingw_get;
        my($volume, $dirs) = File::Spec->splitpath($mingw_get);
        my @dirs = File::Spec->splitdir($dirs);
        splice @dirs, -2;
        push @dirs, qw( msys 1.0 bin );
        my $path = File::Spec->catdir($volume, @dirs);
        die 'no sh.exe' unless -x File::Spec->catfile($path, 'sh.exe');
        $path;
      };
      return $path unless $@;
    }

    foreach my $dir (qw( C:\MinGW\msys\1.0\bin ))
    {
      return $dir if -x File::Spec->catfile($dir, 'sh.exe');
    }

    my $path = eval {
      require Win32;
      require Win32::Shortcut;
      my $lnk_name = File::Spec->catfile(Win32::GetFolderPath(Win32::CSIDL_DESKTOP(), 1), 'MinGW Installer.lnk');
      die "No MinGW Installer.lnk" unless -r $lnk_name;
      my $lnk      = Win32::Shortcut->new;
      $lnk->Load($lnk_name);
      my($volume, $dirs) = File::Spec->splitpath($lnk->{Path});
      my @dirs = File::Spec->splitdir($dirs);
      splice @dirs, -3;
      push @dirs, qw( msys 1.0 bin );
      my $path = File::Spec->catdir($volume, @dirs);
      die 'no sh.exe' unless -x File::Spec->catfile($path, 'sh.exe');
      $path;
    };

    return $path unless $@;
  }

  if($override_type ne 'system')
  {
    my $dir = _my_dist_dir();
    return $dir if defined $dir && -d $dir;
  }

  return undef;
}

sub _my_dist_dir
{
  #eval { File::Spec->catdir(dist_dir('Alien-MSYS'), qw( msys 1.0 bin )) };
  my @pm = ('Alien', 'MSYS.pm');
  foreach my $inc (@INC)
  {
    my $pm = File::Spec->catfile($inc, @pm);
    if(-f $pm)
    {
      my $share = File::Spec->catdir($inc, qw( auto share dist ), 'Alien-MSYS' );
      if(-d $share)
      {
        return File::Spec->catdir($share, qw( msys 1.0 bin) );
      }
      last;
    }
  }
  return;
}

1;

=head1 CAVEATS

This L<Alien> is big and slow to install.  I am aware this is an annoying problem.
It is also the only reliable way (that I know of) to install packages from source 
that use autotools on Strawberry or Visual C++ Perl.  Here are some things that you
can do to avoid this painful cost:

=over 4

=item Use the system library if possible

The L<Alien::Build> system is usually smart enough to find the system library
if it is available.  L<Alien::MSYS> is usually only necessary for so called
C<share> installs.

=item Pre-install MSYS

As mentioned above if you preinstall MSYS and set the C<PERL_ALIEN_MSYS_BIN>
environment variable, then you will save yourself some time if you use multiple
installs of Perl like I do.

=item Use another build system

Some projects will provide a makefile that will work with GNU Make and C<cmd.exe>
that you can build without MSYS.  An example of an Alien that takes advantage of
this is L<Alien::libuv>.

Some projects provide both autoconf and CMake.  Although using CMake reliably 
requires L<Alien::cmake3> for C<share> installs, it is much much lighter than L<Alien::MSYS>.

Also obviously you can open a ticket, or make a pull request with the project that you
are alienizing to support build systems that don't suck as much as autoconf.

=item Use MSYS2

Strawberry Perl is convenient for building XS modules without any dependencies
or just dependencies on the small number of libraries that come bundled with
Strawberry Perl.  It is very very painful in my opinion if you depend on libraries
that are not bundled, which is why this Alien exists.  There is an alternative though.

MSYS2 / MinGW provides a MSWin32 Perl as part of a Linux / open source like package
that provides probably all of the libraries that you might want to use as dependencies,
and if it doesn't you can build much easier than with Strawberry + Alien::MSYS.

There are some notes here:

L<https://project-renard.github.io/doc/development/meeting-log/posts/2016/05/03/windows-build-with-msys2/>

On using the MSYS2 / MinGW / MSWin32 Perl from the MSYS2 project.

=back

=cut
