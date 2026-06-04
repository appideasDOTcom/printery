/**
 * top-frame.scad
 *
 * Full upper assembly of the CoreXY printery frame, shown in context above the
 * bottom frame. Includes:
 *
 *   1. Four vertical 2020 corner uprights (382 mm each, cut from 400 mm stock)
 *   2. Top rectangle: two Y rails (405 mm) + two X cross-members (300 mm)
 *   3. Six Z axis pillow blocks:
 *        - Front-left lower   (bolts into Y rail + X cross-member)
 *        - Front-right lower  (mirror of front-left)
 *        - Rear-center lower  (bolts into rear Y rail, symmetric ±X)
 *        - Three upper blocks (one per lead screw, identical, symmetric ±X)
 *   4. Three T8 × 350 mm lead screws (visualized as simple cylinders)
 *   5. Four Y-axis carriage rod end captures (one per rod end, left and right rails)
 *   6. Four X-axis carriage rod end captures (one per rod end, front and rear)
 *   7. Two Y-axis carriage rods (8 mm, cut to 405 mm)
 *   8. Two X-axis carriage rods (8 mm, cut to 300 mm)
 *
 * Origin matches bottom-frame.scad: front-left-bottom outer corner of the
 * bottom frame. This file can be rendered alongside bottom-frame.scad for a
 * complete printer frame preview.
 *
 * Usage:
 *   use <top-frame.scad>
 *   top_frame();
 *
 *   // Full printer frame preview:
 *   use <bottom-frame.scad>
 *   use <top-frame.scad>
 *   bottom_frame();
 *   top_frame();
 */

include <shared-dims.scad>
use <../common/2020-extrusion.scad>
use <z-pillow-block.scad>
use <rod-end-capture.scad>
use <../printerX/Z axis frame brace.scad>

// ---------------------------------------------------------------------------
// Derived values not already in shared-dims
// ---------------------------------------------------------------------------

// Top frame extrusion centerlines (same footprint as bottom frame)
tf_left_cx   = bf_left_cx;     // 10 mm
tf_right_cx  = bf_right_cx;    // 330 mm
tf_front_cy  = bf_front_cy;    // 10 mm
tf_rear_cy   = bf_rear_cy;     // 395 mm
tf_cross_x   = ex;             // 20 mm — X start of cross-members

// Extrusion center Z for the top rectangle
tf_ex_cz     = tf_extrusion_bot_z + ex / 2;  // center of top-layer extrusion

// Upright bottom Z = top of bottom frame top layer
tf_up_bot_z  = bf_top_z;   // 90 mm

// ---------------------------------------------------------------------------
// Helpers for lead screw visualization
// ---------------------------------------------------------------------------
ls_viz_dia   = 8.0;  // T8 lead screw rod diameter

// ---------------------------------------------------------------------------
// Sub-assemblies
// ---------------------------------------------------------------------------

module _corner_uprights() {
    // Four vertical 2020 extrusions at the frame corners
    // Bottom: flush with top of bottom frame; top: flush with bottom of top extrusions
    for (cx = [tf_left_cx, tf_right_cx])
        for (cy = [tf_front_cy, tf_rear_cy])
            translate([cx, cy, tf_up_bot_z])
                extrusion_2020(tf_upright_length, "z");
}

// Wrapper around the top-level geometry in "Z axis frame brace.scad".
// The brace's local corner is at (y=0, z=0):
//   y=0 flat face presses against an upright's inner face;
//   z=0 flat face sits on the horizontal rail at bf_top_z.
module _z_axis_brace() {
    difference() {
        union() { mainBody(); edgePieces(); }
        union() { mainCutout(); throughHoles(); }
    }
}

module _z_axis_braces() {
    // Front-left: brace extends +Y and +Z from the inner corner of the left-front upright
    translate([0, ex, bf_top_z])
        _z_axis_brace();

    // Front-right: mirror X so it faces the right-front upright
    translate([bf_outer_x, ex, bf_top_z])
        mirror([1, 0, 0])
            _z_axis_brace();

    // Rear-left: mirror Y so it extends into the frame in −Y
    translate([0, bf_rear_y_face, bf_top_z])
        mirror([0, 1, 0])
            _z_axis_brace();

    // Rear-right: mirror both X and Y
    translate([bf_outer_x, bf_rear_y_face, bf_top_z])
        mirror([1, 0, 0])
            mirror([0, 1, 0])
                _z_axis_brace();
}

module _rear_center_upright() {
    // Single vertical 2020 upright centered on the rear lead screw (X = ls_rc_x)
    // and flush with the rear Y rail centerline (Y = tf_rear_cy).
    // Same Z span as the four corner uprights.
    translate([ls_rc_x, tf_rear_cy, tf_up_bot_z])
        extrusion_2020(tf_upright_length, "z");
}

module _top_rectangle() {
    // Left Y rail
    translate([tf_left_cx, 0, tf_ex_cz])
        extrusion_2020(tf_y_rail, "y");
    // Right Y rail
    translate([tf_right_cx, 0, tf_ex_cz])
        extrusion_2020(tf_y_rail, "y");
    // Front X cross-member (between Y rails)
    translate([tf_cross_x, tf_front_cy, tf_ex_cz])
        extrusion_2020(tf_x_rail, "x");
    // Rear X cross-member
    translate([tf_cross_x, tf_rear_cy, tf_ex_cz])
        extrusion_2020(tf_x_rail, "x");
}

