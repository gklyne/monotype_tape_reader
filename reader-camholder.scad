// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;

module layout_reader_camera_holder() {
    // Phone/camera holder
    translate([-spacing, spacing*0, 0])
        phone_camera_holder() ;
    translate([spacing, spacing*0, 0])
        phone_camera_holder() ;
    translate([-spacing*1.5, spacing*1, 0])
        phone_holder_rod_support() ;    
    translate([spacing*0, spacing*1, 0])
        phone_holder_rod_support() ;    
    // translate([0,2*spacing,0])
    //     phone_holder_rod_fixing_arm() ;
    translate([-spacing*1.5,spacing*2,0])
        phone_holder_rod_fixing_plate() ;
    translate([+spacing*0,spacing*2,0])
        phone_holder_rod_fixing_plate() ;
}

translate([spacing*2, spacing*1, 0]) layout_reader_camera_holder() ;

// phone_holder_rod_fixing_plate() ;

// phone_holder_rod_support() ;    
