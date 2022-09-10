////////////////////////////////////////////////////////////////////////////////
// Common components
////////////////////////////////////////////////////////////////////////////////

delta = 0.01 ;
clearance = 0.1 ;

mt_sprocket_pitch = 159 / 50 ;
mt_sprocket_dia   = 1.5 ;
mt_sprocket_width = 104.3 ;
mt_overall_width  = 110 ;

module lozenge(l,bevel_l,w,h) {
    // Lozenge object along Z axis: one point on origin, other on X-axis
    //
    // l       = overall length (between points)
    // bevel_l = length of sloping shoulder
    // w       = width of lozenge
    // h       = height of lozenge
    //
    linear_extrude(height=h, center=false) {
        polygon(
            points=[
                [0,        0],  
                [bevel_l,  w/2],
                [l-bevel_l,w/2],
                [l,        0],
                [l-bevel_l,-w/2],
                [bevel_l,  -w/2],
                ]
            ) ;
    }
}

module oval(x, d, h) {
    // Oval shape aligned on the X axis, with one end centred on the origin
    //
    // x  = X position of second centre of curvature
    // d  = width of oval, also diameter of curved ends
    // h  = height (thickness) of oval
    //
    cylinder(d=d, h=h, $fn=16) ;
    translate([x,0,0])
        cylinder(d=d, h=h, $fn=16) ;
    translate([x/2,0,h/2])
        cube(size=[x, d, h], center=true) ;
}

module shaft_hole(d, l) {
    // Cutout for shaft hole diameter d and length l
    // Shaft axis on Z axis.
    //
    translate([0,0,-delta]) {
        cylinder(d=d, h=l+delta*2, $fn=16) ;
    };
}

module shaft_slot(x1, x2, y, d, h) {
    translate([x1,y,-delta])
        oval(x2-x1, d, h+2*delta) ;    
}

module torus(tr, rr) {
    // Torus centred on origin.
    //
    // tr       torus radius (centre of ring to centre of rim)
    // rr       rim radius
    //
    rotate_extrude($fn=64) {
        translate([tr,0,0])
            circle(r=rr, $fn=32) ;
    }
}
// torus(20, 3);

// Hex nut recess on centre of X-Y plane
//
// af = nut dimension AF (across flats, = spanner size)
//
module nut_recess(af, t)  {
    od = af * 2 / sqrt(3) ; // Diameter
    translate([0,0,-delta]) {
        cylinder(d=od, h=t+delta*2, $fn=6) ;
    // Cone above to allow printing without support:
    // Leaves flat shoulders at corners to support nut: 
    // assume that these are short enough for the printing to bridge.
    // Similarly, tip of pyramid is truncated.
    translate([0,0,t])
        cylinder(d1=af-0.25, d2=2, h=af*0.35, $fn=12) ;
    }
}

// Cutout for vertical screw hole with downward-facing countersink at top, 
// centred on origin.
//
// The centre of the countersink top face lies on the origin.
// The countersink and screw shaft hole lie on the -ve Z axis
// A recess hole lies along the +ve Z axis 
//
// od = overall diameter (for screw head)
// oh = overall height (screw + head + recess)
// sd = screw diameter
// sh = screw height (to top of countersink)
//
module countersinkZ(od, oh, sd, sh)
{
    // echo("countersinkZ od: ", od) ;
    // echo("countersinkZ oh: ", oh) ;
    // echo("countersinkZ sd: ", sd) ;
    // echo("countersinkZ sh: ", sh) ;
    union()
    {
        intersection()
        {
            translate([0,0,-sh]) cylinder(r=od/2, h=oh, $fn=12);
            translate([0,0,-od/2]) cylinder(r1=0, r2=oh+od/2, h=oh+od/2, $fn=12);
        }
    translate([0,0,-sh+delta]) cylinder(r=sd/2, h=sh+2*delta, $fn=12);
    }
}

// Countersink with screw directed along negative X-axis
module countersinkX(od, oh, sd, sh)
{
    rotate([0,90,0]) countersinkZ(od, oh, sd, sh);
}

// Countersink with screw directed along negative Y-axis
module countersinkY(od, oh, sd, sh)
{
    rotate([90,0,0]) countersinkZ(od, oh, sd, sh);
}


////////////////////////////////////////////////////////////////////////////////
// Basic wheel shapes
////////////////////////////////////////////////////////////////////////////////

module wheel(r,t) {
    // Wheel blank lying on X-Y plane, centred on the origin
    //
    // r  = radius
    // t  = thickness
    cylinder(r=r, h=t, center=false, $fn=48) ;
}
// wheel(40, 5) ;

module pulley(d,t) {
    // Pulley outside diameter d, thickness t, on X-Y plane and centred on Z axis
    cylinder(d1=d, d2=d-t, h=t/2+delta) ;
    translate([0,0,t/2])
        cylinder(d1=d-t, d2=d, h=t/2+delta) ;    
}


