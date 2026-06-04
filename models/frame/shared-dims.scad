/**
 * shared-dims.scad
 *
 * Single source of truth for all frame, motion, and hardware dimensions.
 * Include this in every model in the frame/ directory:
 *   include <shared-dims.scad>
 *
 * Do NOT place any geometry here — variables and derived values only.
 */

// ---------------------------------------------------------------------------
// Render quality
// ---------------------------------------------------------------------------
$fa = 1.0;
$fs = 0.1;

// ---------------------------------------------------------------------------
// 2020 extrusion
// ---------------------------------------------------------------------------
ex               = 20.0;   // Nominal extrusion cross-section (mm)

// ---------------------------------------------------------------------------
// Bottom frame (already built — values must match bottom-frame.scad)
// ---------------------------------------------------------------------------
bf_y_rail        = 405.0;  // Y rail length
bf_x_rail        = 300.0;  // X cross-member length (between Y rails)
bf_corner_post   = 50.0;   // Corner post height
bf_outer_x       = bf_x_rail + 2 * ex;          // 340 mm outer width
bf_top_z         = ex + bf_corner_post + ex;     // 90 mm — top face of bottom frame top layer
bf_top_layer_bot_z = ex + bf_corner_post;          // 70 mm — bottom face of top-layer extrusion

// Corner post X/Y centerlines (frame origin = front-left-bottom outer corner)
bf_left_cx       = ex / 2;                       // 10 mm
bf_right_cx      = bf_outer_x - ex / 2;          // 330 mm
bf_front_cy      = ex / 2;                       // 10 mm
bf_rear_cy       = bf_y_rail - ex / 2;           // 395 mm
bf_rear_y_face   = bf_y_rail - ex;               // 385 mm — inside face of rear Y rail

// ---------------------------------------------------------------------------
// Lead screw (T8 × 350 mm)
// ---------------------------------------------------------------------------
ls_length        = 350.0;  // Physical lead screw rod length
ls_lower_engage  = 10.0;   // mm of screw inside lower bearing block
ls_upper_engage  = 10.0;   // mm of screw inside upper bearing block
ls_travel        = ls_length - ls_lower_engage - ls_upper_engage;  // 330 mm nut travel

// Lower pillow block geometry
pb_wall          = 5.0;    // XY side-wall thickness around bearing OD
pb_floor         = 4.0;    // Z floor/ceiling thickness (one closed end per block)
pb_bearing_od    = 22.0;   // 608zz outer diameter
pb_bearing_h     = 7.0;    // 608zz height
pb_bearing_id    = 8.0;    // 608zz inner bore
pb_flange_od     = 10.5;   // Spacer flange OD
pb_flange_h      = 2.0;    // Spacer flange height
pb_stack_h       = pb_bearing_h * 2 + pb_flange_h;  // 16.0 mm — double-bearing stack
pb_block_h       = pb_stack_h + pb_floor;             // 20.0 mm — pillow block total height
pb_block_xy      = pb_bearing_od + pb_wall * 2;      // 32.0 mm — block footprint (square)

// Lower block: bottom flush with the bottom face of the top-layer extrusion
// Block mounts on the inside vertical face of the extrusion, not on top of it
pb_lower_bot_z   = bf_top_layer_bot_z;                // 70 mm
pb_lower_top_z   = pb_lower_bot_z + pb_block_h;       // 104 mm

// Lead screw bottom: floor + bearing + spacer above block bottom = 9 mm above floor top
pb_ls_bottom_z   = pb_lower_bot_z + pb_floor + pb_bearing_h + pb_flange_h;  // 83 mm

// Upper block: screw top sits at spacer bottom, which is bearing + spacer below ceiling
// upper_top = pb_ls_bottom_z + ls_length + pb_flange_h + pb_bearing_h + pb_floor
pb_upper_top_z   = pb_ls_bottom_z + ls_length + pb_flange_h + pb_bearing_h + pb_floor;  // 446 mm
pb_upper_bot_z   = pb_upper_top_z - pb_block_h;       // 426 mm

// ---------------------------------------------------------------------------
// Top frame (vertical uprights + top rectangle)
// ---------------------------------------------------------------------------
// Top frame extrusion occupies the same Z range as the upper pillow blocks (same as lower/bottom)
tf_extrusion_bot_z  = pb_upper_bot_z;              // 426 mm
tf_extrusion_top_z  = tf_extrusion_bot_z + ex;     // 458 mm

