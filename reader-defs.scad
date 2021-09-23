// Default dimensions


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

read_l = spool_w_all ;  // Reader bridge length (inner)
read_w = 16 ;           // Width of bridge
read_extra_w = 5 ;      // Extra width for reader bridge for tie-down
read_h = 90 ;           // Height of reader bridge above base plate
read_side_t = side_t ;  // Reader bridge side support thickness
read_side_base_t = 16 ; // Reader bridge side support thickness at base 
read_side_apex_w = 24 ;
read_side_apex_h = 4 ;
read_side_base_w = 40 ;
read_side_peg_d  = 4 ;

read_groove_w = 2.25 ;  // EL wire goove width
read_groove_d = 3 ;     // EL wire groove depth


delta = 0.01 ;          // Small value to force overlap
spacing = outer_d+10 ;  // Object spacing (layout pitch)
part_gap = 10 ;         // Spacing between exploded assembly parts

