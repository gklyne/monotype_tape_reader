include <reader-defs.scad> ;

/*    
shaft_d = 8.2 ;         // Shaft diameter
core_d = 18 ;           // Core diameter
bevel_d = 30 ;          // Bevel inner diameter
outer_d = 40 ;          // Spool outer diameter
crank_hub_d = 25 ;      // Diameter of crank hub
handle_hub_d = 10 ;     // Diameter of handle end of crank
handle_d = 4 ;          // Diameter of handle
base_fix_d = 4 ;        // Diameter of base fixing screw hole

crank_l = 40 ;          // Length of crank (between shaft and handle centres

side_t = 4 ;            // Thickness of spool side
side_rim_t = 2 ;        // Thickness of spool side rim (beveled)
crank_hub_t = 6 ;       // Thickness of crank hub
crank_arm_t = 4 ;       // Thickness of crank arm

spool_w_all = 112 ;     // Width of spool (overall between ends)
spool_w_end = 20 ;      // Width of spool (to inside of end)
spool_w_mid = spool_w_all - 2*spool_w_end ;
                        // width of spool middle spacer

shaft_nut_af = 13 ;     // Nut diameter across faces
shaft_nut_t  = 4 ;      // Nut thickness

handle_nut_af = 7 ;     // Nut diameter across faces
handle_nut_t  = 3 ;     // Nut thickness

winder_side_h = 50 ;    // Height to centre of winder shaft
winder_side_w = 40 ;    // Width base of winder side support
winder_side_t = 4 ;     // Thickness of winder side support
winder_apex_d = 16 ;    // Radius of apex of winder side support
winder_base_t = 16 ;    // Thickness at base of winder

delta = 0.1 ;           // Small value to force overlap
spacing = outer_d+10 ;  // Object spacingh (pitch)
part_gap = 10 ;         // Spacing between exploded assembly parts
*/

// Utilities

module shaft_hole(d, l) {
        translate([0,0,-delta]) {
            cylinder(d=d, h=l+delta*2) ;
        };
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

// read_l = spool_w_all ;  // Reader bridge length (inner)
// read_w = 16 ;           // Width of bridge
// read_extra_w = 10 ;     // Extra width for reader bridge for tie-down
// read_h = 90 ;           // Height of reader bridge above base plate
// read_side_t = side_t ;  // Reader bridge side support thickness
// read_side_base_t = 16 ; // Reader bridge side support thickness at base 
// 
// read_side_apex_w = 24 ;
// read_side_apex_h = 4 ;
// read_side_base_w = 40 ;
// read_side_peg_d  = 4 ;
// 
// read_groove_w = 2.25 ;  // EL wire goove width
// read_groove_d = 3 ;     // EL wire groove depth

module tape_reader_bridge() {
    total_l = read_l + 2*(read_side_t + read_extra_w) ;
    difference() {
        rotate([0,90,0])
            cylinder(d=read_w, h=total_l, center=true) ;
        translate([0,0,-read_w/2])
            cube(size=[total_l+delta, read_w+delta, read_w+delta], center=true) ;

        translate([0,0,(read_w-read_groove_d)/2])
            cube(size=[total_l+delta, read_groove_w, read_groove_d], center=true) ;
    }
}

module read_side_support() {
    // Side in X-Y plane, shaft cente at origin, extends along +X axis
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
                paths=[[0,2,4,6,8, 9,7,5,3,1, 0]]
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

// hold_side_l = 80 ;      // Length is side of holder
// hold_side_h = 10 ;      // Height of side above base
// hold_side_t1 = 7 ;      // Thickness of side at base
// hold_side_t2 = 8 ;      // Thickness of side at top
// 
// hold_base_l1 = 60 ;     // Length of base near side
// hold_base_l2 = 50 ;     // Length of base towards centre
// hold_base_t = 8 ;       // Thickness of base (to accommodate hole)
// hold_base_w = 20 ;      // Width of base piece
// 
// hold_rail_p = 40 ;      // Distance between rail holes
// hold_rail_d = 4 ;       // Diameter of rail holes
// 
// hold_fix_p = 25 ;       // Distance between fixing holes
// hold_fix_d = 4 ;        // Diameter of fixing holes
// hold_fix_o = 30 ;       // Offset from vertical rod to holder fixing holes
// 
// hold_fix_t = 6 ;        // Thickness of phone holder-to-rod fixing
// hold_fix_w = 8 ;        // Width of phone holder-to-rod fixing
// hold_fix_l = 80 ;       // Length of phone holder-to-rod fixing
// hold_fix_rod_d = 8 ;    // Diameter of phone holder support rod
// hold_fix_hub_d = 16 ;   // Diameter of phone holder support hub
// 
// hold_fix_plate_l = hold_fix_o + hold_fix_rod_d*2 ;
// hold_fix_plate_w = hold_fix_p + hold_fix_rod_d*2 ;

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
    module plate_outline() {
        linear_extrude(height=hold_fix_t)
            {
            polygon(
                points=[
                    [0,0], 
                    [hold_fix_plate_l, 0], 
                    [hold_fix_plate_l, hold_fix_rod_d*2],
                    [hold_fix_rod_d*2, hold_fix_plate_w], 
                    [0, hold_fix_plate_w]
                    ],
                paths=[[0,1,2,3,4,0]]
                ) ;
            }
        }
    difference() {
        plate_outline() ;
        translate([hold_fix_rod_d+hold_fix_o, hold_fix_rod_d,0])
            shaft_hole(hold_fix_rod_d, hold_fix_t ) ;
        union() {
            translate([hold_fix_rod_d, hold_fix_rod_d+hold_fix_p, 0])
                shaft_hole(hold_fix_d, hold_fix_rod_d ) ;
            translate([hold_fix_rod_d, hold_fix_rod_d, 0])
                shaft_hole(hold_fix_d, hold_fix_t ) ;
        } ;
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

// rod_support_h = 40 ;
// rod_support_t = side_t ;  // Rod support side support thickness
// rod_support_base_t = 16 ; // Rod support side support thickness at base 
// 
// rod_support_apex_w = 24 ;
// rod_support_base_w = 45 ;
    
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
        // @@QUESTION: Should this be spaced away from the side plate to allow a nut on the rod?
        holder_wdth = hold_fix_rod_d*2 ;
        holder_dpth = rod_support_t*2+hold_fix_rod_d ;
        difference() {
            union() {               
                translate([0,0,holder_wdth/4])
                    cube(size=[rod_support_t, holder_wdth, holder_wdth/2], center=true) ;
                translate([0,0,holder_dpth/2])
                    rotate([0,90,0])
                        cylinder(d=holder_dpth,h=rod_support_t, center=true) ;
            }
            translate([-rod_support_t/2,0,rod_support_t+hold_fix_rod_d/2])
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


