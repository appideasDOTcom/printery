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
// Tolerances
// ---------------------------------------------------------------------------
rod_bore_tol     = 0.1;   // Slip-fit tolerance added to 8 mm linear rod bore diameter

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
pb_bearing_od    = 22.1;   // 608zz outer diameter
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
// The sled rides on the Y rod via two RJ4JP bearings held in a pocket near
// the TOP of the sled (see x-rod-sled.scad). The X gantry rods are captured
// lower in the sled body, clear of that bearing pocket.
carriage_rod_dia     = 8.0;   // 8 mm round rod
rod_clearance        = 5.0;   // gap between mount block and adjacent post wall
yrm_bore_x           = 13.5;  // Y-rod bore centre offset from outer face of the mount block (mm)
y_rod_left_x         = ex + yrm_bore_x;               // 33.5 mm — left rod centre
y_rod_right_x        = bf_outer_x - ex - yrm_bore_x;  // 306.5 mm — right rod centre
y_rod_length         = bf_y_rail;         // cut to 405 mm (or trim from 405 mm stock)

// RJ4JP bearing retainer profile — copied verbatim from printerx
//   "X axis carriage" / "Y carriage bearing retainer" (tested RJ4JP clamp).
//   Do not alter these; the trap-ring spacing/depth is what makes the dry
//   polymer bearing seat correctly without over-clamping.
rj_bearing_od        = 15.1;
rj_length            = 24.0;   // RJ4JP body length (doc says 24, really ~23.7)
rj_y_bolt_pitch      = 18.0;
rj_piece_margin      = 5.5;
rj_base_y            = rj_y_bolt_pitch + rj_piece_margin * 2;   // 29 — one-bearing pocket module length
rj_trap_ring_spacing = 15.3;
rj_trap_ring_depth   = 0.2;
rj_trap_ring_width   = 0.6;
rj_cutout_to_end     = ((rj_base_y - rj_trap_ring_spacing) / 2 + 1) - rj_trap_ring_width;  // 7.25
rj_shell             = 3.95;   // wall around bearing OD (matches printerx 23 mm shaft OD)

// Sled outer envelope
sled_w               = rj_bearing_od + rj_shell * 2;   // 23 mm (X) — full RJ4JP shell
sled_h               = 57.0;                            // Z — 50 mm spec + 5 mm bottom extension + 2 mm to clear X rod / bearing pocket
sled_d               = rj_base_y * 2 + 2;              // 60 mm (Y) — two-bearing retainer span
sled_top_z           = utf_post_top_z + 3;             // 499 mm — 3 mm above UTF post tops to clear front pulley geometry
sled_bot_z           = utf_post_bot_z;                  // 446 mm — fixed to UTF post bottom, independent of sled_top_z

// X rods: diagonal layout — front rod at top of sled, rear rod at bottom.
// Bore edge is x_rod_local_edge_gap mm from each adjacent sled face.
x_rod_mid_y          = bf_y_rail / 2;     // 202.5 mm — X rod Y midpoint in frame
x_rod_local_edge_gap = 3.0;              // bore outer edge to nearest sled face (mm)
_x_rod_bore_r        = (carriage_rod_dia + rod_bore_tol) / 2;  // 4.05 mm — bore radius
_sled_front_y        = x_rod_mid_y - sled_d / 2;              // 172.5 mm — sled front face, global Y
// Global Y positions
x_rod_front_y        = _sled_front_y + x_rod_local_edge_gap + _x_rod_bore_r;           // 179.65 mm
x_rod_rear_y         = _sled_front_y + sled_d - x_rod_local_edge_gap - _x_rod_bore_r;  // 225.35 mm
// Local Z positions in sled (from sled bottom)
// Front rod raised 3 mm (edge gap reduced from 3.0 to 1.0) to clear Y bearing pocket after y_rod_z lift.
x_rod_front_local_z  = sled_h - 1.0 - _x_rod_bore_r;                    // 49.85 mm
x_rod_rear_local_z   = x_rod_local_edge_gap + _x_rod_bore_r + 5;        // 12.15 mm
// Global Z positions
x_rod_front_z        = sled_bot_z + x_rod_front_local_z;   // 488.85 mm
x_rod_rear_z         = sled_bot_z + x_rod_rear_local_z;    // 453.15 mm

