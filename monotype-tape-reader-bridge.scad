// monotype-tape-reader-winder.scad

include <monotype-tape-reader-defs.scad> ;

use <monotype-tape-reader.scad> ;

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

translate([spacing*2, 0, 0]) layout_reader_bridge() ;

