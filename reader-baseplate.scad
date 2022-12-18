// baseplate.scad

include <reader-defs.scad> ;

use <reader-common.scad> ;

module rect_frame(lx, ly, t, w) {
    // Rectangular frame on X-Y plane, centred on the origin
    //
    // lx = overall X extent
    // ly = overall Y extent
    // t  = thickness of frame
    // w  = width of frame borders
    //
    translate([0,0,t/2]) {
        difference() { 
            cube(size=[lx, ly, t], center=true) ;
            cube(size=[lx-w*2, ly-w*2, t+delta*2], center=true) ;
        }
    }
}


module rect_shell(lx, ly, t, w, h) {
    // Rectangular shell on X-Y plane, centred on the origin, consisting
    // of a rectangular frame and sides.
    //
    // lx = overall X extent
    // ly = overall Y extent
    // t  = thickness of frame and sides
    // w  = width of frame borders
    // h  = height of sides
    //
    union() {
        rect_frame(lx, ly, t, w) ;
        rect_frame(lx, ly, h, t) ;
    }
}

module diagonal_brace(lx, ly, t, w, flip=false) {
    // Rectangular diagonal brace on X-Y plane, centred on the origin:
    // fits into 'rect_frame' with same dimensions
    //
    // lx = overall X extent
    // ly = overall Y extent
    // t  = thickness of brace
    // w  = width of diagonal_brace
    // flip = if False than align lower-left to upper-right
    //        if true then align upper-left to lower-right
    //
    rot_angle = flip ? atan2(ly, lx) : atan2(-ly, lx) ;
    translate([0,0,t/2]) {
        intersection() {
            cube(size=[lx, ly, t], center=true) ; // clip region
            rotate([0,0,rot_angle])
                cube(size=[lx+ly, w, t], center=true) ;  // "stock" bar for cross-brace
        }
    }
}

module cross_brace_y(ly, px, t, w) {
    // Rectangular Y-spanning brace on X-Y plane, centred on the origin:
    //
    // ly = overall Y extent
    // px = X position
    // t  = thickness of brace
    // w  = width of brace
    //
    translate([0,0,t/2]) {
        cube(size=[w, ly, t], center=true) ;
    }
}

module mount_hole_nut_holder(x, y, tp, hd, tn, af) {
    // Cutaway for mounting hole and nut holder, situated on X-Y plane
    //
    // x  = X-centre of mounting hole
    // y  = Y-centre of mounting hole
    // tp = thickness of mounting plate
    // tn = thickness of nut holder
    // hd = hole diameter
    // af = nut size across faces
    //
    translate([x, y, -delta])
        cylinder(d=hd, h=tp+tn+2*delta) ;
    translate([x, y, tp])
        nut_recess(af, tn+delta) ;
}

// mount_hole_nut_holder(200, 0, base_t, mount_hole_d, mount_nut_t, mount_nut_af) ;

module mount_holes(lx, ly, t, hp, hd, nt, af, px=0, py=0) {
    // Mounting holes on X-axis for mounting plate, including cutaway for nut.
    //
    // Defined separately so they can be applied to a merged shape.
    //
    // Holes are centred within the Y-extent of the plate not including an outer shall,
    // which is presumed to be the same thickness as the plate itself.
    //
    // lx = overall X extent of plate
    // ly = overall Y extent of plate
    // t  = thickness of plate
    // hp = hole pitch (between centres)
    // hd = mounting hole diameter
    // nt = mounting nut thickness
    // af = mounting nut size across faces
    // px = position of plate corner - sign determines which corner
    // px = position of plate corner - sign determines which corner
    //
    tx = ( px < 0 ? (px+lx/2)
         : px > 0 ? (px-lx/2)
         : 0 ) ;
    ty = ( py < 0 ? (py+(ly+t)/2)
         : py > 0 ? (py-(ly+t)/2)
         : 0 ) ;

    // translate([tx,ty,t/2]) {
    //     union() {
    //         translate([-hp/2,0,0]) cylinder(t+delta*2, d=hd, center=true) ;
    //         translate([ hp/2,0,0]) cylinder(t+delta*2, d=hd, center=true) ;
    //     }
    // }
    mount_hole_nut_holder(tx-hp/2, ty, t, hd, nt, af) ;
    mount_hole_nut_holder(tx+hp/2, ty, t, hd, nt, af) ;
}

