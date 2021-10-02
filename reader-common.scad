include <reader-defs.scad> ;

// Utilities

module oval(x, d, h) {
    cylinder(d=d, h=h) ;
    translate([x,0,0])
        cylinder(d=d, h=h) ;
    translate([x/2,0,h/2])
        cube(size=[x, d, h], center=true) ;
}

module shaft_hole(d, l) {
        translate([0,0,-delta]) {
            cylinder(d=d, h=l+delta*2) ;
        };
}

module shaft_slot(x1, x2, y, d, h) {
    translate([x1,y,-delta])
        oval(x2-x1, d, h+2*delta) ;    
}
  
module nut_recess(af, t)  {
    od = af * 2 / sqrt(3) ; // Diameter
    translate([0,0,-delta]) {
        cylinder(d=od, h=t+delta, $fn=6) ;
    }
}

module web_base(w_x, w_y, w_t) {
    // Web with corner on origin, extending along +ve X and Y axes
    // Slight negative x- and y- overlap forces merge with existing shape
    linear_extrude(height=w_t, center=true) {
        polygon(
            points=[
                [-delta, -delta], [-delta, w_y],
                [0, w_y], [w_x, 0],
                [w_x, 0], [w_x, -delta],
                ],
            paths=[[0,1,2,3,4,5,0]]
            ) ;
    }
}

module web_oriented(w_x, w_y, w_t) {
    // Web with corner on origin, extending along +ve or -ve X and Y axes
    if (w_x >= 0)
        {
        if (w_y >= 0)
            {
                web_base(w_x, w_y, w_t) ;
            }
        else // w_y < 0
            {
                // flip through x-z plane: reverse y-axis
                mirror(v=[0,1,0]) web_base(w_x, -w_y, w_t) ;
            }
        }
    else // w_x < 0
        {
        if (w_y >= 0)
            {
                // flip through y-z plane: reverse x-axis
                mirror(v=[1,0,0]) web_base(-w_x, w_y, w_t) ;
            }
        else // w_y < 0
            {
                // flip through x-z and y-z planes: reverse x- and y- axes
                mirror(v=[1,1,0]) web_base(-w_x, -w_y, w_t) ;
            }
        }
 }

module web_xz(x, y, z, w_x, w_z, w_t) {
    // Web in X-Z plane, outer corner at x, y, z
    if (y >= 0) {
        // Rotate around X maps Y to Z, Z to -Y (???)
        translate([x, y - w_t/2, z]) rotate([90,0,0]) web_oriented(w_x, w_z, w_t) ;
    }
    else { // y < 0
        translate([x, y + w_t/2, z]) rotate([90,0,0]) web_oriented(w_x, w_z, w_t) ;
    }
}

module dovetail_key(l, ws, we, t) {
    // Shape for dovetail key, shoulder centre on origin, key extending along -X axis
    // lying on X-Y plane.
    //
    // l  = length from shoulder to end of dovetail
    // ws = width of key at shoulder
    // we = width of key at end
    // t  = thickness of key
    //
    linear_extrude(height=t, center=false) {
        polygon(
            points=[
                [0, ws/2],  [0, -ws/2],
                [-l, we/2], [-l, -we/2]
                ],
            paths=[[0,2,3,1,0]]
            ) ;
    }
}

module dovetail_socket_cutout(l, ws, we, t) {
    // Shape to cutout dovetail socket in piece lying on X-Y plane,
    // with key shoulder centre on origin and piece extending in -X direction
    //
    // (Cutout piece extends below and above Z axis)
    //
    // l  = length from shoulder to end of dovetail
    // ws = width of key at shoulder
    // we = width of key at end
    // t  = thickness of key piece
    //
    translate([+delta,0,-delta]) {
        dovetail_key(l+delta*2, ws, we, t+delta*2) ;
    }
}

module dovetail_tongue_cutout(l, ws, we, wp, t) {
    // Shape to cutout dovetail tongue in end of piece lying on X-Y plane,
    // with key end centre on origin and extending in +X direction
    //
    // (Cutout piece extends below and above Z axis)
    //
    // l  = length from shoulder to end of dovetail
    // ws = width of key at shoulder
    // we = width of key at end
    // wp = width of piece behind tongue
    // t  = thickness of piece with tongue
    //
    difference() {
        translate([-l/2,0,t/2]) {
            cube(size=[l+delta, wp+delta, t+delta], center=true) ;
        } ;
        dovetail_socket_cutout(l+delta, ws, we, t+delta) ;
    }
}

// Spool

module spool_edge(shaft_d, core_d, bevel_d, outer_d, side_t, side_rim_t) {
    // Edge in X-Y plane with centre of outer face at (0,0,0)
    union() {
        cylinder(d1=outer_d, d2=outer_d, h=side_rim_t) ;
        translate([0,0,side_rim_t]) {
            cylinder(d1=outer_d, d2=bevel_d, h=side_t-side_rim_t) ;
        } ;
    } ;
}

module pulley(d,t) {
    cylinder(d1=d, d2=d-t, h=t/2+delta) ;
    translate([0,0,t/2])
        cylinder(d1=d-t, d2=d, h=t/2+delta) ;    
}


module spool_core(d_core, w_core) {
    cylinder(d=d_core, h=w_core) ;
}

module half_spool(shaft_d, core_d, bevel_d, outer_d, side_t, side_rim_t, w_spool_end) {
    difference() {
        union() {
            spool_edge(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t
            );
            spool_core(d_core=core_d, w_core=w_spool_end+side_t);
        } ;
        union() {
            shaft_hole(d=shaft_d, l=w_spool_end+side_t) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
        } ;
    }
} ;

