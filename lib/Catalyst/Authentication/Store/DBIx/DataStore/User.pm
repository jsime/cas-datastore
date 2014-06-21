package Catalyst::Authentication::Store::DBIx::DataStore::User;

use strict;
use warnings;

use base 'Catalyst::Authentication::User';

use Authen::Passphrase::BlowfishCrypt;

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

    my $sql = qq|
        select r.$self->{'store'}{'role_name'} as role_name
        from $self->{'store'}{'user_role_table'} ur
            join $self->{'store'}{'role_table'} r
                on ( r.$self->{'store'}{'role_key'}
                     =
                     ur.$self->{'store'}{'user_role_role_key'})
        where ur.$self->{'store'}{'user_role_user_key'} = ?
    |;

    my $res = $self->{'store'}{'dbh'}->do($sql, $self->{'user_id'});

    return undef unless $res;

    my @roles;
    while ($res->next) {
        push(@roles, $res->{'role_name'});
    }

    return @roles;
}

=head2 check_password

Relies on Authen::Passphrase::BlowfishCrypt to verify user's password using
the strong bcrypt cipher (considerably stronger than SHA-1). Called only when
you have selected 'self_check' for your authentication type.

This method may be replaced with your own by passing in a subroutine
reference under the 'password_check' configuration key.

=cut

sub check_password {
    my ($self, $password) = @_;

    my $ppr = Authen::Passphrase::BlowfishCrypt->from_crypt(
        $self->{'password'}
    );

    return 1 if $ppr->match($password);
    return 0;
}

=head2 hash_password

Creates a hashed version of the given passphrase using the strong bcrypt
cipher provided via Authen::Passphrase::BlowfishCrypt. Value returned is
a crypt string containing all components necessary to verify password
input later.

This method is only useful if you have chosen 'self_check' for your
authentication's password type, but have not provided a subroutine
reference to 'password_check' in the configuration. If you have provided
your own check subroutine, you are responsible for generating hashes of
passphrases which it will be able to understand.

=cut

sub hash_password {
    my ($self, $cleartext) = @_;

    my $ppr = Authen::Passphrase::BlowfishCrypt->new(
        cost        => 12,
        key_nul     => 1,
        salt_random => 1,
        passphrase  => $cleartext
    );

    return $ppr->as_crypt;
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
