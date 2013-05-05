#!perl -T
use 5.010;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Catalyst::Authentication::Store::DataStore' ) || print "Bail out!\n";
}

diag( "Testing Catalyst::Authentication::Store::DataStore $Catalyst::Authentication::Store::DataStore::VERSION, Perl $], $^X" );
