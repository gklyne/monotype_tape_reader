// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;


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
    hole_x = hold_fix_o_x ;
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
    slot_x1 = hold_slot_o_x1 ;
    slot_x2 = hold_slot_o_x2 ;
    slot_y  = hold_fix_plate_w/2 + hold_fix_o_y ;
    //neck_x  = (hold_slot_o_x1 + hold_slot_o_x2)/2 ;
    //neck_x  = hold_slot_o_x1 + hold_fix_plate_w/4 ;
    neck_x  = hold_fix_plate_w*0.75 ;
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
        shaft_slot(slot_x1, slot_x2, slot_y, hold_fix_rod_d, hold_fix_t) ;
        translate([hold_fix_rod_d, hold_fix_rod_d+hold_fix_p, 0])
            shaft_hole(hold_fix_d, hold_fix_rod_d ) ;
        translate([hold_fix_rod_d, hold_fix_rod_d, 0])
            shaft_hole(hold_fix_d, hold_fix_t ) ;
    }
}

module phone_holder_rod_adjusting_plate() {
    // NOTE: all holes are centred rod diameter from edges
    slot_x1 = hold_short_slot_o_x1 ;
    slot_x2 = hold_short_slot_o_x2 ;
    slot_y  = hold_fix_plate_w/2 + hold_fix_o_y ;
    //neck_x  = (hold_short_slot_o_x1 + hold_short_slot_o_x2)/2 ;
    // neck_x  = hold_short_slot_o_x1 + hold_fix_plate_w/4 ;
    neck_x  = hold_fix_plate_w*0.75 ;
    module plate_outline() {
        linear_extrude(height=hold_fix_t)
            {
            polygon(
                points=[
                    [0,0], 
                    [hold_fix_rod_d*2, 0], 
                    [neck_x,slot_y-hold_fix_rod_d],
                    [slot_x2, slot_y-hold_fix_rod_d], 
                    [slot_x2, slot_y+hold_fix_rod_d],
                    [neck_x,slot_y+hold_fix_rod_d],
                    [hold_fix_rod_d*2, hold_fix_plate_w], 
                    [0, hold_fix_plate_w]
                    ],
                paths=[[0,1,2,3,4,5,6,7,0]]
                ) ;
            }
        translate([hold_short_slot_o_x2, slot_y, 0])
            cylinder(h=hold_fix_t, r=hold_fix_rod_d, center=false) ;
        }
    difference() {
        plate_outline() ;
        shaft_slot(hold_short_slot_o_x1, hold_short_slot_o_x2, slot_y, hold_fix_rod_d, hold_fix_t) ;
        translate([hold_fix_rod_d, hold_fix_rod_d+hold_fix_p, 0])
            shaft_hole(hold_fix_d, hold_fix_rod_d ) ;
        translate([hold_fix_rod_d, hold_fix_rod_d, 0])
            shaft_hole(hold_fix_d, hold_fix_t ) ;
    }
}

module phone_camera_holder() {
    module phone_holder_base() {
        // Centre baseline on origin, extend X axis, lying on Z=0 plane
        difference() {
            linear_extrude(height=hold_base_t+hold_base_offset)
                polygon(
                    points=[
                        [-hold_base_l1/2,0], [+hold_base_l1/2,0],
                        [-hold_base_l2/2,hold_base_w], [+hold_base_l2/2,hold_base_w]
                        ],
                    paths=[[0,2,3,1,0]]
                    ) ;
            translate([-hold_base_l1/2,hold_side_t1,hold_base_t+delta]) {
                cube(size=[hold_base_l1, hold_base_w, hold_base_offset]) ;
                }
            }
        } ;


