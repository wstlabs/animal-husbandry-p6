use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::Sim::Dice;
use KeyBag::Ops;

my @frisky is ro = frisky-animals();
constant %STOCK = {
    r => 60, s => 24, p => 20, c => 12, h => 6, 
    d =>  4, D =>  2
};

class Farm::Sim::Game  {
    has %!p;         # players (and stock): hash of hashes of animals
    has $!dice;      # combined fox-wolf die object
    has @!e;         # event queue: array of hashes representing events
    has $!cp;        # current player
    has %!tr;        # player trading code objects
    has %!ac;        # player accept trade code objects
    has $!j;         # current step
    has $!n;         # (optional) last step 
    has @!r;         # (optional) canned roll sequence, for testing
    has $!debug;     # (optional) debug flag
    submethod BUILD(:%!p, :@!e, :$!cp = 'player_1', :%!tr, :%!ac, :$!n, :@!r, :$!debug = 0) {
        %!p<stock> //= posse(%STOCK); 
        $!dice     //= Farm::Sim::Dice.instance;
        $!j = 0;
        $!debug = 0 unless defined($!debug);
    }

    method trace(*@a)  { if ($!debug > 0)  { say @a } }
    method debug(*@a)  { if ($!debug > 1)  { say @a } }

    #
    # static (factory-like) instance generators 
    #

    # creates an empty game on $n players 
    method simple (:$k, :$n, :$debug )  {
        my %p = hash map { ; "player_$_" => posse({}) }, 1..$k;
        self.new(p => %p, :$n, :$debug)
    }

    # creates a standard contest game on the specified player list 
    # XXX should check integrity of tr, ac hashes 
    method contest (:@players, :%tr, :%ac, :$n, :$debug )  {
        my %p = hash map { ; $_ => posse({}) }, @players; 
        self.new(p => %p, :%tr, :%ac, :$n, :$debug)
    }

    method posse (Str $name)  { %!p{$name}.clone }
    method players { %!p.keys.sort }
    method table {
        hash map -> $k,$v {
            $k => $v.Str
        }, %!p.kv
    }
    
    method stats {
        return { 
            j => $!j
        }
    }


    #
    # play for a fixed number of rounds
    #
    multi method play(Int $n where { $n >= 0 })  {
        self.play-round() for 1..$n;
        return self
    }

    #
    # keep playing until we hit some limit specified by
    # parameters given to the constructor 
    #
    multi method play()  {
        while (1)  {
            last if defined($!n) && $!j >= $!n;
            last if @!r.Int > 0  && $!j >= @!r;
            self.play-round() 
        }
        return self
    }
    
    method play-round  {
        my $roll  = @!r[$!j] // $!dice.roll;
        my $was   = self.posse($!cp);
        my @need  = $was.need;
        self.trace("::play step: $!j");
        self.trace("::play curr: $!cp");
        self.trace("::play have: $was");
        self.trace("::play need: ", @need.join('') );
        self.trace("::play roll: $roll");
        self.publish: { :type<roll>, :player($!cp), :$roll };
        self.effect($!cp,$roll);
        self.trace( "::play done: ?");
        my $now    = self.posse($!cp);
        self.show-recent( :$was, :$now );
        self.incr;
        return self
    }

    #
    # note that we process the [w] and [f] rolls in the same order as in 
    # carl's original version, even though this ordering was apparently not 
    # clearly stated in the printed instructions for the game.  however, 
    # the choice of ordering affects only the event logging, not the outcome 
    # on the player's animals.
    # 
    # note also that in any case, we proceed to attempt to mate with whatever 
    # animal was contained in the roll after the the predator has had his way 
    # with the existing posse. 
    #
    method effect(Str $player, Str $roll)  {
        self.trace("::effect $player ~ $roll");
        given $roll {
            when /[w]/ { 
                my $posse = self.posse($player);
                self.trace("::effect posse = $posse");
                if ('D' ∈ $posse)  {
                    # say "LOSE ", 'D'; 
                    self.transfer( $player, 'stock', 'D' )
                }
                else  {
                    # say "LOSE ", ~$posse.slice([<r s p c>]);
                    self.transfer( $player, 'stock', $posse.slice([<r s p c>]) )
                }
                proceed;
            }
            when /[f]/ { 
                my $posse = self.posse($player);
                self.trace("::effect posse = $posse");
                if ('d' ∈ $posse)  {
                    # say "LOSE ", 'd'; 
                    self.transfer( $player, 'stock', 'd' )
                }
                else  {
                    # say "LOSE ", ~$posse.slice([<r>]);
                    self.transfer( $player, 'stock', $posse.slice([<r>]) )
                }
                proceed;
            }
            default  {
                my $stock = self.posse('stock'); 
                my $posse = self.posse($player);
                self.trace("::effect posse = $posse");
                self.trace("::effect stock = $stock");
                my $desired = $posse ⚤ $roll;
                self.trace("::effect desired = $desired");
                my $allowed = $desired ∩ $stock;
                self.trace("::effect allowed = $allowed"); 
                # say "GAIN ", ~$allowed; 
                self.transfer( 'stock', $player, $allowed )
            }
        }
    }

