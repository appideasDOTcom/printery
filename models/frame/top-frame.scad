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

include <../common/shared-dims.scad>
use <../common/2020-extrusion.scad>
use <../motion-system/z-pillow-block.scad>
use <../motion-system/z-carriage-sled.scad>
use <../printerX/Z axis frame brace.scad>
use <../build-plate/corner-bracket.scad>
use <../build-plate/front-crossbar.scad>
use <../build-plate/right-crossbar.scad>

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

module _z_linear_rods() {
    // Three 8 mm × 362 mm vertical rods, one per lead screw, centred to each
    // lead screw in X and located at z_lr_rod_cy from the outer block face in Y.
    // Each rod bottoms out inside the lower block bore and rises into the upper
    // block bore; Z span = pb_lower_top_z − z_lr_bore_depth to
    //                       pb_upper_bot_z + z_lr_bore_depth  (362.4 mm total).
    fl_cx = ex + pb_block_xy/2;                          // 36 mm
    fl_cy = ex + z_lr_rod_cy;                            // 29.1 mm
    fr_cx = bf_outer_x - ex - pb_block_xy/2;             // 304 mm
    rc_cx = ls_rc_x;                                     // 170 mm
    rc_cy = bf_rear_y_face - z_lr_rod_cy;                // 375.9 mm

    rod_z0  = pb_lower_top_z - z_lr_bore_depth;          // 76.8 mm
    rod_len = z_lr_length + 2 * z_lr_clearance;          // 362.4 mm

    color("cornflowerblue") {
        translate([fl_cx, fl_cy, rod_z0])
            cylinder(d = z_lr_dia, h = rod_len);
        translate([fr_cx, fl_cy, rod_z0])
            cylinder(d = z_lr_dia, h = rod_len);
        translate([rc_cx, rc_cy, rod_z0])
            cylinder(d = z_lr_dia, h = rod_len);
    }
}

module _lead_screws() {
    // Bearing centres reflect the new pillow-block geometry (rod section added).
    // X is unchanged; Y shifts inward by (z_lr_bearing_cy − pb_block_xy/2).
    fl_cx = ex + pb_block_xy/2;                      // 36 mm  (unchanged)
    fl_cy = ex + z_lr_bearing_cy;                     // 49.3 mm
    fr_cx = bf_outer_x - ex - pb_block_xy/2;         // 304 mm (unchanged)
    rc_cx = ls_rc_x;                                 // 170 mm
    rc_cy = bf_rear_y_face - z_lr_bearing_cy;        // 355.7 mm

    color("silver", 0.7) {
        translate([fl_cx, fl_cy, pb_ls_bottom_z])
            cylinder(d = ls_viz_dia, h = ls_length);
        translate([fr_cx, fl_cy, pb_ls_bottom_z])
            cylinder(d = ls_viz_dia, h = ls_length);
        translate([rc_cx, rc_cy, pb_ls_bottom_z])
            cylinder(d = ls_viz_dia, h = ls_length);
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
    translate([_cx_fl, _cy_f, _z_pre]) z_carriage_left();
	echo( _z_pre );

    // Front-right
    translate([_cx_fr, _cy_f, _z_pre]) z_carriage_assembly();

    // Rear-center: rotate 180° so relief and lead screw offset face the correct direction
    translate([_cx_rc, _cy_r, _z_pre]) rotate([0, 0, 180]) z_carriage_assembly();
}

// NOTE: The Y carriage rods and their end-capture blocks are owned by
// upper-top-frame.scad (they live in the upper-top frame, captured by
// y_rod_mount). They are intentionally NOT rendered here — see
// upper-top-frame.scad for the single source of truth.

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
                          _z_linear_rods();
}

// ---------------------------------------------------------------------------
// Output — renders all frame layers together for context
// ---------------------------------------------------------------------------
use <bottom-frame.scad>
use <upper-top-frame.scad>
use <../motion-system/z-belt-tensioner.scad>

color("peru")      bottom_frame();
top_frame();
color("gold")      _z_carriage_sleds();
// color("burlywood") upper_top_frame();

// Z belt tensioner — right side, immediately behind front-right lower pillow block
// Local X=0 placed at the right extrusion inner face; body extends inward (−X)
color("tomato") translate([bf_outer_x - ex, ex + z_lr_block_depth + 20.5, pb_lower_bot_z])
    z_belt_tensioner();

