
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Test::More" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "A Log::Log4perl wrapper for use with Clustericious.",
  "dist_author" => [
    "Graham Ollis <plicease\@cpan.org>"
  ],
  "dist_name" => "Clustericious-Log",
  "dist_version" => "0.12_01",
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
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
