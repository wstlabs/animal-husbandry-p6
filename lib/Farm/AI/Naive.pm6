#
# A naive hill climbing strategy.  Doesn't pretend to do anything fancy; 
# at each step it just tries the most obvious thing that could bring it 
# closer to winning state, while avoiding obvious missteps.  
#
# For a more detailed description, see the README at the top of this 
# distribution.
#
use Farm::AI::Strategy;
use Farm::AI::Search;
use Farm::Sim::Posse;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade  {
        my %trade = self.find-stock-trade;
        %trade ?? { with => 'stock', %trade } !! Nil
    }

    method find-stock-trade  {
        my $S = self.posse('stock');
        my $P = self.current;
        if ((my $x = $P.wish) ∈ $S)  {
            my @t = find-admissible-trades($P,$x).grep: { $_ ⊲ $P }; 
            return { buying => $x, selling => @t.pick  } if @t
        }  
        for avail-dogs($S,$P) -> $x  {
            my @t = find-admissible-trades($P,$x).sort: { $^a ‹d› $^b };
            return { buying => $x, selling => @t[0]    } if @t
        }
        for $P.gimme -> $x {
            my @t = find-admissible-trades($P,$x).grep: { !m/<[dD]>/ };
            return { buying => $x, selling => @t.pick  } if @t
        }
        return Nil;
    }

    method eval-trade(Str $with)  {
        return False 
    } 

}

