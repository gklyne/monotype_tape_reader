// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;

////////////////////////////////////////////////////////////////////////////////
// Definitions
////////////////////////////////////////////////////////////////////////////////

// @@@@ moved to reader-defs.scad
// Guide roller parameters (shape of rims each end)

// guide_rim_1_extra_radius = 3 ;      // Rim bevel outer 
// guide_rim_2_extra_radius = 0.25 ;   // Rim bevel inner
// guide_rim_1_width        = 0.2 ;    // Rim end thickness
// guide_rim_2_width        = 2 ;      // Rim bevel thickness 
// guide_rim_overall_width  = mt_overall_width + 5 ;  // Each rim 2.2 + 0.6 tape clearance
// @@@@

////////////////////////////////////////////////////////////////////////////////
// Utilities for tape guide objects
////////////////////////////////////////////////////////////////////////////////

module shaft_nut_carrier(d1, d2, h, af, t) {
    // Cylindrical section on X-Y plane, centred on origin, with shaft hole and
    // nut carrier cutout.
    //
    // d1 = diameter of cylindrical section
    // d2 = diameter of shaft hole
    // h  = height of cylindrical section
    // af = size (across flats) of nut
    // t  = thickness of nut
    // 
    t1 = t + nut_recess_height(af) ;    // Overall height of nut recess
    h1 = (h-t1)*0.5 ;                   // Height to bottom of nut recess
    h2 = h1 + t/2 ;                     // Height to centre of nut ejection shaft
    difference() {
        cylinder(d=d1, h=h, $fn=16) ;
        shaft_hole(d2, h) ;
        translate([0,0,h1])
            extended_nut_recess(af, t, d1) ;
        translate([0,0,h2])
            rotate([0,90,0])
                cylinder(d=t,h=d1+2*delta, $fn=6, center=true) ;
    }
}
// Instance shaft_nut_carrier(d1, d2, h, af, t)
// shaft_nut_carrier(16, m4, 8, 7, 3.1) ;

