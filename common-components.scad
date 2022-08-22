////////////////////////////////////////////////////////////////////////////////
// Common components
////////////////////////////////////////////////////////////////////////////////

delta = 0.01 ;

mt_sprocket_pitch = 159 / 50 ;
mt_sprocket_dia   = 1.4 ;
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

// Hex nut recess on centre of X-Y plane
//
// af = nut dimension AF (across flats, = spanner size)
//
module nut_recess(af, t)  {
    od = af * 2 / sqrt(3) ; // Diameter
    translate([0,0,-delta]) {
        cylinder(d=od, h=t+delta*2, $fn=6) ;
    // Pyramid at end to allow printing without support:
    translate([0,0,t])
        cylinder(d1=od, d2=0, h=t/2, $fn=6) ;
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
                    cylinder(d1=pd, d2=pd*0.1, h=pd*0.75, center=false, $fn=12) ;
    
}


// Test: sprocketed tape guide

ornp = sprocket_or_np_from_pitch(12, mt_sprocket_pitch) ;
or   = ornp[0] ;
np   = ornp[1] ;
pd   = mt_sprocket_dia ;
wt   = mt_overall_width + 2 ;
fr   = 1.5 ;
sw   = 2 ;
ht1  = (mt_overall_width - mt_sprocket_width)/2 ;
ht2  = ht1 + mt_sprocket_width ;

difference() {
    union() {
        spoked_wheel(4, 10, or+delta, fr, wt, 5, sw) ;
        sprocket_pins(or, ht1, np, pd) ;
        sprocket_pins(or, ht2, np, pd) ;
    }
    shaft_hole(4, wt) ;
}



module sprocket_wheel_3_spoked(hd, rd, od, np, t) {
    // 3-spoked sprocket wheel lying on X-Y plane, centered on origin.
    // No axle hole.
    //
    // hd  = hub diameter
    // rd  = inner rim diameter
    // od  = outer rim diameter
    // np  = number of sprockets around diameter
    // t   = thickness (also diameter of sprocket pins)
    //@@@@
}


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
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


