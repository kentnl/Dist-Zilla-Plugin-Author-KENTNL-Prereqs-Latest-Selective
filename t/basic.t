use strict;
use warnings;

use Test::More;
use Test::DZil qw( simple_ini );
use Dist::Zilla::Util::Test::KENTNL 1.003001 qw( dztest );

# FILENAME: basic.t
# CREATED: 08/31/14 00:29:32 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: basic

my $test = dztest();
$test->add_file( 'dist.ini',
  simple_ini( [ 'Prereqs', { 'Test::More' => 0 } ], ['Author::KENTNL::Prereqs::Latest::Selective'], ) );
$test->build_ok;
my $dm = $test->distmeta->{prereqs}->{runtime};

ok( exists $dm->{requires}->{'Test::More'}, "Test::More is required" ) or diag explain $dm;
require Test::More;
if ( eval { Test::More->VERSION('0.90'); 1; } ) {
  isnt( $dm->{requires}->{'Test::More'}, '0.89', "Test::More is better than 0.89" );
}
isnt( $dm->{requires}->{'Test::More'}, '0', "Test::More is better than 0" );

done_testing;