module _z_pillow_blocks_lower() {
    // Block -X and -Y faces flush with the inner faces of the corner extrusions.
    // Wings extend OUTWARD past the block edges and press against those faces.

    // Front-left: -X face at x=ex, -Y face at y=ex
    translate([ex, ex, pb_lower_bot_z])
        z_pillow_block(bolts = "xy");

    // Front-right: mirror of front-left, +X face at x=bf_outer_x-ex
    translate([bf_outer_x - ex, ex, pb_lower_bot_z])
        mirror([1, 0, 0])
            z_pillow_block(bolts = "xy");

    // Rear center: +Y face flush with rear X-member inner face
    translate([ls_rc_x - pb_block_xy/2, bf_rear_y_face - pb_block_xy, pb_lower_bot_z])
        z_pillow_block(bolts = "xx");
}

module _z_pillow_blocks_upper() {
    // Same X/Y placement as lower blocks.
    // flip=true: pocket opens downward, wings at top of block (aligned with top extrusion).

    // Front-left upper
    translate([ex, ex, pb_upper_bot_z])
        z_pillow_block(bolts = "xy", flip = true);

    // Front-right upper (mirrored)
    translate([bf_outer_x - ex, ex, pb_upper_bot_z])
        mirror([1, 0, 0])
            z_pillow_block(bolts = "xy", flip = true);

    // Rear center upper
    translate([ls_rc_x - pb_block_xy/2, bf_rear_y_face - pb_block_xy, pb_upper_bot_z])
        z_pillow_block(bolts = "xx", flip = true);
}

module _lead_screws() {
    // Bearing centers = block placement + pb_block_xy/2 in X and Y.
    fl_cx = ex + pb_block_xy/2;                      // 36 mm
    fl_cy = ex + pb_block_xy/2;                      // 36 mm
    fr_cx = bf_outer_x - ex - pb_block_xy/2;         // 304 mm
    rc_cx = ls_rc_x;                                 // 170 mm
    rc_cy = bf_rear_y_face - pb_block_xy/2;          // 369 mm

    color("silver", 0.7) {
        translate([fl_cx, fl_cy, pb_ls_bottom_z])
            cylinder(d = ls_viz_dia, h = ls_length);
        translate([fr_cx, fl_cy, pb_ls_bottom_z])
            cylinder(d = ls_viz_dia, h = ls_length);
        translate([rc_cx, rc_cy, pb_ls_bottom_z])
            cylinder(d = ls_viz_dia, h = ls_length);
    }
}

module _y_carriage_rods() {
    // Two 8 mm rods running the full Y span at each side of the frame
    // Captured at each end by a rod_end_capture block on the top frame extrusion
    color("steelblue", 0.8) {
        translate([y_rod_left_x, 0, y_rod_z])
            rotate([-90, 0, 0])
                cylinder(d = carriage_rod_dia, h = y_rod_length);
        translate([y_rod_right_x, 0, y_rod_z])
            rotate([-90, 0, 0])
                cylinder(d = carriage_rod_dia, h = y_rod_length);
    }
}

module _y_rod_captures() {
    // Four rod-end capture blocks, one at each end of each Y carriage rod.
    // Block bore runs in local +Y. Back face (at local Y=rec_block_d) bolts into
    // the extrusion T-slot on the extrusion's inner face.
    //
    // Front end (no mirror):
    //   translate Y = tf_front_cy - ex/2 = 0
    //   → block Y = 0..rec_block_d, back face at world Y = rec_block_d = 20 = extrusion inner face ✓
    //
    // Rear end (mirror [0,1,0]):
    //   mirror flips +Y → -Y, so back face is now at -rec_block_d from translate Y
    //   translate Y = bf_rear_y_face + rec_block_d = 405
    //   → back face at world Y = 405 - 20 = 385 = bf_rear_y_face ✓

    for (rx = [y_rod_left_x, y_rod_right_x]) {
        // Front end
        translate([rx - rec_block_w/2,
                   tf_front_cy - ex/2,
                   y_rod_z - ex/2])
            rod_end_capture();

        // Rear end
        translate([rx - rec_block_w/2,
                   bf_rear_y_face + rec_block_d,
                   y_rod_z - ex/2])
            mirror([0, 1, 0])
                rod_end_capture();
    }
}

// ---------------------------------------------------------------------------
// Top-level module
// ---------------------------------------------------------------------------

module top_frame() {
    color("tan")          _corner_uprights();
    color("tan")          _rear_center_upright();
    color("sienna")       _z_axis_braces();
    color("tan")          _top_rectangle();
    color("orange")       _z_pillow_blocks_lower();
    color("orange")       _z_pillow_blocks_upper();
    color("silver", 0.7)  _lead_screws();
}

// ---------------------------------------------------------------------------
// Output — renders all frame layers together for context
// ---------------------------------------------------------------------------
use <bottom-frame.scad>
use <upper-top-frame.scad>

color("peru")      bottom_frame();
top_frame();
// color("burlywood") upper_top_frame();
