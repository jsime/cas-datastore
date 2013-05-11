package Catalyst::Authentication::Store::DBIx::DataStore;

use 5.010;
use strict;
use warnings FATAL => 'all';

use DBIx::DataStore ( config => 'yaml' );

=head1 NAME

Catalyst::Authentication::Store::DBIx::DataStore - Authentication store for Catalyst
based on DBIx::DataStore.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Catalyst qw( Authentication );
    use DBIx::DataStore;

    my $dbh = DBIx::DataStore->new('MyApp');

    __PACKAGE__->config->{'authentication'} = {
        default_realms => 'default',
        realms => {
            default => {
                credential => {
                    'class'              => 'Password',
                    'password_field'     => 'password',
                    'password_type'      => 'hashed',
                    'password_hash_type' => 'SHA-1'
                },
                store => {
                    class      => 'DBIx::DataStore',
                    dbh        => $dbh,
                    user_table => 'users',
                    user_key   => 'user_id',
                    user_name' => 'username',
                    role_table => 'roles',
                    role_key   => 'role_id',
                    role_name  => 'role_name',
                    user_role_table    => 'user_roles',
                    user_role_user_key => 'user_id',
                    user_role_role_key => 'role_id'
                }
            }
        }
    };

=head1 DESCRIPTION

Catalyst::Authentication::Store::DBIx::DataStore provides a backend storage module for
Catalyst that wraps DBIx::DataStore. Functionally, this module is very similar to
the ::DBI auth store, except that it can make use of DBIx::DataStore objects
(either newly-created ones internally, or one you pass in during setup).

The recommended method is to pass a DBIx::DataStore object in during setup. This
allows the application to avoid any overhead of reconnecting to the database on
each call (assuming you aren't using a DBI pooler), and avoids needlessly opening
a second connection, separate from the one your application would use for all
other database access.

A word of warning, however. While most authentication checks happen before
anything else, and would therefor be occuring before you may start sensitive
transactions, this may not always be the case. Be mindful of situations where
you may need to make an authentication check while your DBIx::DataStore object
is within a transaction. You shouldn't need to worry about this module failing
your transaction (SQL syntax errors and the like), but your open transaction
may not have immediate visibility of account changes made by other controllers.

=head1 SUBROUTINES/METHODS

=head2 new

Initializes the C::A::S::DBIx::DataStore object.

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

    my %defaults = (
        user_table          => 'public.users',
        user_key            => 'user_id',
        user_name           => 'username',
        role_table          => 'public.roles',
        role_key            => 'role_id',
        role_name           => 'role_name',
        user_role_table     => 'public.user_roles',
        user_role_user_key  => 'user_id',
        user_role_role_key  => 'role_id',
    );

    $self->{$_} = exists $config->{$_} && $config->{$_} =~ m{\w}o ? $config->{$_} : $defaults{$_}
        for keys %defaults;

    return $self;
}

=head2 find_user

Locates a user based on the credentials supplied to the authenticate method.
Returns a Catalyst::Authentication::Store::DBIx::DataStore::User object (which
inherits from Catalyst::Authentication::User);

=cut

sub find_user {
    my ($self, $authinfo, $c) = @_;
}

=head2 for_session

Returns User ID for user's session.

=cut

sub for_session {
    my ($self, $c, $user) = @_;

    return $user->id;
}

=head2 from_session

Returns Catalyst::Authentication::Store::DBIx::DataStore::User object constructed
from session data.

=cut

sub from_session {
    my ($self, $c, $frozenuser) = @_;
}

=head2 user_supports

Wraps the ::User::supports() class method.

=cut

sub user_supports {
    my @features = @_;

    return Catalyst::Authentication::Store::DBIx::DataStore::User::supports(@features);
}

=head1 AUTHOR

Jon Sime, C<< <jonsime at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-authentication-store-dbix-datastore at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Authentication-Store-DBIx-DataStore>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Authentication::Store::DBIx::DataStore


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Authentication-Store-DBIx-DataStore>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Authentication-Store-DBIx-DataStore>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Authentication-Store-DBIx-DataStore>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Authentication-Store-DBIx-DataStore/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Jon Sime.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1;
