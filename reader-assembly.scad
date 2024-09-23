// reader-assembly.scad
//
// Monoscope (Monotype Tape reader) assembly


include <reader-defs.scad> ;

use <reader-baseplate.scad> ;
use <reader-camholder.scad> ;
use <reader-winder.scad> ;
use <reader-bridge.scad> ;
use <reader-electronics_mounting.scad> ;

offset   = 1 ;  // 1 for exploded assembly, 0.001 for actual assembly
offset_X = offset*40 ;
offset_Y = offset*40 ;
offset_Z = offset*40 ;

camera_Z            = 260 ;
electronics_Z       = 100 ;

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
bracket_hubd        = bracket_sd*1.5 ;                      // Shaft-suppoort hub diameter
bracket_od          = stepper_body_dia + bracket_fw*2 ;     // Holder outside diamater
bracket_mount_x     = (bracket_od*0.6) ;                    // X-offset of shaft from motor centre
bracket_mount_y     = bracket_od/2-bracket_hubd/2 ;         // Y-offset of shaft from motor centre

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
    yo = base_w/2 + rod_support_shell_w + offset_Y ;
    zo = rod_support_h + 2*offset_Z ;
    translate([xo, yo, zo])
        rotate([90,90,0])
            phone_holder_rod_support() ;
    translate([-xo, yo, zo])
        rotate([90,90,0])
            phone_holder_rod_support() ;
}


// Camera holder
module camera_holder() {
    xo = rod_support_base_o + 2*offset_X ;
    yo = base_w/2 + rod_support_shell_w ;
    zo = offset_Z ;

    translate([0,0,camera_Z+4*offset_Z]) {
        xo1 = xo - (hold_slot_o_x1 + hold_slot_o_x2)/2 ;
        yo1 = yo + hold_fix_plate_w/2 + hold_fix_o_y ;
        zo1 = 0 ;
        yoh = winder_side_t + hold_fix_rod_d ;
        translate([-xo1,yo1-yoh,zo1])
            rotate([0,0,180])
                phone_holder_rod_anti_rotation_plate() ;

        xo2 = xo  - (hold_short_slot_o_x1 + hold_short_slot_o_x2)/2 ;
        yo2 = yo - hold_fix_plate_w/2 + hold_fix_o_y ;
        zo2 = 0 ;
        translate([xo2,yo2-yoh,zo2])
            phone_holder_rod_adjusting_plate() ;

        xo3 = xo - hold_short_slot_o_x2 + 2*hold_fix_rod_d + hold_side_t1 ;
        yo3 = yo ;
        zo3 = hold_base_t + hold_base_offset + offset_Z ;
        translate([xo3,yo3-yoh,-zo3])
            rotate([-90,0,90])
                phone_camera_holder() ;

        xo4 = xo - hold_slot_o_x2 + 2*hold_fix_rod_d + 2*hold_side_t1 ;
        yo4 = yo ;
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
    zo = winder_side_h + 3*offset_Z ;
    translate([-xo,0,zo]) {
        translate([0,-yo,0])
            rotate([-90,90,0])
                spool_side_support_slotted(r=140, s_d=m6) ;
        translate([0,yo,0])
            rotate([90,90,0])
                spool_side_support_slotted(r=-140, s_d=m6) ;
    }
}

// Winder spool holder
module draw_spool_holder() {
    xo = base_l/2 - winder_side_w/2 + 2*offset_X ;
    yo = base_w/2 ;
    zo = winder_side_h + 3*offset_Z ;
    translate([xo,0,zo]) {
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
        loy = yo + 0.5*offset_Y ;
        loz = winder_apex_d*0.45 ;
        translate([-lox,-loy,-loz])
            rotate([90,150,0])
                swivel_arm_locking_brace(motor_swivel_l-4, bracket_fw, m3, m3_nut_af, m3_nut_t) ;

    }
}

// Read bridge supports and rollers
module reader_bridge() {
    yo = base_w/2 + 2*offset_Y ;
    zo = 2*offset_Z ;
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
            poy = yo + offset_Y/2 ;
            poz = read_h - guide_follower_pivot_x ;
            apy = side*90 - 90 ;  // zero or -180
            translate([pox,poy,poz])
                rotate([90,apy,0])
                    tape_follower_short_arm_no_elbow() ;
            translate([pox,-poy,poz])
                rotate([-90,apy,0])
                    tape_follower_short_arm_no_elbow() ;
            // Tape follower roller
            fox = pox + side*tape_follower_short_arm_l ;
            foy = guide_rim_overall_width/2 ;
            foz = poz ;
            translate([fox,foy,foz])
                rotate([90,0,0])
                    tape_follower_roller() ;
        }
    }
}