module shaft_nut_cutout_____unused____(af1, t1, af2, t2, r) {
    // Cutouts for captive nut on shaft axis
    //
    // af1 = across-faces size of nut on shaft
    // t1  = thickness of nut on shaft
    // af2 = width of access hole in rim
    // t2  = thickness of access hole in rim
    // r   = radius of rim
    //
    // Recess in hub to hold the nut
    nut_recess(af1, t1) ;
    translate([-af1*0.4,0,0]) nut_recess(af1, t1) ;  // Extend along -x for nut entry
    // Opening in rim to allow access
    translate([-r,0,0]) nut_recess(af2, t2) ;
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


////////////////////////////////////////////////////////////////////////////////
// Tape reader bridge (with lighting groove)
////////////////////////////////////////////////////////////////////////////////

module shade_shell(inner_r, outer_r, h) {
    // Same parameters as ring, but defines sloping sides for printing shade
    rotate([0,0,180]) {
        difference() {
            cylinder(r=outer_r, h=h, center=false, $fn=7) ;
            translate([0,0,-delta])
                cylinder(r=inner_r, h=h+2*delta, center=false, $fn=7) ;
        }
    }
    // inner_w = inner_r * sqrt(2) ;
    // outer_w = outer_r * sqrt(2) ;
    // translate([0,0,h/2])
    //     rotate([0,0,45])
    //         difference() {
    //             cube(size=[outer_w, outer_w, h], center=true) ;
    //             cube(size=[inner_w, inner_w, h+2*delta], center=true) ;
    //         } ;
}

module tape_reader_bridge_with_guides() {
    module guide_flange() {
        // Guide flange with shades for exposed EL wire
        //
        // guide_tr = Guide thickness at rim
        // guide_tr = Guide thickness at core
        // guide_tb = Guide thickness of bevel
        guide_offset = spool_w_all/2 ;  // Offset to guide (at base of bevel)
        shade_t = 0.8 ;                 // Thickness of shade shell
        shade_o = 0.5 ;                 // Shell centre offset (downwards)
        translate([0,0,guide_offset+guide_tb])
            cylinder(d=guide_w, h=guide_tr+delta, center=false) ;        // Rim
        translate([0,0,guide_offset])
            cylinder(d1=read_w, d2=guide_w, h=guide_tb, center=false) ;  // Bevel
        difference() {
            translate([shade_o,0,guide_offset-guide_ist])             // Shade shell
                shade_shell(guide_w/2-shade_t, guide_w/2, guide_ost+guide_ist) ;
            // Angled cutaway for inner shade
            translate([0,0,guide_offset+guide_tb])    // Inner shade
                rotate([0,-26,0])
                    translate([0,0,-guide_ist])
                        cube(size=[guide_w*2, guide_w, guide_ist*2], center=true) ;
            // Angled cutaway for outer shade
            // read_side_apex_h is height of dovetail on sides
            // read_extra_l is distance of side from inner guide flange
            // guide_tc is the full (combined bevel and rim) thickness of the guide flange
            // read_total_l = spool_w_all + 2*(read_side_t + read_extra_l) ;
            // -X translates to +Z after rotation
            outer_shade_a = 45 ;
            outer_shade_h = read_side_apex_h - (read_extra_l-guide_tc)/tan(outer_shade_a) + clearance*2 ;
            translate([-outer_shade_h,0,guide_offset+guide_tc])    // Outer shade
                rotate([0,outer_shade_a,0]) {
                    cylinder(d=1,h=guide_w+2) ;
                    translate([-guide_w,-guide_w/2,0]) {
                        cube(size=[guide_w, guide_w, guide_ost*2]) ;
                    }
                }
            // Cutaway lower part of outer shade shell
            translate([-outer_shade_h,-guide_w/2,guide_offset+guide_tb+guide_tr])
                cube(size=[guide_w, guide_w, guide_ost*2]) ;
        }
    }
    rotate([0,90,0])
        difference() {
            union() {
                cylinder(d=read_w, h=read_total_l, center=true) ;
                guide_flange() ;
                mirror(v=[0, 0, 1]) guide_flange() ;
            }
            // Cutaway lower part of bridge cylinder
            translate([read_w/2, 0, 0])
                cube(size=[read_w+delta, guide_w+delta, read_total_l+delta], center=true) ;
            // Cutaway groove for EL wire
            //    -(read_w-read_groove_w)/2 -> tangential to top of bridge
            //    ... +read_groove_w*___    -> move down to create narrower slot
            translate([-(read_w-read_groove_w)/2+read_groove_w*0.1,0,0])
                cylinder(d=read_groove_w, h=read_total_l+delta, center=true, $fn=12) ;
            // Cutaway threading hole
            //    -read_w/2-guide_eld*0.5 -> tangential to top of bridge
            //    ... +read_groove_w*0.4_ -> move down to create slot
            translate([-read_w/2-guide_eld*0.5+read_groove_w*0.45,0,0])
                cylinder(d=guide_eld, h=read_total_l+delta, center=true, $fn=12) ;
    }
}


module tape_reader_bridge_dovetailed() {
    module bridge_dovetail_cutout() {
        translate([-read_total_l/2+read_side_t,0,0])
            dovetail_tongue_cutout(
                read_side_t+delta, read_w-3, read_w-2, read_w+delta, read_side_apex_h
        ) ;
    }
    difference() {
        tape_reader_bridge_with_guides() ;
        bridge_dovetail_cutout() ;
        mirror(v=[1, 0, 0]) bridge_dovetail_cutout() ;
    }
}

module tape_reader_bridge_el_wire_clip() {
    // Clip to hold down ends of EL wire in reader bridge groove
    //
    // Pushes on over end of bridge and sits inside the support sides
    //
    clip_w = 3 ;        // Width of clip
    clip_t = 2.5 ;      // Thickness of clip
    clip_r1 = read_w/2+clearance ;
    clip_r2 = read_w/2+clip_w ;
    difference() {
        union() {
            ring(r1=clip_r1, r2=clip_r2, t=clip_t) ;
            translate([-read_w/2,-read_w/2-clip_w,0])
                cube(size=[read_w/2, 2*clip_r2, clip_t]) ;
            }
        translate([-clip_r1-clip_w,-clip_r2-delta,-delta])
            cube(size=[read_w/2, 2*clip_r2+2*delta, clip_t+2*delta]) ;
    }
}

module curved_edge(l,t,dir) {
    //  Curved edge for platform:
    //  lying on X-Y plane, non-radiused edge along X-axis, centred around Y axis, 
    //  extending along Y axis in direction indicated by 'dir'.
    //
    //  l = overall length of edge
    //  t = thickness and width of edge, also radius of curve
    //  dir = +1 to extend towards +Y direction, -1 for extend towards -Y
    //
    rotate([0,-90,0]) {
        difference() {
            cylinder(r=t, h=l, center=true) ;
            translate([0,-t*0.5*dir,0])
                cube(size=[(t+delta)*2,t+delta,l+2*delta], center=true) ;
            translate([-t*0.5,0,0])
                cube(size=[t+delta,(t+delta)*2,l+2*delta], center=true) ;

        }
    }
}
// curved_end(40, 10, +1) ;

decoder_platform_w = 40 ;
decoder_platform_t = read_side_apex_h ;
decoder_scale_groove_w = 5 ;
decoder_scale_groove_d = 3;
decoder_clearance = 0.5 ;

decoder_scale_t1   = 4 ;
decoder_scale_t2   = 1 ;
decoder_scale_w    = decoder_platform_w*0.5 ;

module tape_decoder_platform_dovetailed() {
    module bridge_dovetail_cutout() {
        translate([-read_total_l/2+read_side_t,0,0])
            dovetail_tongue_cutout(
                read_side_t, read_w-3, read_w-2, decoder_platform_w*2, decoder_platform_t
        ) ;
    }
    difference() {
        union() {
            translate([0,0,+decoder_platform_t/2])
                cube(size=[read_total_l, decoder_platform_w, decoder_platform_t], center=true) ;
            translate([0,decoder_platform_w/2-delta,0])
                curved_edge(read_total_l, decoder_platform_t, +1) ;
            translate([0,-(decoder_platform_w/2-delta),0])
                curved_edge(read_total_l, decoder_platform_t, -1) ;
        }
        translate([0,-decoder_platform_w*0.4,decoder_platform_t])
            cube(
                size=[read_total_l+delta,decoder_scale_groove_w,decoder_scale_groove_d*2],
                center=true
                ) ;
        translate([0,+decoder_platform_w*0.4,decoder_platform_t])
            cube(
                size=[read_total_l+delta,decoder_scale_groove_w,decoder_scale_groove_d*2],
                center=true
                ) ;
        bridge_dovetail_cutout() ;
        mirror(v=[1, 0, 0]) bridge_dovetail_cutout() ;
    }
}

module tape_decoder_scale() {
    difference() {
        union() {
            // Scale body
            translate([0,decoder_scale_w*0.5,+decoder_scale_t1/2])
                cube(size=[read_total_l-read_side_t*2, decoder_scale_w, decoder_scale_t1], center=true) ;
            // Guide lugs
            lug_w = decoder_scale_groove_w - decoder_clearance ;
            lug_d = decoder_scale_groove_d - decoder_clearance ;
            translate([0,lug_w*0.5,-lug_d*0.5+delta])
                cube(size=[read_total_l-read_side_t*2, lug_w, lug_d], center=true) ;
        }
        // Cutaway width of tape
        translate([0,decoder_scale_groove_w*0.5,-decoder_scale_groove_d*0.5])
            cube(size=[mt_overall_width, decoder_scale_groove_w+2*delta, decoder_scale_groove_d+delta], center=true) ;
        // Cutaway bevel
        lb = decoder_scale_w - decoder_scale_groove_w ;
        tb = decoder_scale_t1 - decoder_scale_t2 ;
        translate([0,decoder_scale_groove_w,decoder_scale_t1])
            rotate([-atan2(tb,lb),0,0])
                translate([0,decoder_scale_w*0.5-decoder_scale_groove_w,+decoder_scale_t1/2])
                    cube(size=[read_total_l, decoder_scale_w*1.1, decoder_scale_t1], center=true) ;
    }
}


////////////////////////////////////////////////////////////////////////////////
// Sprocket pins
////////////////////////////////////////////////////////////////////////////////

function sprocket_or_np_from_pitch(or_max, p) =
    // Calculates outside diameter and number of sprocket pins
    //
    // Always returns an even number of pins, adjusting the supplied radius accordingly.
    //
    // or_max = maximum outside radius - the actual value is slightly smaller than this
    // p      = sprocket hole pitch
    //
    let (
        sc_max = PI * or_max,           // Minimum outside semi-circumference
        np     = floor(sc_max / p),     // Number of sprocket pins on semi-circumference
        sc     = np * p,                // Actual semi-circumference for number of pins at given pitch
        // @@QUERY: reduce to allow for thickness of paper (0.08mm)?
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
                    cylinder(d1=pd, d2=pd*0.1, h=pd*0.85, center=false, $fn=8) ;
}


////////////////////////////////////////////////////////////////////////////////
// Sprocketed tape guide
////////////////////////////////////////////////////////////////////////////////

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
    //
    ornp = sprocket_or_np_from_pitch(or_max, mt_sprocket_pitch) ;
    or   = ornp[0] ;
    np   = ornp[1] ;
    ht1  = (gow - gsw)/2 ;
    ht2  = ht1 + gsw ;