module pulley_round_belt(pd, pw, bd) {
    // Pulley with channel for round belt, lying on X-Y plane, centred at origin.
    //
    // pd = diameter of pulley
    // pw = width of pulley
    // bd = diameter of drive belt
    //
    difference() {
        cylinder(d=pd, h=pw, center=false, $fn=48) ;
        translate([0,0,pw/2])
            torus(pd/2, bd/2) ;
    }
}
// pulley_round_belt(30, 5, 3) ;


module ring(r1, r2, t) {
    // Circular ring lying on X-Y plane, centred on the origin
    //
    // r1 = inner radius
    // r2 = outer radius
    // t  = thickness
    difference() {
        cylinder(r=r2, h=t, center=false, $fn=48) ;
        translate([0,0,-delta])
            cylinder(r=r1, h=t+2*delta, center=false, $fn=48) ;
    }
}

// ring(20, 40, 5) ;


module segment_cutout(a1, a2, sr, t) {
    // Cutout (use with `difference()`) to remove all but a segment of a shape.
    //
    // NOTE: only works for angles up to 180 degrees.
    //
    // a1 = first radial edge angle for the resulting segment
    // a2 = second radial edge angle for the resulting segment (a2>a1)
    // sr = maximum segment radius
    // t  = thickness of segment
    //
    rotate([0,0,a1])
        translate([-(sr+delta), -(sr+delta), -delta])
            cube(size=[2*(sr+delta), sr+delta, t+2*delta], center=false) ;
    rotate([0,0,a2])
        translate([-(sr+delta), 0, -delta])
            cube(size=[2*(sr+delta), sr+delta, t+2*delta], center=false) ;
}


module segment(a, sr, t) {
    // Circle segment in X-Y plane with centre on origin, and one radial edge on
    // the positive X-axis.  The second radial edge is `a` degrees anticlockwise 
    // from the positive X-axis.
    //
    // NOTE: only works for angles up to 180 degrees.
    //
    // a  = angle of segment
    // sr = radius of segment
    // t  = thickness of segment
    //
    difference() {
        cylinder(r=sr, h=t, center=false, $fn=48) ;
        segment_cutout(0, a, sr, t) ;
    }
}
// segment(60, 20, 5) ;


module ring_segment(a1, a2, r1, r2, t) {
    // Circular ring segment lying on X-Y plane, centred on the origin, with radial 
    // edges at `a1` and `a2` degrees anticlockwise from the positive X-axis.
    //
    // NOTE: only works for angles up to 180 degrees.
    //
    // a1 = first radial edge angle
    // a2 = second radial edge angle (a2>a1)
    // r1 = inner radius
    // r2 = outer radius
    // t  = thickness
    difference() {
        ring(r1, r2, t) ;
        segment_cutout(a1, a2, r2, t) ;
    }
}
// ring_segment(60, 120, 30, 40, 5) ;


