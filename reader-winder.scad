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


// translate([spacing*2,spacing,0]) layout_winder() ;

// winder_side_support_slotted(r=145) ;
translate([0,+spacing*0.5,0]) winder_side_support_slotted(r=140) ;
translate([0,-spacing*0.5,0]) winder_side_support_slotted(r=-140) ;

clip_len = spool_w_all-15 ;
spool_clip(core_d, core_d+4, clip_len) ;


//             // Cutout to flex retaining lug
//             f_x1 = 0 ;
//             f_x2 = 2 ;
//             f_y  = shaft_d*0.75 ; // *sign(r) ;
//             f_d  = 2 ;
// translate([0,+spacing*0.5,0]) 
//             translate([f_x1, f_y  ,0])
//                 # oval(f_x2-f_x1, f_d, winder_side_t+delta*2) ;



// crank_handle(
//     crank_l=crank_l, 
//     shaft_d=shaft_d, crank_hub_d=crank_hub_d, 
//     handle_hub_d=handle_hub_d, handle_d=handle_d, 
//     crank_hub_t=crank_hub_t, crank_arm_t=crank_arm_t, handle_hub_t=crank_end_t
//     ) ;