    difference() {
        union() {
            wheel(or+delta, gow) ;
            sprocket_pins(or, ht1, np, pd) ;
            sprocket_pins(or, ht2, np, pd) ;
            rr1 = or + guide_rim_1_extra_radius ;   // Rim outer ..
            rw1 = guide_rim_1_width ;
            rr2 = or + guide_rim_2_extra_radius ;   // Rim inner (bevel) ..
            rw2 = guide_rim_2_width ;
            // Bottom rim...
            cylinder(r=rr1, h=rw1, $fn=24) ;
            translate([0,0,rw1-delta])
               cylinder(r1=rr1, r2=rr2, h=rw2, $fn=24) ;
            // Top rim
            translate([0,0,gow-rw1-rw2+delta])
                cylinder(r1=rr2, r2=rr1, h=rw2, $fn=24) ;
            translate([0,0,gow-rw1])
                cylinder(r=rr1, h=rw1, $fn=24) ;
        }
        shaft_hole(sd, gow) ;
        translate([0,0,gow/2])
            shaft_middle_cutout(rr-fr, gow*0.5) ;
        translate([0,0,-delta])
            spoked_wheel_cutouts(hr, rr, fr, gow+2*delta, 3, sw) ;
    }
} ;

// @@@@ moved to reader-defs.scad
// Guide sprocket diameter and positioning...
// guide_sprocket_dia      = 22 ;
// guide_sprocket_sep      = guide_sprocket_dia*1.8 + read_w ;
// guide_sprocket_ht_off   = guide_sprocket_dia*0.5 ;
// @@@@