module spool_spacer(shaft_d, core_d, w_spacer, w_spool_end) {
    difference() {
        union() {
            spool_core(d_core=core_d, w_core=w_spacer);
        } ;
        union() {
            shaft_hole(d=shaft_d, l=w_spacer) ;
        } ;
    }
} ;




module crank_handle(
        crank_l, 
        shaft_d, crank_hub_d, handle_hub_d, handle_d, 
        crank_hub_t, crank_arm_t
    ) {
    difference() {
        union() {
            cylinder(d=crank_hub_d, h=crank_hub_t) ;
            translate([0,0,crank_hub_t-delta])
                pulley(crank_hub_d, crank_hub_t) ;
            translate([crank_l/2,0,crank_arm_t/2]) 
                cube(size=[crank_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([crank_l,0,0]) 
                cylinder(d=handle_hub_d, h=crank_hub_t) ;
        } ;
        union() {
            shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            translate([crank_l,0,0]) {
                shaft_hole(d=handle_d, l=crank_hub_t) ;
                nut_recess(af=handle_nut_af, t=handle_nut_t) ;
            }
        } ;
    }
}


module winder_side_support() {
    // Side in X-Y plane, shaft centre at origin, extends along +X axis
    module side_profile() {
        linear_extrude(height=winder_side_t)
            {
            polygon(
                points=[
                    [0,-winder_apex_d/2], [0,winder_apex_d/2],
                    [winder_side_h-winder_base_t,-winder_side_w/2], [winder_side_h-winder_base_t,winder_side_w/2],
                    [winder_side_h,-winder_side_w/2], [winder_side_h,winder_side_w/2]
                    ],
                paths=[[0,2,4,5,3,1,0]]
                ) ;
            }
        }
    module side_apex() {
        cylinder(h=winder_side_t, d=winder_apex_d) ;
        }
    module side_base() {
        translate([winder_side_h-winder_side_t, -winder_side_w/2, 0])
            {
                difference() {
                    cube(size=[winder_side_t, winder_side_w, winder_base_t], center=false) ;
                    translate([0, winder_side_w*0.25, winder_base_t/2+winder_side_t/2])
                        rotate([0,90,0])
                            shaft_hole(base_fix_d, winder_side_t) ;
                    translate([0, winder_side_w*0.75, winder_base_t/2+winder_side_t/2])
                        rotate([0,90,0])
                            shaft_hole(base_fix_d, winder_side_t) ;
                }
            }
        }
    difference()
        {
        union()
            {
                side_profile() ;
                side_apex() ;
                side_base() ;
                web_side = winder_base_t - winder_side_t ;
                web_xz(winder_side_h-winder_side_t, -winder_side_w/2, winder_side_t, -web_side, web_side, winder_side_t) ;
                web_xz(winder_side_h-winder_side_t,  winder_side_w/2, winder_side_t, -web_side, web_side, winder_side_t) ;
            } ;
        union()
            {
                shaft_hole(shaft_d, winder_side_t) ;
            } ;
        }
}

// Tape reader bridge (with lighting groove) and supports

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
        translate([read_h-read_side_t, -read_side_base_w/2, 0])
            {
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
    difference()
        {
        union()
            {
                side_profile() ;
                side_base() ;
                web_side = read_side_base_t - read_side_t ;
                web_xz(read_h-read_side_t, -read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
                web_xz(read_h-read_side_t,  read_side_base_w/2, read_side_t, -web_side, web_side, read_side_t) ;
            } ;
        union()
            {
                shaft_hole(shaft_d, read_side_t) ;
                translate([read_h-read_side_base_t-read_side_t, +0.25*read_side_base_w,0])
                    shaft_hole(read_side_peg_d, read_side_t) ;
                translate([read_h-read_side_base_t-read_side_t, -0.25*read_side_base_w,0])
                    shaft_hole(read_side_peg_d, read_side_t) ;
            } ;
        }
}

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

module phone_holder_rod_anti_rotation_plate() {
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

module phone_camera_holder() {
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


module winder_assembly() {
    // Spool and crank handle
    spool_pos_x   = side_t + spool_w/2 + part_gap/2 ;
    winder_side_x = winder_side_t + spool_w/2 + part_gap/2 + part_gap ;
    winder_pos_x  = winder_side_x + 2*part_gap ;
    translate([-spool_pos_x,0,winder_side_h])
        rotate([0,90,0])
            half_spool(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
                );
    translate([spool_pos_x,0,winder_side_h])
        rotate([0,-90,0])
            half_spool(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
                );
    translate([winder_pos_x,0,winder_side_h])
        rotate([-45,0,0])
            rotate([0,90,0])
                crank_handle(
                    crank_l=crank_l, 
                    shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
                    handle_hub_d=handle_hub_d, handle_d=handle_d, 
                    crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t
                    ) ;
    // Winder supports
    translate([winder_side_x,0,winder_side_h])
        rotate([0,90,180])
            winder_side_support() ;
    translate([-winder_side_x,0,winder_side_h])
        rotate([0,90,0])
            winder_side_support() ;
}

module read_bridge_assembly() {
    // Reader bridge and support
    side_support_x = side_t + part_gap + spool_end_w + part_gap/2 ;
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
        rotate([0,0,0])
            phone_holder_rod_fixing() ;
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
            crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t
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
            crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t
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

layout_print_1() ;
// layout_print_2() ;
// layout_print_3() ;
// layout_print_spacer() ;

// spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid, w_spool_end=spool_w_end) ;

//        crank_handle(
//            crank_l=crank_l, 
//            shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
//            handle_hub_d=handle_hub_d, handle_d=handle_d, 
//            crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t
//            ) ;
//
//
//    translate([2*spacing,0,0])
//        pulley(crank_hub_d, 4) ;


