// reader-assembly.scad
//
// Monoscope (Monotype Tape reader) assembly

offset_X = 30 ;
offset_Y = 20 ;
offset_Z = 20 ;


include <reader-defs.scad> ;

use <reader-baseplate.scad> ;
use <reader-camholder.scad> ;
use <reader-winder.scad> ;
use <reader-bridge.scad> ;

// Base plate
module base_plate() {
    rotate([180,0,0]) {
    translate( [-2*offset_X,0,0] )
        reader_half_baseplate_1() ;
    translate( [+2*offset_X,0,0] )
        reader_half_baseplate_2() ; 
    }
}

// Rod supports
module rod_supports() {
    xo = rod_support_base_o + 2*offset_X ;
    yo = base_w/2+rod_support_shell_w ;
    zo = rod_support_h + offset_Z ;
    translate([xo, yo, zo])
        rotate([90,90,0])
            phone_holder_rod_support() ;
    translate([-xo, yo, zo])
        rotate([90,90,0])
            phone_holder_rod_support() ;
}


// Camera holder
module camera_holder() {
    translate([0,0,200+3*offset_Z]) {
        xo1 = rod_support_base_o + 2*offset_X - (hold_slot_o_x1+hold_slot_o_x2)/2 ;
        yo1 = base_w/2 + rod_support_shell_w + hold_fix_plate_w/2 + hold_fix_o_y ;
        zo1 = 0 ;
        yoh = winder_side_t + hold_fix_rod_d ;
        translate([-xo1,yo1-yoh,zo1])
            rotate([0,0,180])
                phone_holder_rod_anti_rotation_plate() ;

        xo2 = rod_support_base_o + 2*offset_X  - (hold_short_slot_o_x1 + hold_short_slot_o_x2)/2 ;
        yo2 = base_w/2 + rod_support_shell_w - hold_fix_plate_w/2 + hold_fix_o_y ;
        zo2 = 0 ;
        translate([xo2,yo2-yoh,zo2])
            phone_holder_rod_adjusting_plate() ;

        xo3 = rod_support_base_o + 2*offset_X - hold_short_slot_o_x2 + 2*hold_fix_rod_d + hold_side_t1 ;
        yo3 = base_w/2 + rod_support_shell_w ;
        zo3 = hold_base_t + hold_base_offset + offset_Z ;
        translate([xo3,yo3-yoh,-zo3])
            rotate([-90,0,90])
                phone_camera_holder() ;

        xo4 = rod_support_base_o + 2*offset_X - hold_slot_o_x2 + 2*hold_fix_rod_d + 2*hold_side_t1 ;
        yo4 = base_w/2 + rod_support_shell_w ;
        zo4 = hold_base_t + hold_base_offset + offset_Z ;
        translate([-xo4,yo4-yoh,-zo4])
            rotate([-90,0,-90])
                phone_camera_holder() ;
    }
}

// Feed spool holder
module feed_spool_holder() {
    xo = base_l/2 - winder_side_w/2 + 2*offset_X ;
    yo = base_w/2 ;
    translate([-xo,0,winder_side_h+2*offset_Z]) {
        translate([0,-yo,0])
            rotate([-90,90,0])
                spool_side_support_slotted(r=140, s_d=m6) ;
        translate([0,yo,0])
            rotate([90,90,0])
                spool_side_support_slotted(r=-140, s_d=m6) ;
    }
}

// Winder spool holder
module winder_spool_holder() {

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

    xo = base_l/2 - winder_side_w/2 + 2*offset_X ;
    yo = base_w/2 ;
    translate([xo,0,winder_side_h+2*offset_Z]) {
        // Spool holder sides
        translate([0,-yo,0])
            rotate([90,0,180])
                spool_and_swivel_mount_side_support(5, -1, s_d=m6) ;
        translate([0,yo,0])
            rotate([90,90,0])
                spool_side_support_slotted(r=140, s_d=m6) ;
        // Hinged motor bracket
        mox = motor_support_l + stepper_body_dia ;
        moz = winder_side_h - motor_support_l*sin(motor_support_a) ;
        translate([-mox,-yo,-moz])
            rotate([-90,0,0])
                stepper_swivel_bracket(
                    stepper_body_dia, bracket_fw, bracket_ft, 
                    stepper_hole_dia, stepper_hole_pitch, stepper_nut_af, -1) ;
        // Motor bracket locking arm
        lox = winder_apex_d*0.55 + 5 ;
        loy = yo + offset_Y ;
        loz = winder_apex_d*0.45 ;
        translate([-lox,-loy,-loz])
            rotate([90,150,0])
                swivel_arm_locking_brace(motor_swivel_l-4, bracket_fw, m3, m3_nut_af, m3_nut_t) ;

    }
}

module reader_bridge() {
    yo = base_w/2 + 2*offset_Y ;
    zo = offset_Z ;
    translate([0,0,zo]) {
        // Side supports
        translate([0, -yo,0])
            rotate([0,90,90])
                translate([-read_h,0,0])
                    reader_bridge_side_support_dovetailed() ;
        translate([0, yo,0])
            rotate([0,90,-90])
                translate([-read_h,0,0])
                    reader_bridge_side_support_dovetailed() ;
        // Bridge
        translate([0,0,read_h]) {
            rotate([0,0,90])
                tape_reader_bridge_dovetailed() ;
        }
        for (side=[-1,+1]) {
            // Guide sprockets
            sox = side*guide_sprocket_sep/2 ;
            soy = guide_rim_overall_width/2 ;
            soz = read_h - guide_sprocket_ht_off ;
            translate([sox,soy,soz])
                rotate([90,0,0])
                    sprocket_tape_guide() ;
            // Guide rollers
            rox = side*guide_roller_centre_y ;
            roy = guide_rim_overall_width/2 ;
            roz = read_h - guide_roller_centre_x ;
            translate([rox,roy,roz])
                rotate([90,0,0])
                    roller_tape_guide() ;
            // Follower arms
            pox = side*guide_follower_pivot_y ;
            poy = base_w/2 + 3*offset_Y ;
            poz = read_h - guide_follower_pivot_x ;
            apy = side*90 - 90 ;  // zero or -180
            translate([pox,poy,poz])
                rotate([90,apy,0])
                    tape_follower_short_arm_no_elbow() ;
            translate([pox,-poy,poz])
                rotate([-90,apy,0])
                    tape_follower_short_arm_no_elbow() ;
            // Tape followers
            fox = pox + side*tape_follower_short_arm_l ;
            foy = guide_rim_overall_width/2 ;
            foz = poz ;
            translate([fox,foy,foz])
                rotate([90,0,0])
                    tape_follower_roller() ;
        }
    }
}




base_plate() ;
rod_supports() ;
camera_holder() ;
feed_spool_holder() ;
winder_spool_holder() ;
reader_bridge() ;