// Tape feed spool
module feed_spool() {
    xo = base_l/2 - winder_side_w/2 + 4*offset_X ;
    yo = base_w/2 ;
    zo = winder_side_h+3*offset_Z ;
    // Spool middle
    translate([-xo,spool_w_mid/2,zo])
        rotate([90,0,0])
            spool_middle(spool_w_mid) ;
    // Spool ends
    yoe = yo - spool_side_t - spool_w_end + offset_Y ;
    translate([-xo,yoe,zo])
        rotate([90,0,0])
            spool_end(
                shaft_d=spool_shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t,
                core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=spool_side_t, side_rim_t=spool_side_rim_t, w_spool_end=spool_w_end
                ) ;
    translate([-xo,-yoe,zo])
        rotate([-90,0,0])
            spool_end(
                shaft_d=spool_shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t,
                core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=spool_side_t, side_rim_t=spool_side_rim_t, w_spool_end=spool_w_end
                ) ;
    // Crank nuts and crank
    yon = yo + 2 + 0.5*offset_Y ;
    translate([-xo,-yon,zo])
        rotate([90,0,0])
            crank_handle_pushon_nut(m8_nut_af, 5, m4, m4_nut_af, m4_nut_t) ;
    translate([-xo,yon,zo])
        rotate([-90,0,0])
            crank_handle_pushon_nut(m8_nut_af, 5, m4, m4_nut_af, m4_nut_t) ;
    yoh = yon + 15 + 0.5*offset_Y ;
    translate([-xo,-yoh,zo])
        rotate([-90,0,0])
            crank_handle_pushon(
                shaft_d=shaft_d, crank_hub_d=18, crank_hub_t=7, 
                drive_nut_af=m8_nut_af, drive_nut_t=5, 
                crank_arm_l=crank_l, crank_arm_t=5, 
                handle_d=handle_d, handle_hub_d=handle_hub_d, handle_hub_t=6
                ) ;
    // Spool clip
    yoc = spool_w_all/2 ;
    translate([-xo,yoc,zo])
        rotate([90,0,0])
            spool_clip_closed(core_d+0.8, core_d+3.8, bevel_d-2, spool_w_all-clearance, spool_w_end) ;
}

// Tape draw spool (driven end)
module draw_spool() {
    xo = base_l/2 - winder_side_w/2 + 5*offset_X ;
    yo = base_w/2 ;
    zo = winder_side_h+3*offset_Z ;
    // Spool middle
    translate([xo,spool_w_mid/2,zo])
        rotate([90,0,0])
            spool_middle(spool_w_mid) ;
    // Spool ends
    yoe = yo - spool_side_t - spool_w_end + offset_Y ;
    translate([xo,yoe,zo])
        rotate([90,0,0])
            spool_end(
                shaft_d=spool_shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t,
                core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=spool_side_t, side_rim_t=spool_side_rim_t, w_spool_end=spool_w_end
                ) ;
    translate([xo,-yoe,zo])
        rotate([-90,0,0])
            spool_end(
                shaft_d=spool_shaft_d, shaft_nut_af=spool_shaft_nut_af, shaft_nut_t=spool_shaft_nut_t,
                core_d=core_d, bevel_d=bevel_d, outer_d=outer_d, 
                side_t=spool_side_t, side_rim_t=spool_side_rim_t, w_spool_end=spool_w_end
                ) ;
    // Drive pulley
    yop = yo + 5  + offset_Y ;
    translate([xo,-yop,zo])
        rotate([90,0,0])
            drive_pulley(
                shaft_d=shaft_d, shaft_nut_af=shaft_nut_af, shaft_nut_t=shaft_nut_t, drive_pulley_d=drive_pulley_d
            ) ;
    // Spool clip
    yoc = spool_w_all/2 ;
    translate([xo,yoc,zo])
        rotate([90,0,0])
            spool_clip_closed(core_d+0.8, core_d+3.8, bevel_d-2, spool_w_all-clearance, spool_w_end) ;
}


