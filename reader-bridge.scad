// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;


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
        translate([0,0,read_l/2+guide_tb/2])
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
                // rotate([0,0,82])  tension_bar() ;     // Angle determined by trial/error :(
                // rotate([0,0,-82]) tension_bar() ;
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

module tape_reader_bridge_dovetailed() {
    module bridge_dovetail_cutout() {
        translate([-read_total_l/2+read_side_t,0,0])
            dovetail_tongue_cutout(
                read_side_t, read_w-3, read_w-2, read_side_apex_w, read_side_apex_h
        ) ;
    }
    difference() {
        tape_reader_bridge_with_guides() ;
        bridge_dovetail_cutout() ;
        mirror(v=[1, 0, 0]) bridge_dovetail_cutout() ;
    }
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
            rr1 = or + 1 ;      // Rim end ..
            rw1 = 0.2 ;
            rr2 = or + 0.25 ;    // Rim bevel ..
            rw2 = 0.6 ;
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
            shaft_middle_cutout(rr-fr, gow*0.45) ;
        translate([0,0,-delta])
            spoked_wheel_cutouts(hr, rr, fr, gow+2*delta, 3, sw) ;
    }
} ;


// Generate part 
//

guide_sprocket_fillet_r = 1.5 ;  
guide_sprocket_spoke_w  = 2 ;

guide_sprocket_dia      = 22 ;
guide_sprocket_shaft_d  = m4 ;
guide_sprocket_hub_r    = m4 ;
guide_sprocket_rim_r    = guide_sprocket_dia/2 - 1.5 ;
guide_sprocket_width    = mt_overall_width + 2.5 ;
guide_sprocket_off      = 1 ;       // Offset from side (standoff hub thickness)

// Positioning...
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
        // M4 nut cutouts:  7 AF x 3.1 thick
        translate([0,0,12]) {
            extended_nut_recess_with_ejection_hole(7, 3.1, guide_sprocket_dia) ;
        }
        translate([0,0,guide_sprocket_width-12]) {
            extended_nut_recess_with_ejection_hole(7, 3.1, guide_sprocket_dia) ;
        }
        shaft_hole(guide_sprocket_shaft_d, guide_sprocket_width) ;
    }
}

sprocket_tape_guide() ;

////////////////////////////////////////////////////////////////////////////////
// Roller tape guide
////////////////////////////////////////////////////////////////////////////////
//
// The purpose of this guide is to keep the tape wrapped around the sprocket guide.
// Implemented as roller to reduce friction.
//

module roller_guide_3_spoked(sd, hr, rr, or, fr, sw, gow) {
    // 3-spoked roller tape guide, end on X-Y plane, centred on origin.
    //
    // sd     = shaft diameter
    // hr     = hub radius
    // rr     = inner rim radius
    // or     = outer radius
    // fr     = fillet radius of spoke cutout
    // sw     = spoke width
    // gow    = overall width of guide
    //

    difference() {
        union() {
            wheel(or+delta, gow) ;
            rr1 = or + 1 ;          // Rim end ..
            rw1 = 0.2 ;
            rr2 = or + 0.25 ;       // Rim bevel ..
            rw2 = 0.6 ;
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
            shaft_middle_cutout(rr-fr, gow*0.6) ;
        translate([0,0,-delta])
            spoked_wheel_cutouts(hr, rr, fr, gow+2*delta, 3, sw) ;
    }
} ;

guide_roller_fillet_r   = 0.5 ;  
guide_roller_spoke_w    = 1.5 ;

guide_roller_outer_d    = 14 ;
guide_roller_shaft_d    = guide_sprocket_shaft_d ;
guide_roller_hub_r      = guide_roller_shaft_d ;
guide_roller_rim_r      = guide_roller_outer_d/2 - 0.8 ;
guide_roller_width      = mt_overall_width + 2.5 ;
guide_roller_off        = guide_sprocket_off ;

guide_roller_centre_x   = guide_sprocket_ht_off*1.6 ;
guide_roller_centre_y   = guide_sprocket_sep/2 + guide_sprocket_dia*0.5 + guide_roller_outer_d*0.6 ;

module roller_tape_guide() {
    or = guide_roller_outer_d/2 ;
    difference() {
        union() {
            roller_guide_3_spoked(
                guide_roller_shaft_d, guide_roller_hub_r,  
                guide_roller_rim_r, or,  
                guide_roller_fillet_r, guide_roller_spoke_w, 
                guide_roller_width
                ) ;
            translate([0,0,12+3.5])
                circular_platform(r=guide_roller_rim_r+clearance*4, h=6) ;
            translate([0,0,guide_roller_width-12+3.5])
                circular_platform(r=guide_roller_rim_r+clearance*4, h=6) ;
        }
        // M4 nut cutouts:  7 AF x 3.1 thick
        translate([0,0,12]) {
            // shaft_nut_cutout(7, 3.1, 8, 4, or) ;
            extended_nut_recess_with_ejection_hole(7, 3.1, guide_roller_outer_d+1) ;
        }
        translate([0,0,guide_roller_width-12]) {
            // shaft_nut_cutout(7, 3.1, 8, 4, or) ;
            extended_nut_recess_with_ejection_hole(7, 3.1, guide_roller_outer_d+1) ;
        }
        shaft_hole(guide_sprocket_shaft_d, guide_roller_width) ;
    }
}

// Generate part 
// roller_tape_guide() ;
// difference() {roller_tape_guide() ; cube(size=[20,20,160]) ;}

////////////////////////////////////////////////////////////////////////////////
// Tape reader bridge supports
////////////////////////////////////////////////////////////////////////////////

module read_side_support() {
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
            cylinder(d=guide_sprocket_shaft_d+2, h=read_side_t+guide_sprocket_off) ;
        translate([guide_sprocket_ht_off, -guide_sprocket_sep/2, 0])
            cylinder(d=guide_sprocket_shaft_d+2, h=read_side_t+guide_sprocket_off) ;
    }

