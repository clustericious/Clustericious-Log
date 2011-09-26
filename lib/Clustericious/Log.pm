package Clustericious::Log;

use List::Util qw/first/;
use Log::Log4perl qw/:easy/;
use MojoX::Log::Log4perl;
use File::ReadBackwards;

use warnings;
use strict;

=head1 NAME

Clustericious::Log - Manage logging for clustericious CIs.

=cut

=head1 SYNOPSIS

use Clustericious::Log -init_logging => "appname";

=head1 DESCRIPTION

Uses log4perl to do logging, and looks for log4perl.conf
in several predefined directories.

Also imports TRACE DEBUG ERROR, etc. like using Log::Log4perl qw/:easy/;

=cut

our $VERSION = '0.04';

sub import {
    my $class = shift;
    my $dest = caller;
    my %args = @_;
    if (my $app_name = $args{-init_logging}) {
        init_logging($app_name);
    }
    no strict 'refs';
    *{"${dest}::$_"} = *{"${class}::$_"} for qw/TRACE INFO DEBUG ERROR WARN FATAL LOGDIE/;
}

=over

=item init_logging

Start logging.  Looks for log4perl.conf or $app.log4perl.conf
in ~, ~/etc, /util/etc and /etc.

=cut

sub init_logging {
    my $app_name = shift;
    $app_name = shift if $app_name eq __PACKAGE__;
    $app_name = $ENV{MOJO_APP} unless $app_name && $app_name ne 'Clustericious::App';

    my @Confdirs = $ENV{HARNESS_ACTIVE} ?
        ($ENV{CLUSTERICIOUS_TEST_CONF_DIR}) :
        ($ENV{HOME}, "$ENV{HOME}/etc", "/util/etc", "/etc" );

    # Logging
    $ENV{LOG_LEVEL} ||= ( $ENV{HARNESS_ACTIVE} ? "WARN" : "DEBUG" );

    my $l4p_dir; # dir with log config file.
    my $l4p_pat; # pattern for screen logging
    my $l4p_file; # file (global or app specific)

    if ($ENV{HARNESS_ACTIVE}) {
        $l4p_pat = "# %5p: %m%n";
    } else  {
        $l4p_dir  = first { -d $_ && (-e "$_/log4perl.conf" || -e "$app_name.log4perl.conf") } @Confdirs;
        $l4p_pat  = "[%d] [%Z %H %P] %5p: %m%n";
        $l4p_file = first {-e "$l4p_dir/$_"} ("$app_name.log4perl.conf", "log4perl.conf");
    }

    Log::Log4perl::Layout::PatternLayout::add_global_cspec('Z', sub {$app_name});

    my $logger = MojoX::Log::Log4perl->new( $l4p_dir ? "$l4p_dir/$l4p_file":
      { # default config
       ($ENV{LOG_FILE} ? (
          "log4perl.rootLogger"              => "$ENV{LOG_LEVEL}, File1",
          "log4perl.appender.File1"          => "Log::Log4perl::Appender::File",
          "log4perl.appender.File1.layout"   => "PatternLayout",
          "log4perl.appender.File1.filename" => "$ENV{LOG_FILE}",
          "log4perl.appender.File1.layout.ConversionPattern" => "[%d] [%Z %H %P] %5p: %m%n",
        ):(
          "log4perl.rootLogger"               => "$ENV{LOG_LEVEL}, SCREEN",
          "log4perl.appender.SCREEN"          => "Log::Log4perl::Appender::Screen",
          "log4perl.appender.SCREEN.layout"   => "PatternLayout",
          "log4perl.appender.SCREEN.layout.ConversionPattern" => "$l4p_pat",
       )),
      # These categories (%c) are too verbose by default :
       "log4perl.logger.Mojolicious"                     => "WARN",
       "log4perl.logger.Mojolicious.Plugin.RequestTimer" => "WARN",
       "log4perl.logger.MojoX.Dispatcher.Routes"         => "WARN",
    });

    INFO("Initialized logger");
    INFO("Log config found : $l4p_dir/$l4p_file") if $l4p_dir;
    # warn "# started logging ($l4p_dir/log4perl.conf)\n" if $l4p_dir;
    return $logger;
}

=item tail

Returns a string with the last $n lines of the logfile.

If multiple log files are defined, it only uses the first one alphabetically.

=cut

sub tail {
    my $self = shift;
    my %args = @_;
    my $count = $args{lines} || 10;
    my %appenders = %{ Log::Log4perl->appenders };
    my ($first) = sort keys %appenders;
    my $obj = $appenders{$first}->{appender};
    $obj->can("filename") or return "no filename for appender $first";
    my $filename = $obj->filename;
    my $fp = File::ReadBackwards->new($filename) or return "Can't read $filename : $!";
    my @lines;
    my $line;
    while ( defined( $line = $fp->readline ) ) {
        push @lines, $line;
        last if ( (0 + @lines) >= $count);
    };
    return join '', @lines;
}


1;
