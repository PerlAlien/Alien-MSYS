package Alien::MSYS::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );
use File::Path qw( mkpath );
use File::Spec;

sub ACTION_build
{
  my $self = shift;

  # TODO: skip all this if not MSWin32

  require HTTP::Tiny;
  my $http = HTTP::Tiny->new;
  
  my $url = 'http://sourceforge.net/projects/mingw/files/Installer/mingw-get/';
  my $index = $http->get($url);
  
  $index->{status} =~ /^2..$/ || die join(' ', $index->{status}, $index->{reason}, $url);
  
  my $link;
  
  for($index->{content} =~ m{"/(projects/mingw/files/Installer/mingw-get/mingw-get-.*?-(\d\d\d\d\d\d\d\d)-(\d+))/"})
  {
    if(!defined $link || ($link->{date} <= $2 && $link->{num} < $3))
    {
      $link = {
        url  => "http://sourceforge.net/$1",
        date => $2,
        num  => $2,
      };
    }
  }

  die "couldn't find mingw-get in index" unless $link;

  $url = $link->{url};
  $index = $http->get($url);
  
  print "url = $url\n";
  
  $index->{status} =~ /^2..$/ || die join(' ', $index->{status}, $index->{reason}, $url);

  die "couldn't find mingw-get in download index"
    unless $index->{content} =~ m{"(https?://.*/mingw-get-.*?-bin.zip/download)"};
    
  $url = $1;
  my $download = $http->get($url);

  $download->{status} =~ /^2..$/ || die join(' ', $download->{status}, $download->{reason}, $url);

  require Archive::Zip;
  
  my $dir = File::Spec->catdir(qw( _alien mingw-get ));
  mkpath($dir, 1, 0755);
  
  chdir $dir;
  
  my $zip = Archive::Zip->new;
  $zip->readFromFileHandle(do {
    open my $fh, '+<', \$download->{content};
    $fh;
  });
  $zip->extractTree();
  
  _cdup();
  _cdup();

  # TODO: uncomment
  #$self->SUPER::ACTION_build(@_);
}

sub _cdup
{
  chdir(File::Spec->updir);
}

1;
