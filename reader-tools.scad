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
spool_removal_tool_t    = 8 ;
thumb_d                 = 25 ;

roller_gripping_tool_l  = 50 ;
roller_gripping_tool_w  = 8 ;
roller_gripping_tool_t  = 8 ;
roller_gripping_tool_d  = 14+1 ;

sprocket_gripping_tool_l  = 50 ;
sprocket_gripping_tool_w  = 8 ;
sprocket_gripping_tool_t  = 8 ;
sprocket_gripping_tool_d  = 20.5+1.5 ;


////////////////////////////////////////////////////////////////////////////////
// Spool removal tool
////////////////////////////////////////////////////////////////////////////////

// Provides something to push against when extracting spool from winder side slot

module spool_removal_tool(tool_l, tool_w, tool_t, side_r, side_t, slot_l, slot_w) {
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
            cylinder(r=side_r-slot_l/2, h=tool_t+2*delta) ;
        // Cut away so tool fits into slot
        translate([0,0,side_t])
            difference() {
                cylinder(r=side_r, h=tool_t+delta) ;
                translate([0,-(slot_w-2)/2,-delta])
                    cube(size=[side_r, slot_w-2, tool_t+3*delta]) ;
            }
        // Cut away thumb hole
        translate([tool_l+thumb_d/2,0,-delta])
            cylinder(d=thumb_d, h=tool_t+2*delta) ;
    }
}

////-spool_removal_tool()
spool_removal_tool(
    spool_removal_tool_l, spool_removal_tool_w, spool_removal_tool_t, 
    winder_apex_d/2, winder_side_t, 
    spool_sleeve_d, spool_sleeve_d
    ) ;


////////////////////////////////////////////////////////////////////////////////
// Roller gripping tool
////////////////////////////////////////////////////////////////////////////////

// Used to hold 

module roller_gripping_tool(l, w, t, d) {
    ring_t = 5 ;
    ring_d = d + ring_t*2 ;
    difference() {
        union() {
            translate([d/2,-w/2,0])
                cube(size=[l,w,t]) ;
            cylinder(d=ring_d, h=t) ;
            translate([-ring_d/2,-w/2,0])
                cube(size=[ring_d,w/2,t]) ;
        }
        translate([-d/2,-d,-delta]) {
            cube(size=[d,d,t+2*delta]) ;
        }
        translate([-d/2-ring_t,-d-w/2,-delta]) {
            cube(size=[ring_d,d,t+2*delta]) ;
        }
        translate([0,0,-delta]) {
            cylinder(d=d, h=t+2*delta) ;
        }
        #translate([-d/2+1,0,t/2]) {
            rotate([0,180,0])
                screw_recess_X(m3, ring_t+2, m3_nut_af, m3_nut_t+1) ;
        }
    }
}

////-roller_gripping_tool()
translate([0,thumb_d/2+roller_gripping_tool_d,0])
    roller_gripping_tool(
        roller_gripping_tool_l, roller_gripping_tool_w, roller_gripping_tool_t, 
        roller_gripping_tool_d
        ) ;


////////////////////////////////////////////////////////////////////////////////
// Sprocket gripping tool
////////////////////////////////////////////////////////////////////////////////

////-sprocket_gripping_tool()
translate([0,thumb_d/2+roller_gripping_tool_d+sprocket_gripping_tool_d,0])
    roller_gripping_tool(
        sprocket_gripping_tool_l, sprocket_gripping_tool_w, sprocket_gripping_tool_t, 
        sprocket_gripping_tool_d
        ) ;


