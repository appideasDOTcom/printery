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

// Lower pillow block geometry (block bottom flush with bf_top_z)
pb_wall          = 5.0;    // Min wall around bearing pocket
pb_bearing_od    = 22.0;   // 608zz outer diameter
pb_bearing_h     = 7.0;    // 608zz height
pb_bearing_id    = 8.0;    // 608zz inner bore
pb_flange_od     = 10.5;   // Spacer flange OD
pb_flange_h      = 2.0;    // Spacer flange height
pb_stack_h       = pb_bearing_h * 2 + pb_flange_h;  // 16.0 mm — double-bearing stack
pb_block_h       = pb_stack_h + pb_wall * 2;         // 26.0 mm — pillow block total height
pb_block_xy      = pb_bearing_od + pb_wall * 2;      // 32.0 mm — block footprint (square)

// Lower block: bottom flush with the bottom face of the top-layer extrusion
// Block mounts on the inside vertical face of the extrusion, not on top of it
pb_lower_bot_z   = bf_top_layer_bot_z;                // 70 mm
pb_lower_top_z   = pb_lower_bot_z + pb_block_h;       // 96 mm

// Lead screw bottom sits at the bearing pocket floor inside the lower block
pb_ls_bottom_z   = pb_lower_bot_z + pb_wall;          // 75 mm

// Upper pillow block: bearing pocket top aligns with lead screw top minus upper engagement
pb_upper_bot_z   = pb_lower_bot_z + ls_length - ls_upper_engage - pb_stack_h; // 394 mm
pb_upper_top_z   = pb_upper_bot_z + pb_block_h;       // 420 mm

// ---------------------------------------------------------------------------
// Top frame (vertical uprights + top rectangle)
// ---------------------------------------------------------------------------
// Top frame extrusion bottom face sits just above the upper pillow block
tf_extrusion_bot_z  = pb_upper_top_z;              // 420 mm
tf_extrusion_top_z  = tf_extrusion_bot_z + ex;     // 440 mm

// Vertical upright length: from top of bottom frame top layer to bottom of top frame
tf_upright_length   = tf_extrusion_bot_z - bf_top_z; // 330 mm — cut from 400 mm stock
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
// CoreXY carriage linear rods
// ---------------------------------------------------------------------------
// Y rods: one each side, running full frame Y span, at the X rail centerlines
// Sit just inside the top frame, above upper pillow blocks
carriage_rod_dia     = 8.0;   // 8 mm round rod
y_rod_left_x         = bf_left_cx;        // 10 mm — left Y rod X position
y_rod_right_x        = bf_right_cx;       // 330 mm — right Y rod X position
y_rod_z              = tf_extrusion_bot_z - carriage_rod_dia / 2 - 2.0;  // ~466 mm center
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
// M5 hardware
// ---------------------------------------------------------------------------
m5_through_dia       = 5.4;
m5_head_dia          = 9.0;
m5_head_depth        = 3.5;
m5_tnut_clearance    = 20.0;  // Elbow connector occupies first 20 mm of each rail
