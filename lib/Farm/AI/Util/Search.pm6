use Farm::Sim::Util;
use Farm::Sim::Posse;
use KeyBag::Ops;

#
# combinatorially generated table of trades equivalent to one
# of the 5 core ("frisky") animals, <r s p c h>. 
#
constant %T = { 
    'r' => [<r>],
    's' => [<d s r6>],
    'p' => [<p d2 ds s2 dr6 sr6 r12>],
    'c' => [<
        D c
        p3 
        p2d2 p2ds p2s2 p2dr6 p2r12 p2sr6 
        pd4 
        pd3r6 pd3s 
        pd2r12 pd2s2 pd2sr6 
        pdr18 pds2r6 pds3 pdsr12 
        ps4 ps3r6 ps2r12 psr18 pr24 
        d4s2 d4sr6 d4r12 
        d3s3 d3s2r6 d3sr12 d3r18 
        d2s4 d2s3r6 d2s2r12 d2sr18 d2r24 
        ds5 ds4r6 ds3r12 ds2r18 dsr24 dr30 
        s6 s5r6 s4r12 s3r18 s2r24 sr30 r36 >],
    'h' => [<
        h
        D2 Dc 
        Dp3 
        Dp2d2 Dp2dr6 Dp2ds Dp2r12 Dp2s2 Dp2sr6 
        Dpd4 
        Dpd3s 
        Dpd2r12 Dpd2s2 Dpd2sr6 Dpd3r6 
        Dpdr18 Dpds2r6 Dpds3 Dpdsr12 
        Dps4 Dps3r6 Dps2r12 Dpsr18 Dpr24 
        Dd4r12 Dd4s2 Dd4sr6 
        Dd3r18 Dd3s2r6 Dd3s3 Dd3sr12 
        Dd2r24 Dd2s2r12 Dd2s3r6 Dd2s4 Dd2sr18 
        Ddr30 Dds2r18 Dds3r12 Dds4r6 Dds5 Ddsr24 
        Ds6 Ds5r6 Ds4r12 Ds3r18 Ds2r24 Dsr30 
        Dr36 
        c2 
        cp3 
        cp2d2 cp2dr6 cp2ds cp2r12 cp2s2 cp2sr6 
        cpd4 
        cpd3r6 cpd3s 
        cpd2r12 cpd2s2 cpd2sr6 
        cpds3 cpds2r6 cpdsr12 cpdr18 
        cps4 cps3r6 cps2r12 cpsr18 cpr24 
        cd4r12 cd4s2 cd4sr6 
        cd3r18 cd3s2r6 cd3s3 cd3sr12 
        cd2r24 cd2s2r12 cd2s3r6 cd2s4 cd2sr18 
        cds5 cds4r6 cds3r12 cds2r18 cdsr24 cdr30 
        cs6 cs5r6 cs4r12 cs3r18 cs2r24 csr30 cr36 
        p6 
        p5d2 p5dr6 p5ds p5r12 p5s2 p5sr6 
        p4d4 
        p4d3r6 p4d3s 
        p4d2r12 p4d2s2 p4d2sr6 
        p4ds3 p4ds2r6 p4dsr12 p4dr18 
        p4s4 p4s3r6 p4s2r12 p4sr18 p4r24 
        p3d4r12 p3d4s2 p3d4sr6 
        p3d3r18 p3d3s2r6 p3d3s3 p3d3sr12 
        p3d2r24 p3d2s2r12 p3d2s3r6 p3d2s4 p3d2sr18 
        p3dr30 p3ds2r18 p3ds3r12 p3ds4r6 p3ds5 p3dsr24 
        p3s6 p3s5r6 p3s4r12 p3s3r18 p3s2r24 p3sr30 p3r36 
        p2d4s4 p2d4s3r6 p2d4s2r12 p2d4sr18 p2d4r24 
        p2d3r30 p2d3s2r18 p2d3s3r12 p2d3s4r6 p2d3s5 p2d3sr24 
        p2d2r36 p2d2s2r24 p2d2s3r18 p2d2s4r12 p2d2s5r6 p2d2s6 p2d2sr30 
        p2ds7 p2ds6r6 p2ds5r12 p2ds4r18 p2ds3r24 p2ds2r30 p2dsr36 p2dr42 
        p2s8 p2s7r6 p2s6r12 p2s5r18 p2s4r24 p2s3r30 p2s2r36 p2sr42 p2r48 
        pd4r36 pd4s2r24 pd4s3r18 pd4s4r12 pd4s5r6 pd4s6 pd4sr30 
        pd3r42 pd3s2r30 pd3s3r24 pd3s4r18 pd3s5r12 pd3s6r6 pd3s7 pd3sr36 
        pd2r48 pd2s2r36 pd2s3r30 pd2s4r24 pd2s5r18 pd2s6r12 pd2s7r6 pd2s8 pd2sr42 
        pdr54 pds2r42 pds3r36 pds4r30 pds5r24 pds6r18 pds7r12 pds8r6 pds9 pdsr48 
        ps10 ps9r6 ps8r12 ps7r18 ps6r24 ps5r30 ps4r36 ps3r42 ps2r48 psr54 pr60 
        d4s8 d4s7r6 d4s6r12 d4s5r18 d4s4r24 d4s3r30 d4s2r36 d4sr42 d4r48 
        d3s9 d3s8r6 d3s7r12 d3s6r18 d3s5r24 d3s4r30 d3s3r36 d3s2r42 d3sr48 d3r54 
        d2s10 d2s9r6 d2s8r12 d2s7r18 d2s6r24 d2s5r30 d2s4r36 d2s3r42 d2s2r48 d2sr54 d2r60 
        ds11 ds10r6 ds9r12 ds8r18 ds7r24 ds6r30 ds5r36 ds4r42 ds3r48 ds2r54 dsr60 
        s12 s11r6 s10r12 s9r18 s8r24 s7r30 s6r36 s5r42 s4r48 s3r54 s2r60 
    >]
};


