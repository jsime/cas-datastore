package Catalyst::Authentication::Store::DBIx::DataStore;

use 5.010;
use strict;
use warnings FATAL => 'all';

use Data::Dumper;
use DBIx::DataStore ( config => 'yaml' );

use Catalyst::Authentication::Store::DBIx::DataStore::User;

=head1 NAME

Catalyst::Authentication::Store::DBIx::DataStore - Authentication store for Catalyst
based on DBIx::DataStore.

=head1 VERSION

Version 0.09

=cut

our $VERSION = '0.09';


=head1 SYNOPSIS

The following example shows available configuration options for this module. When
using the Catalyst::Plugin::Authentication module, specify the 'DBIx::DataStore'
class for your store. If you wish to use an existing DBIx::DataStore object for
user lookups, pass it via the 'dbh' key.

The remaining options specify what tables and columns to use for looking up
users and their roles. The example below shows the default values that will be
used if you do not specify your own.

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

                    # If you choose the weak SHA-1 password supported by default
                    # in Catalyst::Authentication::Credential::Password
                    'password_type'      => 'hashed',
                    'password_hash_type' => 'SHA-1',

                    # Or if you prefer to pass in a much stronger password validator
                    'password_type'      => 'self_check',
                },
                store => {
                    class      => 'DBIx::DataStore',
                    dbh        => $dbh,
                    user_table => 'public.users',
                    user_key   => 'user_id',
                    user_name  => 'username',
                    role_table => 'public.roles',
                    role_key   => 'role_id',
                    role_name  => 'role_name',
                    user_role_table    => 'public.user_roles',
                    user_role_user_key => 'user_id',
                    user_role_role_key => 'role_id',

                    # If you are using 'self_check' and want something other than
                    # bcrypt(), then pass in a subroutine reference
                    password_check => \&my_checker,
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

None of these methods should be called directly. They are intended for use through
the Catalyst::Plugin::Authentication interface only.

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

    $self->{'defaults'} = {
        user_table          => '"public"."users"',
        user_key            => '"user_id"',
        user_name           => '"username"',
        role_table          => '"public"."roles"',
        role_key            => '"role_id"',
        role_name           => '"role_name"',
        user_role_table     => '"public"."user_roles"',
        user_role_user_key  => '"user_id"',
        user_role_role_key  => '"role_id"',
        active              => '"active"',
        password_check      => undef,
    };

    $self->{$_} = exists $config->{$_} && $config->{$_} =~ m{\w}o ? $self->quote_id($config->{$_}) : $self->{'defaults'}{$_}
        for keys %{$self->{'defaults'}};

    return $self;
}

=head2 find_user

Locates a user based on the credentials supplied to the authenticate method.
Returns a Catalyst::Authentication::Store::DBIx::DataStore::User object (which
inherits from Catalyst::Authentication::User);

=cut

sub find_user {
    my ($self, $authinfo, $c) = @_;

    return undef unless exists $self->{'dbh'} && ref($self->{'dbh'}) eq 'DBIx::DataStore';

    $authinfo->{'user_name'} = $authinfo->{'username'}
        if exists $authinfo->{'username'} && !exists $authinfo->{'user_name'};
    my @cols = qw( user_id user_key user_name active );

    my $sql = 'select * from ' . $self->{'user_table'} . ' where '
        . join(' and ', map { $self->{$_} . ' = ?' }
            sort grep { exists $authinfo->{$_} } @cols);

    my $res = $self->{'dbh'}->do(
        $sql,
        map { $authinfo->{$_} } sort grep { exists $authinfo->{$_} } @cols
    );

    return undef unless $res && $res->next;

    my $user = Catalyst::Authentication::Store::DBIx::DataStore::User->new($self, $res);
    return $user if $user;
    return undef;
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
    my ($self, $c, $frozen) = @_;

    return $self->find_user({ user_key => $frozen }, $c);
}

=head2 user_supports

Wraps the ::User::supports() class method.

=cut

sub user_supports {
    my @features = @_;

    return Catalyst::Authentication::Store::DBIx::DataStore::User::supports(@features);
}

=head2 quote_id

=cut

sub quote_id {
    my ($self, $name) = @_;

    # TODO actually quote the identifiers (split on periods; use DBI's method; be careful to not choke if the names are already quoted (and particularly if the already-quoted bits have periods in them))

    return $name;
}

=head1 AUTHOR

Jon Sime, C<< <jonsime at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests at L<https://github.com/jsime/cas-datastore/issues>.

=head1 SEE ALSO

=over 4

=item L<Catalyst::Plugin::Authentication>

=back

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

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Jon Sime.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1;
