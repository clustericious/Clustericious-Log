
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "A Log::Log4perl wrapper for use with Clustericious.",
  "dist_author" => [
    "Graham Ollis <plicease\@cpan.org>"
  ],
  "dist_name" => "Clustericious-Log",
  "dist_version" => "0.15",
  "license" => "perl",
  "module_name" => "Clustericious::Log",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "File::HomeDir" => "0.91",
    "File::ReadBackwards" => 0,
    "List::Util" => 0,
    "Log::Log4perl" => 0,
    "Log::Log4perl::Appender::TAP" => 0,
    "MojoX::Log::Log4perl" => 0,
    "Test::Builder::Module" => 0,
    "perl" => "v5.10.0"
  },
  "script_files" => [],
  "test_requires" => {
    "Test::More" => 0
  }
);


my %fallback_build_requires = (
  "Module::Build" => "0.3601",
  "Test::More" => 0
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