// X rod bore geometry: top rod stops 2 mm short of the yrod_relief opening.
// yrod_relief inner edge = yrod_x - relief_above_axis = sled_w/2 - 5.0 = 6.5 mm from outer face.
x_rod_bore_depth = sled_w - (sled_w / 2 - 5.0) - 2.0;  // 14.5 mm — blind bore from inner face
x_rod_air_depth  = sled_w - x_rod_bore_depth;           //  8.5 mm — air escape from outer face to bore floor

// X rod physical length: free span between sled inner faces + bore depth each side.
// Sled centres follow the Y-rod bore position (yrm_bore_x from shared-dims).
_x_rod_cx_l     = ex + yrm_bore_x;                      // 33.5 mm
_x_rod_cx_r     = bf_outer_x - ex - yrm_bore_x;         // 306.5 mm
x_rod_free_span = _x_rod_cx_r - _x_rod_cx_l - sled_w;   // 250 mm — inner face to inner face
x_rod_length    = x_rod_free_span + 2 * x_rod_bore_depth;  // 279 mm — cut from 362 mm stock

// Y rod height: centre the bearing pocket so the solid wall above it (to the
// sled top — gap "B") equals the web below it (to the rear X-rod bore top — gap "A").
_xrod_bore_top_z     = x_rod_rear_z + _x_rod_bore_r;            // 466.3 mm — top of rear X-rod bore
y_rod_z              = 485.2;     // rod bore 1 mm below corner-bracket M5 bore in y-rod-mount; raised 3 mm to clear front pulley nut trap

// ---------------------------------------------------------------------------
// Wing tabs (pillow blocks and captures)
// ---------------------------------------------------------------------------
wing_t               = 5.0;   // Wing tab thickness — how far the tab protrudes from a block face
wing_extend          = 20.0;  // How far the wing tab extends past the block body edge

// ---------------------------------------------------------------------------
// Z-axis stabilization linear rod (8 mm rod, 362 mm long)
// ---------------------------------------------------------------------------
z_lr_dia         = carriage_rod_dia;    // Physical rod diameter
z_lr_length      = 362.0;  // Physical rod length
z_lr_clearance   = 0.2;    // Extra bore depth on each end (rod treated as 362.4 mm)
z_lr_bore_dia    = z_lr_dia + rod_bore_tol;    // Bore diameter for the 8 mm rod
z_lr_wall        = 5.0;    // Plastic wall thickness flanking the rod bore

// Distance from the outer (extrusion-facing) block face to each bore centre:
z_lr_rod_cy      = z_lr_wall + z_lr_bore_dia / 2;                                     // 9.1 mm
z_lr_bearing_cy  = z_lr_rod_cy + z_lr_bore_dia / 2 + z_lr_wall + pb_bearing_od / 2;  // 29.3 mm

// Total pillow block depth (outer face → inner face):
z_lr_block_depth = z_lr_bearing_cy + pb_bearing_od / 2 + pb_wall;                     // 45.4 mm

// Blind-bore depth from the inner face in each block so the rod bottoms out.
// Inner-face gap = pb_upper_bot_z − pb_lower_top_z = 336 mm.
z_lr_bore_depth  = (z_lr_length + z_lr_clearance * 2 - (pb_upper_bot_z - pb_lower_top_z)) / 2;  // 13.2 mm

// ---------------------------------------------------------------------------
// M3 hardware
// ---------------------------------------------------------------------------
m3_through_dia       = 3.4;   // clearance bore for M3 bolt
m3_head_dia          = 6.0;   // pan/socket head diameter
m3_head_depth        = 3.0;   // socket head height
m3_nut_corner_dia    = 6.35;  // corner-to-corner diameter, DIN 934
m3_nut_depth         = 2.4;   // DIN 934 nominal thickness

// ---------------------------------------------------------------------------
// M5 hardware
// ---------------------------------------------------------------------------
m5_through_dia       = 5.5;
m5_head_dia          = 9.0;
m5_head_depth        = 3.5;
m5_nut_corner_dia    = 9.5;   // corner-to-corner (circumscribed) diameter, DIN 934
m5_nut_depth         = 4.8;  // DIN 934 nominal thickness
m5_tnut_clearance    = 20.0;  // Elbow connector occupies first 20 mm of each rail
