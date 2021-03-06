use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::AI::Search;
use Farm::AI::Search::Data;

say table-counts;

my $x = downward-equiv-to('h');
say "x = ", $x.WHICH;

my @piggy = downward-equiv-to('h').grep(/p/);
say "piggy = ", @piggy.Int;
say "doggy   = ", downward-equiv-to('h').grep(/<[dD]>/).Int;

my @dogs = grep /<[d]>/, downward-equiv-to('h');
say "dogs = ", @dogs.Int;

my %t = hash map -> $k { $k => downward-equiv-to($k).Int }, domestic-animals;
say "t = ", %t;

{
    my $x = posse("d4c3");
    my $y = posse("D3h3c6p5");
    my @t = avail-d($x,$y);
    # say "t = ", @t;
    # for @t -> $k { say $k }
    for avail-d($x,$y) -> $k { say $k }
    my $z = posse("sr6");
    for avail-d($x,$z) -> $k { say $k }
    for avail-D($y,$x) -> $k { say $k }
}


=begin END

