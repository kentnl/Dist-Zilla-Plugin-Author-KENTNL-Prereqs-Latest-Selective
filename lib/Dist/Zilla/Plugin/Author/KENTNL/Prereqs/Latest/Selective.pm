use strict;
use warnings;

package Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective;
BEGIN {
  $Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective::VERSION = '0.1.0';
}

# ABSTRACT: Selectively upgrade a few modules to depend on the version used.

use Moose;
use Module::Data;
use Dist::Zilla::Util::EmulatePhase qw( get_prereqs expand_modname );

with expand_modname('-PrereqSource');

our $in_recursion = undef;

sub wanted_latest {
	return { map { $_ => 1 } qw(  Test::More Module::Build ) };
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
	if ( defined $in_recursion ) { 
		return;
	}
	local $in_recursion = 1;
	my $self = shift;
	my $prereqs = get_prereqs({
		zilla => $self->zilla,
		with  => [qw( -PrereqSource )],
		skip_isa => [ __PACKAGE__ ],
	});
	my $np = $prereqs->cpan_meta_prereqs->clone();

	$self->for_each_dependency($np, sub{
		my ( $self, $args ) = @_;
		my $package = $args->{package};
		if ( exists $self->wanted_latest->{$package} ) {
			$self->register_prereqs(
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

__END__
=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::Plugin::Author::KENTNL::Prereqs::Latest::Selective - Selectively upgrade a few modules to depend on the version used.

=head1 VERSION

version 0.1.0

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

