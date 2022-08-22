include <reader-defs.scad> ;

////////////////////////////////////////////////////////////////////////////////
// Generic shapes
////////////////////////////////////////////////////////////////////////////////

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


// Triangular structure reinforcing webs

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

// Dovetail interlocking shapes  
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

// Spoked wheel and component shapes

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
        //translate([-(sr+delta), -(sr+delta), -delta])
        //    cube(size=[2*(sr+delta), sr+delta, t+2*delta], center=false) ;
        //rotate([0,0,a])
        //    translate([-(sr+delta), 0, -delta])
        //        cube(size=[2*(sr+delta), sr+delta, t+2*delta], center=false) ;
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
    // NOTE: calculations for p3 and p5 are approximate, based on an assumption
    // that fr is small compared with hr and sr.  The fillet radius centre is
    // taken to be on a tangent to the hub/spoke circle, which is not strictly true.
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

//@@@@ needs rework
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

// Normalized tree is growing past 200000 elements. Aborting normalization



// Wheel with sprocket pins ... @@@@

function sprocket_or_np_from_pitch(or_max, p) =
    // Calculates outside diameter and number of sprocket pins
    //
    // Always returns an evenm number of pins, adjusting the 
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

module sprocket_pins(or, wt, np, pd) {
    // Ring of sprocket teeth (for adding to wheel)
    // Positioned for wheel on X-Y plane with axis through origin
    //
    // NOTE: `or` and `np` should be chosen for even spacing of pins around the wheel:
    //       see `sprocket_or_np_from_pitch` above for adjustment calculation.
    //
    // or  = outside radius of wheel (where sprocket pins are positioned)
    // wt  = thickness of wheel (pins are centred on thickness)
    // np  = number of sprocket pins around diameter
    // pd  = diameter of each sprocket pin
    //
    // Array pins around wheel
    ap = 360 / np ;     // Angle at centre between pins
    for (i=[0:np-1])
        rotate([0,0,i*ap])
            // Translate pin to sit on rim of wheel
            translate([or, 0, wt/2])
                // Rotate pin to X-axis
                rotate([0,90,0])
                    // Conical pin
                    cylinder(d1=pd, d2=pd*0, h=pd, center=false, $fn=12) ;
    
}


mt_sprocket_pitch = 159 / 50 ;
mt_sprocket_dia   = 1.5 ;

ornp = sprocket_or_np_from_pitch(20, mt_sprocket_pitch) ;
or = ornp[0] ;
np = ornp[1] ;
pd = mt_sprocket_dia ;

sprocket_pins(or, 5, np, pd) ;

spoked_wheel(8, 16, or+delta, 2, 5, 5, 4) ;




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
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////















// Spool and winder

module spool_edge(shaft_d, core_d, bevel_d, outer_d, side_t, side_rim_t) {
    // Edge in X-Y plane with centre of outer face at (0,0,0)
    union() {
        cylinder(d1=outer_d, d2=outer_d, h=side_rim_t) ;
        translate([0,0,side_rim_t]) {
            cylinder(d1=outer_d, d2=bevel_d, h=side_t-side_rim_t) ;
        } ;
    } ;
}

module pulley(d,t) {
    cylinder(d1=d, d2=d-t, h=t/2+delta) ;
    translate([0,0,t/2])
        cylinder(d1=d-t, d2=d, h=t/2+delta) ;    
}


module spool_core(d_core, w_core) {
    cylinder(d=d_core, h=w_core) ;
}

module half_spool(shaft_d, core_d, bevel_d, outer_d, side_t, side_rim_t, w_spool_end) {
    difference() {
        union() {
            spool_edge(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t
            );
            spool_core(d_core=core_d, w_core=w_spool_end+side_t);
        } ;
        union() {
            shaft_hole(d=shaft_d, l=w_spool_end+side_t) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
        } ;
    }
} ;

