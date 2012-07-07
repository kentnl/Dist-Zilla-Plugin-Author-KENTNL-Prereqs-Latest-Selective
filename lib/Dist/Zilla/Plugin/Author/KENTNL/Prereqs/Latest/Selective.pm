use strict;
use warnings;

package Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective;

# ABSTRACT: Selectively upgrade a few modules to depend on the version used.

use Moose;
use Module::Data;
use Dist::Zilla::Util::EmulatePhase qw( get_prereqs expand_modname );

with expand_modname('-PrereqSource');

=head1 SYNOPSIS


	[Autoprereqs]

	[Author::KENTNL::Prereqs::Latest::Selective]

This will automatically upgrade the minimum required version to the currently running version, for a selective  list of packages,
wherever they appear in dependencies.

Currently, the list of packages that will be upgraded to the current version are as follows:

=over 4

=item * Test::More    - What I test all my packages with

=item * Module::Build - The Installer I use for everything

=item * Dist::Zilla::PluginBundle::Author::KENTNL - The config setup I use for everything.

=back

=cut


=method wanted_latest

	my $hash = $plugin->wanted_latest();

A Hashmap of Modules I want to be "Latest I've released with"

	{
		'Test::More' => 1,
		'Module::Build' => 1,
		'Dist::Zilla::PluginBundle::Author::KENTNL' => 1,
	}

=cut

sub wanted_latest {
  return { map { $_ => 1 } qw(  Test::More Module::Build Dist::Zilla::PluginBundle::Author::KENTNL ) };
}

=method current_version_of

	my $v = $plugin->current_version_of('Foo');

Returns the currently installed version of a given thing.

=cut

sub current_version_of {
  my ( $self, $package ) = @_;
  return Module::Data->new($package)->version;
}

sub for_each_dependency {
  my ( $self, $cpanmeta, $callback ) = @_;

  my $prereqs = $cpanmeta->{prereqs};
  for my $phase ( keys %{$prereqs} ) {
    my $phase_data = $prereqs->{$phase};
    for my $type ( keys %{$phase_data} ) {
      my $type_data = $phase_data->{$type};
      next unless $type_data->isa('CPAN::Meta::Requirements');
      my $requirements = $type_data->{requirements};
      for my $package ( keys %{$requirements} ) {

        $callback->(
          $self,
          {
            phase       => $phase,
            type        => $type,
            package     => $package,
            requirement => $requirements->{$package},
          }
        );
      }
    }
  }
}

our $in_recursion = 0;

sub register_prereqs {
  if ( defined $in_recursion and $in_recursion > 0 ) {
    return;
  }
  local $in_recursion = ( $in_recursion + 1 );

  my $self    = shift;
  my $prereqs = get_prereqs(
    {
      zilla    => $self->zilla,
      with     => [qw( -PrereqSource )],
      skip_isa => [ __PACKAGE__, qw( -MetaData::BuiltWith ) ],
    }
  );

  $self->for_each_dependency(
    $prereqs->cpan_meta_prereqs => sub {
      my ( $_self, $args ) = @_;
      my $package = $args->{package};

      return unless exists $self->wanted_latest->{$package};

      $self->zilla->register_prereqs(
        { phase => $args->{phase}, type => $args->{type} },
        $package, $self->current_version_of($package),
      );
    }
  );

  1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
