// Default dimensions

m_clearance = 0.25 ;    // Clearance for close-clearance holes
m3 = 3+m_clearance ;    // Close clearance hole for M3 screw
m4 = 4+m_clearance ;    // Close clearance hole for M4 screw
m5 = 5+m_clearance ;    // Close clearance hole for M5 screw
m8 = 8+m_clearance ;    // Close clearance hole for M8 screw

m3_nut_af    = 5.5 ;    // M3 nut a/f size
m3_nut_t     = 2.1 ;    // M3 nut thickness (for recess)
m3_hinge_dia = 7.5 ;    // M3 hinge knuckle diametert

m4_nut_af    = 7 ;      // M4 nut a/f size
m4_nut_t     = 3.1 ;    // M4 nut thickness (for recess)
m4_slimnut_t = 2.5 ;    // M4 slim nut thickness (for recess)
m4_nylock_t  = 4.3 ;    // M4 nylock nut thickness (for recess)

m8_nut_af    = 13 ;     // M8 nut a/f size
m8_nut_t     = 6.5 ;    // M8 nut thickness (for recess)
m8_slimnut_t = 4 ;      // M8 slim nut thickness (for recess)

// Monotype system parameters

// 159/50 = 3.18
// 285.5/90 = 3.172
mt_sprocket_pitch = 3.2 ;   // was: 159/50; paper was riding up on pins after about 20 holes
mt_sprocket_dia   = 1.6 ;   // was: 1.5
mt_sprocket_width = 104.3 ; // Between sprocket hole rows
mt_overall_width  = 110 ;   // Overall width of tape
mt_paper_tickness = 0.08 ;  // Thickness of paper tape

// Winder

small_shaft_d      = m4 ;           // Shaft diameter
small_shaft_nut_af = m4_nut_af ;    // Nut diameter across faces
small_shaft_nut_t  = m4_nut_t ;     // Nut thickness

// shaft_d      = small_shaft_d ;
// shaft_nut_af = small_shaft_nut_af ;
// shaft_nut_t  = small_shaft_nut_t ;

shaft_d      = m8 ;                 // Shaft diameter
shaft_nut_af = m8_nut_af ;          // Nut diameter across faces
shaft_nut_t  = m8_slimnut_t ;       // Nut thickness

core_d = 40 ;           // Core diameter
bevel_d = 72 ;          // Bevel inner diameter
outer_d = 80 ;          // Spool outer diameter
crank_hub_d = 25 ;      // Diameter of crank hub
drive_pulley_d = 60 ;   // Diameter of drive pulley
drive_pulley_t = 10 ;   // Thickness of drive pulley
handle_hub_d = 10 ;     // Diameter of handle end of crank
handle_d = m4 ;         // Diameter of handle
base_fix_d = m4 ;       // Diameter of base fixing screw hole
sup_t = 4 ;             // Default thickness for side supports @@was side_t

crank_l = 40 ;          // Length of crank (between shaft and handle centres

crank_hub_t = 16 ;      // Thickness of crank hub
crank_arm_t = 6 ;       // Thickness of crank arm
crank_end_t = 8 ;       // Thickness of crank handle hub (at end of arm)

spool_side_t = 2.5 ;    // Thickness of carrier spool side
spool_side_rim_t = 1 ;  // Thickness of carrier spool side rim (bevelled)
spool_w_all = 114 ;     // Width of spool (overall between ends)
spool_w_end = 5 ;       // Width of spool (to inside of end)
spool_w_plug = 8 ;      // Width of spool-end plug overlap
spool_w_mid = spool_w_all - 2*spool_w_end ;
                        // width of spool middle spacer


handle_nut_af = 7 ;     // Nut diameter across faces
handle_nut_t  = 3 ;     // Nut thickness

winder_side_h = 60 ;    // Height to centre of winder shaft
winder_side_w = 40 ;    // Width base of winder side support
winder_side_t = sup_t ; // Thickness of winder side support
winder_apex_d = 19 ;    // Diameter of apex of winder side support
winder_base_t = 16 ;    // Thickness at base of winder

motor_support_l = 40 ;  // Length of motor mount support arm
motor_support_a = 20 ;  // Angle of motor mount support arm


// Reader bridge

read_w = 16 ;           // Width of bridge
read_extra_w = 5 ;      // Extra length for reader bridge for tie-down

