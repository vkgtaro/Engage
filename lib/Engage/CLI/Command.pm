package Engage::CLI::Command;

use Moose;
use Engage::Exception;
extends 'MooseX::App::Cmd::Command';
with 'Engage::Utils';
with 'Engage::Config';
with 'Engage::Log';
with 'Engage::Class::Loader';

has '+config_prefix' => (
    default => 'cli'
);

no Moose;

__PACKAGE__->add_loader('API');
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Craftworks, C<< <craftwork at cpan org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Craftworks, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