// Guide sprocket details
guide_sprocket_fillet_r = 1.5 ;  
guide_sprocket_spoke_w  = 2 ;

guide_sprocket_shaft_d  = m4 ;
guide_sprocket_sleeve_d = m6 ;
guide_sprocket_hub_r    = m4 ;
guide_sprocket_rim_r    = guide_sprocket_dia/2 - 1.5 ;
guide_sprocket_width    = guide_rim_overall_width ;
guide_sprocket_off      = 1 ;       // Offset from side (standoff hub thickness)

// Guide sprocket diameter and positioning...
guide_sprocket_dia      = 22 ;
guide_sprocket_sep      = guide_sprocket_dia*1.8 + read_w ;
guide_sprocket_ht_off   = guide_sprocket_dia*0.5 ;

module sprocket_tape_guide() {
    ornp = sprocket_or_np_from_pitch(guide_sprocket_dia/2, mt_sprocket_pitch) ;
    or   = ornp[0] ;
    np   = ornp[1] ;
    difference() {
        union() {
            sprocket_guide_3_spoked(
                guide_sprocket_shaft_d, 
                guide_sprocket_hub_r,  guide_sprocket_rim_r, guide_sprocket_dia/2,  
                guide_sprocket_fillet_r, guide_sprocket_spoke_w, 
                mt_sprocket_dia,
                mt_sprocket_width, 
                guide_sprocket_width) ;
            translate([0,0,12+3.5])
                circular_platform(r=guide_sprocket_rim_r+delta, h=10) ;
            translate([0,0,guide_sprocket_width-12+3.5])
                circular_platform(r=guide_sprocket_rim_r+delta, h=10) ;
        }
        // M4 nylock nut cutouts
        translate([0,0,10]) {
            extended_nylock_recess_with_ejection_hole(m4_nut_af, m4_nylock_t, guide_sprocket_dia) ;
        }
        translate([0,0,guide_sprocket_width-10-m4_nylock_t]) {
            extended_nylock_recess_with_ejection_hole(m4_nut_af, m4_nylock_t, guide_sprocket_dia) ;
        }
        shaft_hole(guide_sprocket_shaft_d, guide_sprocket_width) ;
    }
}


////////////////////////////////////////////////////////////////////////////////
// Roller tape guide
////////////////////////////////////////////////////////////////////////////////
//
// The purpose of this guide is to keep the tape wrapped around the sprocket guide.
// Implemented as roller to reduce friction.
//

module roller_guide_3_spoked(sd, hr, rr, or, fr, sw, gow, ghw) {
    // 3-spoked roller tape guide, end on X-Y plane, centred on origin.
    //
    // sd     = shaft diameter
    // hr     = hub radius
    // rr     = inner rim radius
    // or     = outer radius
    // fr     = fillet radius of spoke cutout
    // sw     = spoke width
    // gow    = overall width of guide
    // ghw    = width of support hub at ends
    //

    difference() {
        union() {
            wheel(or+delta, gow) ;
            rr1 = or + guide_rim_1_extra_radius ;   // Rim outer ..
            rw1 = guide_rim_1_width ;
            rr2 = or + guide_rim_2_extra_radius ;   // Rim inner (bevel) ..
            rw2 = guide_rim_2_width ;
            // Bottom rim...
            cylinder(r=rr1, h=rw1, $fn=24) ;
            translate([0,0,rw1-delta])
               cylinder(r1=rr1, r2=rr2, h=rw2, $fn=24) ;
            // Top rim
            translate([0,0,gow-rw1-rw2+delta])
                cylinder(r1=rr2, r2=rr1, h=rw2, $fn=24) ;
            translate([0,0,gow-rw1])
                cylinder(r=rr1, h=rw1, $fn=24) ;
        }
        shaft_hole(sd, gow) ;
        translate([0,0,gow/2])
            shaft_middle_cutout(rr-fr, gow-2*ghw) ;
        translate([0,0,-delta])
            spoked_wheel_cutouts(hr, rr, fr, gow+2*delta, 3, sw) ;
    }
} ;