module mount_plate(lx, ly,  t, hp, hd, nt, af, px=0, py=0) {
    // Mounting plate on X-Y plane, on frame corner/edge, with 2 mounting holes on X-axis.
    // (use 'translate' to position on baseplate)
    // (use 'rotate' to change orientaton)
    //
    // lx = overall X extent of plate
    // ly = overall Y extent of plate
    // t  = thickness of baseplate (nut thickness is added)
    // hp = mounting hole pitch (between centres)
    // hd = mounting hole diameter
    // nt = mounting nut thickness
    // af = mounting nut size across faces
    // px = position of plate corner - sign determines which corner
    // px = position of plate corner - sign determines which corner
    //
    tx = ( px < 0 ? (px+lx/2)
         : px > 0 ? (px-lx/2)
         : 0 ) ;
    ty = ( py < 0 ? (py+ly/2)
         : py > 0 ? (py-ly/2)
         : 0 ) ;
    difference() {
        translate([tx,ty,(t+nt)/2]) {
            cube(size=[lx, ly, t+nt], center=true) ; // plate
        }
        mount_holes(lx, ly,  t, hp, hd, nt, af, px, py) ;
    }
}

module corner_support_foot(lx, ly, t, h, px, py) {
    // Support foot on X-Y plane, on frame corner
    //
    // lx = overall X extent of foot
    // ly = overall Y extent of foot
    // t  = thickness of foot
    // h  = height of foot
    // px = position of plate corner - sign determines which corner
    // px = position of plate corner - sign determines which corner
    //
    ra = 30*sign(px)*sign(py) ;
    intersection() {
        rect_frame(abs(px)*2, abs(py)*2, h, t) ;    // clip from rectangular shell
        translate([px,py,-h])             // clip_profile for angled feet
            rotate(a=ra, v=[-px,py,0])
                linear_extrude(height=h*4, center=true) 
                    polygon([ [-lx,0], [0,-ly], [+lx,0], [0,+ly] ]) ;
    }        
}

module side_support_foot_x(l, h, t, px, py) {
    // Support foot on X-axis-aligned edge of frame
    //
    // l  = length of support foot
    // h  = height of support foot
    // t  = thickness of support foot
    // px = X position of centre of foot 
    // py = Y position of outside of foot
    //
    translate([px, py-sign(py)*t/2, h/2]) {
        intersection() {
            cube(size=[l, t, h], center=true) ;  // "stock" bar for foot
            translate([-h/2,0,0])
                rotate([0,-30,0])
                    cube(size=[l, t, l], center=true) ;
            translate([+h/2,0,0])
                rotate([0,+30,0])
                    cube(size=[l, t, l], center=true) ;
        }
    }

}

module baseplate_clamp(l, w, h, l1, h1, h2, d) {
    // l  = overall length of clamp (excluding rounded ends)
    // w  = width of clamp
    // h  = overall height of clamp
    // l1 = length of clamp bridge
    // h1 = height (from base) of clamp bridge
    // h2 = height (from base) of clamp hook end
    // d  = diameter of screw hole
    //
    difference() {
        oval(l, w, h) ;
        translate([l1/2,0,h-h1/2])
            cube(size=[l1, w+delta, h1+delta], center=true) ;
        translate([-w/2,0,h-h2/2])
            cube(size=[w+delta, w+delta, h2+delta], center=true) ;
        translate([l,0,0])
            // flip through x-y plane: reverse z-axis
            mirror(v=[0,0,1]) 
                countersinkZ(d*2, h+2*delta, d, h+delta) ;
    }
}

// Test clamp
// baseplate_clamp(20, 10, 12, 8, 9, 6, 5) ;

// Tests
// rect_frame(100, 60, 4, 6);
// rect_shell(100, 60, 4, 6, 12);
// diagonal_brace(100, 60, 4, 8) ;
// diagonal_brace(100, 60, 4, 6, true) ;
// diagonal_brace(100, 60, 4, 6, false) ;
// cross_brace_y(60, 0, 4, 6) ;

