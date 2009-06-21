package Engage::Utils;

use Moose::Role;
use MooseX::Types::Path::Class;
use Cwd;

has 'home' => (
    is  => 'ro',
    isa => 'Path::Class::Dir',
    builder => '_build_home',
    coerce => 1,
);

has 'app_name' => (
    is  => 'ro',
    isa => 'Str',
    builder => '_build_app_name',
);

sub _build_app_name {
    my $pkg = ref shift;
    return index($pkg, ':') != -1
            ?  substr $pkg, 0, index($pkg, ':')
            : $pkg;
}

sub _build_home {
    my $self = shift;

    my $home;

    if ( my $env = $self->env_value('HOME') ) {
        $home = $env;
    }
    else {
        my $class = ref $self;
        (my $file = "$class.pm") =~ s{::}{/}go;

        if ( my $inc_entry = $INC{$file} ) {
            (my $path = $inc_entry ) =~ s/$file$//;
            $home = Path::Class::Dir->new($path);
        }
        else {
            $home = Path::Class::Dir->new(Cwd::cwd);
        }

        $home = $home->absolute->cleanup->resolve;
        $home = $home->parent while $home =~ /b?lib$/o;
    }

    return $home;
}

sub env_value {
    my ( $self, $key ) = @_;

    my $class = blessed $self ? ref $self : $self;
    $class =~ s/::/_/g;
    $class = uc $class;
    $key   = uc $key;

    for my $prefix ( $class, 'ENGAGE' ) {
        if ( defined( my $value = $ENV{"${prefix}_${key}"} ) ) {
            return $value;
        }
    }
    return;
}

sub path_to {
    my ( $self, @path ) = @_;
    my $path = Path::Class::Dir->new( $self->home, @path );
    if ( -d $path ) {
        return $path->resolve;
    }
    else {
        return Path::Class::File->new( $self->home, @path );
    }
}

no Moose::Role;

1;

__END__

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 env_value($class, $key)

Checks for and returns an environment value. For instance, if $key is
'home', then this method will check for and return the first value it finds,
looking at $ENV{MYAPP_HOME} and $ENV{ENGAGE_HOME}.

=head2 path_to(@path)

Merges C<@path> with C<< home() >> and returns a
L<Path::Class::Dir> object. Note you can usually use this object as
a filename, but sometimes you will have to explicitly stringify it
yourself by calling the C<<->stringify>> method.

For example:

    $self->path_to( 'db', 'sqlite.db' );

=head1 AUTHOR

Craftworks, C<< <craftwork at cpan org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Craftworks, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
