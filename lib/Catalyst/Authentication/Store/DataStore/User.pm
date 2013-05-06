package Catalyst::Authentication::Store::DataStore::User;

use strict;
use warnings;

use base Catalyst::Authentication::User;

sub new {
    my ($class) = @_;

    my $self = bless {}, $class;

    # TODO setup user data

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
