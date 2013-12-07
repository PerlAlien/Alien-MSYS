package Alien::MSYS;

use strict;
use warnings;
use base qw( Exporter );

our @EXPORT_OK = qw( msys msys_run msys_path );

# ABSTRACT: Tools required for automake scripts in Windows
# VERSION

=head1 FUNCTIONS

=head2 msys

=cut

sub msys (&)
{
  local $ENV{PATH} = $^O eq 'MSWin32' ? msys_path().";$ENV{PATH}" : $ENV{PATH};
  $_[0]->();
}

=head2 msys_path

=cut

sub msys_path ()
{
  return undef unless  $^O eq 'MSWin32';
  return $ENV{PERL_ALIEN_MSYS} if defined $ENV{PERL_ALIEN_MSYS};
  foreach my $try (qw( C:\MinGW\msys\1.0\bin D:\MinGW\msys\1.0\bin ))
  {
    return $try if -d $try;
  }
  return undef;
}

=head2 msys_run

=cut

sub msys_run
{
  my $cmd = \@_;
  msys { system @$cmd }
}

1;
