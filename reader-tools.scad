// reader-tools.scad
//
// Define tools to assist with assembly and operation of Monotype tape reader
//

include <reader-defs.scad> ;

use <reader-common.scad> ;

////////////////////////////////////////////////////////////////////////////////
// Definitions
////////////////////////////////////////////////////////////////////////////////

spool_removal_tool_l    = outer_d/2 + spool_sleeve_d ;
spool_removal_tool_w    = 10 ;
spool_removal_tool_t    = 6 ;
thumb_d                 = 25 ;

roller_gripping_tool_l  = 50 ;
roller_gripping_tool_w  = 8 ;
roller_gripping_tool_t  = 8 ;
roller_gripping_tool_d  = 14 ;

sprocket_gripping_tool_l  = 50 ;
sprocket_gripping_tool_w  = 8 ;
sprocket_gripping_tool_t  = 8 ;
sprocket_gripping_tool_d  = 20.5 ;

gripping_tool_ring_t    = 5 ;


////////////////////////////////////////////////////////////////////////////////
// Spool removal tool
////////////////////////////////////////////////////////////////////////////////

// Provides something to push against when extracting spool from winder side slot
//
// tool_l   length of tool handle from spool centre
// tool_w   width of tool handle
// tool_t   thickness of tool
// side_r   radius of spool holder side against which the tool presses
// side_t   thickness of guide that locates against spool holder side
// side_l   length of guide that locates against spool holder side
// slot_w   width of slot that locating tongue engages with
//
module spool_removal_tool(tool_l, tool_w, tool_t, side_r, side_t, side_l, slot_w) {
    difference() {
        // Blank body
        union() {
            translate([0,-tool_w/2,0])
                cube(size=[tool_l+thumb_d/2, tool_w, tool_t]) ;
            translate([tool_l+thumb_d/2,0,0])
                cylinder(d=thumb_d+4, h=tool_t) ;
        }
        // Cut away radius at end
        translate([0,0,-delta])
            cylinder(r=side_r-side_l, h=tool_t+2*delta) ;
        // Cut away so tool fits into slot
        translate([0,0,side_t])
            difference() {
                cylinder(r=side_r, h=tool_t+delta) ;
                translate([0,-(slot_w-clearance)/2,-delta])
                    cube(size=[side_r, slot_w-clearance, tool_t+3*delta]) ;
            }
        // Cut away thumb hole
        translate([tool_l+thumb_d/2,0,-delta])
            cylinder(d=thumb_d, h=tool_t+2*delta) ;
    }
}

////-spool_removal_tool()
// spool_removal_tool(
//     spool_removal_tool_l, spool_removal_tool_w, spool_removal_tool_t, 
//     winder_apex_d/2, 1.6, 2, spool_sleeve_d
//     ) ;


////////////////////////////////////////////////////////////////////////////////
// Roller gripping tool
////////////////////////////////////////////////////////////////////////////////

// Used to hold roller when assembling and adjusting end-float screws
//
// l        length of handle from roller centre
// w        width of handle
// t        thickness of handle
// d        diameter of roller

module roller_gripping_tool(l, w, t, d) {
    ring_t = gripping_tool_ring_t ;
    ring_d = d + ring_t*2 ;
    gap_d  = d-0.5 ;
    difference() {
        // Tool body blank
        union() {
            translate([-1,0,0])
                cylinder(d=ring_d, h=t) ;
            translate([d/2,-w/2,0])
                cube(size=[l,w,t]) ;
            translate([-ring_d/2,-w/2,0])
                cube(size=[ring_d,w/2,t]) ;
        }
        // Cut away for roller body
        translate([0,0,-delta]) {
            cylinder(d=d, h=t+2*delta) ;
        }
        // Cut away end 
        translate([-ring_d-5,-ring_d*0.5,-delta]) {
         cube(size=[ring_d,ring_d,t+2*delta]) ;
        }
        // Cut away opening to slip over roller
        translate([-d,-gap_d*0.5,-delta]) {
            cube(size=[d,gap_d,t+2*delta]) ;
        }
        translate([0,-d/2+1,t/2]) {
         rotate([0,0,-90])
             hex_screw_recess_X(m3, ring_t+2, m3_nut_af, m3_nut_t+1) ;
        }
    }
}