// Electronics mount rail
module electronics_mount() {
    holder_wdth = hold_fix_rod_d*2 ;
    holder_dpth = rod_support_base_t ;
    holder_hght = holder_dpth-holder_wdth/2 ;
    yo = base_w/2 + rod_support_shell_w - holder_hght + 3*offset_Y ;
    zo = electronics_Z + 2*offset_Z ;
    // Rail
    yor = yo + hold_fix_rod_d + mount_rail_t ;
    translate([0,yor,zo])
        rotate([90,0,0])
            electronics_mount_rail() ;
    // Rod clamp blocks
    xoc  = mount_rail_rod_p / 2 ;
    yoc1 = yo + hold_fix_rod_d - 0.4*offset_Y ;
    yoc2 = yo - hold_fix_rod_d - 1*offset_Y ;
    translate([xoc,yoc1,zo])
        rotate([90,0,0])
            rod_mounting_clamp(8,m4,m4_nut_af,m4_nut_t) ;
    translate([xoc,yoc2,zo])
        rotate([-90,0,0])
            rod_mounting_clamp(8,m4,m4_nut_af,m4_nut_t) ;
    translate([-xoc,yoc1,zo])
        rotate([90,0,0])
            rod_mounting_clamp(8,m4,m4_nut_af,m4_nut_t) ;
    translate([-xoc,yoc2,zo])
        rotate([-90,0,0])
            rod_mounting_clamp(8,m4,m4_nut_af,m4_nut_t) ;
    // Raspberry Pi mounting plate
    xop = 0 ;
    yop = yo + hold_fix_rod_d + mount_rail_t + offset_Y ;
    translate([xop,yop,zo])
       rotate([-90,0,0])
            pizero_rail_mount_plate() ;
}

// base_plate() ;
// rod_supports() ;
// camera_holder() ;
// feed_spool_holder() ;
// feed_spool() ;
// draw_spool_holder() ;
// draw_spool() ;
// reader_bridge() ;
// electronics_mount() ;

// Parts to print - black
module parts_to_print_black() {
    // reader_half_baseplate_1() ;
    reader_half_baseplate_2() ;
}
parts_to_print_black() ;


// Parts to print - white
module parts_to_print_white() {

    // translate([0,25,0])
    //     phone_holder_rod_support() ;
    // translate([0,75,0])
    //     phone_holder_rod_support() ;

    // translate([0,-50,0])
    //     phone_holder_rod_anti_rotation_plate() ;

    // translate([-30,75,0])
    //     stepper_swivel_bracket(
    //         stepper_body_dia, bracket_fw, bracket_ft, 
    //         stepper_hole_dia, stepper_hole_pitch, stepper_nut_af, -1) ;
    // translate([-75,50,0])
    //     spool_and_swivel_mount_side_support(5, -1, s_d=m6) ;

    // translate([0,-25,0])

    // translate([-60,25,0])
    //     pizero_rail_mount_plate() ;
    // translate([0,-20,0])
    //     electronics_mount_rail() ;

}
// parts_to_print_white() ;

// Parts to print - brown/dark
module parts_to_print_brown() {

}
// parts_to_print_brown() ;



