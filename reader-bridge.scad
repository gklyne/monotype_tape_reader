// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;

module layout_reader_bridge() {
    // Reader bridge and support
    translate([
    0,1*spacing,0])
        tape_reader_bridge() ;
    translate([-winder_side_h/2,spacing*2,0])
        read_side_support() ;
    translate([-winder_side_h/2,3*spacing,0])
        read_side_support() ;
}

module layout_reader_bridge_dovetailed() {
    // Reader bridge and support
    translate([
    0,1*spacing,0])
        tape_reader_bridge_dovetailed() ;
    translate([-winder_side_h/2,spacing*2,0])
        read_side_support_dovetailed() ;
    translate([-winder_side_h/2,3*spacing,0])
        read_side_support_dovetailed() ;
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

module read_side_support_dovetailed() {
    difference() {
        read_side_support() ;
        translate([0,0,read_side_t])
            rotate([0,-90,0])
                dovetail_socket_cutout(read_side_t, read_w-3, read_w-2, read_side_apex_h) ;
    }
}

// translate([spacing*2, 0, 0]) layout_reader_bridge() ;
// translate([spacing*2, 0, 0]) 
    layout_reader_bridge_dovetailed() ;
// tape_reader_bridge() ;
// tape_reader_bridge_dovetailed() ;
// translate([0,spacing,0])
//     read_side_support_dovetailed() ;





