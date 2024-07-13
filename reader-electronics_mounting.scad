// reader-electronics_mounting.scad
//
// Define mounting elements that can be merged for different requirements.
//

include <reader-defs.scad> ;

use <reader-common.scad> ;
use <common-components.scad> ;

////////////////////////////////////////////////////////////////////////////////
// Definitions
////////////////////////////////////////////////////////////////////////////////


pizero_pcb_len          = 65 ;
pizero_pcb_wid          = 30 ;
pizero_mount_holes_len  = 58 ;
pizero_mount_holes_wid  = 23 ;

pizero_mountplate_len   = 72 ;
pizero_mountplate_wid   = 35 ;
pizero_mountplate_len_2 = 88 ;
pizero_mountplate_wid_2 = 12 ;
pizero_mountplate_r     = 3 ;               // Corner radius
pizero_mount_hole_d     = m2_5 ;            // Mounting screw diameter
pizero_mount_hole_af    = m2_5_nut_af ;     // Mount nut recess AF
pizero_mount_hole_nut_t = m2_5_nut_t ;      // Mount nut recess thickness
pizero_mount_stud_h     = 7 ;               // Overall height of mounting stud
pizero_mount_stud_d     = 4.5 ;             // Diameter (top) of mounting stud
pizero_mount_stud_h_2   = m2_5_nut_t*2.2 ;  // Shoulder height of mounting stud
pizero_mount_stud_d_2   = m2_5_nut_af*1.6 ; // Shoulder diameter of mounting stud
pizero_boxwall_t        = 1.5 ;

// @@@@
// function rod_clamp_screw_pitch(rod_d)   = rod_d*2 ;
// function rod_clamp_len(rod_d)           = rod_d*3.2 ;
// function rod_clamp_wid(rod_d)           = rod_d*1.5 ;
// 
// mount_rail_rod_p        = 89*2 ;    // Distance between support rods
// mount_rail_len          = mount_rail_rod_p + rod_clamp_len(8) ;
// mount_rail_wid          = rod_clamp_wid(8) ;
// mount_rail_t            = 5 ;
// mount_rail_hole_x       = [0, 8, 16, 24, 32, 40, 48, 56, 64, 72] ;
// mount_rail_clamp_x      = [mount_rail_rod_p/2-8, mount_rail_rod_p/2+8] ;
// @@@@

////////////////////////////////////////////////////////////////////////////////
// Raspberry Pi zero 2 mounting plate
////////////////////////////////////////////////////////////////////////////////

// Mounting plate for Raspberry Pi Zero
//
// Lies on X-Y plane, centred about origin
//

module pizero_mount_plate_blank() {
    half_l = pizero_mountplate_len / 2 ;
    half_w = pizero_mountplate_wid / 2 ;
    rounded_rectangle_plate(
        -half_l,-half_w,half_l,half_w,
        pizero_mountplate_r,pizero_boxwall_t
        ) ;
    half_l_2 = pizero_mountplate_len_2 / 2 ;
    half_w_2 = pizero_mountplate_wid_2 / 2 ;
    rounded_rectangle_plate(
        -half_l_2,-half_w_2,half_l_2,half_w_2,
        pizero_mountplate_r,pizero_boxwall_t
        ) ;
    half_px = pizero_mount_holes_len/2 ;
    half_py = pizero_mount_holes_wid/2 ;
    for (x = [-half_px,half_px]) {
        for (y = [-half_py,half_py]) {
            translate([x,y,0]) {
                cylinder(d=pizero_mount_stud_d, h=pizero_mount_stud_h, $fn=12) ;
                cylinder(d=pizero_mount_stud_d_2, h=pizero_mount_stud_h_2, $fn=12) ;
            }
        }
    }
}


module pizero_mount_holes() {
    half_px = pizero_mount_holes_len/2 ;
    half_py = pizero_mount_holes_wid/2 ;
    for (x = [-half_px,half_px]) {
        for (y = [-half_py,half_py]) {
            translate([x,y,-delta]) {
                // mirror([0,0,1])
                //     countersinkZ(
                //         pizero_mount_hole_d*2, pizero_mount_stud_h+2*delta, 
                //         pizero_mount_hole_d, pizero_mount_stud_h+2*delta) ;
                cylinder(d=pizero_mount_hole_d, h=pizero_mount_stud_h+2*delta, $fn=12) ;
                nut_recess(pizero_mount_hole_af, pizero_mount_hole_nut_t) ;
            }
        }
    }
}


