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
                pulley(crank_hub_d, crank_hub_t) ;
            translate([crank_l/2,0,crank_arm_t/2]) 
                cube(size=[crank_l,handle_hub_d,crank_arm_t], center=true) ;
            translate([crank_l,0,0]) 
                cylinder(d=handle_hub_d, h=handle_hub_t) ;
        } ;
        union() {
            shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
            nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            translate([crank_l,0,0]) {
                //shaft_hole(d=handle_d, l=crank_hub_t) ;
                nut_recess(af=handle_nut_af, t=handle_nut_t) ;
                translate([0,0,handle_hub_t])
                    countersinkZ(od=handle_d*2,oh=crank_hub_t, sd=handle_d, sh=handle_hub_t) ;
            }
        } ;
    }
}

module drive_pulley(shaft_d, drive_pulley_d) {
    intersection() {
        difference() {
            union() {
                cylinder(d=drive_pulley_d, h=crank_hub_t) ;
                translate([0,0,crank_hub_t-delta])
                    pulley(drive_pulley_d, crank_hub_t) ;
            } ;
            union() {
                shaft_hole(d=shaft_d, l=crank_hub_t*2) ;
                nut_recess(af=shaft_nut_af, t=shaft_nut_t) ;
            } ;
        }
    spoked_wheel(
        hr=shaft_d, sr=drive_pulley_d/2-crank_hub_t*0.6, or=drive_pulley_d, fr=3, 
        wt=crank_hub_t*2, 
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
        shaft_hole(shaft_d, winder_side_t) ;
        }

}

module spool_side_support_slotted(r=145) {
    // Winder support with slot for removing shaft
    //
    // r  = angle of rotation of slot from vertical
    //
    difference() {
        s_ox  = 0.50 ;           // Slot offset diameter multiplier
        f_xm = shaft_d*s_ox/2 ;  // Mid-point of flex cutout
        f_oy = -0.675*shaft_d ;  // Y-offset of flex cutout
        f_d  = 1.7 ;             // width of flex cutout
        f_l  = 6.0 ;             // Length flex cutout (excl radius ends)
        spool_side_support() ;
        // Cutout to allow spool to be removed
        rotate([0,0,r]) {
            translate([shaft_d*s_ox,0,-delta])
                oval(shaft_d, shaft_d, winder_side_t+delta*2) ;
            // Cutouts to flex retaining lugs
            translate([f_xm-f_l/2, f_oy, 0])
                oval(f_l, f_d, winder_side_t+delta*2) ;
            translate([f_xm-f_l/2, -f_oy, 0])
                oval(f_l, f_d, winder_side_t+delta*2) ;
        } 
    }    
}

// spool_side_support instances
//
// translate([spacing*0.5,-spacing*0.5,0]) spool_side_support_slotted(r=140) ;
// translate([spacing*1.5,-spacing*0.5,0]) spool_side_support_slotted(r=-140) ;
// translate([spacing*0.5,+spacing*0.5,0]) spool_side_support_slotted(r=140) ;
// translate([spacing*1.5,+spacing*0.5,0]) spool_side_support_slotted(r=-140) ;


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


////////////////////////////////////////////////////////////////////////////////
// Tape spool clip
////////////////////////////////////////////////////////////////////////////////

module spool_clip(core_d, outer_d, len, end) {
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
                    // Rim for better print adhesion...
                    cylinder(d1=outer_d+5, d2=core_d, h=0.4) ;
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
        translate([outer_d*0.85,0,-delta])
            cylinder(d=outer_d, h=len+2*delta) ;  // Clip cutaway
        // translate([0,0,0])
        //     rotate([0,-90,0])
        //         shaft_slot(len*0.25, len*0.75, 0, core_d*0.75, outer_d+delta*2) ;
        translate([0,0,len/2])
            rotate([0,90,0])
                translate([-len*0.4,0,-outer_d*0.5-delta])
                    lozenge(len*0.8, core_d*0.4, core_d*0.8, outer_d+2*delta) ;
        translate([0,0,len/2])
            rotate([90,0,0])        // Prisms align Y
                rotate([0,0,90]) {  // Points align Y
                    translate([+len*0.02,0,-outer_d*0.5-delta])
                        lozenge(len*0.38, core_d*0.2, core_d*0.4, outer_d+2*delta) ;
                    translate([-len*0.40,0,-outer_d*0.5-delta])
                        lozenge(len*0.38, core_d*0.2, core_d*0.4, outer_d+2*delta) ;
                }
    }
}

spool_clip(core_d+clearance, core_d+3, spool_w_all-clearance, spool_w_end) ;

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



////////////////////////////////////////////////////////////////////////////////
// Obsolete design elements?
////////////////////////////////////////////////////////////////////////////////

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

module spool_with_spacers() {
    translate([-spacing,0,0])
        spool_end(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([0,0,0])
        spool_end(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([-spacing,spacing,0])
        spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;
    translate([0,spacing,0])
        spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;
}

module winder_assembly() {
    // Spool and crank handle
    spool_pos_x   = side_t + spool_w_all/2 + part_gap/2 ;
    winder_side_x = winder_side_t + spool_w_all/2 + part_gap/2 + part_gap ;
    winder_pos_x  = winder_side_x + 2*part_gap ;
    translate([-spool_pos_x,0,winder_side_h])
        rotate([0,90,0])
            spool_end(
                shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
                );
    translate([spool_pos_x,0,winder_side_h])
        rotate([0,-90,0])
            spool_end(
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
                    crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, 
                    handle_hub_t=crank_end_t
                    ) ;
    // Winder supports
    translate([winder_side_x,0,winder_side_h])
        rotate([0,90,180])
            spool_side_support() ;
    translate([-winder_side_x,0,winder_side_h])
        rotate([0,90,0])
            spool_side_support() ;
}

// winder_assembly()

module layout_winder() {
    // Spools
    translate([-spacing,0,0])
        spool_end(
            shaft_d=shaft_d, core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
            side_t=side_t, side_rim_t=side_rim_t, w_spool_end=spool_w_end
            );
    translate([0,0,0])
        spool_end(
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
        spool_side_support() ;
    translate([-spacing,spacing,0])
        spool_side_support() ;
}

// translate([spacing*2,spacing,0]) layout_winder() ;


