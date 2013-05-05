#!perl -T
use 5.010;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Catalyst::Plugin::Authentication::Store::DataStore' ) || print "Bail out!\n";
}

diag( "Testing Catalyst::Plugin::Authentication::Store::DataStore $Catalyst::Plugin::Authentication::Store::DataStore::VERSION, Perl $], $^X" );
