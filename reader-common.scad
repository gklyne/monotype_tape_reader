include <reader-defs.scad> ;
include <common-components.scad> ;

// Parts for holding phone camera

module old_phone_holder_rod_fixing_arm() {
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

module old_phone_holder_rod_fixing_plate() {
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

module old_phone_holder_rod_anti_rotation_plate() {
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

module old_phone_camera_holder() {
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
    
 module old_phone_holder_rod_support() {
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

// Assemblies

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

