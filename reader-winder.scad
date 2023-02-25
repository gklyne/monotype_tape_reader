// monotype-tape-reader-winder.scad
//
// This module defines tape spools and components for drawing the tape over 
// the read head

include <reader-defs.scad> ;
include <common-components.scad> ;

////////////////////////////////////////////////////////////////////////////////
// Winder and drive pulley
////////////////////////////////////////////////////////////////////////////////

module crank_handle(
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

module drive_pulley(shaft_d, drive_pulley_d) {
    extra_pulley_t = drive_pulley_t*0.0 ;  // Extra pulley thickness for hub recess, etc.
    intersection() {
        difference() {
            union() {
                cylinder(d=drive_pulley_d, h=extra_pulley_t) ;
                translate([0,0,extra_pulley_t-delta])
                    // pulley(drive_pulley_d, drive_pulley_t) ;
                    pulley_round_belt(drive_pulley_d, drive_pulley_t, drive_pulley_t-1) ;
            } ;
            union() {
                shaft_hole(d=shaft_d, l=drive_pulley_t*2) ;
                nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            } ;
        }
    spoked_wheel(
        hr=shaft_d, sr=drive_pulley_d/2-crank_hub_t*0.6, or=drive_pulley_d, fr=3, 
        wt=crank_hub_t*1.5, 
        ns=6, sw=3
        ) ;
    }
}

////-crank_handle(
////        crank_l, 
////        shaft_d, crank_hub_d, handle_hub_d, handle_d, 
////        crank_hub_t, crank_arm_t, handle_hub_t)
// crank_handle(
//     crank_l=crank_l, 
//     shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
//     handle_hub_d=handle_hub_d, handle_d=handle_d, 
//     crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=crank_end_t
//     ) ;

////-drive_pulley(shaft_d, drive_pulley_d)
// drive_pulley(shaft_d=shaft_d, drive_pulley_d=drive_pulley_d) ;
// translate([0,spacing,0])
//     drive_pulley(shaft_d=shaft_d, drive_pulley_d=drive_pulley_d) ;
// translate([spacing,spacing,0])
//     drive_pulley(shaft_d=shaft_d, drive_pulley_d=drive_pulley_d) ;


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
        s_ox  = 0.50 ;           // Slot offset diameter multiplier
        f_xm = shaft_d*s_ox/2 ;  // Mid-point of flex cutout
        f_oy = -0.660*shaft_d ;  // Y-offset of flex cutout
        f_d  = 1.7 ;             // width of flex cutout
        f_l  = 7.0 ;             // Length flex cutout (excl radius ends)
        winder_side_spacer_h = winder_side_t+0.5 ;
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
                oval(shaft_d, shaft_d, winder_side_spacer_h+delta*2) ;
            // Cutouts to flex retaining lugs
            translate([f_xm-f_l/2, f_oy, 0])
                oval(f_l, f_d, winder_side_spacer_h+delta*2) ;
            translate([f_xm-f_l/2, -f_oy, 0])
                oval(f_l, f_d, winder_side_spacer_h+delta*2) ;
            // Remove part of spacer ring
            translate([shaft_d*0.4,-shaft_d,winder_side_t+delta])
                cube(size=[shaft_d*2, shaft_d*2, winder_side_spacer_h]) ;
        } 
    }    
}


////-spool_side_support_slotted(r=145)
// translate([spacing*0.5,-spacing*0.5,0]) spool_side_support_slotted(r=140) ;
// translate([spacing*1.5,-spacing*0.5,0]) spool_side_support_slotted(r=-140) ;
// translate([spacing*0.5,+spacing*0.5,0]) spool_side_support_slotted(r=140) ;
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
// translate([spacing*0.5,-spacing*0.75,0]) spool_and_winder_side_support(-1) ;
// translate([spacing*0.5,+spacing*0.75,0]) spool_and_winder_side_support(+1) ;


////////////////////////////////////////////////////////////////////////////////
// Stepper motor bracket
////////////////////////////////////////////////////////////////////////////////

stepper_body_dia    = 29.5 ;
stepper_body_height = 31.5 ;    // Includes wire entry cover
stepper_wire_height = 2 ;       // Height of wire entry cover (beyond body radius)
stepper_wire_width  = 19 ;      // Width of wire entry cover
stepper_hole_dia    = m4 ;
stepper_nut_af      = 7 ;
stepper_hole_pitch  = 35 ;

bracket_sd          = m8 ;                                  // Bracket shaft hole diameter
bracket_fw          = 4 ;                                   // Width of frame around motor
bracket_ft          = winder_side_t+12 ;                     // Thickness of frame and brace
bracket_hubd        = bracket_sd*1.5 ;                      // Shaft-suppoort= hub diameter
bracket_od          = stepper_body_dia + bracket_fw*2 ;     // Holder outside diamater
bracket_mount_x     = (bracket_od*0.6) ;                    // X-offset of shaft from motor centre
bracket_mount_y     = bracket_od/2-bracket_hubd/2 ;         // Y-offset of shaft from motor centre

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
// stepper_bracket(stepper_body_dia, bracket_fw, bracket_ft, 
//    stepper_hole_dia, stepper_hole_pitch, stepper_nut_af) ;
// stepper_bracket_sleeve() ;

