// monotype-tape-reader-winder.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;

module layout_winder() {
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


module spool_with_spacers() {
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
    translate([-spacing,spacing,0])
        spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;
    translate([0,spacing,0])
        spool_spacer(shaft_d=shaft_d, core_d=core_d, w_spacer=spool_w_mid/2, w_spool_end=spool_w_end) ;
}


// translate([spacing*2,spacing,0]) layout_winder() ;

// ## winder_side_supports
//
translate([spacing*0.5,-spacing*0.5,0]) winder_side_support_slotted(r=140) ;
translate([spacing*1.5,-spacing*0.5,0]) winder_side_support_slotted(r=-140) ;
translate([spacing*0.5,+spacing*0.5,0]) winder_side_support_slotted(r=140) ;
translate([spacing*1.5,+spacing*0.5,0]) winder_side_support_slotted(r=-140) ;

// ## spool_clips
//
// clip_len = spool_w_all-2 ;
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


// ## winder_crank_pulleys
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