    module phone_holder_side() {
        // Thinner edge on Y axis, centred on X axis
        rotate([0,-90,0])
            linear_extrude(height=hold_side_l, center=true)
                {
                //
                //    h   +          +
                //
                //               +
                //               +
                //              +
                //              +
                //               +
                //
                //   -d   +      +
                //        0      t1  t2
                //
                polygon(
                    points=[
                        [0, -delta], 
                        [0, hold_side_h],
                        [hold_side_t2,hold_side_h],
                        [hold_side_t1,hold_side_h*0.8],
                        [hold_side_t1,hold_side_h*0.5+2],  // V-groove for phone buttons
                        [hold_side_t1-1.25,hold_side_h*0.5+1.25],
                        [hold_side_t1-1.25,hold_side_h*0.5-1.25],
                        [hold_side_t1,hold_side_h*0.5-2],
                        [hold_side_t1,-delta],
                        ],
                    paths=[[0,1,2,3,4,5,6,7,8,0]]
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
            translate([-hold_fix_p/2,hold_side_h,hold_side_t1/2])
                rotate([90,0,0]) {
                    shaft_hole(hold_fix_d, hold_base_t+hold_side_h+hold_base_offset);
                    nut_recess(m4_nut_af, m4_nut_t) ;
                }
            translate([+hold_fix_p/2,hold_side_h,hold_side_t1/2])
                rotate([90,0,0]) {
                    shaft_hole(hold_fix_d, hold_base_t+hold_side_h+hold_base_offset);
                    nut_recess(m4_nut_af, m4_nut_t) ;
                }
            } ;
        }
    }

////-phone_camera_holder
// phone_camera_holder() ;


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
        holder_wdth = hold_fix_rod_d*2.4 ;
        holder_dpth = rod_support_base_t ;
        holder_hght = holder_dpth - hold_fix_rod_d - 0*holder_wdth/2 ;
        recess_t    = rod_support_nut_t ;
        difference() {
            union() {               
                translate([0,0,holder_hght/2])
                    cube(size=[rod_support_block_t, holder_wdth, holder_hght], center=true) ;
                translate([0,0,holder_hght])
                    rotate([0,90,0])
                        cylinder(d=holder_wdth,h=rod_support_block_t, center=true) ;
            }
            translate([-rod_support_block_t/2,0,holder_hght]) {
                rotate([0,90,0])
                    shaft_hole(hold_fix_rod_d, rod_support_block_t+2*delta) ;
            }
            translate([rod_support_block_t/2-recess_t+delta,0,holder_hght])
                rotate([0,90,0]) {
                    nut_recess_Z(rod_support_nut_af, recess_t) ;
                    translate([-rod_support_nut_af/2,0,recess_t/2])
                        cube(size=[rod_support_nut_af, rod_support_nut_af, recess_t],
                            center=true
                        ) ;

                }
            // Cutaway for mounting screw head
            translate([-rod_support_block_t/2-delta,0,holder_hght]) {
                translate([0,rod_support_base_w*0.25,0]) {
                    rotate([0,90,0])
                        cylinder(d1=4, d2=6, h=rod_support_block_t+2*delta) ;
                }
                translate([0,-rod_support_base_w*0.25,0]) {
                    rotate([0,90,0])
                        cylinder(d1=5, d2=7, h=rod_support_block_t+2*delta) ;
                }
            }
        }
    }
    union() {
        side_profile() ;
        side_base() ;
        translate([rod_support_block_t/2,0,0])
            rod_holder() ;
        translate([rod_support_h*0.75,0,0])
            rod_holder() ;
        web_side = rod_support_base_t - rod_support_t ;
        web_xz(rod_support_h-rod_support_t, -rod_support_base_w/2, rod_support_t, -web_side, web_side, rod_support_t) ;
        web_xz(rod_support_h-rod_support_t,  rod_support_base_w/2, rod_support_t, -web_side, web_side, rod_support_t) ;
    } ;
}


// Layout all parts

module layout_reader_camera_holder() {
    // Phone/camera holder
    translate([-spacing*0.6, -spacing*0.3, 0])
        phone_camera_holder() ;
    translate([-spacing*0.6, spacing*0.3, 0])
        phone_camera_holder() ;
    translate([-spacing*1, spacing*1, 0])
        phone_holder_rod_support() ;    
    translate([spacing*0, spacing*1, 0])
        phone_holder_rod_support() ;    
    // translate([0,2*spacing,0])
    //     phone_holder_rod_fixing_arm() ;
    // translate([-spacing*1.5,spacing*2,0])
    //     phone_holder_rod_fixing_plate() ;
    translate([-spacing*0,spacing*0.1,0])
        phone_holder_rod_anti_rotation_plate() ;
    translate([+spacing*0,-spacing*0.5,0])
        phone_holder_rod_adjusting_plate() ;
    // translate([-spacing*0,spacing*1.2,0])
    //     phone_holder_rod_fixing_plate() ;
}

////-layout_reader_camera_holder
//translate([spacing*2, spacing*1, 0]) 
    layout_reader_camera_holder() ;

// phone_holder_rod_fixing_plate() ;

// phone_holder_rod_anti_rotation_plate() ;

// shaft_slot(hold_slot_o_x1, hold_slot_o_x2, 75, hold_fix_rod_d, hold_fix_t) ;

// phone_holder_rod_support() ;    
