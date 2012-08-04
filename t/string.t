use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Farm::Sim::Util;
use KeyBag::Ops;
use Test;
plan *;

sub test_bij($s, %h)  {
    ok  hashify($s)   eqv %h, "$s --> Hash";
    ok  stringify(%h) eq  $s, "$s <-- Hash";

    my ($x,$y);
    lives_ok { $x = posse($s) },  "$s --> Obj";
    is "$x", $s,                  "$s <-- Obj";
    lives_ok { $y = posse(%h) },  "%h --> Obj";
    is "$y", $s,                  "$s <-- Obj";
    ok $y.hash eqv %h,            "%h <-- Obj";
}

sub test_surj($s, %h)  {
    my $x;
    ok  hashify($s) eqv %h,       "$s --> Hash eqv Hash";
    lives_ok { $x = posse($s) },  "$s --> Obj";
    ok  $x.hash eqv %h,           "$s --> Obj eqv Hash";
    # say "x      = ", $x;
    # say "x.hash = ", $x.hash;
    # say "h      = ", %h;
}

#
# straightforward (bijective) cases
#
{
    test_bij( '∅',    {}                  );
    test_bij( 'r',    { r => 1 }          );
    test_bij( 'r2',   { r => 2 }          );
    test_bij( 'r666', { r => 666 }        );
    test_bij( 'rs',   { r => 1, s => 1 }  );
    test_bij( 
        'r2p3ch', { 
            r => 2, p => 3, c => 1, h => 1 
        }
    )
}



#
# non-bijective cases
#
{
    test_surj( 'rr',   { r => 2 } );
    test_surj( 'r3r2', { r => 5 } );
}

#
# degenerate cases
#
{
    test_surj( 'r0',   {}          );
    test_surj( 'r01',  { r => 1 }  );
}

#
# failing cases
#
{
    constant @broken = ( 
        '',
        'x', 'x2', 'xr', 'rx', 
        '∅∅', 'r∅', '∅r',
        'r-1', 'r1/2', 'r1.0',
        0, 1, 2, '2',
        '0r', '1r', '2r3'
    );

    for @broken -> $s {
        dies_ok { my %h = hashify($s) }, $s 
    }

}





