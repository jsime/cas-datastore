package Catalyst::Authentication::Store::DBIx::DataStore::User;

use strict;
use warnings;

use base Catalyst::Authentication::User;

sub new {
    my ($class, $userdata) = @_;

    my $self = bless {}, $class;

    # TODO i may just want something that works quickly now, but others are
    # going to want something more generic and flexible -- make that happen
    $self->{$_} = $userdata->{$_} for grep { exists $userdata->{$_} }
        qw( user_id email username password );

    return $self;
}

sub id {
    my ($self) = @_;

    return $self->{'user_id'} if exists $self->{'user_id'};
    return;
}

sub supported_features {
    return undef;
}

sub get {
    my ($self, $field) = @_;

    $field = lc($field);

    # TODO refetch from database (possibly with configurable caching)
    # so that changes are reflected immediately

    return $self->{$field}
        if exists $self->{$field};
    return;
}

sub get_object {
    my ($self) = @_;

    return $self;
}

1;
