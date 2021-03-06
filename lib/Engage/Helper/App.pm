package Engage::Helper::App;

use Moose;
use POSIX;
extends 'Engage::Helper';
use Data::Dumper;

has 'gen_app' => (
    is  => 'ro',
    isa => 'Bool',
);

has 'gen_makefile' => (
    is  => 'ro',
    isa => 'Bool',
);

has 'gen_scripts' => (
    is  => 'ro',
    isa => 'Bool',
);

after 'mk_stuff' => sub {
    print qq/Change to application directory and Run "perl Makefile.PL" to make sure your install is complete\n/;
};

no Moose;

__PACKAGE__->meta->make_immutable;

sub BUILDARGS {
    my ( $self, $args ) = @_;
    return +{
        %$args,
        gen_app      => !($args->{'makefile'} || $args->{'scripts'}),
        gen_makefile => !$args->{'scripts'},
        gen_scripts  => !$args->{'makefile'},
    }
}

sub BUILD {
    my $self = shift;

    my $app_prefix = $self->app_prefix;
    $self->vars({
        'all_from' => File::Spec->catfile( 'lib', split '::', $self->name ) . '.pm',
        'time'     => POSIX::strftime('%Y-%m-%d %H:%M:%S UTC', gmtime),
    });

    $self->set_dir(
        'dod' => $self->catdir('app', 'DOD'),
        'dao' => $self->catdir('app', 'DAO'),
        'api' => $self->catdir('app', 'API'),
        'srv' => $self->catdir('app', 'SRV'),
        'wui' => $self->catdir('app', 'WUI'),
    );

    $self->push_dirs(
        $self->catdir( 'static', 'css' ),
        $self->catdir( 'static', 'image' ),
        $self->catdir( 'static', 'js' ),
    );

    $self->set_file( 'readme'    => $self->catdir('root', 'README') );
    $self->set_file( 'changes'   => $self->catdir('root', 'Changes') );
    $self->set_file( 'makefile'  => $self->catdir('root', 'Makefile.PL') );
    $self->set_file( 'modulebuildrc' => $self->catdir( 'extlib', '.modulebuildrc') );
    $self->set_file( 's_create'  => $self->catdir('script', "$app_prefix\_create.pl") );
    $self->set_file( 's_cli'     => $self->catdir('script', "$app_prefix\_cli.pl") );
    $self->set_file( 's_fastcgi' => $self->catdir('script', "$app_prefix\_fastcgi.pl") );
    $self->set_file( 's_server'  => $self->catdir('script', "$app_prefix\_server.pl") );
}

1;

__DATA__
___[readme]___
Run script/[% app_prefix %]_server.pl to test the application.
___[makefile]___
use inc::Module::Install;

name '[% dir.base %]';
all_from '[% all_from %]';

requires 'Moose';

install_script glob('script/*.pl');
auto_install;
WriteAll;
___[changes]___
This file documents the revision history for Perl extension [% name %].

0.001  [% time %]
       - initial revision, generated by Engage
___[class_api]___
package [% name %]::API;

use Moose;
extends 'Engage::API';

__PACKAGE__->meta->make_immutable;
___[class_dao]___
package [% name %]::DAO;

use Moose;
extends 'Engage::DAO';

__PACKAGE__->meta->make_immutable;
___[s_create]___
#![% perlpath %]
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use local::lib '--self-contained', "$FindBin::Bin/../extlib";
use Getopt::Long;
use Pod::Usage;
use Engage::Helper;

my %opt = (
    'help'  => 0,
    'force' => 0,
    'mech'  => 0,
);

GetOptions( \%opt,
    'help|?',
    'force|nonew',
    'mech|mechanize'
);

my $helper = shift;

pod2usage(1) if ( $opt{'help'} || !$helper );

STDOUT->autoflush;
Engage::Helper->new(
    name => [% name %],
    helper => $helper,
    %opt
)->mk_stuff or pod2usage(1);

___[s_cli]___
#![% perlpath %]
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use local::lib '--self-contained', "$FindBin::Bin/../extlib";
use [% name %]::CLI -run;
___[s_fastcgi]___
#![% perlpath %]
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use local::lib '--self-contained', "$FindBin::Bin/../extlib";
use [% name %]::FCGI::Daemon;
[% name %]::FCGI::Daemon->new( site => shift )->run;
___[s_server]___
#![% perlpath %]
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use local::lib '--self-contained', "$FindBin::Bin/../extlib";
use Getopt::Long;
use Pod::Usage;
___[modulebuildrc]___
install --install_base extlib