sub table-counts is export {
    hash map -> $k {
        $k => equiv-to($k).Int 
    }, domestic-animals() 
}

# a simple alias which "binds" animal symbols of equivalent worth
# and also loudly fails if we're not given a valid animal symbol
sub deref-to(Str $x) {
        $x eq 'd' ?? %T{'s'} !! 
        $x eq 'D' ?? %T{'c'} !! 
    %T.exists($x) ?? %T{$x}  !! die "invalid (non-domestic) animal symbol '$x'"
}

sub equiv-to(Str $x) is export { deref-to($x).list }

sub find-admissible-trades(Farm::Sim::Posse $p, Str $x) is export {
    grep { $p ⊇ fly($_) }, equiv-to($x)
}


# flyweight pattern for posse instances - which, theoretically, should save a lot 
# on construction costs -- but currently at the cost of volatility, in currently 
# the instances are rw, and fully open to mutation (so don't do that, please).
my %F;
multi sub fly(Farm::Sim::Posse $x --> Farm::Sim::Posse) is export { $x }
multi sub fly(             Str $x --> Farm::Sim::Posse) is export {
    die "can't inflate:  not a domestic posse string" unless is-domestic-posse-str($x);
    %F{$x} //= posse($x)
}
sub fly-stats is export { n => %F.keys.Int }


# simple quantifiers which provide a list of available small (or big) dogs,
# respectively, which are owned by $P and which $Q can (nominally) afford to buy.
# Note that this -doesn't- mean that $Q has animals available for trade to buy 
# these dogs from $P; just that in principle it has enough animals available 
# for trade, so that it might be worth searching for matching trades.
multi sub avail-d(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    my $k = $P.avail('d',$Q);
    ( map { $_ > 1 ?? "d$_" !! "d" }, 1..$k ).reverse
}
multi sub avail-D(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    my $k = $P.avail('D',$Q);
    ( map { $_ > 1 ?? "D$_" !! "D" }, 1..$k ).reverse
}
multi sub avail-d(Pair $p) is export { avail-d($p.kv) }
multi sub avail-D(Pair $p) is export { avail-D($p.kv) }





=begin END