module pizero_rail_mount_holes() {
    hole_x = [-24, -8, 8, 24] ;
    hole_y = [-16, 0, 16] ;
    for (x = hole_x)
        for (y = hole_y)
            translate([x,y,-delta])
                cylinder(d=m4, h=pizero_boxwall_t+2*delta, $fn=16) ;
    hole_x_2 = [-40, -24, -8, 8, 24, 40] ;
    hole_y_2 = [0] ;
    for (x = hole_x_2)
        for (y = hole_y_2)
            translate([x,y,-delta])
                cylinder(d=m4, h=pizero_boxwall_t+2*delta, $fn=16) ;
}


module pizero_mount_cup_washer() {
    difference() {
        cylinder(d=pizero_mount_hole_d*2, h=pizero_mount_hole_d, $fn=12) ;
        translate([0,0,pizero_mount_hole_d+delta])
            countersinkZ(
                pizero_mount_hole_d*2, pizero_mount_hole_d+2*delta, 
                pizero_mount_hole_d, pizero_mount_hole_d+2*delta) ;

    }    
}


module pizero_rail_mount_plate() {
    difference() {
        pizero_mount_plate_blank() ;
        pizero_mount_holes() ;
        pizero_rail_mount_holes() ;
    }
    for ( i = [1,2,3,4] ) {
        translate([-pizero_mountplate_len_2*0.55 + i*20, 30, 0])
            pizero_mount_cup_washer() ;
}}


////-pizero_rail_mount_plate()
pizero_rail_mount_plate() ;

for ( i = [1,2,3,4] ) {
    translate([0, 25, 0])
        pizero_mount_cup_washer() ;
}


////////////////////////////////////////////////////////////////////////////////
// Rod mounting clamp
////////////////////////////////////////////////////////////////////////////////

// Mounting clamp for attaching to M8 rod
//
// Lying on X-Y plane, centred on origin

module rod_mounting_clamp(rod_d, clamp_screw_d, clamp_nut_af, clamp_nut_t) {
    cutout_d        = rod_d ;
    clamp_l         = rod_clamp_len(rod_d) ;
    clamp_w         = rod_clamp_wid(rod_d) ;
    clamp_h         = rod_d ;
    screw_x         = rod_clamp_screw_pitch(rod_d)/2 ;
    difference() {
        union() {
            translate([-clamp_l/2,-clamp_w/2,0])
                cube(size=[clamp_l,clamp_w,clamp_h]) ;
        }
        // Cutout for rod
        translate([0,0,clamp_h])
            rotate([90,0,0])
                cylinder(d=cutout_d, h=clamp_w+2*delta, center=true, $fn=16) ;
        // Cutouts for tightening screws
        for ( x=[-screw_x, screw_x] ) {
            translate([x, 0, -delta]) {
                hex_screw_recess_Z(clamp_screw_d, clamp_h+2*delta, clamp_nut_af, clamp_nut_t) ;
                nut_recess(clamp_nut_af, clamp_nut_t)  ;
            }
        }
    }
}

////-rod_mounting_clamp()
// for (y=[-30,30])
//     for (x=[-20,20])
//         translate([x,y,0])
//             rod_mounting_clamp(8,m4,m4_nut_af,m4_nut_t) ;


////////////////////////////////////////////////////////////////////////////////
// electronics_mount_rail
////////////////////////////////////////////////////////////////////////////////

// Mounting rail for electronics
//
// Lying on X-Y plane, centred on origin

module electronics_mount_rail() {
    difference() {
        union() {
            translate([-mount_rail_len/2, -mount_rail_wid/2, 0])
                cube(size=[mount_rail_len, mount_rail_wid, mount_rail_t]) ;
        }
        for (x = mount_rail_hole_x) {
            translate([-x, 0, mount_rail_t+delta])
                mirror([0,0,1])
                    hex_screw_recess_Z(m4, mount_rail_t+2*delta, m4_nut_af, m4_nut_t) ;
            translate([+x, 0, mount_rail_t+delta])
                mirror([0,0,1])
                    hex_screw_recess_Z(m4, mount_rail_t+2*delta, m4_nut_af, m4_nut_t) ;
        }
        for (x = mount_rail_clamp_x) {
            translate([-x, 0, -delta])
                cylinder(d=m4, h=mount_rail_t+2*delta, $fn=16) ;
            translate([+x, 0, -delta])
                cylinder(d=m4, h=mount_rail_t+2*delta, $fn=16) ;
        }
    }
}

////-electronics_mount_rail()
// translate([0,50,0])
//     electronics_mount_rail() ;

////////////////////////////////////////////////////////////////////////////////
// xxxx
////////////////////////////////////////////////////////////////////////////////