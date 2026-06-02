/**
 * upper-top-frame.scad
 *
 * Upper-top frame: 50 mm corner posts sitting on top of the top-frame extrusion,
 * connected by a rectangle of 2020 extrusions on top.
 *
 * This is the mounting surface for carriage rod end captures and any future
 * top-of-frame hardware. Same XY footprint as all other frame layers.
 *
 * Usage:
 *   use <upper-top-frame.scad>
 *   upper_top_frame();
 *
 *   // Full printer frame preview:
 *   use <bottom-frame.scad>
 *   use <top-frame.scad>
 *   use <upper-top-frame.scad>
 *   bottom_frame();
 *   top_frame();
 *   upper_top_frame();
 */

include <shared-dims.scad>
use <../common/2020-extrusion.scad>
use <y-rod-mount.scad>

// ---------------------------------------------------------------------------
// Dimensions — now in shared-dims.scad (utf_post_h, utf_post_bot_z, etc.)
// ---------------------------------------------------------------------------

// Same XY corner centerlines as the rest of the frame
utf_left_cx      = bf_left_cx;    // 10 mm
utf_right_cx     = bf_right_cx;   // 330 mm
utf_front_cy     = bf_front_cy;   // 10 mm
utf_rear_cy      = bf_rear_cy;    // 395 mm

// Block dimensions match y-rod-mount.scad
_blk_w = 20.0;   // block X width
_blk_d = 20.0;   // block Y depth

// Placement: blocks flush against the inner corner faces.
// Left inner face X=20, right inner face X=320, front inner face Y=20, rear inner face Y=385.
_blk_x_l  = ex;                           // 20 mm — left block left face
_blk_x_r  = bf_outer_x - ex - _blk_w;    // 300 mm — right block left face
_blk_y_f  = 0;                            // front block front face flush with frame front
_blk_y_r  = bf_rear_y_face;              // 385 mm — rear block front face

// ---------------------------------------------------------------------------
// Module
// ---------------------------------------------------------------------------
module upper_top_frame() {
    // Corner posts
    color("burlywood") for (cx = [utf_left_cx, utf_right_cx])
        for (cy = [utf_front_cy, utf_rear_cy])
            translate([cx, cy, utf_post_bot_z])
                extrusion_2020(utf_post_h, "z");

    // Top rectangle
    color("burlywood") {
        translate([utf_left_cx,  0,           utf_ex_cz]) extrusion_2020(bf_y_rail, "y");
        translate([utf_right_cx, 0,           utf_ex_cz]) extrusion_2020(bf_y_rail, "y");
        translate([ex,           utf_front_cy, utf_ex_cz]) extrusion_2020(bf_x_rail, "x");
        translate([ex,           utf_rear_cy,  utf_ex_cz]) extrusion_2020(bf_x_rail, "x");
    }

    // Y rod mounts — one plain block per corner, no mirroring needed (symmetric)
    // Front-left
    color("yellow") translate([_blk_x_l, _blk_y_f, utf_post_bot_z]) y_rod_mount();
    // Front-right
    color("yellow") translate([_blk_x_r, _blk_y_f, utf_post_bot_z]) y_rod_mount();
    // Rear-left
    color("yellow") translate([_blk_x_l, _blk_y_r, utf_post_bot_z]) y_rod_mount();
    // Rear-right
    color("yellow") translate([_blk_x_r, _blk_y_r, utf_post_bot_z]) y_rod_mount();

    // Y rods — 4mm shorter than full span, centred (2mm gap at each end)
    color("cornflowerblue") {
        translate([_blk_x_l + _blk_w / 2, 2, utf_post_bot_z + 25]) rotate([-90, 0, 0])
            cylinder(d = carriage_rod_dia, h = y_rod_length - 4);
        translate([_blk_x_r + _blk_w / 2, 2, utf_post_bot_z + 25]) rotate([-90, 0, 0])
            cylinder(d = carriage_rod_dia, h = y_rod_length - 4);
    }
}

// ---------------------------------------------------------------------------
// Preview — open this file to see all three frame layers
// ---------------------------------------------------------------------------
use <top-frame.scad>   // also brings bottom-frame module in scope
use <bottom-frame.scad>

color("peru")      bottom_frame();
top_frame();
upper_top_frame();
