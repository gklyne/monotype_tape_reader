// baseplate.scad

include <reader-defs.scad> ;

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

module mount_holes(lx, ly, t, hp, hd, px=0, py=0) {
    // Mounting holes on X-axis for mounting plate.
    // Defined separately so they can be applied toa merged shape.
    //
    // Holes are centred within the Y-extent of the plate not including an outer shall,
    // which is presumed to be the same thickness as the plate itself.
    //
    // lx = overall X extent of plate
    // ly = overall Y extent of plate
    // t  = thickness of plate
    // hp = hole pitch (between centres)
    // hd = hole diameter
    // px = position of plate corner - sign determines which corner
    // px = position of plate corner - sign determines which corner
    //
    tx = ( px < 0 ? (px+lx/2)
         : px > 0 ? (px-lx/2)
         : 0 ) ;
    ty = ( py < 0 ? (py+(ly+t)/2)
         : py > 0 ? (py-(ly+t)/2)
         : 0 ) ;
    translate([tx,ty,t/2]) {
        union() {
            translate([-hp/2,0,0]) cylinder(t+delta*2, d=hd, center=true) ;
            translate([ hp/2,0,0]) cylinder(t+delta*2, d=hd, center=true) ;
        }
    }
}

module mount_plate(lx, ly,  t, hp, hd, px=0, py=0) {
    // Mounting plate on X-Y plane, on frame corner/edge, with 2 mounting holes on X-axis.
    // (use 'translate' to position on baseplate)
    // (use 'rotate' to change orientaton)
    //
    // lx = overall X extent of plate
    // ly = overall Y extent of plate
    // t  = thickness of plate
    // hp = hole pitch (between centres)
    // hd = hole diameter
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
        translate([tx,ty,t/2]) {
            cube(size=[lx, ly, t], center=true) ; // plate
        }
        mount_holes(lx, ly,  t, hp, hd, px, py) ;
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
                    polygon([[-lx,0], [0,-ly], [+lx,0], [0,+ly] ]) ;
    }        
}

//module side_support_foot(l, t, h, px, py) {
//    // @@TODO?
//    0
//}

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

    base_l   = 240 ;
    base_w   = 130 ;
    base_t   = 4 ;
    border_w = 8 ;
    shell_h  = 8 ;
    brace_w  = 8 ;
    mount_l  = winder_side_w ;
    mount_w  = 20 ;
    hole_d   = 4 ;

    foot_lx  = 30 ;
    foot_ly  = 20 ;
    foot_h   = 12 ;

    plate_px = base_l/2 ;
    // plate_py = base_w/2-base_t ;
    plate_py = base_w/2 ;

module rod_support_mounting_plate() {
    // rod support mounting plate, centred on origin
    difference() {
        union() {
            rect_shell(rod_support_base_w, rod_support_shell_w, base_t, border_w, shell_h) ;
            mount_plate(rod_support_base_w, rod_support_base_t, base_t, 
                        rod_support_base_w/2, hold_fix_d, px=0, py=-rod_support_shell_w/2) ;
            side_support_foot_x(foot_lx, foot_h, base_t, 0, -rod_support_shell_w/2) ;
        } ;
        mount_holes(rod_support_base_w, rod_support_base_t, base_t, 
                    rod_support_base_w/2, hold_fix_d, px=0, py=-rod_support_shell_w/2) ;
    }
}

module main_reader_baseplate() {
    difference() {
        union() {

            rect_shell(base_l, base_w, base_t, border_w, shell_h) ;
            cross_brace_y(base_w, 0, base_t, brace_w) ;
            diagonal_brace(base_l, base_w, base_t, brace_w, flip=false) ;
            diagonal_brace(base_l, base_w, base_t, brace_w, flip=true) ;

            mount_plate(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=+plate_px, py=+plate_py ) ;
            mount_plate(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=+plate_px, py=-plate_py) ;
            mount_plate(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=-plate_px, py=+plate_py ) ;
            mount_plate(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=-plate_px, py=-plate_py) ;
            mount_plate(mount_l, mount_w, base_t, read_side_base_w/2, hole_d, 0, py=+plate_py) ;
            mount_plate(mount_l, mount_w, base_t, read_side_base_w/2, hole_d, 0, py=-plate_py) ;

            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, +base_l/2, +base_w/2) ;
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, +base_l/2, -base_w/2) ;
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, -base_l/2, +base_w/2) ;
            corner_support_foot(foot_lx, foot_ly, base_t, foot_h, -base_l/2, -base_w/2) ;
            side_support_foot_x(foot_lx, foot_h, base_t, 0, +base_w/2) ;
            side_support_foot_x(foot_lx, foot_h, base_t, 0, -base_w/2) ;
        } ;
        mount_holes(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=+plate_px, py=+plate_py ) ;
        mount_holes(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=+plate_px, py=-plate_py) ;
        mount_holes(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=-plate_px, py=+plate_py ) ;
        mount_holes(mount_l, mount_w, base_t, winder_side_w/2, hole_d, px=-plate_px, py=-plate_py) ;
        mount_holes(mount_l, mount_w, base_t, read_side_base_w/2, hole_d, 0, py=+plate_py) ;
        mount_holes(mount_l, mount_w, base_t, read_side_base_w/2, hole_d, 0, py=-plate_py) ;
    }
}

module reader_baseplate() {
    // Combine main baseplate with rod support plate
    main_reader_baseplate() ;
    translate([rod_support_base_o,-base_w/2 - rod_support_shell_w/2,0]) {
        rod_support_mounting_plate() ;
    }

}

// rod_support_mounting_plate() ;

// main_reader_baseplate() ;

reader_baseplate() ;
