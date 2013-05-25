package Catalyst::Authentication::Store::DBIx::DataStore::User;

use strict;
use warnings;

use base 'Catalyst::Authentication::User';

=head1 NAME

Catalyst::Authentication::Store::DBIx::DataStore::User

=head1 DESCRIPTION

This module provides the User class for the DBIx::DataStore based Catalyst authentication
plugin. This module is not intended to be used directly by anything other than
Catalyst::Authentication::Store::DBIx::DataStore;

=head1 METHODS

=head2 new

User class constructor. Requires a reference to the calling authentication store object
followed by a hash reference containing all the available (or visible) user fields.

=cut

sub new {
    my ($class, $store, $userdata) = @_;

    my $self = bless {}, $class;

    $self->{'store'} = $store;

    # TODO i may just want something that works quickly now, but others are
    # going to want something more generic and flexible -- make that happen
    $self->{$_} = $userdata->{$_} for grep { exists $userdata->{$_} }
        qw( user_id email username password );

    return $self;
}

=head2 id

Returns the User ID.

=cut

sub id {
    my ($self) = @_;

    return $self->{'user_id'} if exists $self->{'user_id'};
    return;
}

=head2 roles

Returns list of roles associated with the current user.

=cut

sub roles {
    my ($self) = @_;

    return undef unless exists $self->{'store'};
    return undef unless exists $self->{'store'}{'dbh'} && ref($self->{'store'}{'dbh'}) eq 'DBIx::DataStore';

    # TODO honor the column name mappings from the store object
    my $sql = 'select r.role_name from public.user_roles ur join public.roles r on (r.role_id = ur.role_id) where ur.user_id = ?';

    my $res = $self->{'store'}{'dbh'}->do($sql, $self->{'user_id'});

    return undef unless $res;

    my @roles;
    while ($res->next) {
        push(@roles, $res->{'role_name'});
    }

    return @roles;
}

=head2 supported_features

Returns an array (or undef) indicating which Catalyst authentication, authorization,
and session features are supported.

=cut

sub supported_features {
    my ($self) = @_;

    return {
        session => 1,
        roles   => 1,
    };
}

=head2 get

Returns the value of a specific field from the User class. Accepts a single argument,
which should be the name of the field whose value is desired. Any failure results in
the return of nothing.

=cut

sub get {
    my ($self, $field) = @_;

    $field = lc($field);

    # TODO refetch from database (possibly with configurable caching)
    # so that changes are reflected immediately

    return $self->{$field}
        if exists $self->{$field};
    return;
}

=head2 get_object

Returns the User object. Intended for use by the superclass.

=cut

sub get_object {
    my ($self) = @_;

    return $self;
}

1;
