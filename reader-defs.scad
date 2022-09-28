// Default dimensions

m4 = 4.2 ;              // Close clearance hole for M4 screw
m8 = 8.2 ;              // Close clearance hole for M8 screw


// Winder

shaft_d = m8 ;          // Shaft diameter
core_d = 40 ;           // Core diameter
bevel_d = 72 ;          // Bevel inner diameter
outer_d = 80 ;          // Spool outer diameter
crank_hub_d = 25 ;      // Diameter of crank hub
drive_pulley_d = 60 ;   // Diameter of drive pulley
handle_hub_d = 10 ;     // Diameter of handle end of crank
handle_d = m4 ;         // Diameter of handle
base_fix_d = m4 ;       // Diameter of base fixing screw hole

crank_l = 40 ;          // Length of crank (between shaft and handle centres

side_t = 2.5 ;          // Thickness of spool side
side_rim_t = 1 ;        // Thickness of spool side rim (bevelled)
crank_hub_t = 8 ;      // Thickness of crank hub
crank_arm_t = 6 ;       // Thickness of crank arm
crank_end_t = 8 ;       // Thickness of crank handle hub (at end of arm)

spool_w_all = 114 ;     // Width of spool (overall between ends)
spool_w_end = 5 ;       // Width of spool (to inside of end)
spool_w_plug = 8 ;      // Width of spool-end plug overlap
spool_w_mid = spool_w_all - 2*spool_w_end ;
                        // width of spool middle spacer

shaft_nut_af = 13 ;     // Nut diameter across faces
shaft_nut_t  = 4 ;      // Nut thickness

handle_nut_af = 7 ;     // Nut diameter across faces
handle_nut_t  = 3 ;     // Nut thickness

winder_side_h = 60 ;    // Height to centre of winder shaft
winder_side_w = 40 ;    // Width base of winder side support
winder_side_t = 4 ;     // Thickness of winder side support
winder_apex_d = 19 ;    // Radius of apex of winder side support
winder_base_t = 16 ;    // Thickness at base of winder

// Reader bridge

read_l = spool_w_all ;  // Reader bridge length (inner)
read_w = 16 ;           // Width of bridge
read_extra_w = 5 ;      // Extra length for reader bridge for tie-down

guide_w  = 28 ;         // Width of guide flange on bridge
guide_tc = 2 ;          // Guide thickness at core
guide_tr = 1 ;          // Guide thickness at rim
guide_tb = guide_tc-guide_tr ;  // Guide thickness of bevel
guide_eld = 4.5 ;       // EL wire threading hole diameter
tension_bar_d = 4 ;     // Tensioning bar diameter

read_h = 90 ;           // Height of reader bridge above base plate
read_side_t = side_t ;  // Reader bridge side support thickness
read_side_base_t = 16 ; // Reader bridge side support thickness at base 
read_total_l     = spool_w_all + 2*(read_side_t + read_extra_w) ;
read_side_apex_w = 24 ;
read_side_apex_h = 6 ;
read_side_base_w = 40 ;
read_side_peg_d  = m4 ;

read_groove_w = 2.25 ;  // EL wire goove width
read_groove_d = 2.5 ;   // EL wire groove depth

// Parts for holding phone camera

hold_side_l = 80 ;      // Length is side of holder
hold_side_h = 10 ;      // Height of side above base
hold_side_t1 = 7 ;      // Thickness of side at base
hold_side_t2 = 8 ;      // Thickness of side at top

hold_base_l1 = 60 ;     // Length of base near side
hold_base_l2 = 50 ;     // Length of base towards centre
hold_base_t = 8 ;       // Thickness of base (to accommodate hole)
hold_base_w = 20 ;      // Width of base piece

hold_rail_p = 40 ;      // Distance between rail holes
hold_rail_d = m4 ;      // Diameter of rail holes

hold_fix_p = 25 ;       // Distance between fixing holes
hold_fix_d = m4 ;       // Diameter of fixing holes
hold_fix_o_x = 12 ;     // X-offset from vertical rod to holder fixing holes
hold_fix_o_y = 0 ;      // Y-offset from vertical rod to centre between fixing holes

hold_fix_t = 6 ;        // Thickness of phone holder-to-rod fixing
hold_fix_w = 8 ;        // Width of phone holder-to-rod fixing
hold_fix_l = 80 ;       // Length of phone holder-to-rod fixing
hold_fix_rod_d = 8 ;    // Diameter of phone holder support rod
hold_fix_hub_d = 16 ;   // Diameter of phone holder support hub

hold_fix_plate_l = hold_fix_o_x + hold_fix_rod_d*2 ;
hold_fix_plate_w = hold_fix_p + hold_fix_rod_d*2 ;

hold_slot_o_x1 = 25 ;   // Start of anti-rotation slot
hold_slot_o_x2 = 100 ;  // end of anti-rotation slot

hold_slot_plate_l = hold_slot_o_x2 + hold_fix_rod_d ;

// Bracket to hold phone camera support rod

rod_support_h = 50 ;
rod_support_t = side_t ;    // Rod support side support thickness
rod_support_base_t = 20 ;   // Rod support side support thickness at base 
rod_support_base_o = 89 ;   // X-offset from reader bar to phone support rod

rod_support_apex_w = 24 ;
rod_support_base_w = 45 ;
rod_support_shell_w = 24 ;

// Baseplate dimensions

base_l   = 400 ; // was 240 ;
base_w   = 130 ;
base_t   = 4 ;
border_w = 8 ;
shell_h  = 8 ;
brace_w  = 8 ;
mount_l  = winder_side_w ;
mount_w  = winder_base_t ;
hole_d   = m4 ;

foot_lx  = 36 ;     // At top surface of baseplate: tapers away to foot
foot_ly  = 26 ;
foot_h   = 14 ;

plate_px = base_l/2 ;
plate_py = base_w/2 ;

// Misc
delta = 0.01 ;          // Small value to force overlap
spacing = outer_d+10 ;  // Object spacing (layout pitch)
part_gap = 10 ;         // Spacing between exploded assembly parts

