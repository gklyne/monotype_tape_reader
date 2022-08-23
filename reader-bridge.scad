// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;

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
    translate([-winder_side_h/2,spacing*1,0])
        read_side_support_dovetailed() ;
    translate([-winder_side_h/2,spacing*2,0])
        read_side_support_dovetailed() ;
}

// Tape reader bridge (with lighting groove)

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

// Tape reader bridge supports

guide_sprocket_dia     = 24 ;
guide_sprocket_sep     = guide_sprocket_dia + read_w ;
guide_sprocket_ht_off  = guide_sprocket_dia*0.6 ;
guide_sprocket_shaft_d = 4 ;
guide_sprocket_off     = 1 ;
winder_shaft_height    = (read_h+read_side_base_t)*0.4 ;

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
        translate([guide_sprocket_ht_off, guide_sprocket_sep/2, 0])
            cylinder(d=guide_sprocket_shaft_d+2, h=read_side_t+guide_sprocket_off) ;
        translate([guide_sprocket_ht_off, -guide_sprocket_sep/2, 0])
            cylinder(d=guide_sprocket_shaft_d+2, h=read_side_t+guide_sprocket_off) ;
    }

    // Reader side support assembly...
    difference() {
        union() {
            side_profile() ;
            side_guide_sprocket_arms() ;
            side_base() ;
            web_side = read_side_base_t - read_side_t ;
            web_xz(read_h-read_side_t, -read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
            web_xz(read_h-read_side_t,  read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
        } ;
        union() {
            // shaft_hole(shaft_d, read_side_t) ;
            translate([read_h-winder_shaft_height,0,0])
                shaft_hole(shaft_d, read_side_t) ;
            translate([read_h-read_side_base_t-read_side_t, +0.25*read_side_base_w,0])
                shaft_hole(read_side_peg_d, read_side_t) ;
            translate([read_h-read_side_base_t-read_side_t, -0.25*read_side_base_w,0])
                shaft_hole(read_side_peg_d, read_side_t) ;
            translate([guide_sprocket_ht_off, guide_sprocket_sep/2, 0])
                shaft_hole(guide_sprocket_shaft_d, read_side_t+guide_sprocket_off) ;
            translate([guide_sprocket_ht_off, -guide_sprocket_sep/2, 0])
                shaft_hole(guide_sprocket_shaft_d, read_side_t+guide_sprocket_off) ;
        } ;
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

// ## reader-bridge
//
// translate([spacing*2, 0, 0]) layout_reader_bridge() ;
// translate([spacing*2, 0, 0]) 

layout_reader_bridge_dovetailed() ;

// tape_reader_bridge() ;
// tape_reader_bridge_dovetailed() ;
// translate([0,spacing,0])
//     read_side_support_dovetailed() ;





