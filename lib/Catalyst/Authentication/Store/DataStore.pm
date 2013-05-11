package Catalyst::Authentication::Store::DataStore;

use 5.010;
use strict;
use warnings FATAL => 'all';

use DBIx::DataStore ( config => 'yaml' );

=head1 NAME

Catalyst::Authentication::Store::DataStore - The great new Catalyst::Authentication::Store::DataStore!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Catalyst::Authentication::Store::DataStore;

    my $foo = Catalyst::Authentication::Store::DataStore->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my ($class, $config, $app, $realm) = @_;

    my $self = bless {}, $class;

    # do setup stuff
    if (exists $config->{'dbh'} && ref($config->{'dbh'}) eq 'DBIx::DataStore') {
        $self->{'dbh'} = $config->{'dbh'};
    } elsif (exists $config->{'datastore'}) {
        $self->{'dbh'} = DBIx::DataStore->new($config->{'datastore'});
    }

    $self->{'user_table'} = exists $config->{'user_table'} && $config->{'user_table'} =~ m{\w}o
        ? $config->{'user_table'} : 'users';

    return $self;
}

=head2 find_user

=cut

sub find_user {
    my ($self, $authinfo, $c) = @_;
}

=head2 for_session

=cut

sub for_session {
    my ($self, $c, $user) = @_;
}

=head2 from_session

=cut

sub from_session {
    my ($self, $c, $frozenuser) = @_;
}

=head2 user_supports

=cut

sub user_supports {
    my @features = @_;

    return Catalyst::Authentication::Store::DataStore::User::supports(@features);
}

=head1 AUTHOR

Jon Sime, C<< <jonsime at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-authentication-store-datastore at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Authentication-Store-DataStore>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Authentication::Store::DataStore


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Authentication-Store-DataStore>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Authentication-Store-DataStore>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Authentication-Store-DataStore>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Authentication-Store-DataStore/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Jon Sime.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Catalyst::Authentication::Store::DataStore