    module side_guide_roller_arms(side) {
        // Extend side arms to include pivot for roller
        // oval_xy(x1, y1, x2, y2, d, h)
        oval_xy(
            guide_roller_centre_x, guide_roller_centre_y*side, 
            guide_sprocket_ht_off, (guide_sprocket_sep/2)*side,
            guide_roller_outer_d, winder_side_t
        ) ;
        translate([guide_roller_centre_x, guide_roller_centre_y*side, 0])
            cylinder(d=guide_roller_shaft_d+2, h=read_side_t+guide_sprocket_off) ;
    }

    // Reader side support assembly...
    difference() {
        union() {
            side_profile() ;
            side_guide_sprocket_arms() ;
            side_guide_roller_arms(+1) ;
            side_guide_roller_arms(-1) ;
            side_base() ;
            web_side = read_side_base_t - read_side_t ;
            web_xz(read_h-read_side_t, -read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
            web_xz(read_h-read_side_t,  read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
        } ;
        // Shaft holes for guide sprockets
        translate([guide_sprocket_ht_off, guide_sprocket_sep/2, 0])
            shaft_hole(guide_sprocket_shaft_d, read_side_t+guide_sprocket_off) ;
        translate([guide_sprocket_ht_off, -guide_sprocket_sep/2, 0])
            shaft_hole(guide_sprocket_shaft_d, read_side_t+guide_sprocket_off) ;
        // Shaft holes for guide rollers
        translate([guide_roller_centre_x, guide_roller_centre_y, 0])
            shaft_hole(guide_sprocket_shaft_d, read_side_t+guide_sprocket_off) ;
        translate([guide_roller_centre_x, -guide_roller_centre_y, 0])
            shaft_hole(guide_sprocket_shaft_d, read_side_t+guide_sprocket_off) ;
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

} // module read_side_support

module read_side_support_dovetailed() {
    difference() {
        read_side_support() ;
        translate([0,0,read_side_t])
            rotate([0,-90,0])
                dovetail_socket_cutout(read_side_t, read_w-3, read_w-2, read_side_apex_h) ;
    }
}

// read_side_support() ;
// read_side_support_dovetailed() ;

////////////////////////////////////////////////////////////////////////////////
// Assemblies...
////////////////////////////////////////////////////////////////////////////////

module layout_reader_bridge() {
    // Reader bridge and support
    translate([
    0,spacing*1,0])
        tape_reader_bridge() ;
    translate([-winder_side_h/2,spacing*1.5,0])
        read_side_support() ;
    translate([-winder_side_h/2,spacing*2,0])
        read_side_support() ;
}

module layout_reader_bridge_dovetailed() {
    // Reader bridge and support
    translate([0,spacing*0,0])
        tape_reader_bridge_dovetailed() ;
    translate([-winder_side_h/2,50,0])
        read_side_support_dovetailed() ;
    translate([-winder_side_h/2,120,0])
        read_side_support_dovetailed() ;
}

// ## reader-bridge
//
// translate([spacing*2, 0, 0]) layout_reader_bridge() ;
// translate([spacing*2, 0, 0]) 

// layout_reader_bridge_dovetailed() ;

// tape_reader_bridge() ;
// tape_reader_bridge_dovetailed() ;
// translate([0,spacing,0])
//     read_side_support_dovetailed() ;





