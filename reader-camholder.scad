// monotype-tape-reader-winder.scad

include <monotype-tape-reader-defs.scad> ;

use <monotype-tape-reader.scad> ;

module layout_reader_camera_holder() {
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

translate([spacing*2, spacing*1, 0]) layout_reader_camera_holder() ;

