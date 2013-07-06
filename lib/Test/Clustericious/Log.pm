package Test::Clustericious::Log;

use strict;
use warnings;

BEGIN {
  unless($INC{'File/HomeDir/Test.pm'})
  {
    eval q{ use File::HomeDir::Test };
    die $@ if $@;
  }
}

use File::HomeDir;
use Test::Builder::Module;
use Clustericious::Log ();

# ABSTRACT: Clustericious logging in tests.
# VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

# TRACE DEBUG INFO WARN ERROR FATAL

sub import
{
  my($class) = @_;

  $Clustericious::Log::harness_active = 0;

  my $home = File::HomeDir->my_home;
  mkdir "$home/etc" unless -d "$home/etc";
  mkdir "$home/log" unless -d "$home/log";

  my $config = {
    FileX => [ 'TRACE', 'FATAL'  ],
    NoteX => [ 'DEBUG', 'WARN'  ],
    DiagX => [ 'ERROR', 'FATAL' ],
  };

  open my $fh, '>', "$home/etc/log4perl.conf";

  print $fh "log4perl.rootLogger=TRACE, FileX, NoteX, DiagX\n";
  
  while(my($appender, $levels) = each %$config)
  {
    my($min, $max) = @{ $levels };
    print $fh "log4perl.filter.Match$appender = Log::Log4perl::Filter::LevelRange\n";
    print $fh "log4perl.filter.Match$appender.LevelMin = $min\n";
    print $fh "log4perl.filter.Match$appender.LevelMax = $max\n";
    print $fh "log4perl.filter.Match$appender.AcceptOnMatch = true\n";
  }
  
  print $fh "log4perl.appender.FileX=Log::Log4perl::Appender::File\n";
  print $fh "log4perl.appender.FileX.filename=$home/log/test.log\n";
  print $fh "log4perl.appender.FileX.mode=append\n";
  print $fh "log4perl.appender.FileX.layout=PatternLayout\n";
  print $fh "log4perl.appender.FileX.layout.ConversionPattern=[%P %p{1} %rms] %F:%L %m%n\n";
  print $fh "log4perl.appender.FileX.Filter=MatchFileX\n";
  
  print $fh "log4perl.appender.NoteX=Log::Log4perl::Appender::TAP\n";
  print $fh "log4perl.appender.NoteX.method=note\n";
  print $fh "log4perl.appender.NoteX.layout=PatternLayout\n";
  print $fh "log4perl.appender.NoteX.layout.ConversionPattern=%5p %m%n\n";
  print $fh "log4perl.appender.NoteX.Filter=MatchNoteX\n";

  print $fh "log4perl.appender.DiagX=Log::Log4perl::Appender::TAP\n";
  print $fh "log4perl.appender.DiagX.method=diag\n";
  print $fh "log4perl.appender.DiagX.layout=PatternLayout\n";
  print $fh "log4perl.appender.DiagX.layout.ConversionPattern=%5p %m%n\n";
  print $fh "log4perl.appender.DiagX.Filter=MatchDiagX\n";
  
  close $fh;  
}

END
{
  my $tb = Test::Builder::Module->builder;
  my $home = File::HomeDir->my_home;
  
  unless($tb->is_passing)
  {
    if(-r "$home/log/test.log")
    {
      $tb->diag("detailed log");
      open my $fh, '<', "$home/log/test.log";
      $tb->diag(<$fh>);
      close $fh;
    }
    else
    {
      $tb->diag("no detailed log");
    }
  }
}

1;