// mount_plate(20, 16, 4, 12, 4, px=+44, py=+28) ;
// mount_plate(20, 16, 4, 12, 4, 0,      py=+28) ;
// mount_plate(20, 16, 4, 12, 4, px=-44, py=+28) ;
// mount_plate(20, 16, 4, 12, 4, px=+44, py=-28) ;
// mount_plate(20, 16, 4, 12, 4, px=0,   py=-28) ;
// mount_plate(20, 16, 4, 12, 4, px=-44, py=-28) ;
 
// lx = 30 ;
// ly = 20 ;
// px = 50 ;
// py = -30 ;
// 
// ra = 30*sign(px)*sign(py) ;
// 
// translate([px,py,-5])
// rotate(a=ra, v=[-px,py,0])
// linear_extrude(height=50, center=true) polygon([[-lx,0], [0,-ly], [+lx,0], [0,+ly] ]) ;

// rect_shell(100, 60, 4, 6, 6);
// corner_support_foot(30, 20, 4, 10, +50, +30) ;
// corner_support_foot(30, 20, 4, 10, +50, -30) ;
// corner_support_foot(30, 20, 4, 10, -50, +30) ;
// corner_support_foot(30, 20, 4, 10, -50, -30) ;
// side_support_foot_x(30, 10, 4, 0, +30) ;
// side_support_foot_x(30, 10, 4, 0, -30) ;

// Baseplate

// base_l   = 240 ;
// base_w   = 130 ;
// base_t   = 4 ;
// border_w = 8 ;
// shell_h  = 8 ;
// brace_w  = 8 ;
// mount_l  = winder_side_w ;
// mount_w  = winder_base_t ;
// mount_hole_d   = m4 ;
// 
// foot_lx  = 30 ;
// foot_ly  = 20 ;
// foot_h   = 12 ;
// 
// plate_px = base_l/2 ;
// plate_py = base_w/2 ;

module rod_support_mounting_plate() {
    // rod support mounting plate, centred on origin
    difference() {
        union() {
            rect_shell(rod_support_base_w, rod_support_shell_w, base_t, border_w, shell_h) ;
            mount_plate(rod_support_base_w, rod_support_base_t, base_t, 
                        rod_support_base_w/2, hold_fix_d, hold_nut_t, hold_nut_af,
                        px=0, py=-rod_support_shell_w/2) ;
            side_support_foot_x(foot_lx, foot_h, base_t, 0, -rod_support_shell_w/2) ;
        } ;
        // mount_holes(rod_support_base_w, rod_support_base_t, base_t, 
        //             rod_support_base_w/2, hold_fix_d, hold_nut_t, hold_nut_af,
        //             px=0, py=-rod_support_shell_w/2) ;
    }
}

module main_reader_baseplate() {
    difference() {
        union() {

            rect_shell(base_l, base_w, base_t, border_w, shell_h) ;
            cross_brace_y(base_w, 0, base_t, brace_w) ;
            diagonal_brace(base_l, base_w, base_t, brace_w, flip=false) ;
            diagonal_brace(base_l, base_w, base_t, brace_w, flip=true) ;

            // Various mounting plates
            mount_plate(mount_l, mount_w, base_t, 
                        winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                        px=+plate_px, py=+plate_py ) ;
            mount_plate(mount_l, mount_w, base_t, 
                        winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af,  
                        px=+plate_px, py=-plate_py) ;
            mount_plate(mount_l, mount_w, base_t, 
                        winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                        px=-plate_px, py=+plate_py ) ;
            mount_plate(mount_l, mount_w, base_t, 
                        winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                        px=-plate_px, py=-plate_py) ;
            mount_plate(mount_l, mount_w, base_t, 
                        read_side_base_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                        px=0, py=+plate_py) ;
            mount_plate(mount_l, mount_w, base_t, 
                        read_side_base_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                        px=0, py=-plate_py) ;
            // Additional braces for mounting plates
            // rect_shell(lx, ly, t, w, h)
            rect_shell(mount_l+(border_w*2), base_w, base_t, border_w, shell_h) ;

            // Support feet
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, +base_l/2, +base_w/2) ;
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, +base_l/2, -base_w/2) ;
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, -base_l/2, +base_w/2) ;
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, -base_l/2, -base_w/2) ;
            side_support_foot_x(foot_lx, foot_h, base_t, 0, +base_w/2) ;
            side_support_foot_x(foot_lx, foot_h, base_t, 0, -base_w/2) ;
        } ;
        // Cutaways for mount holes
        mount_holes(mount_l, mount_w, base_t, 
                    winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                    px=+plate_px, py=+plate_py ) ;
        mount_holes(mount_l, mount_w, base_t, 
                    winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                    px=+plate_px, py=-plate_py) ;
        mount_holes(mount_l, mount_w, base_t, 
                    winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                    px=-plate_px, py=+plate_py ) ;
        mount_holes(mount_l, mount_w, base_t, 
                    winder_side_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                    px=-plate_px, py=-plate_py) ;
        mount_holes(mount_l, mount_w, base_t, 
                    read_side_base_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                    px=0, py=+plate_py) ;
        mount_holes(mount_l, mount_w, base_t, 
                    read_side_base_w/2, mount_hole_d, mount_nut_t, mount_nut_af, 
                    px=0, py=-plate_py) ;
    }
}

