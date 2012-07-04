
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => "0.88"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Selectively upgrade a few modules to depend on the version used.",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Author-KENTNL-Prereqs-Latest-Selective",
  "dist_version" => "0.1.0",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Data::Dump" => 0,
    "Dist::Zilla::Util::EmulatePhase" => 0,
    "Moose" => 0,
    "perl" => "v5.10.0",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
