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
                pulley(crank_hub_d, drive_pulley_t) ;
            translate([crank_l/2,0,crank_arm_t/2]) 
                cube(size=[crank_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([crank_l,0,0]) 
                cylinder(d=handle_hub_d, h=handle_hub_t) ;
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
        } ;
    }
}

module drive_pulley(shaft_d, drive_pulley_d) {
    // Spoked pulley
    intersection() {
        difference() {
            union() {
                cylinder(d=drive_pulley_d, h=drive_pulley_t*0.5) ;
                translate([0,0,drive_pulley_t*0.5-delta])
                    pulley(drive_pulley_d, drive_pulley_t) ;
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

// Crank and drive pulley instances
//
// crank_handle(
//     crank_l=crank_l, 
//     shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
//     handle_hub_d=handle_hub_d, handle_d=handle_d, 
//     crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=crank_end_t
//     ) ;
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


// spool_side_support instances
//
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
    winder_y    = -outer_d*0.7*side ;
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

// spool_and_winder_side_support instances
//
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
stepper_hole_pitch  = 35 ;

bracket_sd          = m4 ;
bracket_fw          = 3 ;
bracket_hubd        = bracket_sd*2.6 ;
bracket_od          = stepper_body_dia + bracket_fw*2 ;
bracket_mount_x     = (bracket_od-bracket_hubd/2) ;
bracket_mount_y     = bracket_od/2-bracket_hubd/2 ;

module stepper_bracket(bd, hd, hp, side=+1) {
    fw   = bracket_fw ;     // Width of surrounding frame
    sd   = bracket_sd ;     // Bracket end shaft diameter
    hubd = bracket_hubd ;   // Bracket end hub diameter
    hubr = hubd/2 ;
    od   = bd + fw*2 ;      // Outside diameter of bracket frame
    r    = 1 ;
    x1   = -stepper_wire_width/2+r ;
    x2   = -x1 ;
    y1   = -stepper_body_dia/2-stepper_wire_height+r ;
    y2   = 0 ;
    difference() {
        union() {
            // body ring
            cylinder(d=od, h=winder_side_t) ;
            // wire cover extension
            rounded_rectangle_plate(x1,y1, x2,y2, r+fw, winder_side_t) ;
            // mounting lugs
            oval_xy(
                -stepper_hole_pitch/2,0,
                stepper_hole_pitch/2,0, 
                d=stepper_hole_dia*2, h=winder_side_t
            ) ;
            // Winder bracket mounting arm:
            // brace_xy(x1, y1, x2, y2, w, d1, d2, h)
            brace_xy(
                bracket_mount_x*side, bracket_mount_y,  // x1, y1
                0, (od/2-hubr)*-0.5,                    // x2, y2
                sd*2, hubd, sd, winder_side_t           // w, d1, d2, h
                ) ;
        }
        // Cutaway:
        hc = winder_side_t + 2*delta ;
        translate([0,0,-delta]) {
            //   body
            cylinder(d=bd, h=hc) ;
            //   L mounting hole
            translate([-stepper_hole_pitch/2,0,0])
                cylinder(d=hd, h=hc) ;
            //   R mounting hole
            translate([+stepper_hole_pitch/2,0,0])
                cylinder(d=hd, h=hc) ;
            //   countersink for mounting screw
            translate([bracket_mount_x*side, bracket_mount_y, winder_side_t+delta])
                countersinkZ(od=sd*2, oh=winder_side_t+delta*2, sd=sd, sh=winder_side_t) ;
            //   wire entry cover (rounded rect r=1)
            rounded_rectangle_plate(x1,y1, x2,y2, r, hc) ;
            //   wire entry
            translate([0,0,winder_side_t-1.8])
                rectangle_plate(-3,y1-r-fw-1,+3,0,hc) ;
        }
    }
}

module stepper_bracket_sleeve() {
    washer_t = 2 ;
    sleeve_h = winder_side_t+washer_t ;
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


stepper_bracket(stepper_body_dia, stepper_hole_dia, stepper_hole_pitch) ;

stepper_bracket_sleeve() ;

// Combined spool and stepper motor bracket
// NOTE: this has the cutrout for stepper motor wires on the wrong side
//       One-part print is probably not great for this.
//
// translate([-bracket_mount_x,-bracket_mount_y,0])
//     stepper_bracket(stepper_body_dia, stepper_hole_dia, stepper_hole_pitch) ;
// winder_x    = winder_apex_d/2 ;
// winder_y    = -outer_d*0.7 ;
// rotate([0,0,-90])
//     translate([-winder_x, -winder_y, 0]) 
//         spool_and_winder_side_support(+1) ;


////////////////////////////////////////////////////////////////////////////////
// Stepper motor pulley
////////////////////////////////////////////////////////////////////////////////

module stepper_shaft(sd, af, sl) {
    intersection() {
        cylinder(d=sd, h=sl, center=false, $fn=12) ;
        translate([-sd/2,-af/2,0])
            cube(size=[sd, af, sl], center=false) ;
    }
}
// stepper_shaft(5, 3, 25) ;

module stepper_pulley(pd, pt, hd, ht, sd, af) {
    difference() {
        union() {
            // pulley
            pulley(pd, pt) ;
            // hub
            cylinder(d=hd, h=pt+ht, center=false, $fn=48) ;
        }
    translate([0,0,-delta]) {
        // shaft hole
        stepper_shaft(sd, af, pt+ht+2*delta) ;
        // Spoke cutouts (not for small pulley)
        spoked_wheel_cutouts(hr=hd/2+2, sr=(pd-pt)/2-1, fr=2, wt=pt+2*delta, ns=6, sw=3) ;
        }
    }
}

pulley_dia       = 40 ;   // Small: 20; spool: drive_pulley_d (==60)
pulley_width     = 6 ;
pulley_hub_dia   = 10 ; 
pulley_hub_width = 3 ; 
pulley_shaft_dia = 5.3 ;
pulley_shaft_af  = 3.1 ;

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


module spool_middle_hub(w_hub) {
    // A push-in hub for the spool moddile piece to support the spool when
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

// spool_middle_hub(w_hub=spool_w_end) ;


////////////////////////////////////////////////////////////////////////////////
// Tape spool clip
////////////////////////////////////////////////////////////////////////////////

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
                    // Flance to protect tape, and for better print adhesion...
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