guide_roller_fillet_r       = 0.5 ;  
guide_roller_spoke_w        = 1.5 ;

// @@@@ guide_roller_outer_d        = 14 ;
guide_roller_shaft_d        = guide_sprocket_shaft_d ;
guide_roller_sleeve_d       = guide_sprocket_sleeve_d ;
guide_roller_hub_r          = guide_roller_shaft_d ;
guide_roller_rim_r          = guide_roller_outer_d/2 - 0.8 ;
guide_roller_width          = guide_rim_overall_width ;
guide_hub_width             = guide_roller_width * 0.2 ;

follower_roller_shaft_d     = m4 ;
follower_roller_sleeve_d    = m6 ;
follower_hub_width          = 12 ;
follower_sleeve_len         = 6 ;
follower_roller_hub_r       = follower_roller_shaft_d ;

// @@@@
// guide_roller_centre_x       = guide_sprocket_ht_off*1.6 ;  // e.g. 1.6 for droop, 1 for level, 0.7 for // lift
// guide_roller_centre_y       = 
//     guide_sprocket_sep/2 + 
//     guide_sprocket_dia*0.5 + guide_roller_outer_d*0.5 + 
//     guide_rim_1_extra_radius*2 + 1 ;
// 
// guide_follower_pivot_x      = guide_sprocket_ht_off*1 ;  // e.g. 1.6 for droop, 1 for level, 0.7 for lift
// guide_follower_pivot_y      = guide_roller_centre_y + 12 ;
// @@@@


module roller_tape_guide() {
    or = guide_roller_outer_d/2 ;
    difference() {
        union() {
            roller_guide_3_spoked(
                guide_roller_shaft_d, guide_roller_hub_r,  
                guide_roller_rim_r, or,  
                guide_roller_fillet_r, guide_roller_spoke_w, 
                guide_roller_width, guide_hub_width
                ) ;
            translate([0,0,12+3.5])
                circular_platform(r=guide_roller_rim_r+clearance*4, h=6) ;
            translate([0,0,guide_roller_width-12+3.5])
                circular_platform(r=guide_roller_rim_r+clearance*4, h=6) ;
        }
        ////
        // M4 nut cutouts:  7 AF x 3.1 thick
        // translate([0,0,12]) {
        //     // shaft_nut_cutout(7, 3.1, 8, 4, or) ;
        //     extended_nut_recess_with_ejection_hole(7, 3.1, guide_roller_outer_d+1) ;
        // }
        // translate([0,0,guide_roller_width-12]) {
        //     // shaft_nut_cutout(7, 3.1, 8, 4, or) ;
        //     extended_nut_recess_with_ejection_hole(7, 3.1, guide_roller_outer_d+1) ;
        // }
        ////
        // M4 nylock nut cutouts
        translate([0,0,10]) {
            extended_nylock_recess_with_ejection_hole(m4_nut_af, m4_nylock_t, guide_sprocket_dia) ;
        }
        translate([0,0,guide_sprocket_width-10-m4_nylock_t]) {
            extended_nylock_recess_with_ejection_hole(m4_nut_af, m4_nylock_t, guide_sprocket_dia) ;
        }
        shaft_hole(guide_sprocket_shaft_d, guide_roller_width) ;
    }
}

////////////////////////////////////////////////////////////////////////////////
// Tape reader bridge supports
////////////////////////////////////////////////////////////////////////////////

module reader_bridge_side_support() {
    pivot_hub_t = read_side_t+guide_sprocket_off ;

