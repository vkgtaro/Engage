use strict;
use warnings;
use Test::More tests => 5;
use Test::File::Contents;
use FindBin;
use Data::Dumper;

BEGIN { use_ok 'Engage::Log' }

{
    package MyApp;
    use Moose;
    with 'Engage::Config';
    with 'Engage::Log';
    has '+config_path' => (
        default => "$FindBin::Bin/conf/"
    );
}

#=============================================================================
# new
#=============================================================================
ok( my $o = MyApp->new( config_prefix => 'dod' ), 'new' );

#=============================================================================
# isa
#=============================================================================
isa_ok( $o->logger, 'Log::Dispatch::Config', 'logger' );
isa_ok( $o->log,    'Log::Dispatch::Config', 'log' );

#=============================================================================
# logging
#=============================================================================
{
    $o->log->debug('debug');
    my $file = $o->log->{'outputs'}{'default'}{'filename'};
    file_contents_like( $file, qr/^[\w: ]{25}\[debug\]/, 'logging' );
    diag( "remove temporary file $file" );
    unlink $file;
}