module reader_baseplate() {
    // Combine main baseplate with rod support plate
    main_reader_baseplate() ;
    translate([-rod_support_base_o, -base_w/2 - rod_support_shell_w/2,0]) {
        rod_support_mounting_plate() ;
    }
    translate([+rod_support_base_o,-base_w/2 - rod_support_shell_w/2,0]) {
        rod_support_mounting_plate() ;
    }

    // Rod support frame
    rod_support_base_l = rod_support_base_o*2-rod_support_base_w+base_t ;
    //translate([0,-base_w/2 - rod_support_shell_w/2,0]) {
    //    rect_shell(rod_support_base_l, rod_support_shell_w, base_t, base_t /*border_w*/ , shell_h) ;
    //}

    // Rod support bracing
    // rod_support_brace_l = (base_l-rod_support_base_l)/2 + base_t ; // full length of base plate
    // translate([-(base_l-rod_support_brace_l)/2,0,0])
    //     rect_shell(rod_support_brace_l, base_w, base_t, border_w, shell_h) ;
    rod_support_brace_l = rod_support_base_w ; // Brace each side of mounting plate
    translate([-(rod_support_base_o),0,0])
        rect_shell(rod_support_base_w, base_w, base_t, border_w, shell_h) ;
    translate([+(rod_support_base_o),0,0])
        rect_shell(rod_support_base_w, base_w, base_t, border_w, shell_h) ;
}

module reader_half_baseplate_cutaway() {
    cutaway_l = base_l/2 + delta ;
    cutaway_w = base_w + 2*rod_support_shell_w + 2*delta ;
    cutaway_h = foot_h + 2*delta ;
    notch_h   = border_w/4 ;
    notch_o   = (base_w/2) - border_w ;
    translate([0, 0, cutaway_h/2-delta])
        linear_extrude(height=cutaway_h, center=true) 
            polygon([ [0,-cutaway_w/2]
                    , [0,(-notch_h*2)-notch_o], [-notch_h,(-notch_h)-notch_o], [+notch_h,(+notch_h)-notch_o], [0,(+notch_h*2)-notch_o]
                    , [0,(-notch_h*2)], [-notch_h,(-notch_h)], [+notch_h,(+notch_h)], [0,(+notch_h*2)]
                    , [0,(-notch_h*2)+notch_o], [-notch_h,(-notch_h)+notch_o], [+notch_h,(+notch_h)+notch_o], [0,(+notch_h*2)+notch_o]
                    , [0,+cutaway_w/2]
                    , [+cutaway_l, +cutaway_w/2]
                    , [+cutaway_l, -cutaway_w/2]
                    , [0,-cutaway_w/2]
                    ]) ;
}

module reader_half_baseplate_1() {
    difference () {
        reader_baseplate() ;
        reader_half_baseplate_cutaway() ;
    }
}

module reader_half_baseplate_2() {
    difference () {
        reader_baseplate() ;
        rotate( [0,0,180] )
            reader_half_baseplate_cutaway() ;
    }
}

// rod_support_mounting_plate() ;

// main_reader_baseplate() ;

// reader_baseplate() ;

// translate( [-10,0,0] )
//     reader_half_baseplate_1() ;

translate( [+10,0,0] )
    reader_half_baseplate_2() ;

// for (offset = [0,border_w*4])
//     translate([0,offset,0])
//         baseplate_clamp(border_w*2.5, 12, foot_h+base_t, border_w+0.1, foot_h, foot_h-2, 5) ;