module spool_spacer(shaft_d, core_d, w_spacer, w_spool_end) {
    difference() {
        union() {
            spool_core(d_core=core_d, w_core=w_spacer);
        } ;
        union() {
            shaft_hole(d=shaft_d, l=w_spacer) ;
        } ;
    }
} ;

// The spool clip is also intended to slide off the winder core
// It may need the inner diameter increasing slightly
module spool_clip(core_d, outer_d, len) {
    difference() {
        cylinder(d=outer_d, h=len) ;
        translate([0,0,-delta])
            cylinder(d=core_d, h=len+2*delta) ;   // Core
        translate([outer_d*0.75,0,-delta])
            cylinder(d=outer_d, h=len+2*delta) ;  // Clip cutaway
        // translate([0,0,0])
        //     rotate([0,-90,0])
        //         shaft_slot(len*0.25, len*0.75, 0, core_d*0.75, outer_d+delta*2) ;
        translate([0,0,len/2])
            rotate([0,90,0])
                translate([-len*0.4,0,-outer_d*0.5-delta])
                    lozenge(len*0.8, core_d*0.4, core_d*0.8, outer_d+2*delta) ;
        translate([0,0,len/2])
            rotate([90,0,0])        // Prisms align Y
                rotate([0,0,90]) {  // Points align Y
                    translate([+len*0.02,0,-outer_d*0.5-delta])
                        lozenge(len*0.38, core_d*0.2, core_d*0.4, outer_d+2*delta) ;
                    translate([-len*0.40,0,-outer_d*0.5-delta])
                        lozenge(len*0.38, core_d*0.2, core_d*0.4, outer_d+2*delta) ;
                }
    }
}

// clip_len = spool_w_all-15 ;
// spool_clip(core_d, core_d+4, clip_len) ;