read_h = 90 ;           // Height of reader bridge above base plate
read_side_t = sup_t ;   // Reader bridge side support thickness
read_side_base_t = 16 ; // Reader bridge side support thickness at base 
read_total_l     = spool_w_all + 2*(read_side_t + read_extra_w) ;
read_side_apex_w = 24 ;
read_side_apex_h = 6 ;
read_side_base_w = 40 ;
read_side_peg_d  = m4 ;

read_groove_w = 2.4 ;   // EL wire groove width
read_groove_d = 2.75 ;  // EL wire groove depth

guide_w  = 28 ;         // Width of guide flange on bridge
guide_tc = 2 ;          // Guide thickness at core
guide_tr = 1 ;          // Guide thickness at rim
guide_tb = guide_tc-guide_tr ;  // Guide thickness of bevel
guide_eld = 5.5 ;       // EL wire threading hole diameter
guide_ist = 3 ;         // EL wire shade inner overhang thickness
guide_ost = (read_total_l-spool_w_all)/2+1 ; // EL wire shade outer overhang thickness


// Parts for holding phone camera

hold_side_l = 80 ;      // Length is side of holder
hold_side_h = 12 ;      // Height of side above base
hold_side_t1 = 8 ;      // Thickness of side at base
hold_side_t2 = 10 ;     // Thickness of side at top

hold_base_l1 = 60 ;     // Length of base near side
hold_base_l2 = 50 ;     // Length of base towards centre
hold_base_t = 8 ;       // Thickness of base (to accommodate hole)
hold_base_w = 20 ;      // Width of base piece
hold_base_offset = 4 ;  // Thickness of standoff for clamp nut clearance

hold_rail_p = 40 ;      // Distance between rail holes
hold_rail_d = m4 ;      // Diameter of rail holes

hold_fix_p   = 25 ;     // Distance between fixing holes
hold_fix_d   = m4 ;     // Diameter of fixing holes
hold_nut_t   = 3.1 ;    // Thickness of holder fixing nut
hold_nut_af  = 6.9 ;    // Size across faces of holder fixing nut recess (tight fit)
hold_fix_o_x = 20 ;     // X-offset from vertical rod to holder fixing holes
hold_fix_o_y = 0 ;      // Y-offset from vertical rod to centre between fixing holes

// Dimensions for phone holder-to-rod attachment plate

hold_fix_t = 6 ;        // Thickness of plate (Z)
hold_fix_w = 8 ;        // Width of plate to shoulder (X)
hold_fix_l = 80 ;       // Length of phone holder-to-rod fixing (Y)
hold_fix_rod_d = 8 ;    // Diameter of phone holder support rod
hold_fix_hub_d = 16 ;   // Diameter of phone holder support hub

hold_fix_plate_l = hold_fix_o_x + hold_fix_rod_d ;
hold_fix_plate_w = hold_fix_p + hold_fix_rod_d*2 ;

// Dimensions for long slot plate to prevent rotation of camera

hold_slot_o_x1 = 60 ;   // Start of anti-rotation slot
hold_slot_o_x2 = 100 ;  // end of anti-rotation slot

// Dimensions for short slot plate to allow sideways adjustment of camera

hold_short_slot_o_x1 = 15 ;   // Start of adjustment slot
hold_short_slot_o_x2 = 40 ;   // end of adjustment slot

// Bracket to hold phone camera support rod

rod_support_h = 50 ;
rod_support_t = sup_t ;     // Rod support side support thickness
rod_support_base_t = 20 ;   // Rod support side support thickness at base 
rod_support_base_o = 89 ;   // X-offset from reader bar to phone support rod

rod_support_apex_w = 24 ;
rod_support_base_w = 45 ;
rod_support_shell_w = 24 ;

// Baseplate dimensions

base_l   = 360 ; // was 300, 240, 400 ;
base_w   = 130 ;
base_t   = 4 ;
border_w = 8 ;
shell_h  = 8 ;
brace_w  = 8 ;
mount_l  = winder_side_w ;
mount_w  = winder_base_t ;

mount_hole_d = m4 ;
mount_nut_t  = 3 ;
mount_nut_af = 7 ;

foot_lx  = 36 ;     // At top surface of baseplate: tapers away to foot
foot_ly  = 26 ;
foot_h   = 14 ;

plate_px = base_l/2 ;
plate_py = base_w/2 ;

// Misc
delta = 0.01 ;          // Small value to force overlap
clearance = 0.1 ;       // Clearance for close-fitting objects
spacing = outer_d+10 ;  // Object spacing (layout pitch)
part_gap = 10 ;         // Spacing between exploded assembly parts

