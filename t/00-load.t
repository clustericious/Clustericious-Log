#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Clustericious::Log' ) || print "Bail out!
";
}

diag( "Testing Clustericious::Log $Clustericious::Log::VERSION, Perl $], $^X" );