// ---------------------------------------------------------------------------
// Build plate corner brackets — 235×235 mm array, 2 mm below upper pillow block tops
// ---------------------------------------------------------------------------

_cb_span      = 235;                              // outer-edge to outer-edge spacing
_cb_origin_x  = bf_outer_x / 2 - _cb_span / 2;  // X of front-left bracket outer corner
_cb_origin_y  = bf_y_rail / 2 - _cb_span / 2;   // Y of front-left bracket outer corner
_cb_sled_z    = ((pb_lower_top_z + pb_upper_bot_z) / 2 - (rj_base_y + 2) / 2);  // sled bottom Z (matches _z_pre in _z_carriage_sleds)
_cb_z         = _cb_sled_z + 31 - cb_wall_height;      // bottom face of bracket (12.2 mm tall, wall extends 2 mm above)
_cb_bar_z     = _cb_z;                           // crossbar bottom: same as bracket bottom

// Front crossbar: local x=0 is its left end, y=0 is the flat (front) edge, z=0 is the bottom.
// Rear crossbar: rotated 180° so flat wall faces +Y (rear); x=0 after rotation is the right end.
// Left crossbar: rotated 90° so flat wall faces −X (left-outside); bar spans along Y.
_fcb_length    = 195;
_fcb_origin_x  = bf_outer_x / 2 - _fcb_length / 2;          // front: left end centered on frame
_rcb_origin_x  = bf_outer_x / 2 + _fcb_length / 2;          // rear (180°): right end centered on frame
_lcb_origin_x  = _cb_origin_x;                               // left: wall flush with left bracket outer face
_lcb_origin_y  = _cb_origin_y + _cb_span / 2 + _fcb_length / 2;  // left (−90°): bar centered on bracket Y span
_rcb_side_x    = _cb_origin_x + _cb_span;                    // right: wall flush with right bracket outer face
_rcb_side_y    = _cb_origin_y + _cb_span / 2 - _fcb_length / 2;  // right (90°): bar centered on bracket Y span

module _build_plate_brackets() {
	color("slateblue") {
		// Front-left: notch faces +X, +Y (no rotation)
		translate([_cb_origin_x, _cb_origin_y, _cb_z])
			front_left_bed_bracket();
		// Front-right: rotate 90° CW → notch faces −X, +Y
		translate([_cb_origin_x + _cb_span, _cb_origin_y, _cb_z])
			front_right_bed_bracket();
		// Rear-right: rotate 180° → notch faces −X, −Y
		translate([_cb_origin_x + _cb_span, _cb_origin_y + _cb_span, _cb_z])
			rear_right_bed_bracket();
		// Rear-left: rotate 270° CW → notch faces +X, −Y
		translate([_cb_origin_x, _cb_origin_y + _cb_span, _cb_z])
			rear_left_bed_bracket();
	}

    // Front crossbar: centered on frame X, front edge flush with bracket front, bottom flush with brackets
	color( "lightblue" ) {
		translate([_fcb_origin_x, _cb_origin_y, _cb_bar_z])
			front_crossbar();

		// Rear crossbar: rotated 180° so flat wall faces +Y (rear), bar body extends inward (−Y)
		// Back-edge notch removed via rear_crossbar_cutout()
		difference() {
			translate([_rcb_origin_x, _cb_origin_y + _cb_span, _cb_bar_z])
				rotate([0, 0, 180])
					front_crossbar();
			translate([_rcb_origin_x, _cb_origin_y + _cb_span + (12), _cb_bar_z])
				rotate([0, 0, 180])
					rear_crossbar_cutout();
		}

		// Left crossbar: rotated −90° so flat wall faces −X (left-outside), bar body extends inward (+X)
		translate([_lcb_origin_x, _lcb_origin_y, _cb_bar_z])
			rotate([0, 0, -90])
				front_crossbar();

		// Right crossbar: rotated 90° so flat wall faces +X (right-outside), bar body extends inward (−X)
		translate([_rcb_side_x - 15, _rcb_side_y, _cb_bar_z])
			rotate([0, 0, 90])
				right_crossbar();
	}
}

_build_plate_brackets();