module crank_handle(
        crank_l, 
        shaft_d, crank_hub_d, handle_hub_d, handle_d, 
        crank_hub_t, crank_arm_t, handle_hub_t) {
    difference() {
        union() {
            cylinder(d=crank_hub_d, h=crank_hub_t) ;
            translate([0,0,crank_hub_t-delta])
                pulley(crank_hub_d, crank_hub_t) ;
            translate([crank_l/2,0,crank_arm_t/2]) 
                cube(size=[crank_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([crank_l,0,0]) 
                cylinder(d=handle_hub_d, h=handle_hub_t) ;
        } ;
        union() {
            shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            translate([crank_l,0,0]) {
                //shaft_hole(d=handle_d, l=crank_hub_t) ;
                nut_recess(af=handle_nut_af, t=handle_nut_t) ;
                translate([0,0,handle_hub_t])
                    countersinkZ(od=handle_d*2,oh=crank_hub_t, sd=handle_d, sh=handle_hub_t) ;
            }
        } ;
    }
}

module drive_pulley(shaft_d, drive_pulley_d) {
    difference() {
        union() {
            cylinder(d=drive_pulley_d, h=crank_hub_t) ;
            translate([0,0,crank_hub_t-delta])
                pulley(drive_pulley_d, crank_hub_t) ;
        } ;
        union() {
            shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
        } ;
    }
}

module winder_side_support() {
    // Side in X-Y plane, shaft centre at origin, extends along +X axis
    module side_profile() {
        linear_extrude(height=winder_side_t)
            {
            polygon(
                points=[
                    [0,-winder_apex_d/2], [0,winder_apex_d/2],
                    [winder_side_h-winder_base_t,-winder_side_w/2], [winder_side_h-winder_base_t,winder_side_w/2],
                    [winder_side_h,-winder_side_w/2], [winder_side_h,winder_side_w/2]
                    ],
                paths=[[0,2,4,5,3,1,0]]
                ) ;
            }
        }
    module side_apex() {
        cylinder(h=winder_side_t, d=winder_apex_d) ;
        }
    module side_base() {
        translate([winder_side_h-winder_side_t, -winder_side_w/2, 0])
            {
                difference() {
                    cube(size=[winder_side_t, winder_side_w, winder_base_t], center=false) ;
                    translate([0, winder_side_w*0.25, winder_base_t/2+winder_side_t/2])
                        rotate([0,90,0])
                            shaft_hole(base_fix_d, winder_side_t) ;
                    translate([0, winder_side_w*0.75, winder_base_t/2+winder_side_t/2])
                        rotate([0,90,0])
                            shaft_hole(base_fix_d, winder_side_t) ;
                }
            }
        }
    difference()
        {
        union()
            {
                side_profile() ;
                side_apex() ;
                side_base() ;
                web_side = winder_base_t - winder_side_t ;
                web_xz(winder_side_h-winder_side_t, -winder_side_w/2, winder_side_t, -web_side, web_side, winder_side_t) ;
                web_xz(winder_side_h-winder_side_t,  winder_side_w/2, winder_side_t, -web_side, web_side, winder_side_t) ;
            } ;
        shaft_hole(shaft_d, winder_side_t) ;
        }

}

module winder_side_support_slotted(r=145) {
    // Winder support with slot for removing shaft
    //
    // r  = angle of rotation of slot from vertical
    //
    difference() {
        s_ox  = 0.50 ;           // Slot offset diameter multiplier
        f_xm = shaft_d*s_ox/2 ;  // Mid-point of flex cutout
        f_oy = -0.675*shaft_d ;  // Y-offset of flex cutout
        f_d  = 1.7 ;             // width of flex cutout
        f_l  = 6.0 ;             // Length flex cutout (excl radius ends)
        winder_side_support() ;
        // Cutout to allow spool to be removed
        rotate([0,0,r]) {
            translate([shaft_d*s_ox,0,-delta])
                oval(shaft_d, shaft_d, winder_side_t+delta*2) ;
            // Cutouts to flex retaining lugs
            translate([f_xm-f_l/2, f_oy, 0])
                oval(f_l, f_d, winder_side_t+delta*2) ;
            translate([f_xm-f_l/2, -f_oy, 0])
                oval(f_l, f_d, winder_side_t+delta*2) ;
        } 
    }    
}

// Tape reader bridge (with lighting groove) and supports

module tape_reader_bridge() {
    difference() {
        rotate([0,90,0])
            cylinder(d=read_w, h=read_total_l, center=true) ;
        translate([0,0,-read_w/2])
            cube(size=[read_total_l+delta, read_w+delta, read_w+delta], center=true) ;
        translate([0,0,(read_w-read_groove_d)/2])
            cube(size=[read_total_l+delta, read_groove_w, read_groove_d], center=true) ;
    }
}

module tape_reader_bridge_with_guides() {
    module guide_flange() {
        translate([0,0,read_l/2+guide_tb+guide_tr/2])
            cylinder(d=guide_w, h=guide_tr+delta, center=true) ;        // Rim
        translate([0,0,read_l/2+guide_tr/2])
            cylinder(d1=read_w, d2=guide_w, h=guide_tb, center=true) ;  // Bevel
    }
    module tension_bar() {
        translate([-(guide_w-tension_bar_d)/2,0,0])
            cylinder(d=tension_bar_d, h=read_l+guide_tb*2, center=true, $fn=16) ;
    }
    difference() {
        rotate([0,90,0])
            union() {
                cylinder(d=read_w, h=read_total_l, center=true) ;
                guide_flange() ;
                mirror(v=[0, 0, 1]) guide_flange() ;
                rotate([0,0,82])  tension_bar() ;     // Angle determined by trial/error :(
                rotate([0,0,-82]) tension_bar() ;
            }
        translate([0,0,-read_w/2])
            cube(size=[read_total_l+delta, guide_w+delta, read_w+delta], center=true) ;
        translate([0,0,(read_w-read_groove_d)/2])
            cube(size=[read_total_l+delta, read_groove_w, read_groove_d], center=true) ;
        rotate([0,90,0])
            translate([-read_w/2-guide_eld*0.2,0,0])
                cylinder(d=guide_eld, h=read_total_l+delta, center=true, $fn=8) ;
    }
}

module read_side_support() {
    // Side in X-Y plane, shaft centre at origin, extends along +X axis
    module side_profile() {
        base_h = read_side_t + (read_side_base_t - read_side_t) ;
        linear_extrude(height=winder_side_t)
            {
            polygon(
                points=[
                    [0,-read_w/2], [0,read_w/2],
                    [-read_side_apex_h,-read_w/2], [-read_side_apex_h,read_w/2],
                    [-read_side_apex_h,-read_side_apex_w/2], [-read_side_apex_h,read_side_apex_w/2],
                    [read_h-base_h,-read_side_base_w/2], [read_h-base_h,read_side_base_w/2],
                    [read_h,-read_side_base_w/2], [read_h,read_side_base_w/2],
                    ],
                // paths=[[0,2,4,6,8, 9,7,5,3,1, 0]]
                paths=[[4,6,8, 9,7,5, 4]]
                ) ;
            }
        }
    module side_base() {
        translate([read_h-read_side_t, -read_side_base_w/2, 0])
            {
                difference() {
                    cube(size=[read_side_t, read_side_base_w, read_side_base_t], center=false) ;
                    translate([0, read_side_base_w*0.25, read_side_base_t/2+read_side_t/2])
                        rotate([0,90,0])
                            shaft_hole(read_side_peg_d, read_side_t) ;
                    translate([0, read_side_base_w*0.75, read_side_base_t/2+read_side_t/2])
                        rotate([0,90,0])
                            shaft_hole(read_side_peg_d, read_side_t) ;
                }
            }
        }
    difference()
        {
        union()
            {
                side_profile() ;
                side_base() ;
                web_side = read_side_base_t - read_side_t ;
                web_xz(read_h-read_side_t, -read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
                web_xz(read_h-read_side_t,  read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
            } ;
        union()
            {
                shaft_hole(shaft_d, read_side_t) ;
                translate([(read_h-read_side_base_t-read_side_t)*0.5,0,0])
                    shaft_hole(shaft_d, read_side_t) ;
                translate([read_h-read_side_base_t-read_side_t, +0.25*read_side_base_w,0])
                    shaft_hole(read_side_peg_d, read_side_t) ;
                translate([read_h-read_side_base_t-read_side_t, -0.25*read_side_base_w,0])
                    shaft_hole(read_side_peg_d, read_side_t) ;
            } ;
        }
}

// Parts for holding phone camera

module phone_holder_rod_fixing_arm() {
    module phone_holder_rod_fixing_shape() {
        // Centre hub on origin, extend X axis, lying on Z=0 plane
        union() {
            cylinder(d=hold_fix_hub_d, h=hold_fix_t) ;
            translate([0,-hold_fix_w/2,0])
                cube(size=[hold_fix_l, hold_fix_w, hold_fix_t], center=false) ;
            translate([hold_fix_l,0,0])
                cylinder(d=hold_fix_w, h=hold_fix_t) ;
        }
    }
    difference() {
        phone_holder_rod_fixing_shape() ;
        shaft_hole(hold_fix_rod_d, hold_fix_t ) ;
        translate([0,0,0])
            rotate([0,0,0])
                union() {
                    translate([hold_fix_l-hold_fix_d,0,0])
                        shaft_hole(hold_fix_d, hold_fix_w ) ;
                    translate([hold_fix_l-hold_fix_p-hold_fix_d,0,0])
                        shaft_hole(hold_fix_d, hold_fix_w ) ;
                } ;
    } ;
}

module phone_holder_rod_fixing_plate() {
    // NOTE: all holes are centred rod diameter from edges
    hole_x = hold_fix_rod_d + hold_fix_o_x ;
    hole_y = hold_fix_plate_w/2 + hold_fix_o_y ;
    module plate_outline() {
        linear_extrude(height=hold_fix_t)
            {
            polygon(
                points=[
                    [0,0], 
                    [hold_fix_rod_d*2, 0], 
                    [hold_fix_plate_l, hole_y-hold_fix_rod_d], 
                    [hold_fix_plate_l, hole_y+hold_fix_rod_d],
                    [hold_fix_rod_d*2, hold_fix_plate_w], 
                    [0, hold_fix_plate_w]
                    ],
                paths=[[0,1,2,3,4,5,0]]
                ) ;
            }
        }
    difference() {
        plate_outline() ;
        // Larger hole
        translate([hole_x, hole_y,0])
            shaft_hole(hold_fix_rod_d, hold_fix_t ) ;
        // Smaller holes
        translate([hold_fix_rod_d, hold_fix_rod_d+hold_fix_p, 0])
            shaft_hole(hold_fix_d, hold_fix_rod_d ) ;
        translate([hold_fix_rod_d, hold_fix_rod_d, 0])
            shaft_hole(hold_fix_d, hold_fix_t ) ;
    }
}

module phone_holder_rod_anti_rotation_plate() {
    // NOTE: all holes are centred rod diameter from edges
    slot_y  = hold_fix_plate_w/2 + hold_fix_o_y ;
    neck_x  = (hold_slot_o_x1 + hold_slot_o_x2)/2 ;
    module plate_outline() {
        linear_extrude(height=hold_fix_t)
            {
            polygon(
                points=[
                    [0,0], 
                    [hold_fix_rod_d*2, 0], 
                    [neck_x,slot_y-hold_fix_rod_d],
                    [hold_slot_o_x2, slot_y-hold_fix_rod_d], 
                    [hold_slot_o_x2, slot_y+hold_fix_rod_d],
                    [neck_x,slot_y+hold_fix_rod_d],
                    [hold_fix_rod_d*2, hold_fix_plate_w], 
                    [0, hold_fix_plate_w]
                    ],
                paths=[[0,1,2,3,4,5,6,7,0]]
                ) ;
            }
        translate([hold_slot_o_x2, slot_y, 0])
            cylinder(h=hold_fix_t, r=hold_fix_rod_d, center=false) ;
        }
    difference() {
        plate_outline() ;
        shaft_slot(hold_slot_o_x1, hold_slot_o_x2, slot_y, hold_fix_rod_d, hold_fix_t) ;
        translate([hold_fix_rod_d, hold_fix_rod_d+hold_fix_p, 0])
            shaft_hole(hold_fix_d, hold_fix_rod_d ) ;
        translate([hold_fix_rod_d, hold_fix_rod_d, 0])
            shaft_hole(hold_fix_d, hold_fix_t ) ;
    }
}

module phone_camera_holder() {
    module phone_holder_base() {
        // Centre baseline on origin, extend X axis, lying on Z=0 plane
        linear_extrude(height=hold_base_t)
            {
            polygon(
                points=[
                    [-hold_base_l1/2,0], [+hold_base_l1/2,0],
                    [-hold_base_l2/2,hold_base_w], [+hold_base_l2/2,hold_base_w]
                    ],
                paths=[[0,2,3,1,0]]
                ) ;
            }
        }
    module phone_holder_side() {
        // Thinner edge on Y axis, centred on X axis
        rotate([0,-90,0])
            linear_extrude(height=hold_side_l, center=true)
                {
                polygon(
                    points=[
                        [0, -delta], 
                        [hold_side_t1,-delta],
                        [-delta,hold_side_h], 
                        [hold_side_t2,hold_side_h],
                        ],
                    paths=[[0,2,3,1,0]]
                    ) ;
                } ;
        }
    difference() {
        union() {
            rotate([90,0,0]) {
                    phone_holder_base() ;
                }
            phone_holder_side() ;
            } ;
        union() {
            translate([-hold_rail_p/2,-hold_base_t/2,0])
                shaft_hole(hold_rail_d, hold_base_w) ;
            translate([+hold_rail_p/2,-hold_base_t/2,0])
                shaft_hole(hold_rail_d, hold_base_w) ;
            translate([-hold_fix_p/2,hold_side_h,hold_side_t2/2])
                rotate([90,0,0])
                    shaft_hole(hold_fix_d, hold_base_t+hold_side_h);
            translate([+hold_fix_p/2,hold_side_h,hold_side_t2/2])
                rotate([90,0,0])
                    shaft_hole(hold_fix_d, hold_base_t+hold_side_h);
            } ;
        }
    }


// Bracket to hold phone camera support rod
    
 module phone_holder_rod_support() {
    // Side in X-Y plane, shaft centre at origin, extends along +X axis
    module side_profile() {
        linear_extrude(height=winder_side_t) {
            polygon(
                points=[
                    [0,-rod_support_apex_w/2], [0,rod_support_apex_w/2],
                    [rod_support_h-rod_support_base_t,-rod_support_base_w/2], [rod_support_h-rod_support_base_t,rod_support_base_w/2],
                    [rod_support_h,-rod_support_base_w/2], [rod_support_h,rod_support_base_w/2],
                    ],
                paths=[[0,2,4, 5,3,1, 0]]
                ) ;
        }
    }
    module side_base() {
        translate([rod_support_h-rod_support_t, -rod_support_base_w/2, 0]) {
            difference() {
                cube(size=[rod_support_t, rod_support_base_w, rod_support_base_t], center=false) ;
                translate([0, rod_support_base_w*0.25, rod_support_base_t/2+rod_support_t/2])
                    rotate([0,90,0])
                        shaft_hole(base_fix_d, rod_support_t) ;
                translate([0, rod_support_base_w*0.75, rod_support_base_t/2+rod_support_t/2])
                    rotate([0,90,0])
                        shaft_hole(base_fix_d, rod_support_t) ;
            }
        }
    }
    module rod_holder() {
        // Rod support block centred on X-Y plane, rod hole aligned with X-axis
        holder_wdth = hold_fix_rod_d*2 ;
        holder_dpth = rod_support_base_t ;
        holder_hght = holder_dpth-holder_wdth/2 ;
        difference() {
            union() {               
                translate([0,0,holder_hght/2])
                    cube(size=[rod_support_t, holder_wdth, holder_hght], center=true) ;
                translate([0,0,holder_dpth-holder_wdth/2])
                    rotate([0,90,0])
                        cylinder(d=holder_wdth,h=rod_support_t, center=true) ;
            }
            translate([-rod_support_t/2,0,holder_dpth-holder_wdth/2])
                rotate([0,90,0])
                    shaft_hole(hold_fix_rod_d, rod_support_t) ;
        }
    }
    union() {
        side_profile() ;
        side_base() ;
        translate([rod_support_t/2,0,0])
            rod_holder() ;
        translate([rod_support_h*0.75,0,0])
            rod_holder() ;
        web_side = rod_support_base_t - rod_support_t ;
        web_xz(rod_support_h-rod_support_t, -rod_support_base_w/2, rod_support_t, -web_side, web_side, rod_support_t) ;
        web_xz(rod_support_h-rod_support_t,  rod_support_base_w/2, rod_support_t, -web_side, web_side, rod_support_t) ;
    } ;
}


module winder_assembly() {
    // Spool and crank handle
    spool_pos_x   = side_t + spool_w_all/2 + part_gap/2 ;
    winder_side_x = winder_side_t + spool_w_all/2 + part_gap/2 + part_gap ;
    winder_pos_x  = winder_side_x + 2*part_gap ;
    translate([-spool_pos_x,0,winder_side_h])
        rotate([0,90,0])
            half_spool(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
                );
    translate([spool_pos_x,0,winder_side_h])
        rotate([0,-90,0])
            half_spool(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
                );
    translate([winder_pos_x,0,winder_side_h])
        rotate([-45,0,0])
            rotate([0,90,0])
                crank_handle(
                    crank_l=crank_l, 
                    shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
                    handle_hub_d=handle_hub_d, handle_d=handle_d, 
                    crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, 
                    handle_hub_t=crank_end_t
                    ) ;
    // Winder supports
    translate([winder_side_x,0,winder_side_h])
        rotate([0,90,180])
            winder_side_support() ;
    translate([-winder_side_x,0,winder_side_h])
        rotate([0,90,0])
            winder_side_support() ;
}

module read_bridge_assembly() {
    // Reader bridge and support
    side_support_x = side_t + part_gap + spool_w_mid + part_gap/2 ;
    translate([0,0,read_h])
        tape_reader_bridge() ;
    translate([side_support_x,0,read_h])
        rotate([0,90,180])
            read_side_support() ;
    translate([-side_support_x,0,read_h])
        rotate([0,90,0])
            read_side_support() ;
}

module phone_holder_assembly() {
    // Phone/camera holder
    holder_spacing = hold_base_w + part_gap ;
    holder_height  = read_h*1.75 ;
    rod_fix_x = hold_fix_l - hold_fix_d - hold_fix_p/2 ;
    rod_fix_y = holder_spacing - hold_fix_w/2 ;
    rod_fix_z = holder_height + hold_base_t + part_gap ;
    rod_holder_x = rod_fix_x + rod_support_t + hold_fix_rod_d/2 ;
    translate([0,-holder_spacing,holder_height])
        rotate([-90,0,0])
            phone_camera_holder() ;
    translate([0,holder_spacing,holder_height])
        rotate([-90,0,180])
            phone_camera_holder() ;
    translate([-rod_fix_x,rod_fix_y,rod_fix_z])
        rotate([0,0,-90])
            phone_holder_rod_fixing_plate() ;
    translate([-rod_holder_x,rod_fix_y,rod_support_h])
        rotate([0,90,0])
            phone_holder_rod_support() ;    
}

module layout_assembly() {
    // Render and place parts for printing
    winder_reader_spacing = 90 ;
    translate([0,-winder_reader_spacing,0])
        winder_assembly() ;
    translate([0,winder_reader_spacing,0])
        winder_assembly() ;
    // Reader bridge and support
    translate([0,0,0])
        read_bridge_assembly() ;
    // Phone/camera holder
    translate([0,0,0])
        phone_holder_assembly() ;
}



module layout_print_xz() {
    // Render and place parts for printing

    // Spool and crank handle
    translate([-spacing,0,0])
        half_spool(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([0,0,0])
        half_spool(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([spacing,0,0])
        crank_handle(
            crank_l=crank_l, 
            shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
            handle_hub_d=handle_hub_d, handle_d=handle_d, 
            crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=crank_end_t
            ) ;
    
    // Winder supports
    translate([spacing,spacing,0])
        winder_side_support() ;
    translate([-spacing,spacing,0])
        winder_side_support() ;
    
    // Reader bridge and support
    translate([-spacing,2*spacing,0])
        tape_reader_bridge() ;
    translate([0,2*spacing,0])
        read_side_support() ;
    translate([0,3*spacing,0])
        read_side_support() ;
    
    // Phone/camera holder
    translate([-spacing,5*spacing,0])
        phone_camera_holder() ;
    translate([spacing,5*spacing,0])
        phone_camera_holder() ;
    translate([0,6*spacing,0])
        phone_holder_rod_support() ;    
    translate([0,7*spacing,0])
        phone_holder_rod_fixing() ;
}

module layout_print_spacer() {
    spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;
}


module layout_print_1() {
    // Spools
    translate([-spacing,0,0])
        half_spool(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([0,0,0])
        half_spool(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([spacing*1,0,0])
        spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;
    translate([spacing*2,0,0])
        spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;

    // Crank handle
    translate([0, spacing*2,0])
        crank_handle(
            crank_l=crank_l, 
            shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
            handle_hub_d=handle_hub_d, handle_d=handle_d, 
            crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=crank_end_t
            ) ;
    
    // Winder supports
    translate([spacing,spacing,0])
        winder_side_support() ;
    translate([-spacing,spacing,0])
        winder_side_support() ;
}

module layout_print_2() {
    // Reader bridge and support
    translate([
    0,1*spacing,0])
        tape_reader_bridge() ;
    translate([-winder_side_h/2,spacing*2,0])
        read_side_support() ;
    translate([-winder_side_h/2,3*spacing,0])
        read_side_support() ;
}

module layout_print_3() {
    // Phone/camera holder
    translate([-spacing,0*spacing,0])
        phone_camera_holder() ;
    translate([spacing,0*spacing,0])
        phone_camera_holder() ;
    translate([0,1*spacing,0])
        phone_holder_rod_support() ;    
    translate([0,2*spacing,0])
        phone_holder_rod_fixing() ;
}

module layout_print() {
    // Render and place parts for printing
    translate([spacing,0*spacing,0])
        layout_print_1() ;
    translate([spacing,3*spacing,0])
        layout_print_2() ;
    translate([spacing,9*spacing,0])
        layout_print_3() ;
}

// layout_assembly() ;

// layout_print() ;

// layout_print_1() ;
// layout_print_2() ;
// layout_print_3() ;
// layout_print_spacer() ;

// spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid, w_spool_end=spool_w_end) ;

//        crank_handle(
//            crank_l=crank_l, 
//            shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
//            handle_hub_d=handle_hub_d, handle_d=handle_d, 
//            crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=handle_hub_t
//            ) ;
//
//
//    translate([2*spacing,0,0])
//        pulley(crank_hub_d, 4) ;









// 
// Recap some vector geometry, for calculating centre from straight line to arc 
// in rounded-corner wheel segments.
// 
// On a vector `ab` though `a` and `b`, the closest point `d` to some 
// other point `c` is given by: 
// 
// 1.  d = a + k(b-a)                  // for some k
// 
// 2.  (c-d).(b-a) = 0                 // Dot product of perpendicular
// 
// 3.  c.(b-a) - d.(b-a) = 0           // Expanding (2)
// 
//     c.(b-a) = d.(b-a)
//             = (a+k(b-a)).(b-a)      // Subst from (1)
//             = a.(b-a) + k(b-a).(b-a))
// 
//     c.(b-a) - a.(b-a) = k(b-a).(b-a)
// 
//     (c-a).(b-a) = k(b-a).(b-a)
// 
//     k = ((c-a).(b-a)) / ((b-a).(b-a))
// 
// Distance from c to vector `ab` is:
// 
//     |(c-d)| = |(c-k(b-a))|
// 
// To estimate the position of fillet radius centre P5, we have:
// 
//     a = (0,0)               // origin
//     b = (cos a, sin a)      // unit vector, second edge of segment
//     c = (p5_x, p5_y)        // unknown
//     |(c-k(b-a))| = fr       // fillet radius
//     |c|          = hr+fr    // fillet radius centre distance from hub
// 
//     k = c.b                 // from what we know about a and b above
// 
// Thus
// 
//     |c-c.b b| = fr
// 
//     fr^2 = (c-c.b b).(c-c.b b)
//          = (c.c - 2 c.b b.c + (c.b)^2 b.b) 
//          = c.c - 2 c.b b.c + (c.b)^2    // b.b == 1
//          = (hr+fr)^2 - (c.b)^2
//          = (hr+fr)^2 - (p5_x cos a + p5_y sin a)^2
// 
//     |c|       = hr + fr     // Copied from above
// 
// We need to solve for c, expressed as (p5_x, p5_y):
// 
//     p5_x^2 + p5_y^2 = (hr+fr)^2
// 
//     (p5_x cos a + p5_y sin a)^2 = (hr + fr)^2 - fr^2 
// 
//     (p5_x cos a)^2 + 2 p5_x cos a p5_y sin a + (p5_y sin a)^2 = hr^2 + 2 hr fr + fr^2 - fr^2
//                                                               = hr^2 + 2 hr fr
// 
// <Grumble, gets hard to solve>
// 

