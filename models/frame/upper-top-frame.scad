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
use <z-carriage-sled.scad>

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

    // Y rod mounts — bore always enters from the interior-facing face.
    // Front mounts: y_rod_mount_front() bore enters from Y=_yrm_d (high-Y face),
    //   which becomes the interior face after placement at _blk_y_f.  No mirror.
    // Rear mounts: y_rod_mount_rear() bore enters from Y=0 (low-Y face),
    //   which IS the interior face at _blk_y_r.  No mirror except rear-right in X
    //   so its pulley shaft also faces the printer interior.
    // Front-left
    color("yellow") translate([_blk_x_l, _blk_y_f, utf_post_bot_z]) y_rod_mount_front();
    // Front-right (X-mirror: bore stays at global X=310, extra material toward center)
    color("yellow") translate([_blk_x_r + _blk_w, _blk_y_f, utf_post_bot_z]) mirror([1,0,0]) y_rod_mount_front();
    // Rear-left  (shaft at local X=17, Y=5 — faces +X and -Y interior)
    color("yellow") translate([_blk_x_l, _blk_y_r, utf_post_bot_z]) y_rod_mount_rear();
    // Rear-right (X-mirror: shaft at mirrored X=3, Y=5 — faces -X and -Y interior)
    color("yellow") translate([_blk_x_r + _blk_w, _blk_y_r, utf_post_bot_z]) mirror([1,0,0]) y_rod_mount_rear();

    // Y rods — 4mm shorter than full span, centred (2mm gap at each end).
    // Raised to y_rod_z so they ride high in the sled bearings.
    color("cornflowerblue") {
        translate([_y_rod_cx_l, 2, y_rod_z]) rotate([-90, 0, 0])
            cylinder(d = carriage_rod_dia, h = y_rod_length - 4);
        translate([_y_rod_cx_r, 2, y_rod_z]) rotate([-90, 0, 0])
            cylinder(d = carriage_rod_dia, h = y_rod_length - 4);
    }
}

// Left and right Y-rod centres in X — defined by the (frame-flush) Y-rod
// mount bores, so the rods, sleds, and mounts all share one X reference.
_y_rod_cx_l = _blk_x_l + yrm_bore_x;          // 33.5 mm — bore centre, left rod
_y_rod_cx_r = _blk_x_r + _blk_w - yrm_bore_x;  // 306.5 mm — bore centre, right rod (mirrored block)

module _x_carriage_rods() {
    // Render full physical rod from bore floor (left sled) to bore floor (right sled).
    // Start = left sled outer face + closing wall = _y_rod_cx_l - sled_w/2 + (sled_w - x_rod_bore_depth)
    _x_start = _y_rod_cx_l - sled_w / 2 + (sled_w - x_rod_bore_depth);  // 27 mm
    color("steelblue", 0.6) {
        translate([_x_start, x_rod_front_y, x_rod_front_z])
            rotate([0, 90, 0])
                cylinder(d = carriage_rod_dia, h = x_rod_length);
        translate([_x_start, x_rod_rear_y, x_rod_rear_z])
            rotate([0, 90, 0])
                cylinder(d = carriage_rod_dia, h = x_rod_length);
    }
}

module _x_rod_sleds() {
    // One sled per Y rod, each riding the Y rod and retaining both X rods.
    // Envelope sled_w x sled_d x sled_h; centred on the Y rod in X, centred
    // on the frame in Y, top flush with the UTF post tops (sled_top_z).
    // The sled rounds its outer (−X local) edges; mirror the right-hand one so
    // its rounded edges face the right frame rail (outer = +X there).
    _sled_y = x_rod_mid_y - sled_d / 2;   // 172.5 mm
    color("gold") {
        translate([_y_rod_cx_l - sled_w / 2, _sled_y, sled_bot_z]) x_rod_sled();
        translate([_y_rod_cx_r + sled_w / 2, _sled_y, sled_bot_z]) mirror([1, 0, 0]) x_rod_sled();
    }
}

module _z_carriage_sleds() {
    // Rod centre X positions — match _z_linear_rods()
    _cx_fl = ex + pb_block_xy / 2;               // 36 mm
    _cx_fr = bf_outer_x - ex - pb_block_xy / 2;  // 304 mm
    _cx_rc = ls_rc_x;                            // 170 mm

    // Rod centre Y positions
    _cy_f  = ex + z_lr_rod_cy;                   // 29.1 mm (front rods)
    _cy_r  = bf_rear_y_face - z_lr_rod_cy;       // 375.9 mm (rear rod)

    // Z preview position: mid-travel, cylinder centred
    _z_pre = (pb_lower_top_z + pb_upper_bot_z) / 2 - (rj_base_y + 2) / 2;  // ≈ 249.5 mm

    // Lead screw centre Y positions
    _ls_cy_f = ex + z_lr_bearing_cy;              // 49.3 mm (front screws)
    _ls_cy_r = bf_rear_y_face - z_lr_bearing_cy;  // 355.7 mm (rear screw)

    // Front-left
    translate([_cx_fl, _cy_f, _z_pre]) z_carriage_assembly();

    // Front-right
    translate([_cx_fr, _cy_f, _z_pre]) z_carriage_assembly();

    // Rear-center: rotate 180° so relief and lead screw offset face the correct direction
    translate([_cx_rc, _cy_r, _z_pre]) rotate([0, 0, 180]) z_carriage_assembly();
}

// ---------------------------------------------------------------------------
// Preview — open this file to see all three frame layers
// ---------------------------------------------------------------------------
use <top-frame.scad>   // also brings bottom-frame module in scope
use <bottom-frame.scad>
use <x-rod-sled.scad>
use <hotend-carriage.scad>

color("peru")           bottom_frame();
top_frame();
color("cornflowerblue") _x_carriage_rods();
color("gold")           _x_rod_sleds();
color("gold")           _z_carriage_sleds();
upper_top_frame();
_hc_body_x  = 60.0;
_hc_body_y  = rj_bearing_od + rj_shell * 2;
_hc_bore_cy = _hc_body_y / 2;
_hc_bore_cz = _hc_body_y / 2;
_hc_place_x = bf_outer_x / 2 - _hc_body_x / 2;
_hc_place_y = x_rod_front_y - _hc_bore_cy;
_hc_place_z = x_rod_front_z - _hc_bore_cz;
color("tomato") translate([_hc_place_x, _hc_place_y, _hc_place_z]) hotend_carriage();
