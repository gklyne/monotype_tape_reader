// monotype-tape-reader-winder.scad
//
// This module defines tape spools and components for drawing the tape over 
// the read head

include <reader-defs.scad> ;
include <common-components.scad> ;

////////////////////////////////////////////////////////////////////////////////
// Winder crank and drive pulley
////////////////////////////////////////////////////////////////////////////////

module crank_handle_pushon(
        shaft_d, crank_hub_d, crank_hub_t, 
        drive_nut_af, drive_nut_t, 
        crank_arm_l, crank_arm_t, 
        handle_d, handle_hub_d, handle_hub_t
    ) {
    // Crank handle pushes on to a nut on the shaft.
    //
    // NOTE:    the push-on design is to avoid having the crank handle 
    //          unbalance the spool while reading the tape.
    //
    // shaft_d      = diameter of turned shaft
    // crank_hub_d  = diameter of crank hub
    // crank_hub_t  = thickness of crank hub
    // drive_nut_af = drive nut size AF
    // drive_nut_t  = drive nut thickness
    // crank_arm_l  = length of crank
    // crank_arm_t  = thickness of crank arm
    // handle_d     = diameter of handle shaft
    // handle_hub_d = diameter of handle hub 
    // handle_hub_t = thickness of handle hub
    //
    difference() {
        union() {
            cylinder(d=crank_hub_d, h=crank_hub_t) ;
            translate([crank_l/2,0,crank_arm_t/2]) 
                cube(size=[crank_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([crank_l,0,0]) 
                cylinder(d=handle_hub_d, h=handle_hub_t) ;
        } ;
        union() {
            shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
            translate([0,0,crank_hub_t-drive_nut_t]) {
                nut_recess(af=drive_nut_af, t=drive_nut_t+delta) ;
            }
            translate([crank_l,0,0]) {
                nut_recess(af=handle_nut_af, t=handle_nut_t) ;
                translate([0,0,handle_hub_t+delta])
                    countersinkZ(od=handle_d*2, oh=handle_hub_t+2*delta, sd=handle_d, sh=handle_hub_t) ;
            }
        } ;
    }
}

////-crank_handle_pushon(
////        crank_l, 
////        shaft_d, crank_hub_d, handle_hub_d, handle_d, 
////        crank_hub_t, crank_arm_t, handle_hub_t)
// crank_handle_pushon(
//     shaft_d=shaft_d, crank_hub_d=18, crank_hub_t=7, 
//     drive_nut_af=m8_nut_af, drive_nut_t=5, 
//     crank_arm_l=crank_l, crank_arm_t=5, 
//     handle_d=handle_d, handle_hub_d=handle_hub_d, handle_hub_t=6
//     ) ;

module crank_handle_pushon_nut(
        drive_nut_af,
        drive_nut_t,
        drive_shaft_d,
        shaft_nut_af,
        shaft_nut_t
    ) {
    // Drive nut attached to shaft for push-on crank
    //
    // drive_nut_af     = drive nut size AF
    // drive_nut_t      = drive nut thickness
    // drive_shaft_d    = driven shaft diameter
    // shaft_nut_af     = shaft nut size AF
    // shaft_nut_t      = shaft nut thickness
    //
    difference() {
        nut(drive_nut_af-2*m_clearance, drive_nut_t, drive_shaft_d) ;
        translate([0,0,drive_nut_t-m4_nut_t+delta]) {
            nut_recess(shaft_nut_af, shaft_nut_t) ;
        }
    }
}

////-crank_handle_pushon_nut(
////        drive_nut_d, drive_nut_t, drive_shaft_d,
////        shaft_nut_af, shaft_nut_t)
// translate([-20,0,0])
//     crank_handle_pushon_nut(m8_nut_af, 5, m4, m4_nut_af, m4_nut_t) ;
// translate([-40,0,0])
//     crank_handle_pushon_nut(m8_nut_af, 5, m4, m4_nut_af, m4_nut_t) ;


module crank_handle_balanced(
        crank_l, 
        shaft_d, crank_hub_d, handle_hub_d, handle_d, 
        crank_hub_t, crank_arm_t, handle_hub_t) {
    difference() {
        union() {
            cylinder(d=crank_hub_d, h=crank_hub_t) ;
            translate([0,0,crank_hub_t-delta])
                // pulley(crank_hub_d, drive_pulley_t) ;
                pulley_round_belt(crank_hub_d, drive_pulley_t, drive_pulley_t-1) ;
            translate([crank_l/2,0,crank_arm_t/2]) 
                cube(size=[crank_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([crank_l,0,0]) 
                cylinder(d=handle_hub_d, h=handle_hub_t) ;
            // Balancing arm
            balance_l = crank_l ;
            translate([-balance_l/2,0,crank_arm_t/2]) 
                cube(size=[balance_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([-balance_l,0,0]) 
                cylinder(d=handle_hub_d, h=crank_hub_t) ;
        } ;
        union() {
            shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
            // OLD: nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            // NEW: extends crank so it doesn't foul drive pulley:
            nut_recess(af=shaft_nut_af, t=crank_hub_t-drive_pulley_t+shaft_nut_t) ;
            translate([crank_l,0,0]) {
                nut_recess(af=handle_nut_af, t=handle_nut_t) ;
                translate([0,0,handle_hub_t+delta])
                    countersinkZ(od=handle_d*2, oh=handle_hub_t+2*delta, sd=handle_d, sh=handle_hub_t) ;
            }
            // Balancing arm
            translate([-crank_l,0,0]) {
                translate([0,0,crank_hub_t-handle_nut_t+delta])
                    nut_recess(af=handle_nut_af, t=handle_nut_t) ;
                translate([0,0,-delta])
                    rotate([180,0,0])
                        countersinkZ(od=handle_d*2, oh=crank_hub_t, sd=handle_d, sh=crank_hub_t) ;
            }
        } ;
    }
}

////-crank_handle_balanced(
////        crank_l, 
////        shaft_d, crank_hub_d, handle_hub_d, handle_d, 
////        crank_hub_t, crank_arm_t, handle_hub_t)
// crank_handle_balanced(
//     crank_l=crank_l, 
//     shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
//     handle_hub_d=handle_hub_d, handle_d=handle_d, 
//     crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=crank_end_t
//     ) ;


module drive_pulley(shaft_d, shaft_nut_af, shaft_nut_t, drive_pulley_d) {
    extra_pulley_t = drive_pulley_t*0.0 ;  // Extra pulley thickness for hub recess, etc.
    intersection() {
        difference() {
            union() {
                cylinder(d=drive_pulley_d, h=extra_pulley_t) ;
                translate([0,0,extra_pulley_t-delta])
                    // pulley(drive_pulley_d, drive_pulley_t) ;
                    pulley_round_belt(drive_pulley_d, drive_pulley_t, drive_pulley_t-1) ;
            } ;
            translate([0,0,-delta])
                shaft_hole(d=shaft_d, l=drive_pulley_t+2*delta) ;
            translate([0,0,drive_pulley_t-shaft_nut_t])
                nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
        }
    spoked_wheel(
        hr=shaft_d+1, sr=drive_pulley_d/2-crank_hub_t*0.3, or=drive_pulley_d, fr=3, 
        wt=crank_hub_t*1.5, 
        ns=6, sw=3
        ) ;
    }
}

////-drive_pulley(shaft_d, shaft_nut_af, shaft_nut_t, drive_pulley_d)
// drive_pulley(shaft_d=shaft_d,  shaft_nut_af, shaft_nut_t, drive_pulley_d=drive_pulley_d) ;
// translate([0,spacing,0])
//     drive_pulley(shaft_d=shaft_d, shaft_nut_af=shaft_nut_af, shaft_nut_t=shaft_nut_t, drive_pulley_d=drive_pulley_d) ;
// translate([spacing,spacing,0])
//     drive_pulley(shaft_d=shaft_d, shaft_nut_af=shaft_nut_af, shaft_nut_t=shaft_nut_t, drive_pulley_d=drive_pulley_d) ;


module rewind_pulley(pd, pt, hd, ht, sd, nut_af, nut_t) {
    difference() {
        union() {
            // pulley
            // pulley(pd, pt) ;
            pulley_round_belt(pd, pt, pt-1) ;
            // hub
            cylinder(d=hd, h=pt+ht, center=false, $fn=48) ;
        }
        translate([0,0,-delta]) {
            // shaft hole
            cylinder(d=sd, h=pt+ht+2*delta, $fn=12) ;
            nut_recess(nut_af, nut_t) ;
            // Spoke cutouts (not for small pulley)
            spoked_wheel_cutouts(hr=hd/2+1, sr=(pd-pt)/2, fr=1.5, wt=pt+2*delta, ns=6, sw=3) ;
        }
    }
}

////-rewind_pulley(dia, width, hub_dia, hub_width, shaft_dia) ;
//rewind_pulley(28, 8, 8, 0, m4, m4_nut_af, m4_nut_t*1.5) ;

////////////////////////////////////////////////////////////////////////////////
// Spool supports
////////////////////////////////////////////////////////////////////////////////

module spool_side_support() {
    // Side in X-Y plane, shaft centre at origin, extends along +X axis
    module side_profile() {
        linear_extrude(height=winder_side_t)
            {
            polygon(
                points=[
                    [0,-winder_apex_d/2], [0,winder_apex_d/2],
                    [winder_side_h-winder_base_t,-winder_side_w/2], 
                    [winder_side_h-winder_base_t,winder_side_w/2],
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
        shaft_hole(shaft_d, winder_side_t) ;
        }

}

module spool_side_support_slotted(r=145) {
    // Spool support with slot for removing shaft
    //
    // r  = angle of rotation of slot from vertical
    //
    difference() {
        s_ox  = 0.65 ;                      // Slot offset diameter multiplier
        f_xm = shaft_d*s_ox/2 ;             // Mid-point of flex cutout
        f_d  = 1.7 ;                        // width of flex cutout
        f_l  = 7.0 ;                        // Length flex cutout (excl radius ends)
        f_oy = 0.5*(shaft_d+f_d) + 0.65 ;    // Y-offset of flex cutout
        // Overall height of spacer ridge to prevent spool edges fouling:
        winder_side_spacer_h = winder_side_t+1.0 ;
        union() {
            spool_side_support() ;
            difference() {
                // Hub is double diameter of shaft
                cylinder(r=shaft_d, h=winder_side_spacer_h) ;
                translate([0,0,-delta]) {
                    cylinder(r=shaft_d-1, h=winder_side_spacer_h+2*delta) ;
                }
            }
        }
        // Cutout to allow spool to be removed
        rotate([0,0,r]) {
            translate([shaft_d*s_ox,0,-delta])
                oval(winder_apex_d/2, shaft_d, winder_side_spacer_h+delta*2) ;
            // Cutouts to flex retaining lugs
            translate([f_xm-f_l/2, f_oy, -delta])
                oval(f_l, f_d, winder_side_spacer_h+delta*2) ;
            translate([f_xm-f_l/2, -f_oy, -delta])
                oval(f_l, f_d, winder_side_spacer_h+delta*2) ;
            // Remove part of spacer ring
            translate([shaft_d*0.25,-shaft_d,winder_side_t+delta])
                cube(size=[shaft_d*2, shaft_d*2, winder_side_spacer_h]) ;
        } 
        // Cutout to reduce plastic used
        cutout_r    = winder_apex_d*0.4 ;
        translate([0,0,-delta])
            rounded_triangle_plate(
                winder_apex_d, 0, 
                winder_side_h-winder_base_t,  (winder_side_w/2-cutout_r*2),
                winder_side_h-winder_base_t, -(winder_side_w/2-cutout_r*2),
                cutout_r, winder_side_t+2*delta
            ) ;


    }    
}


////-spool_side_support_slotted(r=145)
// translate([spacing*0.5,-spacing*0.5,0]) spool_side_support_slotted(r=125) ;
// translate([spacing*0.5,+spacing*0.5,0]) spool_side_support_slotted(r=-125) ;
// translate([spacing*1.5,-spacing*0.5,0]) spool_side_support_slotted(r=140) ;
// translate([spacing*1.5,+spacing*0.5,0]) spool_side_support_slotted(r=-140) ;

module spool_and_winder_side_support(side) {
    // Spool and winder support
    //
    // side = +/- 1, for different sides
    //
    slot_rotation = 140*side ;
    lower_arm_x = winder_side_h-winder_base_t ;
    lower_arm_y = 0 ;
    upper_arm_x = winder_apex_d/2 ;
    upper_arm_y = 0 ;
    winder_x    = winder_apex_d/2 ;
    winder_y    = -outer_d*0.6*side ;
    cutout_r    = winder_apex_d*0.4 ;
    difference() {
        union () {
            spool_side_support_slotted(r=slot_rotation) ;
            difference() {
                // Side arms to hold winder
                union() {
                    brace_xy(lower_arm_x,lower_arm_y,
                        winder_x,winder_y,
                        shaft_d*0.8,shaft_d*1.6,shaft_d,winder_side_t
                    ) ;
                    brace_xy(upper_arm_x,upper_arm_y,
                        winder_x,winder_y,
                        shaft_d*0.8,shaft_d*0,shaft_d,winder_side_t
                        ) ;
                }
                translate([winder_x,winder_y,0])
                    shaft_hole(shaft_d, winder_side_t) ;
            }
        }
        // Cutout to reduce plastic used
        translate([0,0,-delta])
            rounded_triangle_plate(
                winder_apex_d, 0, 
                winder_side_h-winder_base_t,  (winder_side_w/2-cutout_r*2),
                winder_side_h-winder_base_t, -(winder_side_w/2-cutout_r*2),
                cutout_r, winder_side_t+2*delta
            ) ;
    }
}

////-spool_and_winder_side_support(side)
//translate([spacing*0.5,-spacing*0.75,0]) spool_and_winder_side_support(-1) ;
//translate([spacing*0.5,+spacing*0.75,0]) spool_and_winder_side_support(+1) ;


////////////////////////////////////////////////////////////////////////////////
// Stepper motor bracket
////////////////////////////////////////////////////////////////////////////////

stepper_body_dia    = 29.5 ;
stepper_body_height = 31.5 ;    // Includes wire entry cover
stepper_wire_height = 2 ;       // Height of wire entry cover (beyond body radius)
stepper_wire_width  = 19 ;      // Width of wire entry cover
stepper_hole_dia    = m4 ;
stepper_nut_af      = m4_nut_af ;
stepper_hole_pitch  = 35 ;

bracket_sd          = m8 ;                                  // Bracket shaft hole diameter
bracket_fw          = 4 ;                                   // Width of frame around motor
bracket_ft          = winder_side_t+12 ;                    // Thickness of frame and brace
bracket_hubd        = bracket_sd*1.5 ;                      // Shaft-suppoort= hub diameter
bracket_od          = stepper_body_dia + bracket_fw*2 ;     // Holder outside diamater
bracket_mount_x     = (bracket_od*0.6) ;                    // X-offset of shaft from motor centre
bracket_mount_y     = bracket_od/2-bracket_hubd/2 ;         // Y-offset of shaft from motor centre


module stepper_mount(bd, fw, ft, hd, hp, af) {
    // Stepper motor mount on X-Y plane, motor axis centred on origin
    //
    // bd   = diameter of motor body
    // fw   = frame width (around motor body)
    // ft   = frame thickness (~ length of motor body)
    // hd   = mounting hole diameter
    // hp   = mounting hole pitch
    // af   = across face size of nut recess
    //

    hubd = bracket_hubd ;     // Bracket end hub diameter
    hubr = hubd/2 ;
    od   = bd + fw*2 ;        // Outside diameter of bracket frame
    r    = 1 ;
    x1   = -stepper_wire_width/2+r ;
    x2   = -x1 ;
    y1   = -stepper_body_dia/2-stepper_wire_height+r ;
    y2   = 0 ;
    msp  = stepper_hole_pitch/2+clearance ; // Mounting hole semi-pitch
    difference() {
        union() {
            // body ring
            cylinder(d=od, h=ft) ;
            // wire cover extension
            rounded_rectangle_plate(x1,y1, x2,y2, r+fw, ft) ;
            // mounting lugs
            oval_xy(-msp,0, msp,0, d=stepper_hole_dia*2.7, h=ft) ;
        }
        // Cutaway:
        hc = ft + 2*delta ;
        translate([0,0,-delta]) {
            //   body
            cylinder(d=bd, h=hc) ;
            //   L mounting hole
            translate([-msp,0,0]) {
                cylinder(d=hd, h=hc) ;
                translate([0,0,5])  // Leaves 5mm for mounting
                    rotate([0,0,90])
                        nut_recess(af, ft) ;
            }
            //   R mounting hole
            translate([+msp,0,0]) {
                cylinder(d=hd, h=hc) ;
                translate([0,0,5])  // Leaves 5mm for mounting
                    rotate([0,0,90])
                        nut_recess(af, ft) ;
            }
            //   wire entry cover (rounded rect r=1)
            rounded_rectangle_plate(x1,y1, x2,y2, r, hc) ;
            //   wire entry
            weh = 2.8 ;     // Wire entry height
            wew = 8 ;       // Wire entry width
            translate([-wew/2,y1-r-fw-delta,-delta])
                bevel_y(-delta,fw+delta, wew,weh, weh-0.25, 38)
                    bevel_y(-delta,fw+delta, 0,weh, weh-0.25, -38)
                        cube(size=[wew,fw+2*delta,weh]) ;
        }
    }
}
////-stepper_mount(bd, fw, ft, hd, hp, af)
//  stepper_mount(stepper_body_dia, bracket_fw, bracket_ft, 
//      stepper_hole_dia, stepper_hole_pitch, stepper_nut_af) ;

module cond_mirror_y(side) {
    // Conditionally mirrors child objects if the supplied "side" value is negative
    if (side < 0)
        { mirror([0,1,0]) children() ; }
    else
        { children() ; }
}

ring_r1 = stepper_wire_width + bracket_fw*1.6 ;
ring_r2 = stepper_wire_width + bracket_fw*3.6 ;

module stepper_swivel_bracket(bd, fw, ft, hd, hp, af, side) {
    // Stepper motor mount on X-Y plane, with swivel hinge centred on origin
    // 
    // bd   = diameter of motor body
    // fw   = frame width (around motor body)
    // ft   = frame thickness (~ length of motor body)
    // hd   = mounting hole diameter
    // hp   = mounting hole pitch
    // af   = across face size of nut recess
    //
    hto = 4 ;           // Size of outer hinge tongues
    hti = ft-hto*2 ;    // Size of inner hinge tongue
    translate([-stepper_body_dia/2-stepper_wire_height-fw/2,(stepper_body_dia/2+fw/2+1)*side,0])
        rotate([0,0,90])
            stepper_mount(bd, fw, ft, hd, hp, af) ;
    // Hinge mount for adjustment
    translate([0,0,0])
        rotate([0,0,180-side*90])
            hinge_inner(fw*3, ft, hti, fw, m3_hinge_dia, m3) ;
    // Locking plate for adjustment
    slot_r1 = (ring_r1+ring_r2-m3)/2 ;
    slot_r2 = (ring_r1+ring_r2+m3)/2 ;
    cond_mirror_y(side) {
        ring_segment_slotted(45, 88, ring_r1, ring_r2, fw, 45, 80, slot_r1, slot_r2) ;
    }
}

module swivel_arm_locking_nut_holder(sd, t, nut_af, nut_t) {
    // oval(x, d, h)
    difference() {
        union() {
            oval(0,(ring_r2-ring_r1),t) ;
            translate([-(sd*0.5),0,0])
                oval(sd*0.75,sd-clearance,t*1.5) ;
        }
        translate([0,0,-delta]) {
            cylinder(d=sd, h=t*2+delta*2, $fn=12) ;
            nut_recess(nut_af, nut_t) ;
        }
    }
}

// Combined spool support and swivel mount for motor bracket
//
// arm_l    length of arm to hold adjustment link
// dir      +1/-1 to select orientation
//
module spool_and_swivel_mount_side_support(arm_l, side) {
    ft  = bracket_ft ;
    pt  = winder_side_t ;
    hto = 4 ;                   // Size of outer hinge tongues
    hti = ft-hto*2 ;            // Size of inner hinge tongue
    arx = winder_apex_d*0.55 ;  // X-offset of adjustment link root
    ary = winder_apex_d*0.45 ;  // Y-offset of adjustment link root
    alx = arm_l+outer_d*0.0 ;   // X-offset of adjustment link end
    aly = 0 ;                   // Y-offset of adjustment link end
    difference() {
        union() {
            slot_rotation = 140*side ;
            // Spool support, translating winder crank axis to origin
            translate([0,0,0])
                rotate([0,0,-90])
                    spool_side_support_slotted(r=slot_rotation) ;
            // Hinge arm from spool support base
            translate([-winder_side_w/2*side,-winder_side_h,0])
                rotate([0,0,62*side-90])
                    translate([-motor_support_l,pt/2*side,0])
                        hinge_outer(motor_support_l, ft, hti, pt, m3_hinge_dia, m3, m3_nut_af, m3_nut_t) ;
            // Bulge for adjustment locking arm
            translate([-arx*side, -ary, 0])
                ////cylinder(d=m3*3, h=pt, $fn=12) ;
                oval_xy(0,0, -alx*side,-aly, d=m3*3, h=pt) ;
        }
        // Hole for adjustment locking arm
        translate([-(arx+alx)*side, -(ary+aly), -delta]) {
            cylinder(d=m3, h=pt+2*delta, $fn=12) ;
            translate([0,0,pt-m3_nut_t])
                nut_recess(m3_nut_af, m3_nut_t+delta) ;
        }
    }
}

module swivel_arm_locking_brace(l, t, sd, nut_af, nut_t) {
    // Upper arm for adjustment lock
    //
    // l        = distance between brace centres
    // t        = thickness of brace
    // sd       = locking screw diameter
    // nut_af   = locking nut size across faces
    // nut_t    = locking nut thickness (for recess)
    //
    // brace_xy(x1, y1, x2, y2, w, d1, d2, h)
    // countersinkZ(od, oh, sd, sh)
    //
    difference() {
        brace_xy(0,0, l, 0, sd*2, sd*3, sd, t) ;
        translate([0,0,t])
            countersinkZ(sd*2, t+2*delta, sd, t+delta) ;
        translate([l,0,t])
            // countersinkZ(sd*2, t+2*delta, sd, t+delta) ;
            cylinder(d=sd, h=t+2*delta, $fn=12) ;
        // translate([0,0,t-nut_t])
        //     nut_recess(nut_af, nut_t+delta) ;
        // translate([l,0,t-nut_t])
        //     nut_recess(nut_af, nut_t+delta) ;
    }
    
}


////-stepper_mount_tension_adjustable
////-stepper_swivel_bracket(bd, fw, ft, hd, hp, af, side)
//translate([0,20,0])
//    stepper_swivel_bracket(
//        stepper_body_dia, bracket_fw, bracket_ft, 
//        stepper_hole_dia, stepper_hole_pitch, stepper_nut_af, -1) ;
////-swivel_arm_locking_nut_holder(sd, t, nut_afd, nut_t)
//translate([0,winder_side_h-20,0])
//    swivel_arm_locking_nut_holder(m3, bracket_fw, m3_nut_af, m3_nut_t) ;
////-spool_and_swivel_mount_side_support(arm_l, side)
//translate([60,winder_side_h,0])
//    spool_and_swivel_mount_side_support(5, -1) ;
////-swivel_arm_locking_brace(l, ft, sd, nut_af, nut_t)
//translate([0,winder_side_h,0])
//    swivel_arm_locking_brace(motor_swivel_l-4, bracket_fw, m3, m3_nut_af, m3_nut_t) ;


module stepper_bracket(bd, fw, ft, hd, hp, af, side=+1) {
    // Stepper motor bracket on X-Y plane, motor axis centred on origin
    //
    // bd   = diameter of motor body
    // fw   = frame width (around motor body)
    // ft   = frame thickness
    // hd   = mounting hole diameter
    // hp   = mounting hole pitch
    // af   = across face size of not recess
    // side = +/-1 for mounting arm to left or right
    //
    sd   = bracket_sd ;       // Bracket end shaft diameter
    hubd = bracket_hubd ;     // Bracket end hub diameter
    hubr = hubd/2 ;
    od   = bd + fw*2 ;        // Outside diameter of bracket frame
    r    = 1 ;
    x1   = -stepper_wire_width/2+r ;
    x2   = -x1 ;
    y1   = -stepper_body_dia/2-stepper_wire_height+r ;
    y2   = 0 ;
    difference() {
        union() {
            // body ring
            cylinder(d=od, h=ft) ;
            // wire cover extension
            rounded_rectangle_plate(x1,y1, x2,y2, r+fw, ft) ;
            // mounting lugs
            oval_xy(
                -stepper_hole_pitch/2,0,
                stepper_hole_pitch/2,0, 
                d=stepper_hole_dia*3, h=ft
            ) ;
            // Winder bracket mounting arm:
            // brace_xy(x1, y1, x2, y2, w, d1, d2, h)
            brace_xy(
                bracket_mount_x*side, bracket_mount_y,  // x1, y1
                0, (od/2-hubr)*-0.5,                    // x2, y2
                hubd, hubd, sd, winder_side_t           // w, d1, d2, h
                ) ;
        }
        // Cutaway:
        hc = ft + 2*delta ;
        translate([0,0,-delta]) {
            //   body
            cylinder(d=bd, h=hc) ;
            //   L mounting hole
            translate([-stepper_hole_pitch/2,0,0]) {
                cylinder(d=hd, h=hc) ;
                translate([0,0,5])  // Leaves 5mm for mounting
                    rotate([0,0,90])
                        nut_recess(af, ft) ;
            }
            //   R mounting hole
            translate([+stepper_hole_pitch/2,0,0]) {
                cylinder(d=hd, h=hc) ;
                translate([0,0,5])  // Leaves 5mm for mounting
                    rotate([0,0,90])
                        nut_recess(af, ft) ;
            }
            //   countersink for mounting screw
            // translate([bracket_mount_x*side, bracket_mount_y, winder_side_t+delta])
            //     countersinkZ(od=sd*2, oh=winder_side_t+delta*2, sd=sd, sh=winder_side_t) ;
            //   wire entry cover (rounded rect r=1)
            rounded_rectangle_plate(x1,y1, x2,y2, r, hc) ;
            //   wire entry
            weh = 2.8 ;     // Wire entry height
            wew = 8 ;       // Wire entry width
            translate([-wew/2,y1-r-fw-delta,-delta])
                bevel_y(-delta,fw+delta, wew,weh, weh-0.25, 38)
                    bevel_y(-delta,fw+delta, 0,weh, weh-0.25, -38)
                        cube(size=[wew,fw+2*delta,weh]) ;
        }
    }
}

module stepper_bracket_sleeve() {
    washer_t = 2 ;
    sleeve_h = winder_side_t+washer_t -1 ;
        // -1 allows sleeve flange and bracket to clamp on spool holder
    difference() {
        union() {
            cylinder(d=shaft_d-m_clearance, h=sleeve_h) ;
            cylinder(d=bracket_hubd, h=washer_t) ;
        }
        translate([0,0,-delta]) {
            cylinder(d=bracket_sd, h=sleeve_h+2*delta) ;
        }
    }
}

////-stepper_bracket(bd, fw, ft, hd, hp, af, side=+1)
//stepper_bracket(stepper_body_dia, bracket_fw, bracket_ft, 
//    stepper_hole_dia, stepper_hole_pitch, stepper_nut_af) ;
//  stepper_bracket_sleeve() ;

// Combined spool and stepper motor bracket
//
// dir  +1/-1 to select orientation
//
module spool_and_motor_side_support(dir) {
    winder_x    = winder_apex_d/2 ;
    winder_y    = -outer_d*0.6 ;
    // Stepper bracket, translating attachment point to origin
    ////translate([-bracket_mount_x*dir,-bracket_mount_y,0])
    ////    stepper_bracket(
    ////        stepper_body_dia, bracket_fw, bracket_ft, 
    ////        stepper_hole_dia, stepper_hole_pitch, stepper_nut_af, 
    ////        dir
    ////        ) ;
    // Spool support, translating winder crank axis to origin
    rotate([0,0,-90])
        translate([-winder_x, -winder_y*dir, 0]) 
            spool_and_winder_side_support(dir) ;
    // Extra stiffening brace
    brace_xy(
        -(winder_y+winder_side_w/2-winder_side_t/2)*dir, -winder_side_h+winder_x+winder_side_t*0.5, 
        -(bracket_mount_x-(stepper_body_dia+bracket_fw)*0.5)*dir, -bracket_mount_y-stepper_hole_dia*1.5, 
        bracket_fw, bracket_fw, 1, bracket_ft
        ) ;

}

////-spool_and_motor_side_support(dir)
//  translate([-40,0,0])
//      spool_and_motor_side_support(-1) ;


////////////////////////////////////////////////////////////////////////////////
// Stepper motor pulley
////////////////////////////////////////////////////////////////////////////////

module stepper_shaft(sd, af, sl) {
    intersection() {
        cylinder(d=sd, h=sl, center=false, $fn=16) ;
        translate([-sd/2,-af/2,0])
            cube(size=[sd, af, sl], center=false) ;
    }
}
// stepper_shaft(5, 3, 25) ;

module stepper_pulley(pd, pt, hd, ht, sd, af) {
    difference() {
        union() {
            // pulley
            // pulley(pd, pt) ;
            pulley_round_belt(pd, pt, pt-1) ;
            // hub
            cylinder(d=hd, h=pt+ht, center=false, $fn=48) ;
        }
    translate([0,0,-delta]) {
        // shaft hole
        stepper_shaft(sd, af, pt+ht+2*delta) ;
        // Spoke cutouts (not for small pulley)
        spoked_wheel_cutouts(hr=hd/2+1, sr=(pd-pt)/2, fr=1.5, wt=pt+2*delta, ns=6, sw=3) ;
        }
    }
}

pulley_dia       = 25 ;   // Small: 20; large: 50; spool: drive_pulley_d (==60)
pulley_width     = 8 ;
pulley_hub_dia   = 8 ; 
pulley_hub_width = 3.1 ;  // 7.1 - pulley_width/2 ?
pulley_shaft_dia = 5.2 ;
pulley_shaft_af  = 3.0 ;

////-stepper_pulley(pd, pt, hd, ht, sd, af)
// stepper_pulley(pulley_dia, pulley_width, pulley_hub_dia, pulley_hub_width, pulley_shaft_dia, pulley_shaft_af) ;

////////////////////////////////////////////////////////////////////////////////
// Tape spool
////////////////////////////////////////////////////////////////////////////////

module spool_edge(shaft_d, core_d, bevel_d, outer_d, side_t, side_rim_t) {
    // Edge in X-Y plane with centre of outer face at (0,0,0)
    union() {
        cylinder(d1=outer_d, d2=outer_d, h=side_rim_t) ;
        translate([0,0,side_rim_t]) {
            cylinder(d1=outer_d, d2=bevel_d, h=side_t-side_rim_t) ;
        } ;
    } ;
}

module spool_core(d_core, w_core) {
    // cylinder(d=d_core, h=w_core) ;
    spoked_wheel(
        hr=shaft_d, sr=d_core/2-3, or=d_core/2, fr=2, 
        wt=w_core, 
        ns=3, sw=3
        ) ;
}

module spool_end(shaft_d, shaft_nut_af, shaft_nut_t, core_d, bevel_d, outer_d, side_t, side_rim_t, w_spool_end) {
    r_inner = core_d/2-3 ;
    hub_t   = w_spool_end+side_t+spool_w_plug ;
    hub_r   = shaft_d+1 ;
    difference() {
        union() {
            spool_edge(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t
            );
            cylinder(r=r_inner-clearance, h=hub_t) ;
            bayonette_plug(
                lp=w_spool_end+side_t, lm=spool_w_plug, 
                ri=core_d/2-5, rm=r_inner-clearance, ro=core_d/2, hl=2, dl=6, nl=3
                ) ;
        } ;
        union() {
            translate([0,0,-delta]) {
                // Hub
                spoked_wheel_cutouts(hr=hub_r, sr=core_d/2-5, fr=2, 
                    wt=hub_t+2*delta, ns=3, sw=4) ;
                // Sppol edge
                spoked_wheel_cutouts(hr=core_d/2, sr=bevel_d/2-1, fr=3, 
                    wt=w_spool_end+side_t+2*delta, ns=6, sw=4) ;
            }
            shaft_hole(d=shaft_d, l=hub_t) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            translate([0,0,hub_t-shaft_nut_t])
                nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
        } ;
    }
} ;

module spool_middle(w_middle) {
    w_half  = w_middle/2+delta ;
    r_inner = core_d/2-3 ;
    difference() {
        union() {
            bayonette_socket(
                ls=w_half, lm=spool_w_plug, 
                ri=r_inner, rm=r_inner, ro=core_d/2, 
                hl=2, dl=6, nl=3) ;
            translate([0,0,w_middle]) {
                rotate([180,0,60])
                    bayonette_socket(
                        ls=w_half, lm=spool_w_plug, 
                        ri=r_inner, rm=r_inner, ro=core_d/2, 
                        hl=2, dl=6, nl=3) ;
            }
            // Pads for improved base adhesion:
            // break these off final printed assembly
            for (ra=[30, 150, 270])
                rotate([0,0,ra]) {
                    translate([core_d/2+1.5,0,-delta])
                        cylinder(d=8, h=0.2, $fn=10) ;
                }
        } ;
        union() {
            // Anti-rotation grooves
            // for (ra=[105, 225, 345])
            for (ra=[30, 150, 270])
                rotate([0,0,ra]) {
                    translate([core_d/2,0,-delta])
                        cylinder(d=2.6, h=w_middle+2*delta, $fn=10) ;
                }
        } ;
    }
} ;

module spool_middle_hub(w_hub) {
    // A push-in hub for the spool middle piece to support the spool when
    // one end has been removed.
    r_inner = core_d/2-3 ;
    difference() {
        cylinder(r=r_inner-clearance, h=w_hub) ;
        shaft_hole(d=spool_shaft_d, l=w_hub) ;
        translate([0,0,-delta]) {
            spoked_wheel_cutouts(hr=spool_shaft_d, sr=core_d/2-5, fr=2, 
                wt=w_hub+2*delta, ns=3, sw=4) ;
        }
    }

}

module spool_shim(w_shim) {
    dl = 6 ;
    hl = 2 ;
    rm = core_d/2-3 ;      // Radius of hole in shim
    ds = segment_corner_adjustment(rm, atan2(dl,rm)) ;
    difference() {
        cylinder(d=core_d, h=w_shim) ;
        translate([0,0,-delta]) {
            cylinder(r=rm, h=w_shim+2*delta) ;
            for (a=[0,120,240]) {
                rotate([0,0,a]) {
                    translate([rm-ds,0,0])
                        rotate([0,90,0])
                            cylinder(d1=dl, d2=radius_lug_top(dl, hl), h=hl+ds) ;
                }
            }
        }
    }
}

module spool_all_parts() {
    for (x=[-1,1]) {
        ////-spool_end
        translate([x*(outer_d),0,0])
        spool_end(
            shaft_d=spool_shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t,
            core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=spool_side_t, side_rim_t=spool_side_rim_t, w_spool_end=spool_w_end
            ) ;
        ////-spool_shim(w_shim)
        translate([x*(outer_d),outer_d,0])
        spool_shim(0.2) ;
    }
    ////-spool_middle(w_middle)
    translate([0,0,0])
        spool_middle(spool_w_mid) ;
    ////-spool_middle_hub(w_hub)
    //translate([0,outer_d,0])
    //    spool_middle_hub(w_hub=spool_w_end) ;
    ////-drive_pulley(shaft_d, shaft_nut_af, shaft_nut_t, drive_pulley_d)
    // Drive pulley with matching shaft dimension
    translate([0,outer_d,0])
        drive_pulley(
            shaft_d=spool_shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t, 
            drive_pulley_d=drive_pulley_d) ;
}

// All spool parts
// 
////-spool_all_parts()
spool_all_parts() ;

// Print spool middle separately with brim in slicer settings to prevent break away from base
////-spool_middle(w_middle)
//spool_middle(spool_w_mid) ;



////////////////////////////////////////////////////////////////////////////////
// Tape spool shaft adapters
////////////////////////////////////////////////////////////////////////////////

module m8_m4_nut_insert(sl) {
    // Insert for M8 nut recess to work with shaft and nut
    //
    // sl = Overall length of M8 shaft insert (including nut recess)
    //
    difference() {
        union() {
            cylinder(d=m8-m_clearance, h=sl, $fn=16) ;
            nut_recess(m8_nut_af-2*m_clearance, m8_slimnut_t) ;
        }
        translate([0,0,-delta]) {
            cylinder(d=m4, h=sl+m8, $fn=16) ;
            nut_recess(m4_nut_af, m4_nut_t) ;
        }
    }
}

////-m8_m4_nut_insert(sl)
// translate([0,10,0]) m8_m4_nut_insert(10) ;


module m8_m4_face_insert(fl,sl) {
    // Insert for M8 shaft hole for M4 shaft, with support flange
    //
    // fl = flange length(thickness)
    // sl = length of shaft insert (not including flange)
    //
    difference() {
        union() {
            cylinder(d=m8, h=sl+fl, $fn=16) ;
            cylinder(d=m8*2, h=fl, $fn=16) ;
        }
        translate([0,0,-delta]) {
            cylinder(d=m4, h=sl+fl+2*delta, $fn=16) ;
        }
    }
}

////-m8_m4_face_insert(sl)
// translate([0,30,0]) m8_m4_face_insert(2, 1) ;


module m8_m4_face_nut_insert(fl,sl) {
    // Insert for M8 shaft hole for M4 shaft, with support flange
    //
    // fl = flange length(thickness)
    // sl = length of shaft insert (not including flange)
    //
    difference() {
        union() {
            cylinder(d=m8, h=sl+fl, $fn=16) ;
            cylinder(d=m8*2, h=fl, $fn=16) ;
        }
        translate([0,0,-delta]) {
            cylinder(d=m4, h=sl+fl+2*delta, $fn=16) ;
            nut_recess(m4_nut_af, m4_slimnut_t) ;
        }
    }
}

////-m8_m4_face_nut_insert(sl)
// translate([0,50,0]) m8_m4_face_nut_insert(4, 1) ;


module m8_m4_shaft_slot(sl, tl, tw, tt) {
    // Shaft slot adapter for using an M4 shaft in an M8 slot
    //
    // sl = M8 shaft slot thickness
    // tl = tab length (between end radius centres)
    // tw = tab width
    // tt = tab thickness
    //
    flare_h  = 0.8 ;                  // Height of protruding retaining flare
    flare_d  = m8 + 1.5 ;                // Outer diameter of retaining flare
    insert_t = sl+tt+flare_h+clearance ;      // Overall thickness of insert
    difference() {
        union() {
            // oval(x, d, h)
            oval(tl, tw, tt) ;
            cylinder(d=m8, h=insert_t, $fn=16) ;
            translate([0,0,insert_t-flare_h]) 
                cylinder(d1=m8, d2=flare_d, h=flare_h, $fn=16) ;
        }
        translate([0,0,-delta])
            cylinder(d=m4, h=insert_t+2*delta, $fn=16) ;        
        translate([m8*0.25,0,-delta])
            oval(tl+m8, m4, insert_t+2*delta) ;
    }
}

////-m8_m4_shaft_slot(sl, tl, tw, tt)
// translate([0,70,0]) m8_m4_shaft_slot(4, 10, 12, 2) ;

////-m8_m4_adapter_set()
for (px=[-12,12] ) {
//     translate([px,10,0]) m8_m4_nut_insert(8) ;
//     translate([px,30,0]) m8_m4_face_insert(2, 1) ;
//     translate([px,50,0]) m8_m4_face_nut_insert(4, 1) ;
//     translate([px,70,0]) m8_m4_shaft_slot(4, 10, 12, 2) ;
} ;


////////////////////////////////////////////////////////////////////////////////
// Tape spool clip
////////////////////////////////////////////////////////////////////////////////

module tape_clip_cutout_shape(l, w, w1, w2, h) {
    // Cutout in spool clip to retain tape
    // Shape standing in X-Y plane with lower end at origin, 
    // length extending +Y, width extending +X
    //
    // l   = overall length of clip
    // w   = overall width of clip
    // w1  = width of clip gap
    // w2  = width of retaining bar
    // h   = height of extrusion
    //
    linear_extrude(height=h) {
        w3 = w - (w1+w2) ;  // Width of tongue cutout
        w4 = w2*2 ;         // Height of ends of retaining bar
        l2 = l * 0.5 ;      // Half height of clip
        l3 = l2 - w2*3 ;    // Height of half-tongue cutout
        //----
        // Single tongue cutout: doesn't print well with tall slender bar:
        // polygon(
        //     points=[
        //         [0,w1+w4], [0,l-(w1+w4)], 
        //         [w3,l-(w1+w4+w3)],
        //         [w3,(w1+w4+w3)] 
        //         ],
        //     paths=[[0,1,2,3,0]]
        //     ) ;
        //----
        // Separate trapezoidal cutouts allowing cross braces half way up
        polygon(
            points=[
                [0,w1+w4], [0,l2-w2], 
                [w3,l2-w2-w3],
                [w3,(w1+w4+w3)] 
                ],
            paths=[[0,1,2,3,0]]
            ) ;
        polygon(
            points=[
                [0,l-(w1+w4)], [0,l2+w2], 
                [w3,l2+w2+w3],
                [w3,l-(w1+w4+w3)] 
                ],
            paths=[[0,1,2,3,0]]
            ) ;
        //----
        // Triangle cutout between braces
        polygon(
            points=[
                [0,l2],
                [w3,l2+w3],
                [w3,l2-w3] 
                ],
            paths=[[0,1,2,0]]
            ) ;
        // Tape insertion slot
        //----
        // Curtaway as single shape:
        // (NOTE: doesn't print cleanly)
        // polygon(
        //     points=[
        //         [0,0], [0,w1], 
        //         [w-w1,w], [w-w1,l-w],
        //         [0,l-w1], [0,l],
        //         [w,l-w], [w,w]
        //         ],
        //     paths=[[0,1,2,3,4,5,6,7,0]]
        //     ) ;
        //----
        // Define as two halves with removable support to stabilize spool side while printing:
        // Bottom half
        support_h=0.2 ;  // Height of stabilizing support where it joins other pieces
        polygon(
            points=[
                [0,0], 
                [0,w1], 
                [w-w1,w], 
                [w-w1,    l2-support_h],
                [w-w1*0.5,l2-support_h],
                [w,       l2-support_h],
                [w,w]
                ],
            paths=[[0,1,2,3,4,5,6,0]]
            ) ;
        // Top half
        polygon(
            points=[
                [0,l], 
                [0,l-w1], 
                [w-w1,l-(w-w1)], 
                [w-w1,    l2+support_h],
                [w-w1*0.5,l2+support_h+w1*0],
                [w,       l2+support_h],
                [w,l-(w-w1)]
                ],
            paths=[[0,1,2,3,4,5,6,0]]
            ) ;
        //----
    }
}

////-tape_clip_cutout_shape(l, w, w1, w2, h)
//tape_clip_cutout_shape(100, 20, 3, 5, 30) ;

module tape_clip_cutout_pair(core_d, len, end) {
    // Pair of tape clip cutouts to be positioned each side of a spool rib,
    // where the spool rib is assumed to be on the +X axis
    //
    // core_d  = inner diameter of clip
    // len     = overall length of clip (width of spool)
    // end     = width of spool ends with no cutout for anti-rotation ribs
    //
    wo  = core_d*0.29 ; // Overall width of single cutout
    w1  = 2 ;           // width of clip gap
    w2  = 3 ;           // width of retaining bar
    w3  = 3 ;           // offset of tape clip from spool rib
    // Rotate to extrude in +X direction from Z-axis
    rotate([0,0,90]) {
        // Rotate to Y-Z plane
        rotate([90,0,0]) {
            // Define cutout shape and reflection, positioned on X-Y plane
            translate([w3,3*end,0])
                tape_clip_cutout_shape(len-6*end, wo, w1, w2, core_d*0.6) ;
            translate([-w3,3*end,0])
                mirror([1,0,0])
                    tape_clip_cutout_shape(len-6*end, wo, w1, w2, core_d*0.6) ;
        }
    }
}

////-tape_clip_cutout_pair(core_d, len, end)
// tape_clip_cutout_pair(core_d+0.8, spool_w_all-clearance, spool_w_end) ;

module spool_clip_closed(core_d, outer_d, flange_d, len, end) {
    // The spool clip is also intended to slide off the winder core
    //
    // core_d  = inner diameter of clip
    // outer_d = outer diameter of clip
    // len     = overall length of clip (width of spool)
    // end     = width of spool ends with no cutout for anti-rotation ribs
    //
    difference() {
        union () {
            difference() {
                union() {
                    cylinder(d=outer_d, h=len) ;
                    // Flange to protect tape, and for better print adhesion...
                    cylinder(d1=flange_d, d2=flange_d-4, h=0.65) ;
                }
                translate([0,0,-delta])
                    cylinder(d=core_d, h=len+2*delta) ;   // Core
            }
            // Anti-rotation ribs
            for (ar=[60,180,300])
                rotate([0,0,ar])
                    translate([core_d/2,0,end])
                        cylinder(d=2.2, h=len-2*end, $fn=10) ;
        }
        // Tape clip cutouts
        for (ar=[60,180,300])
            rotate([0,0,ar])
                tape_clip_cutout_pair(core_d, len, end) ;
    }
}

module spool_clip_open(core_d, outer_d, flange_d, len, end) {
    // The spool clip is also intended to slide off the winder core
    //
    // core_d  = inner diameter of clip
    // outer_d = outer diameter of clip
    // len     = overall length of clip (width of spool)
    // end     = width of spool ends with no cutout for anti-rotation ribs
    //
    difference() {
        spool_clip_closed(core_d, outer_d, flange_d, len, end) ;
        translate([outer_d*0.85,0,-delta])
            cylinder(d=outer_d, h=len+2*delta) ;  // Clip cutaway
    }
}

////-spool_clip_closed(core_d, outer_d, flange_d, len, end)
////-spool_clip_open(core_d, outer_d, flange_d, len, end)
//spool_clip_closed(core_d+0.8, core_d+3.8, bevel_d-2, spool_w_all-clearance, spool_w_end) ;

////////////////////////////////////////////////////////////////////////////////
// Tape spool full set of parts
////////////////////////////////////////////////////////////////////////////////

module spool_parts_old() {
    for (x=[0,1])
        translate([x*(outer_d*1.2),0,0])
            spool_end(
                shaft_d=shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t,
                core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=spool_side_t, side_rim_t=spool_side_rim_t, w_spool_end=spool_w_end
                );
    // translate([0,outer_d,0])
    //     spool_middle(spool_w_mid) ;
    // translate([0,0,0])
    //     spool_middle_hub(w_hub=spool_w_end) ;
}


////-spool_parts()
// spool_parts() ;

// ## spool_clips
//
// clip_len = spool_w_mid ;
// outer_d  = core_d+4 ;
// translate([-outer_d*0.75,0,0])  // 0.75 comes from 'spool_clip'
//     spool_clip(core_d, outer_d, clip_len) ;
// translate([+outer_d*0.75,0,0])
//     rotate([0,0,180])
//         spool_clip(core_d, outer_d, clip_len) ;
// cylinder(d=outer_d, h=0.4) ;    // Improve print adhesion - cut off later


// ## spool_with_spacers
//
// spool_with_spacers() ;
// translate([0,-spacing,0])
//     spool_with_spacers() ;


// End.