// Combined spool and stepper motor bracket
//
// dir  +1/-1 to select orientation
//
module spool_and_motor_side_support(dir) {
    winder_x    = winder_apex_d/2 ;
    winder_y    = -outer_d*0.6 ;
    // Stepper bracket, translating attachment point to origin
    translate([-bracket_mount_x*dir,-bracket_mount_y,0])
        stepper_bracket(
            stepper_body_dia, bracket_fw, bracket_ft, 
            stepper_hole_dia, stepper_hole_pitch, stepper_nut_af, 
            dir
            ) ;
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
// spool_and_motor_side_support(-1) ;


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
stepper_pulley(pulley_dia, pulley_width, pulley_hub_dia, pulley_hub_width, pulley_shaft_dia, pulley_shaft_af) ;

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

module spool_end(shaft_d, core_d, bevel_d, outer_d, side_t, side_rim_t, w_spool_end) {
    r_inner = core_d/2-3 ;
    difference() {
        union() {
            spool_edge(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t
            );
            cylinder(d=core_d, h=w_spool_end+side_t) ;
            bayonette_plug(
                lp=w_spool_end+side_t, lm=spool_w_plug, 
                ri=core_d/2-5, rm=r_inner-clearance, ro=core_d/2, hl=2, dl=6, nl=3
                ) ;
        } ;
        union() {
            translate([0,0,-delta]) {
                spoked_wheel_cutouts(hr=shaft_d, sr=core_d/2-5, fr=2, 
                    wt=w_spool_end+side_t+2*delta, ns=3, sw=4) ;
                spoked_wheel_cutouts(hr=core_d/2, sr=bevel_d/2-1, fr=3, 
                    wt=w_spool_end+side_t+2*delta, ns=6, sw=4) ;
            }
            shaft_hole(d=shaft_d, l=w_spool_end+side_t) ;
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
        } ;
        union() {
            // Anti-rotation grooves
            // for (ra=[105, 225, 345])
            for (ra=[30, 150, 270])
                rotate([0,0,ra])
                    translate([core_d/2,0,-delta])
                        cylinder(d=2.6, h=w_middle+2*delta, $fn=10) ;
        } ;
    }
} ;

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

////-spool_shim(w_shim)
//spool_shim(0.2) ;


module spool_middle_hub(w_hub) {
    // A push-in hub for the spool middle piece to support the spool when
    // one end has been removed.
    r_inner = core_d/2-3 ;
    difference() {
        cylinder(r=r_inner-clearance, h=w_hub) ;
        shaft_hole(d=shaft_d, l=w_hub) ;
        translate([0,0,-delta]) {
            spoked_wheel_cutouts(hr=shaft_d, sr=core_d/2-5, fr=2, 
                wt=w_hub+2*delta, ns=3, sw=4) ;
        }
    }

}

////-spool_middle_hub(w_hub)
// spool_middle_hub(w_hub=spool_w_end) ;


////////////////////////////////////////////////////////////////////////////////
// Tape spool clip
////////////////////////////////////////////////////////////////////////////////

module spool_clip_closed_old(core_d, outer_d, flange_d, len, end) {
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
        translate([0,0,len/2])
            rotate([0,90,0])
                translate([-len*0.37,0,-outer_d*0.5-delta])
                    lozenge(len*0.74, core_d*0.5, core_d*0.7, outer_d+2*delta) ;
        translate([0,0,len/2])
            rotate([90,0,0])        // Prisms align Y
                rotate([0,0,90]) {  // Points align Y
                    translate([+len*0.02,0,-outer_d*0.5-delta])
                        lozenge(len*0.38, core_d*0.25, core_d*0.4, outer_d+2*delta) ;
                    translate([-len*0.40,0,-outer_d*0.5-delta])
                        lozenge(len*0.38, core_d*0.25, core_d*0.4, outer_d+2*delta) ;
                }
    }
}


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
                [w-w1*0.5,l2+support_h+w1*0.5],
                [w,       l2+support_h],
                [w,l-(w-w1)]
                ],
            paths=[[0,1,2,3,4,5,6,0]]
            ) ;
        //----
    }
}

////-tape_clip_cutout_shape(l, w, w1, w2, h)
// tape_clip_cutout_shape(100, 20, 3, 5, 30) ;

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
            // Define cutout shape and reflection, poisitioned on X-Y plane
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
// spool_clip_closed(core_d+0.8, core_d+3.8, bevel_d-2, spool_w_all-clearance, spool_w_end) ;

////////////////////////////////////////////////////////////////////////////////
// Tape spool full set of parts
////////////////////////////////////////////////////////////////////////////////

module spool_parts() {
    for (x=[0,1])
        translate([x*(outer_d*1.2),0,0])
            spool_end(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
                );
    translate([0,outer_d,0])
        spool_middle(spool_w_mid) ;
    translate([0,0,0])
        spool_middle_hub(w_hub=spool_w_end) ;
    // translate([outer_d*1.2,outer_d,0])
    //     spool_clip(core_d, core_d+4, spool_w_mid) ;
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
