use strict;
use warnings;
use Test::More tests => 11;
use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok 'Engage::Config' }

$ENV{'CONFIG_PATH'} = "$FindBin::Bin/conf";

use Data::Dumper;
use MyApp::API::Foo;
use MyApp::API::Email;
use MyApp::Job::Worker::Foo;

my $class = 'MyApp::API::Foo';

#=============================================================================
# new
#=============================================================================
ok( $class->new, 'new' );

#=============================================================================
# loaded_files
#=============================================================================
is_deeply( $class->new( config_prefix => 'dod' )->loaded_files, [
    "$FindBin::Bin/conf/dod.dbic.yml",
    "$FindBin::Bin/conf/dod.general.yml",
    "$FindBin::Bin/conf/dod.general-local.yml",
], 'loaded files include local' );

#=============================================================================
# config_suffix
#=============================================================================
is_deeply( $class->new(
        config_prefix => 'dod',
        config_suffix => 'product'
    )->loaded_files, [
        "$FindBin::Bin/conf/dod.dbic.yml",
        "$FindBin::Bin/conf/dod.general.yml",
], 'loaded files exclude local' );

#=============================================================================
# merge
#=============================================================================
{
    my $config = MyApp::API::Email->new( config_suffix => 'product' )->config;
    is_deeply( $config, {
        'sender' => {
            'mailer' =>  'SMTP',
            'mailer_args' => { 
                'Host' => 'product.example.com',
                'Hello' => 'smtp_host',
            },
        },
    }, 'merge product' );
}
{
    my $config = MyApp::API::Email->new( config_suffix => 'staging' )->config;
    is_deeply( $config, {
        'sender' => {
            'mailer' =>  'SMTP',
            'mailer_args' => { 
                'Host' => 'staging.example.com',
                'Hello' => 'smtp_host',
            },
        },
    }, 'merge staging' );
}

#=============================================================================
# substitute
#=============================================================================
{
    $ENV{'MYAPP_FOO'} = 'env_foo';
    my $home = $class->new->home;
    my $config = $class->new( config_prefix => 'test' )->config;
    is_deeply( $config->{'substitute'}, {
        'env_value' => 'env_foo',
        'path_to' => "$home/somewhere",
        'home' => "$home",
    }, 'substitute' );
}

#=============================================================================
# config_switch
#=============================================================================
{
    local $ENV{'HOSTNAME'} = 'prod001';
    my $config = $class->new( config_prefix => 'test', config_switch => 1 )->config;
    is( $config->{'nproc'}, 5, "config_switch $ENV{HOSTNAME}" );
}
{
    local $ENV{'HOSTNAME'} = 'develop';
    my $config = $class->new( config_prefix => 'test', config_switch => 1 )->config;
    is( $config->{'nproc'}, 3, "config_switch $ENV{HOSTNAME}" );
}
{
    local $ENV{'HOSTNAME'} = 'somewhere';
    my $config = $class->new( config_prefix => 'test', config_switch => 1 )->config;
    is( $config->{'nproc'}, 1, "config_switch $ENV{HOSTNAME}" );
}

#=============================================================================
# config_base
#=============================================================================
{
    local $ENV{'HOSTNAME'} = 'dev';
    my $config = MyApp::Job::Worker::Foo->new(
        config_prefix => 'job',
        config_switch => 1,
        config_base   => 'Job::Worker',
    )->config;
    is_deeply( $config, { class => 'default', foo => 1, bar => 1 }, 'config base' );
}

