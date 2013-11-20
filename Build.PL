
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4201"
  },
  "configure_requires" => {
    "Module::Build" => "0.4201"
  },
  "dist_abstract" => "[DEPRECATED] Selectively upgrade a few modules to depend on the version used.",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Author-KENTNL-Prereqs-Latest-Selective",
  "dist_version" => "0.1.2",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Dist::Zilla::Role::PrereqSource" => 0,
    "Dist::Zilla::Util::EmulatePhase" => 0,
    "Module::Data" => 0,
    "Moose" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Test::More" => "1.001002"
  }
);


my %fallback_build_requires = (
  "Module::Build" => "0.4201",
  "Test::More" => "1.001002"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
