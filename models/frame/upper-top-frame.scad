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

module _x_carriage_rods() {
    // X rods span between the two sleds — from right face of left sled to left face of right sled.
    // Left sled right face: y_rod_left_x + 10 = 45 mm
    // Right sled left face: y_rod_right_x - 10 = 295 mm  →  length = 250 mm
    _x_rod_start = y_rod_left_x + 10;
    _x_rod_len   = y_rod_right_x - y_rod_left_x - 20;   // 250 mm
    color("steelblue", 0.6) {
        translate([_x_rod_start, x_rod_front_y, x_rod_z])
            rotate([0, 90, 0])
                cylinder(d = carriage_rod_dia, h = _x_rod_len);
        translate([_x_rod_start, x_rod_rear_y, x_rod_z])
            rotate([0, 90, 0])
                cylinder(d = carriage_rod_dia, h = _x_rod_len);
    }
}

module _x_rod_sleds() {
    // One sled per Y rod, each retaining both X rods.
    // Sled: 20 mm wide (X) × 50 mm deep (Y) × 50 mm tall (Z)
    // Centred on the Y rod in X; Y start = x_rod_front_y - 5; Z start = x_rod_z - 25
    _sled_y = x_rod_front_y - 5;   // 177.5 mm
    _sled_z = x_rod_z - 25;        // 446 mm
    color("gold") {
        translate([y_rod_left_x  - 10, _sled_y, _sled_z]) x_rod_sled();
        translate([y_rod_right_x - 10, _sled_y, _sled_z]) x_rod_sled();
    }
}

// ---------------------------------------------------------------------------
// Preview — open this file to see all three frame layers
// ---------------------------------------------------------------------------
use <top-frame.scad>   // also brings bottom-frame module in scope
use <bottom-frame.scad>
use <x-rod-sled.scad>

color("peru")           bottom_frame();
top_frame();
color("cornflowerblue") _x_carriage_rods();
color("gold")           _x_rod_sleds();
upper_top_frame();