module segment_rounded(a, sr, t, fr) {
    // Circle segment (see `segment`) but with corners rounded with 
    // fillet radius fr.
    //
    // NOTE: only works for angles up to 180 degrees.
    //
    // NOTE: calculation for p2 and p3 are approximate, based on an assumption
    // that fr is small compared with sr.  The fillet radius centre is taken 
    // to be on a tangent to the spoke circle, which is not strictly true.
    //
    // a  = angle of segment
    // sr = radius of segment
    // t  = thickness of segment
    // fr = fillet radius
    //
    p1 = [fr / tan(a/2), fr] ;
    p2 = [sr - fr,       fr] ;
    p3 = [p1.x + (p2.x-p1.x)*cos(a), p1.y + (p2.x-p1.x)*sin(a)] ;
    union() {
        // inner wedge (extends to full radius)
        translate([p1.x, p1.y, 0])
            segment(a, sr-p1.x, t) ;
        // outer wedge, removing apex
        difference() {
            segment(a, sr - fr, t) ;
            cylinder(r=p1.x, h=2*(t+delta), center=true, $fn=32) ;
        }
        // p1 fillet
        translate([p1.x, p1.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
        // p2 fillet
        translate([p2.x, p2.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
        // p3 fillet
        translate([p3.x, p3.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
    }
}
// for (a=[0,120,240]) rotate([0,0,a]) segment_rounded(110, 20, 5, 2) ;


module hub_segment(a, hr, sr, t) {
    // Circle segment in X-Y plane with hub removed.
    //
    // NOTE: only works for angles up to 180 degrees.
    //
    // a  = angle of segment
    // hr = radius of hub
    // sr = radius of segment
    // t  = thickness of segment
    //
    difference() {
        segment(a, sr, t) ;
        translate([0, 0, -delta])
            cylinder(r=hr, h=t+2*delta, center=false, $fn=24) ;
    }
}
// hub_segment(60, 8, 20, 5) ;


module hub_segment_rounded(a, hr, sr, t, fr) {
    // Circle segment in X-Y plane with hub removed and rounded corners
    //
    // NOTE: only works for angles up to 180 degrees.
    //
    // a  = angle of segment
    // hr = radius of hub
    // sr = radius of segment
    // t  = thickness of segment
    // fr = fillet radius for rounded corners
    //
    bhf1 = asin(fr/(hr+fr)) ;   // Angle to first hub fillet radius centre
    bhf2 = a - bhf1 ;           // Angle to second hub fillet radius centre
    bsf1 = asin(fr/(sr-fr)) ;   // Angle to first segment end fillet radius centre
    bsf2 = a - bsf1 ;           // Angle to second segment end fillet radius centre
    p1 = [fr / tan(a/2), fr] ;
    p2 = [(sr-fr)*cos(bsf1), fr] ;
    p3 = [(sr-fr)*cos(bsf2), (sr-fr)*sin(bsf2)] ;
    p4 = [(hr+fr)*cos(bhf1), fr] ;
    p5 = [(hr+fr)*cos(bhf2), (hr+fr)*sin(bhf2)] ;

    union() {
        hub_segment(a, hr+fr, sr-fr, t) ;
        rotate([0,0,bsf1])
            hub_segment(a-2*bsf1, hr+fr, sr, t) ;
        rotate([0,0,bhf1])
            hub_segment(a-2*bhf1, hr, sr, t) ;
        // p2 fillet
        translate([p2.x, p2.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
        // p3 fillet
        translate([p3.x, p3.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
        // p4 fillet
        translate([p4.x, p4.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
        // p5 fillet
        translate([p5.x, p5.y, 0])
            cylinder(r=fr, h=t, center=false, $fn=16) ;
    }
}
// hub_segment_rounded(110, 8, 20, 5, 2) ;
// for (a=[0,120,240]) rotate([0,0,a]) hub_segment_rounded(100, 8, 20, 5, 2) ;


////////////////////////////////////////////////////////////////////////////////
// Spoked wheel and component shapes
////////////////////////////////////////////////////////////////////////////////

module spoked_wheel_cutout(hr, sr, fr, wt, ns, sw) {
    // Spoked wheel in X-Y plane, centred on the origin.
    //
    // NOTE: there is no axle hole: calling code is expected to include this
    //
    // hr  = Hub radius (actual hub is larger due to fillets)
    // sr  = spoke radius (centre to inside of rim)
    // fr  = fillet radius of spoke cut-outs
    // wt  = thickness of wheel
    // ns  = number of spokes
    // sw  = width of spokes
    //
    as   = 360/ns ;                     // Angle between spokes

    ahs1 = asin((sw/2)/hr) ;            // Angle from spoke centre line to end of spoke meeting with hub
    ahf1 = asin((sw/2+fr)/(hr+fr)) ;    // Angle from spoke centre line to centre of hub fillet
    ahs2 = as - ahs1 ;                  // Angle from spoke centre line to end of next spoke at hub
    ahf2 = as - ahf1 ;                  // Angle from spoke centre line to centre of next hub fillet

    asr1 = asin((sw/2)/sr)  ;           // Angle from spoke centre line to end of spoke meeting with rim
    asf1 = asin((sw/2+fr)/(sr-fr)) ;    // Angle from spoke centre line to centre of rim fillet
    asr2 = as - asr1 ;                  // Angle from spoke centre line to end of next spoke at rim
    asf2 = as - asf1 ;                  // Angle from spoke centre line to centre of next rim fillet

    fh1c = [ cos(ahf1)*(hr+fr), sin(ahf1)*(hr+fr) ] ;   // Hub fillet 1 centre
    fh2c = [ cos(ahf2)*(hr+fr), sin(ahf2)*(hr+fr) ] ;   // Hub fillet 2 centre
    fs1c = [ cos(asf1)*(sr-fr), sin(asf1)*(sr-fr) ] ;   // Rim fillet 1 centre
    fs2c = [ cos(asf2)*(sr-fr), sin(asf2)*(sr-fr) ] ;   // Rim fillet 2 centre

    difference() {
        union() {
            // main part 
            // (the `-fr*sin(ahf1)` is an approximate but close adjustment to meet the 
            // point where the fillet isn tangential to the spoke)
            ring_segment(0, as, hr+fr-fr*sin(ahf1), sr-fr-fr*sin(asf1), wt) ;
            // inner ring
            ring_segment(ahf1, ahf2, hr, hr+2*fr, wt) ;
            // outer ring
            ring_segment(asf1, asf2, sr-2*fr, sr, wt) ;
            // fillets
            for (fc=[fh1c, fh2c, fs1c, fs2c])
                translate([fc.x, fc.y, 0])
                    cylinder(r=fr, h=wt, center=false, $fn=32) ;
        }
        // trim off "wings"
        translate([-sr,sw/2-sr,-delta])
            cube(size=[2*sr, sr, wt+2*delta], center=false) ;
        rotate([0,0,as])
            translate([-sr,-sw/2,-delta])
                cube(size=[2*sr, sr, wt+2*delta], center=false) ;
    }
}  
// spoked_wheel_cutout(15, 30, 2, 5, 6, 4) ;


module spoked_wheel(hr, sr, or, fr, wt, ns, sw) {
    // Spoked wheel in X-Y plane, centred on the origin.
    //
    // NOTE: there is no axle hole: calling code is expected to include this
    //
    // hr  = Hub radius (actual hub is larger due to fillets)
    // sr  = spoke radius (centre to inside of rim)
    // or  = outside radius of wheel
    // fr  = fillet radius of spoke cut-outs
    // wt  = thickness of wheel
    // ns  = number of spokes
    // sw  = width of spokes
    //
    as   = 360/ns ;                     // Angle between spokes
    difference() {
        wheel(or, wt) ;
        for (i=[0:ns-1])
            rotate([0,0,i*as])
                translate([0,0,-delta])
                    spoked_wheel_cutout(hr, sr, fr, wt+2*delta, ns, sw) ;
    }
}
//spoked_wheel(8, 16, 20, 2, 5, 5, 4) ;


////////////////////////////////////////////////////////////////////////////////
// Sprocket pins
////////////////////////////////////////////////////////////////////////////////

function sprocket_or_np_from_pitch(or_max, p) =
    // Calculates outside diameter and number of sprocket pins
    //
    // Always returns an even number of pins, adjusting the 
    //
    // or_max = maximum outside radius - the actual value is slightly smaller than this
    // p      = sprocket hole pitch
    //
    let (
        sc_max = PI * or_max,           // Minimum outside semi-circumference
        np     = floor(sc_max / p),     // Number of sprocket pins on semi-corcumference
        sc     = np * p,                // Actual semi-circumference for number of pins at given pitch
        or     = sc / PI                // Actual outside radius for number of pins at given pitch
    ) [or, np*2] ;

module sprocket_pins(or, ht, np, pd) {
    // Ring of sprocket teeth (for adding to wheel)
    // Positioned for wheel on X-Y plane with axis through origin
    //
    // NOTE: `or` and `np` should be chosen for even spacing of pins around the wheel:
    //       see `sprocket_or_np_from_pitch` above for adjustment calculation.
    //
    // or  = outside radius of wheel (where sprocket pins are positioned)
    // ht  = height of pins above X-Y plane
    // np  = number of sprocket pins around diameter
    // pd  = diameter of each sprocket pin
    //
    // Array pins around wheel
    ap = 360 / np ;     // Angle at centre between pins
    for (i=[0:np-1])
        rotate([0,0,i*ap])
            // Translate pin to sit on rim of wheel
            translate([or, 0, ht])
                // Rotate pin to X-axis
                rotate([0,90,0])
                    // Conical pin
                    cylinder(d1=pd, d2=pd*0.1, h=pd*0.7, center=false, $fn=8) ;
    
}


////////////////////////////////////////////////////////////////////////////////
// Sprocketed tape guide
////////////////////////////////////////////////////////////////////////////////

// pd   = mt_sprocket_dia ;
// wt   = mt_overall_width + 2 ;
// fr   = 1.5 ;
// sw   = 2 ;
// ht1  = (wt - mt_sprocket_width)/2 ;
// ht2  = ht1 + mt_sprocket_width ;

module shaft_nut_cutout(af1, t1, af2, t2, r) {
    // Cutouts for captive nut on shaft axis
    //
    // af1 = accoss-faces size of nut on shaft
    // t1  = thickness of nut on shaft
    // af2 = width of access hole in rim
    // t2  = thickness of access hole in rim
    // r   = radius of rim
    //
    // Recess in hub to hold the nut
    nut_recess(af1, t1) ;
    translate([-af1*0.4,0,0]) nut_recess(af1, t1) ;  // Extend along -x for nut entry
    // Opening in rim to allow access
    translate([-r,0,-(t2-t1)/2]) nut_recess(af2, t2) ;
    // translate([-r,0,t1/2]) cube(size=[r,af2,t2], center=true) ;
    // cube(size=[r,af2,t2], center=true) ;
}

module shaft_middle_cutout(r,l) {
    // Cylinder with pointed ends lying on the Z-axis, centred around z=0
    //
    // Used to cut away middle part of hub to reduce print time and plastic used
    //
    // r  = radius of cutaway cylinder
    // l  = length of cutaway cylinder, not including pointed ends
    //
    cylinder(r=r, h=l, center=true, $fn=12) ;
    translate([0,0,((r+l)/2-delta)])
        cylinder(r1=r, r2=0, h=r, center=true, $fn=12) ;
    translate([0,0,-((r+l)/2-delta)])
        cylinder(r1=0, r2=r, h=r, center=true, $fn=12) ;
}

module sprocket_guide_3_spoked(sd, hr, rr, or_max, fr, sw, pd, gsw, gow) {
    // 3-spoked sprocket tape guide, end on X-Y plane, centred on origin.
    //
    // sd     = shaft diameter
    // hr     = hub radius
    // rr     = inner rim radius
    // or_max = maximum outer rim radius (reduced for even number of sprocket pins)
    // fr     = fillet radius of spoke cutout
    // sw     = spoke width
    // pd     = sprocket pin diameter
    // gsw    = width between guide sprocket holes
    // gow    = overall width of guide
    ornp = sprocket_or_np_from_pitch(or_max, mt_sprocket_pitch) ;
    or   = ornp[0] ;
    np   = ornp[1] ;
    ht1  = (gow - gsw)/2 ;
    ht2  = ht1 + gsw ;

    difference() {
        union() {
            spoked_wheel(hr, rr, or+delta, fr, gow, 3, sw) ;
            sprocket_pins(or, ht1, np, pd) ;
            sprocket_pins(or, ht2, np, pd) ;
        }
        shaft_hole(sd, gow) ;
        translate([0,0,gow/2])
            # shaft_middle_cutout(rr-fr, gow*0.45) ;

        // # translate([0,0,10]) {
        //     // M4 nut:  7 AF x 3.1 thick
        //     shaft_nut_cutout(7, 3.1, 8, 4, or) ;
        //     translate([-4,0,0])
        //         shaft_nut_cutout(7, 3.1, 8, 4, or) ;
        //     //nut_recess(7, 3) ;
        //     //translate([-12-7,-5,-1]) cube(size=[12,7+3, 3+2], center=false) ;
        // }
        // # translate([0,0,wt-10]) {
        //     shaft_nut_cutout(7, 3.1, 8, 4, or) ;
        //     translate([-4,0,0])
        //         shaft_nut_cutout(7, 3.1, 8, 4, or) ;
        // }
    }
} ;


sd     = 4 ;
hr     = 4 ;
rr     = 9.5 ;
or_max = 11 ;
fr     = 1.5 ;
sw     = 2 ;
gow    = mt_overall_width + 2 ;

ornp   = sprocket_or_np_from_pitch(or_max, mt_sprocket_pitch) ;
or     = ornp[0] ;
np     = ornp[1] ;

// Generate part 
//
// difference() {
//     sprocket_guide_3_spoked(sd, hr,  rr, or_max,  fr, sw, 
//                          mt_sprocket_dia,
//                          mt_sprocket_width, 
//                          gow) ;
// 
//     # translate([0,0,12]) {
//      // M4 nut:  7 AF x 3.1 thick
//      shaft_nut_cutout(7, 3.1, 8, 4, or) ;
//      //translate([-4,0,0])
//      //    shaft_nut_cutout(7, 3.1, 8, 4, or) ;
//     }
//     # translate([0,0,gow-12]) {
//      shaft_nut_cutout(7, 3.1, 8, 4, or) ;
//      //translate([-4,0,0])
//      //    shaft_nut_cutout(7, 3.1, 8, 4, or) ;
//     }
// 
// 
// 
// }



////////////////////////////////////////////////////////////////////////////////
// Triangular structure reinforcing webs
////////////////////////////////////////////////////////////////////////////////

module web_base(w_x, w_y, w_t) {
    // Web with corner on origin, extending along +ve X and Y axes
    // Slight negative x- and y- overlap forces merge with existing shape
    linear_extrude(height=w_t, center=true) {
        polygon(
            points=[
                [-delta, -delta], [-delta, w_y],
                [0, w_y], [w_x, 0],
                [w_x, 0], [w_x, -delta],
                ],
            paths=[[0,1,2,3,4,5,0]]
            ) ;
    }
}

module web_oriented(w_x, w_y, w_t) {
    // Web with corner on origin, extending along +ve or -ve X and Y axes
    if (w_x >= 0)
        {
        if (w_y >= 0)
            {
                web_base(w_x, w_y, w_t) ;
            }
        else // w_y < 0
            {
                // flip through x-z plane: reverse y-axis
                mirror(v=[0,1,0]) web_base(w_x, -w_y, w_t) ;
            }
        }
    else // w_x < 0
        {
        if (w_y >= 0)
            {
                // flip through y-z plane: reverse x-axis
                mirror(v=[1,0,0]) web_base(-w_x, w_y, w_t) ;
            }
        else // w_y < 0
            {
                // flip through x-z and y-z planes: reverse x- and y- axes
                mirror(v=[1,1,0]) web_base(-w_x, -w_y, w_t) ;
            }
        }
 }

module web_xz(x, y, z, w_x, w_z, w_t) {
    // Web in X-Z plane, outer corner at x, y, z
    if (y >= 0) {
        // Rotate around X maps Y to Z, Z to -Y (???)
        translate([x, y - w_t/2, z]) rotate([90,0,0]) web_oriented(w_x, w_z, w_t) ;
    }
    else { // y < 0
        translate([x, y + w_t/2, z]) rotate([90,0,0]) web_oriented(w_x, w_z, w_t) ;
    }
}



////////////////////////////////////////////////////////////////////////////////
// Dovetail interlocking shapes  
////////////////////////////////////////////////////////////////////////////////
//
// (NOTE: need to be printed flat on baseplate if end is wider than shoulder)

module dovetail_key(l, ws, we, t) {
    // Shape for dovetail key, shoulder centre on origin, key extending along -X axis
    // lying on X-Y plane.
    //
    // l  = length from shoulder to end of dovetail
    // ws = width of key at shoulder
    // we = width of key at end
    // t  = thickness of key
    //
    linear_extrude(height=t, center=false) {
        polygon(
            points=[
                [0, ws/2],  [0, -ws/2],
                [-l, we/2], [-l, -we/2]
                ],
            paths=[[0,2,3,1,0]]
            ) ;
    }
}

module dovetail_socket_cutout(l, ws, we, t) {
    // Shape to cutout dovetail socket in piece lying on X-Y plane,
    // with key shoulder centre on origin and piece extending in -X direction
    //
    // (Cutout piece extends below and above Z axis)
    //
    // l  = length from shoulder to end of dovetail
    // ws = width of key at shoulder
    // we = width of key at end
    // t  = thickness of key piece
    //
    translate([+delta,0,-delta]) {
        dovetail_key(l+delta*2, ws, we, t+delta*2) ;
    }
}

module dovetail_tongue_cutout(l, ws, we, wp, t) {
    // Shape to cutout dovetail tongue in end of piece lying on X-Y plane,
    // with key end centre on origin and extending in +X direction
    //
    // (Cutout piece extends below and above Z axis)
    //
    // l  = length from shoulder to end of dovetail
    // ws = width of key at shoulder
    // we = width of key at end
    // wp = width of piece behind tongue
    // t  = thickness of piece with tongue
    //
    difference() {
        translate([-l/2,0,t/2]) {
            cube(size=[l+delta, wp+delta, t+delta], center=true) ;
        } ;
        dovetail_socket_cutout(l+delta, ws, we, t+delta) ;
    }
}


////////////////////////////////////////////////////////////////////////////////
// Helical extrusion of solid object
////////////////////////////////////////////////////////////////////////////////


module helix_extrude(h, r, a, ns) {
    // A transformation that takes a solid object centred on the origin on the 
    // X-Y plane, and uses this to create a helical extrusion along the Z axis 
    // with height h, radius r and angle a.
    //
    // The X-axis of the object is aligned along the helix path, and the Y axis
    // is aligned to Z (the axis of extrusion), such that the top of the shape is 
    // on the outside of the helix.
    //
    // h  = height of extrusion path (the resulting object will be higher by 
    //      approximately the X-dimension of the nobject)
    // r  = radius of the helical path of extrusion
    // a  = angle swept by the helical extrusion path (degrees)
    // ns = number of segments used to make up the extruded object.
    //
    // NOTE: ns must to sufficiently large to allow the desired overlap between
    //       successive objectson  the extrusion path.
    //
    sa = a / ns ;           // swept angle per segment (degrees)
    sr = sa*PI/180 ;        // swept angle per segment (radians)
    sc = r*sr ;             // swept circumference per segment
    sh = h / ns ;           // height increase per segment
    st = atan2(sh,sc) ;     // segment tilt to align with helical path (degrees)
    for(i=[1:ns]) {
        translate([0,0,(i-0.5)*sh])     // Lift
            rotate([0,0,(i-0.5)*sa])        // Rotate
                // Swept object
                translate([r, 0, 0])            // Move out along X-axis
                    rotate([st,0,0])                // Tilt to path of helix
                        rotate([0,90,0])                // align shape with direction of extrusion
                            rotate([0,0,90])                // align shape with direction of extrusion
                                children() ;
    }
}

module tapered_cube(l, w1, w2, h) {
    // Tapered cube (or symmeyric prism with trapezoidal cross-section), centred
    // at the origin on the X-Y plane, and extending along the X-axis.
    //
    // l   = length of prism
    // w1  = width of prism at base
    // w2  = width of prisim at top
    // h   = height of prism
    //
    rotate([0,-90,0])
        linear_extrude(height=l, center=true) {
            polygon(
                points=[
                    [0, w1/2],  [0, -w1/2],
                    [h, w2/2],  [h, -w2/2]
                    ],
                paths=[[0,1,3,2,0]]
                ) ;
        }
}
// Test tapered_cube
// tapered_cube(20,12,10,4) ;


module tapered_oval(l, r1, r2, h) {
    // Tapered oval lug for creating channel with helix_extrude
    // centred at origin on X-Y plane, extending along X-axis
    //
    // l  = distance between rounded-end centres
    // r1 = radius of rounded end at base
    // r2 = radius of rounded end at top
    // h  = height of lug
    //
    translate([-l/2,0,0]) cylinder(r1=r1, r2=r2, h=h, $fn=16) ;
    translate([+l/2,0,0]) cylinder(r1=r1, r2=r2, h=h, $fn=16) ;
    tapered_cube(l, r1*2, r2*2, h) ;
}
// Test tapered_oval
// tapered_oval(20,6,5,4) ;


// Test helix_extrude
// helix_extrude(h=20, r=20, a=720, ns=36) cylinder(r1=4, r2=3, h=2) ;
// helix_extrude(h=20, r=20, a=720, ns=36) tapered_oval(l=6, r1=4, r2=3, h=2) ;

// Test helical path for lug
// intersection() {
//     helix_extrude(h=20, r=20, a=720, ns=36) tapered_cube(l=8, w1=8, w2=5, h=2) ;
//     translate([0,0,-4-1])
//         cylinder(r=20+2, h=20+(4+1)*2, $fn=72 ) ;
//     
// }


////////////////////////////////////////////////////////////////////////////////
// Bayonette (push/twist) fitting
////////////////////////////////////////////////////////////////////////////////

function deg_to_rad(a) =
    // Convert angle in degrees to radians
    a/180*PI ;

function segment_length(r, a) =
    // Calculates circumferencial extent of segment
    //
    // r  = radius of segment
    // a  = angle swept by segment (in degrees)
    //
    r*deg_to_rad(a) ; 

function segment_corner_adjustment(rs, a) =
    // Calculates adjustment to enlarge segment towards centere to ensure full
    // overlap with a cylinder on which it is placed
    let (
        ar  = deg_to_rad(a),
        dsc = rs * ar * ar              // Approximating r * sin a * tan a (for small a)
        // _ = echo("segment_chorner_adjustment: rs, ar, dsc", rs, ar, dsc)
    ) dsc ;

function radius_lug_top(dl, hl) = 
    // Get radius for top of lug given radius at base and height of lug
    //
    // Looking here for the largest value that can print without drooping.
    // (hl*1 gives 45-degree overhang)
    dl/2 - hl*0.85 ;

module bayonette_channel_cutout(lm, rm, rlb, rlt, hl, at) {
    // Bayotte fitting channel cutout
    //
    // Centred on the origin and aligned along the Z-axis.  The start of the
    // "push" channel lying on the X-Y plane.
    //
    // lm  = length of mating section of cylinders
    // rm  = radius of mating section of cylinders
    // rlb = radius of base of lug
    // rlt = radius of top of lug
    // hl  = height of lug above mating service (=> depth of channel)
    // at  = angle of twist
    //
    dp  = lm * 0.6 ;            // Distance for "push" channel
    dt  = lm / 32 ;             // Distance for "twist" channel
    dc  = 0.2 ;                 // Distance for final "click" (half)
    ns  = 12 ;                  // Number of segments in twist
    rl  = rm + hl ;             // Radius to top of lug
    ls  = segment_length(rl, at/ns) ;
    // Values used to extend inner face to fully overlap inner cylinder
    dsc = segment_corner_adjustment(rm, at/ns) ;
    rsc = rm - dsc ;
    intersection() {
        cylinder(r=rm+hl, h=lm, $fn=72 ) ;
        union() {
            translate([rsc,0,dp/2-dt+dc])
                rotate([0,90,0])
                    tapered_oval(l=dp, r1=rlb, r2=rlt, h=hl+dsc) ;
            translate([0,0,dp-dt+dc])
                helix_extrude(h=dt, r=rsc, a=at, ns=ns)
                    tapered_cube(l=ls, w1=rlb*2, w2=rlt*2, h=hl+dsc) ;
            // Round end of channel: enlarged for final "click"
            rotate([0,0,at])
                translate([rsc, 0, dp])
                    rotate([0,90,0])        // align shape with direction of extrusion
                        rotate([0,0,90])        // align shape with direction of extrusion
                            cylinder(r1=rlb+dc, r2=rlt+dc, h=hl+dsc, $fn=16) ;
        }
    }
}

// Test bayonette_channel_cutout
// bayonette_channel_cutout(30, 15, 5, 4, 2, 90) ;


module bayonette_socket(ls, lm, ri, rm, ro, hl, dl, nl) {
    // Bayonette (push/twist) socket in cylindrical tube
    //
    // ls  = overall length of socket tube
    // lm  = length of bayonette mating faces
    // ri  = radius of inside of tube
    // rm  = radius of mating faces
    // ro  = radius of outside of tube
    // hl  = height of locking lug above mating face
    // dl  = diameter of locking lug
    // nl  = number of locking lugs (spaced equally around circumference of mating face)
    //
    al  = 360/nl ;                  // Angle between lugs
    at  = al-30 ;                   // angle of twist
    rlb = dl/2 ;                    // Radius of lug at base
    rlt = radius_lug_top(dl, hl) ;  // Radius of lug at top
    // Values used to extend inner face to fully overlap inner cylinder
    dsc = segment_corner_adjustment(rm, ls) ;
    rsc = rm - dsc ;
    difference() {
        cylinder(r=ro, h=ls, $fn=32) ;
        translate([0,0,-delta]) {
            cylinder(r=ri, h=ls+2*delta, $fn=32) ;
            cylinder(r=rm, h=lm, $fn=32) ;
            for (i=[0:nl-1]) {
                rotate([0,0,al*i])
                    bayonette_channel_cutout(lm, rm, rlb, rlt, hl, at) ;
                }
        }
    }
}

// Test bayonette_socket
// ls = 15 ;
// ro = 25 ;
// translate([0,ro*2+20,ls])
//     rotate([0,180,0])
//         bayonette_socket(ls=ls, lm=12, ri=20, rm=22, ro=ro, hl=2, dl=5, nl=3) ;


module bayonette_plug(lp, lm, ri, rm, ro, hl, dl, nl) {
    // Bayonette (push/twist) socket in cylindrical tube
    //
    // lm  = length of bayonette mating faces
    // lp  = length of bayonette plug tube (not including mating face)
    // ri  = radius of inside of tube
    // rm  = radius of mating faces
    // ro  = radius of outside of tube
    // hl  = height of locking lug above mating face
    // dl  = diameter of locking lug
    // nl  = number of locking lugs (spaced equally around circumference of mating face)
    //
    dp  = lm * 0.6 ;                // Distance for "push" channel
    dt  = lm / 32 ;                 // Distance for "twist" channel
    dc  = 0.75 ;                    // Lug offset for snug fit when twisted shut
    al  = 360/nl ;                  // Angle between lugs
    rlb = dl/2 ;                    // Radius of lug at base
    rlt = radius_lug_top(dl, hl) ;  // Radius of lug at top
    // Basic shell
    difference() {
        union() {
            cylinder(r=ro, h=lp, $fn=32) ;
            cylinder(r=rm, h=lp+lm, $fn=32) ;
        }
        translate([0,0,-delta]) {
            cylinder(r=ri, h=lp+lm+2*delta, $fn=32) ;
        }
    }
    // Values used to extend inner face to fully overlap inner cylinder
    dsc = segment_corner_adjustment(rm, atan2(dl,rm)) ;
    rsc = rm - dsc ;
    // Locking lugs
    translate([0,0,lp+dp+dt-dc]) {
        for (i=[0:nl-1]) {
            rotate([0,0,al*i])
                translate([rm-dsc,0,0])
                    rotate([0,90,0])
                        cylinder(r1=rlb, r2=rlt, h=hl+dsc, $fn=12) ;
        }
    }

    
}

// Test bayonette_plug
// bayonette_plug(lp=5, lm=12, ri=20, rm=22, ro=25, hl=2, dl=5, nl=3) ;
// bayonette_plug(lp=5, lm=10, ri=20, rm=22-clearance, ro=25, hl=2, dl=5, nl=3) ;

// Add twist handle (along X axis):
// difference() {
//     translate([-25,0,0]) oval(50, 8, 5) ;
//     translate([0,0,-delta]) cylinder(d=40, h=5+delta*2, $fn=32) ;
// }


module bayonette(ls, lp, lm, ri, rm, ro, hl, dl, nl) {
    // Bayonette (push/twist) socket in cylindrical tube
    //
    // ls  = overall length of socket tube
    // lm  = length of bayonette mating faces
    // lp  = length of bayonette plug tube (not including mating face)
    // ri  = radius of inside of tube
    // rm  = radius of mating faces
    // ro  = radius of outside of tube
    // hl  = height of locking lug above mating face
    // dl  = diameter of locking lug
    // nl  = number of locking lugs (spaced equally around circumference of mating face)
    //
    translate([0,ro+10,0]) {
        translate([0,0,ls])
            rotate([0,180,0])
                bayonette_socket(ls=ls, lm=lm, ri=ri, rm=rm, ro=ro, hl=hl, dl=dl, nl=nl) ;
        // Add twist handle (along X axis):
        difference() {
            translate([-25,0,0]) oval(50, 8, 5) ;
            translate([0,0,-delta]) cylinder(d=40, h=5+delta*2, $fn=32) ;
        }
    }
    translate([0,-ro-10,0]) {
        bayonette_plug(lp=lp, lm=lm, ri=ri, rm=rm-clearance, ro=ro, hl=hl, dl=dl, nl=nl) ;
        // Add twist handle (along Y axis):
        difference() {
            rotate([0,0,90]) translate([-25,0,0]) oval(50, 8, 5) ;
            translate([0,0,-delta]) cylinder(d=40, h=5+delta*2, $fn=32) ;
        }


    }
}

// Test bayonette assembly
bayonette(ls=15, lp=5, lm=10, ri=20, rm=22, ro=25, hl=2, dl=6, nl=3) ;



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