// Vertical upright length: from top of bottom frame top layer to bottom of top frame
tf_upright_length   = tf_extrusion_bot_z - bf_top_z; // 336 mm — cut from 400 mm stock
tf_upright_bot_z    = bf_top_z;                       // 90 mm

// Top frame has same footprint as bottom frame
tf_y_rail           = bf_y_rail;    // 405 mm
tf_x_rail           = bf_x_rail;    // 300 mm

// ---------------------------------------------------------------------------
// Lead screw positions in frame coordinates
// ---------------------------------------------------------------------------
// Front-left lead screw: inset 8 mm from corner post outer faces
ls_inset            = 8.0;
ls_fl_x             = ex + ls_inset;             // 28 mm
ls_fl_y             = ex + ls_inset;             // 28 mm

// Front-right lead screw: mirror of front-left
ls_fr_x             = bf_outer_x - ex - ls_inset; // 312 mm
ls_fr_y             = ls_fl_y;                     // 28 mm

// Rear center lead screw: centered on X, at the rear Y rail
ls_rc_x             = bf_outer_x / 2;             // 170 mm
ls_rc_y             = bf_rear_y_face - ls_inset;  // 377 mm (inset from rear rail inside face)

// ---------------------------------------------------------------------------
// Upper-top frame (50 mm corner posts above top frame + top rectangle)
// ---------------------------------------------------------------------------
utf_post_h           = 50.0;                          // corner post height
utf_post_bot_z       = tf_extrusion_top_z;            // 446 mm — sit on top of top-frame extrusion
utf_post_top_z       = utf_post_bot_z + utf_post_h;   // 496 mm
utf_ex_cz            = utf_post_top_z + ex / 2;       // 506 mm — top extrusion center Z

// ---------------------------------------------------------------------------
// CoreXY carriage linear rods
// ---------------------------------------------------------------------------
// Y rods: inside the upper-top frame, one per side, running full Y span.
// Block back face is rod_clearance inside the corner post inner face.
carriage_rod_dia     = 8.0;   // 8 mm round rod
rod_clearance        = 5.0;   // gap between mount block and adjacent post wall
y_rod_left_x         = ex + rod_clearance + 10;               // 35 mm — rod centre (block is 20 mm wide)
y_rod_right_x        = bf_outer_x - ex - rod_clearance - 10;  // 305 mm
y_rod_z              = utf_post_bot_z + utf_post_h / 2;  // 471 mm — mid-height of UTF posts
y_rod_length         = bf_y_rail;         // cut to 405 mm (or trim from 405 mm stock)

// X rods: two rods running across the X span, riding on the Y rods
// Offset front/back so the sled doesn't tip — spacing TBD by sled design
x_rod_spacing        = 40.0;   // distance between the two X rods (center to center)
x_rod_mid_y          = bf_y_rail / 2;     // 202.5 mm — X rods centered in the frame
x_rod_front_y        = x_rod_mid_y - x_rod_spacing / 2;  // 182.5 mm
x_rod_rear_y         = x_rod_mid_y + x_rod_spacing / 2;  // 222.5 mm
x_rod_z              = y_rod_z;            // same height as Y rods
x_rod_length         = bf_x_rail;         // cut to 300 mm from 360 mm stock

// ---------------------------------------------------------------------------
// Wing tabs (pillow blocks and captures)
// ---------------------------------------------------------------------------
wing_t               = 5.0;   // Wing tab thickness — how far the tab protrudes from a block face
wing_extend          = 20.0;  // How far the wing tab extends past the block body edge

// ---------------------------------------------------------------------------
// Rod-end-capture block dimensions (must stay in sync with rod-end-capture.scad)
// ---------------------------------------------------------------------------
rec_wall             = 5.0;           // side wall thickness around rod bore
rec_bore_depth       = 15.0;          // depth the rod sits in the block
rec_block_w          = carriage_rod_dia + rec_wall * 2;  // 18 mm — block width
rec_block_d          = rec_bore_depth + rec_wall;         // 20 mm — block depth (Y local)

// ---------------------------------------------------------------------------
// M5 hardware
// ---------------------------------------------------------------------------
m5_through_dia       = 5.4;
m5_head_dia          = 9.0;
m5_head_depth        = 3.5;
m5_tnut_clearance    = 20.0;  // Elbow connector occupies first 20 mm of each rail
