use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Clustericious::Log',
    license             => 'perl',
    dist_author         => q{Brian Duggan <brian.duggan@nasa.gov>},
    dist_version_from   => 'lib/Clustericious/Log.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Clustericious-Log-*' ],
    create_makefile_pl => 'traditional',
    requires => {
        'Log::Log4perl' => 0,
        'MojoX::Log::Log4perl' => 0,
        'List::Util' => 0,
        'File::ReadBackwards' => 0,
    }
);

$builder->create_build_script();