////-roller_gripping_tool()
// translate([0,thumb_d/2+roller_gripping_tool_d,0])
//     roller_gripping_tool(
//         roller_gripping_tool_l, roller_gripping_tool_w, roller_gripping_tool_t, 
//         roller_gripping_tool_d
//         ) ;


////////////////////////////////////////////////////////////////////////////////
// Sprocket gripping tool
////////////////////////////////////////////////////////////////////////////////

////-sprocket_gripping_tool()
// translate([0,thumb_d/2+roller_gripping_tool_d+sprocket_gripping_tool_d+gripping_tool_ring_t*3,0])
//     roller_gripping_tool(
//         sprocket_gripping_tool_l, sprocket_gripping_tool_w, sprocket_gripping_tool_t, 
//         sprocket_gripping_tool_d
//         ) ;


////////////////////////////////////////////////////////////////////////////////
// Nut spinner tool
////////////////////////////////////////////////////////////////////////////////

//  Used to tighten camera mounting nuts
//
//  l   = overall length
//  od  = overall diameter
//  sd  = shaft diameter
//  af  = nut AF size
//  nt  = nut thickness (depth of hex recess)
//
module nut_spinner_tool(l, od, sd, af, nt) {
    difference() {
        union() {
            cylinder(d=od, h=l, $nt=6) ;
            // Tabs for bed adhesion
            for (a=[0,120,240])
                rotate([0,0,a])
                    translate([0,-sd/2,0])
                        cube(size=[sd*2.5,sd,0.4]) ;
        }
        translate([0,0,l+delta])
            mirror([0,0,1])
                hex_screw_recess_Z(sd*1.5, l+2*delta, af, nt) ;
    }
}

module nut_spinner_tool_m4(l) {
    nut_spinner_tool(l, m4*2.25, m4, m4_nut_af+clearance*2, m4_nut_t*1.6) ;
}

module nut_spinner_tool_m3(l) {
    nut_spinner_tool(l, m3*2.25, m3, m3_nut_af+clearance*2, m3_nut_t*1.6) ;
}

////-nut_spinner_tool_m4(l)
// translate([-10,0,0])
//     nut_spinner_tool_m3(35) ;
// translate([+10,0,0])
//     nut_spinner_tool_m4(40) ;


////////////////////////////////////////////////////////////////////////////////
// Washer positioning tool
////////////////////////////////////////////////////////////////////////////////

// When assembling the reader rollers,  it is sometimes tricky supporting washers
// in-place while threading shaft screws into the assembly.  This tool is an attempt to help with this.
//
//
// l    = overall length
// od   = overall diameter of head
// wd   = diameter of washer
// sd   = diameter of shaft
// wt   = thickness of washer supports (e.g., for up to 3 washers)
// st   = thickness of supporting shim
//
module washer_positioning_tool(l, od, wd, sd, wt, st) {
    difference() {
        union() {
            cylinder(d=od, h=wt+st) ;
            translate([-wt/2,0,0])
                cube(size=[wt,l,wt+st]) ;
        }
    // Shaft cutout
    translate([0,0,-delta])
        // cylinder(d=sd, h=wt+st+2*delta, $fn=16) ;
        // oval(x, d, h)
        oval(od, sd, wt+st+2*delta) ;
    // Washer support cutout
    translate([0,0,st])
        // cylinder(d=wd, h=wt+delta, $fn=16) ;
        oval(od, wd, wt+delta) ;
    }
}

////-washer_positioning_tool(l, od, wd, sd, wt, st)
////-washer_positioning_tool_m4()
washer_positioning_tool(40, m4_washer_d+2, m4_washer_d, m4, m4_washer_t*3, 0.8) ;


//----
// module part_template(xxx) {
//     difference() {
//         union() {
//             xxx
//         }
//     xxx
//     }
// }
//----