    // Side in X-Y plane, shaft centre at origin, extends along +X axis
    module side_profile() {
        base_h = read_side_t + (read_side_base_t - read_side_t) ;
        linear_extrude(height=read_side_t)
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
        translate([read_h-read_side_t, -read_side_base_w/2, 0]) {
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

    module side_guide_sprocket_arms() {
        // oval(x, d, h)
        translate([guide_sprocket_ht_off,-guide_sprocket_sep/2,0])
            rotate([0,0,90])
                oval(guide_sprocket_sep, guide_sprocket_dia, read_side_t) ;
        // Shaft support hubs
        translate([guide_sprocket_ht_off, guide_sprocket_sep/2, 0])
            cylinder(d=guide_sprocket_sleeve_d+2, h=pivot_hub_t) ;
        translate([guide_sprocket_ht_off, -guide_sprocket_sep/2, 0])
            cylinder(d=guide_sprocket_sleeve_d+2, h=pivot_hub_t) ;
    }

    module side_guide_roller_arms(side) {
        // Extend side arms to include pivot for roller
        // oval_xy(x1, y1, x2, y2, d, h)
        oval_xy(
            guide_sprocket_ht_off, (guide_sprocket_sep/2)*side,
            guide_roller_centre_x, guide_roller_centre_y*side, 
            guide_roller_outer_d, winder_side_t
        ) ;
        translate([guide_roller_centre_x, guide_roller_centre_y*side, 0])
            cylinder(d=guide_roller_sleeve_d+2, h=pivot_hub_t) ;
    }

    module side_guide_follower_arms(side) {
        // Extend side arms to include pivot for follower arms
        // oval_xy(x1, y1, x2, y2, d, h)
        oval_xy(
            guide_roller_centre_x, guide_roller_centre_y*side, 
            guide_follower_pivot_x, guide_follower_pivot_y*side, 
            guide_roller_outer_d, winder_side_t
        ) ;
        // Extra thickness for nut holder
        translate([guide_follower_pivot_x, guide_follower_pivot_y*side, 0])
            cylinder(d=guide_roller_sleeve_d+4, h=pivot_hub_t) ;
    }

    // Reader side support assembly...
    difference() {
        union() {
            side_profile() ;
            side_guide_sprocket_arms() ;
            side_guide_roller_arms(+1) ;
            side_guide_roller_arms(-1) ;
            side_guide_follower_arms(+1) ;
            side_guide_follower_arms(-1) ;
            side_base() ;
            web_side = read_side_base_t - read_side_t ;
            web_xz(read_h-read_side_t, -read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
            web_xz(read_h-read_side_t,  read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
        } ;
        // Shaft holes
        for (side=[-1,1]) {
            // Shaft holes for guide sprockets
            translate([guide_sprocket_ht_off, side*guide_sprocket_sep/2, 0])
                shaft_hole(guide_sprocket_sleeve_d, pivot_hub_t) ;
            // Shaft holes for guide rollers
            translate([guide_roller_centre_x, side*guide_roller_centre_y, 0])
                shaft_hole(guide_roller_sleeve_d, pivot_hub_t) ;
            // Shaft holes for follower pivots
            translate([guide_follower_pivot_x, side*guide_follower_pivot_y, pivot_hub_t+delta]) {
                // shaft_hole(guide_roller_shaft_d, pivot_hub_t) ;
                mirror([0,0,1])
                    hex_screw_recess_Z(m4, pivot_hub_t+2*delta, m4_nut_af, m4_nut_t) ;
            }
        }
        // Cutout to reduce plastic used
        cutout_r = shaft_d ;
        translate([0,0,-delta])
            rounded_triangle_plate(
                guide_sprocket_dia*0.75, 0, 
                read_h-read_side_base_t-read_side_t, +0.15*read_side_base_w,
                read_h-read_side_base_t-read_side_t, -0.15*read_side_base_w,
                cutout_r, winder_side_t+2*delta
            ) ;
    }

} // module reader_bridge_side_support

module reader_bridge_side_support_dovetailed() {
    difference() {
        reader_bridge_side_support() ;
        translate([0,0,read_side_t])
            rotate([0,-90,0])
                dovetail_socket_cutout(read_side_t, read_w-3, read_w-2, read_side_apex_h) ;
    }
}


////////////////////////////////////////////////////////////////////////////////
// Tape follower arm (supporting tape_follower_roller)
////////////////////////////////////////////////////////////////////////////////

// @@@@
// tape_follower_arm_l         = 40 ;          // Arm length between shaft centres
// tape_follower_short_arm_l   = 24 ;          // Short arm length between shaft centres
// tape_follower_elbow_l       = 10 ;          // Length from pivot to end of elbow
// @@@@
tape_follower_arm_w         = m4+4 ;
tape_follower_arm_t         = sup_t ;
tape_follower_hub_t         = sup_t*1.4 ;
tape_follower_short_hub_t   = sup_t*2 ;
tape_follower_hub_d         = m4_nut_af+4 ;
tape_follower_pivot_d       = m6 ;          // Diameter of follower arm pivot shaft
tape_follower_pivot_t       = sup_t*2.5 ;   // Thickness of pivot hub
tape_follower_short_pivot_d = m6 ;          // Diameter of short follower arm pivot shaft
tape_follower_short_pivot_t = sup_t ;       // Short arm thickness of pivot hub

module tape_follower_arm_param(l, w, t, pd, pt, hd, ht, sd, snaf, snt) {
    // Tape follower arm, holds guide roller loosely in position where its
    // weight maintains a slight tension in the tape and helps to ensure a
    // more controlled feed onto the first roller guide.
    //
    // Lying on X-Y plane, pivot centre at origin, arm extending along X-axis.
    //
    // l    = length of arm (between shaft centres)
    // w    = width of arm
    // t    = thickness of arm
    // pd   = diameter of pivot shaft hole
    // pt   = thickness of pivot hub
    // hd   = diameter of roller shaft hub
    // ht   = thickness of roller shaft hub
    // sd   = shaft diameter through hub and end of arm
    // snaf = shaft nut AF size
    // snt  = shaft nut thickness
    //
    //---pt = tape_follower_pivot_t ;        
    elbow_l1 = tape_follower_elbow_l + w*0.65 ;
    elbow_l2 = l - tape_follower_elbow_l - w*0.5;
    difference() {
        union() {
            translate([0,0,t-delta])
                oval(elbow_l1, w, t) ;
            translate([0,0,t-2*delta])
               cylinder(d=w, h=pt, $fn=16) ;
            translate([l-elbow_l2,0,0])
                oval(elbow_l2, w, t) ;
            translate([l,0,0])
               cylinder(d=hd, h=ht, $fn=16) ;
        }
        // cylinder(d=sd, h=t+2*delta, $fn=16) ;
        // Shaft hole at pivot end of arm
        translate([0,0,t-2*delta]) {
            cylinder(d=sd, h=pt+2*delta, $fn=16) ;
        }
        // Countersunk hole at far end of arm
        translate([l,0,ht+delta]) {
            // countersinkZ(od, oh, sd, sh)
            countersinkZ(sd*2, ht+2*delta, sd, ht+2*delta) ;
        }
        // Nut recess at far end of arm
        translate([l,0,0]) {
            nut_recess(snaf, snt) ;
        }
    }
}

module tape_follower_arm() {
    tape_follower_arm_param(
        tape_follower_arm_l, tape_follower_arm_w, tape_follower_arm_t, 
        tape_follower_pivot_d, tape_follower_pivot_t,
        tape_follower_hub_d, tape_follower_hub_t, 
        m4, m4_nut_af, m4_slimnut_t
        ) ;    
}

module tape_follower_short_arm_param(l, w, t, pd, phd, pt, hd, ht, sd, snaf, snt) {
    // Tape follower arm, holds guide roller loosely in position where its
    // weight maintains a slight tension in the tape and helps to ensure a
    // more controlled feed onto the first roller guide.
    //
    // Lying on X-Y plane, pivot centre at origin, arm extending along X-axis.
    //
    // l    = length of arm (between shaft centres)
    // w    = width of arm
    // t    = thickness of arm
    // pd   = diameter of pivot shaft hole
    // phd  = diameter of pivot hub
    // pt   = thickness of pivot hub
    // hd   = diameter of roller shaft hub
    // ht   = thickness of roller shaft hub
    // sd   = shaft diameter through hub and end of arm
    // snaf = shaft nut AF size
    // snt  = shaft nut thickness
    //
    //// pt = tape_follower_pivot_t ;    // Thickness of pivot hub
    difference() {
        union() {
            translate([0,0,0])
                cylinder(d=phd, h=pt, $fn=16) ;
                oval(l, w, t) ;
            translate([l,0,0])
                cylinder(d=hd, h=ht, $fn=16) ;
        }
        // cylinder(d=sd, h=t+2*delta, $fn=16) ;
        // Shaft hole at pivot end of arm
        translate([0,0,-delta]) {
            cylinder(d=pd, h=pt+2*delta, $fn=16) ;
        }
        // Countersunk hole at far end of arm
        translate([l,0,-delta]) {
            // countersinkZ(od, oh, sd, sh)
            mirror([0,0,1])
                countersinkZ(sd*2, ht+2*delta, sd, ht+2*delta) ;
        }
        // Nut recess at far end of arm
        translate([l,0,ht-snt+delta]) {
            nut(snaf, snt, 0) ;
        }
    }
}

module tape_follower_short_arm_no_elbow() {
    tape_follower_short_arm_param(
        tape_follower_short_arm_l, tape_follower_arm_w, tape_follower_arm_t, 
        tape_follower_short_pivot_d, guide_roller_outer_d, tape_follower_short_pivot_t,
        tape_follower_hub_d, tape_follower_short_hub_t, 
        m4, m4_nut_af, m4_slimnut_t
        ) ;    
}

module tape_follower_short_arm() {
    tape_follower_arm_param(
        tape_follower_short_arm_l, tape_follower_arm_w, tape_follower_arm_t, 
        tape_follower_short_pivot_t, tape_follower_short_pivot_t,
        tape_follower_hub_d, tape_follower_short_hub_t, 
        m4, m4_nut_af, m4_slimnut_t
        ) ;    
}


////////////////////////////////////////////////////////////////////////////////
// Tape follower roller
////////////////////////////////////////////////////////////////////////////////

////@@@@
module tape_follower_roller_unused_() {
    od = guide_roller_outer_d+2 ;
    or = od/2 ;
    rr = guide_roller_rim_r+1 ;
    difference() {
        union() {
            roller_guide_3_spoked(
                guide_roller_shaft_d, guide_roller_hub_r,  
                rr, or,  
                guide_roller_fillet_r, guide_roller_spoke_w, 
                guide_roller_width, guide_hub_width
                ) ;
            translate([0,0,12+3.5])
                circular_platform(r=rr+clearance*4, h=6) ;
            translate([0,0,guide_roller_width-12+3.5])
                circular_platform(r=rr+clearance*4, h=6) ;
        }
        // Shaft hole with clearance for free rotation
        shaft_hole(guide_sprocket_shaft_d+1, guide_roller_width) ;
        // M4 nut cutouts:  7 AF x 3.1 thick
        // NOTE: Nuts drilled out to act as bearings
        translate([0,0,12]) {
            extended_nut_recess_with_ejection_hole(7, 3.1, od+1) ;
        }
        translate([0,0,guide_roller_width-12]) {
            extended_nut_recess_with_ejection_hole(7, 3.1, od+1) ;
        }
    }
}

// Roller design without nut cutouts, but using sleeve bearings pushed in to ends
module tape_follower_roller() {
    od = guide_roller_outer_d+2 ;
    or = od/2 ;
    rr = guide_roller_rim_r+1 ;
    difference() {
        union() {
            roller_guide_3_spoked(
                guide_roller_shaft_d+1, follower_roller_hub_r,  
                rr, or,  
                guide_roller_fillet_r, guide_roller_spoke_w, 
                guide_roller_width, follower_hub_width
                ) ;
        }
        // Sleeve holes at each end
        translate([0,0,-delta])
            shaft_hole(follower_roller_sleeve_d, follower_sleeve_len) ;
        translate([0,0,guide_roller_width-follower_sleeve_len+delta])
            shaft_hole(follower_roller_sleeve_d, follower_sleeve_len) ;
    }
}



////////////////////////////////////////////////////////////////////////////////
// Assemblies...
////////////////////////////////////////////////////////////////////////////////

module layout_reader_bridge_dovetailed() {
    // Reader bridge and support
    translate([0,spacing*0,0])
        tape_reader_bridge_dovetailed() ;
    translate([-winder_side_h/2,50,0])
        reader_bridge_side_support_dovetailed() ;
    translate([-winder_side_h/2,120,0])
        reader_bridge_side_support_dovetailed() ;
}

// ## reader-bridge
//
// translate([spacing*2, 0, 0]) layout_reader_bridge() ;
// translate([spacing*2, 0, 0]) 

// layout_reader_bridge_dovetailed() ;

////-tape_reader_bridge_dovetailed
// tape_reader_bridge_dovetailed() ;
////-reader_bridge_side_support_dovetailed
// translate([0,spacing*1,0])
//     reader_bridge_side_support_dovetailed() ;

////-tape_reader_bridge_el_wire_clip()
// translate([0,-read_w,0])
//     tape_reader_bridge_el_wire_clip() ;
// translate([0,+read_w,0])
//     tape_reader_bridge_el_wire_clip() ;




////-reader_bridge_side_support_dovetailed() ;
// reader_bridge_side_support_dovetailed() ;

////-reader_bridge_side_support_dovetailed-2off() ;
//   NOTE: this caused some printing problems; 
//         printing as two single parts worked better.
//         Possibly exacerbated by cold room (~15C) when printing?
// translate([-winder_side_h-40,0,0])
//     reader_bridge_side_support_dovetailed() ;
// translate([+winder_side_h+40,0,0])
//     mirror([1,0,0]) reader_bridge_side_support_dovetailed() ;

////-sprocket_tape_guide
//sprocket_tape_guide() ;
// To see inside...
// difference() { sprocket_tape_guide() ; cube(size=[20,20,160]) ; }

////-roller_tape_guide
//roller_tape_guide() ;
// To see inside...
//difference() { roller_tape_guide() ; cube(size=[20,20,160]) ; }

////-tape_follower_roller
// tape_follower_roller() ;
// To see inside...
// difference() { tape_follower_roller() ; cube(size=[20,20,160]) ; }

////-tape_follower_short_arm_4off
// translate([-20,-40,0]) tape_follower_short_arm_no_elbow() ;
// translate([-20,-20,0]) tape_follower_short_arm_no_elbow() ;
// translate([20,-40,0]) tape_follower_short_arm_no_elbow() ;
// translate([20,-20,0]) tape_follower_short_arm_no_elbow() ;

////-reader-bridge-side-supports-and-follower-arms()
// for (i=[0,1]) {
//     rotate([0,0,90+i*180]) {
//         translate([-read_h*0.65,read_side_base_w*0.75,0]) {
//             reader_bridge_side_support_dovetailed() ;
//             translate([40, 40, 0]) tape_follower_short_arm_no_elbow() ;    
//         }
//     }
// }


////-tape_decoder_platform_dovetailed
// translate([0,80,0]) tape_decoder_platform_dovetailed() ;
////-tape_decoder_scale
// Rotate onto back for printing...
// rotate([90,0,0]) tape_decoder_scale() ;