    method transfer($from, $to, $what) {
        self.trace("::transer $from => $to:  $what");
        if ($what)  {
             %!p{$to}    ⊎= $what;
             %!p{$from}  ∖= $what;
        }
        # self.trace("now: ", self.table);
        self.publish: { 
            :type<transfer>, :$from, :$to, 
            'animals' => "$what"
        };
    }

    method publish(%event) {
        self.trace("::publish {%event.perl}");
        push @!e, {%event}
    }


    #
    # show what happened recently
    #
    method show-recent( :$was, :$now )  { 
        my %m = self.inspect-recent;
        self.trace("::meta = {%m.perl}");
        self.trace("::was = $was, now = $now");
        my $eaten = (defined %m<puts>) ?? "-%m<puts>" !! "";
        say "roll %m<player> $was ~ %m<roll> -> +%m<gets> $eaten » $now";
    }

    method inspect-recent {
        # self.debug("::inspect e = ", @!e.Int);
        my @ev = self.slice-recent-events-upto("type","roll");
        # self.debug("::inspect e = ", @!e.Int);
        self.debug("::inspect top = {@ev.perl}");
        for @ev -> %e  {
            self.debug("::inspect e = {%e.perl}")
        }

        my %r = shift @ev;
        self.debug("::inspect r = {%r.perl}");
        my $player  = %r<player>;
        my $roll    = %r<roll>;
        self.debug("::inspect player  = ", $player);
        self.debug("::inspect roll    = ", $roll);

        my (@gets,@puts);
        for @ev -> %e  {
            self.debug("::inspect e = {%e.perl}");
            my $animals = %e<animals>;
            my $from    = %e<from>;
            my $to      = %e<to>;
            self.debug("::inspect animals = ", $animals);
            self.debug("::inspect from    = ", $from);
            self.debug("::inspect to      = ", $to);
            if ($from eq 'stock')  {
                push @gets, $animals;
            }
            if ($to   eq 'stock')  {
                push @puts, $animals;
            }
        }
        my %s;
        %s<gets> = @gets.join(',') if @gets;
        %s<puts> = @puts.join(',') if @puts;
        return { :$player, :$roll, %s } 
        # my $gets = @gets.join(',');
        # my $puts = @puts.join(',');
        # return { :$player, :$roll, :$gets, :$puts }; 

    }

    #
    # slices from the top of the event stack (non-destructively)
    # until a certain criterion -- here clumsily represnted by a
    # positional $k, $v pair -- is met.
    #
    # Array.new(
    #   {"type" => "roll", "player" => "P1", "roll" => "hr"}, 
    #   {"type" => "transfer", "from" => "stock", "to" => "P1", "animals" => "r"}
    # )
    method slice-recent-events-upto(Str $k, Str $v) {
        gather {
            for @!e.reverse -> %e  {
                take {%e};
                last if %e{$k} eq $v 
            }
        }.reverse
    }

    method incr {
        $!cp = "player_1" unless %!p.exists(++$!cp);
        $!j++
    }
    
};


=begin END

⚤
"»» ..";

        # XXX ugh. why won't this work in p6?
        # my (%re,%te,@xtra) = @evens

            say "play j = $!j";
            say "ugh, ", $!j >= $!n;
            # last if (defined $!n) && ($!j >= $!n);
            # last if (@!r.Int > 0) && ($!j >= @!r);
            last if defined($!n) && $!j >= $!n;
            last if @!r.Int > 0  && $!j >= @!r;
            say "play ..";
            self.play-round() 

