use strict;
use warnings;

package Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective;

# ABSTRACT: Selectively upgrade a few modules to depend on the version used.

use Moose;
use Module::Data;
use Dist::Zilla::Util::EmulatePhase qw( get_prereqs expand_modname );

with expand_modname('-PrereqSource');

our $in_recursion = 0;

sub wanted_latest {
	return { map { $_ => 1 } qw(  Test::More Module::Build Dist::Zilla::PluginBundle::Author::KENTNL ) };
}

sub current_version_of { 
	my ( $self , $package ) = @_;
	return Module::Data->new( $package )->version;
}

use Data::Dump qw( pp );

sub for_each_dependency {
	my ( $self, $cpanmeta, $callback ) = @_; 

	my $prereqs = $cpanmeta->{prereqs};
	for my $phase ( keys %{ $prereqs } ) {
		my $phase_data = $prereqs->{$phase};
		for my $type ( keys %{ $phase_data } ) {
			my $type_data = $phase_data->{$type};
			next unless $type_data->isa( 'CPAN::Meta::Requirements' );
			my $requirements = $type_data->{requirements};
			for my $package ( keys %{ $requirements } ) {
				
				$callback->(
					$self, 
					{
						phase => $phase,
						type  => $type ,
						package => $package,
						requirement => $requirements->{$package},
					}
				);
			}
		}
	}
}

sub register_prereqs {
	if ( defined $in_recursion and $in_recursion > 0 ) {
		return;
	}
	local $in_recursion = ( $in_recursion + 1 );

	my $self = shift;
	my $prereqs = get_prereqs({
		zilla => $self->zilla,
		with  => [qw( -PrereqSource )],
		skip_isa => [ __PACKAGE__  , qw( - MetaData::BuiltWith )],
	});

	$self->for_each_dependency( $prereqs->cpan_meta_prereqs , sub{
		my ( $_self, $args ) = @_;
		my $package = $args->{package};
		if ( exists $self->wanted_latest->{$package} ) {
			print "\e[31m Upgrading $package \e[0m\n";
			my $cv =  $self->current_version_of( $package );
			print "\e[32m $cv\e[0m\n";
			$self->zilla->register_prereqs(
				{ phase => $args->{phase}, type => $args->{type}},
				$package , $self->current_version_of( $package ),
			);
		}
	});

	1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
