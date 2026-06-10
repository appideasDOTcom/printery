/**
 * y-rod-mount.scad
 *
 * Y-axis carriage rod end-capture block: 25 x 20 x 50 mm with a rod bore.
 * Bore centre: X = _yrm_bore_x = 10 (10 mm from the outer face); Z driven by y_rod_z.
 * Block is 25 mm wide — 5 mm of extra material on the center-facing side vs. the rod.
 * Right-side corners are placed with mirror([1,0,0]) at the call site; see upper-top-frame.scad.
 *
 * Two variants:
 *   y_rod_mount_front() — rod bore enters from the Y=_yrm_d face (interior face).
 *   y_rod_mount_rear()  — rod bore enters from the Y=0 face + stacked pulley pockets.
 *                         Pulley pocket opens through X+ and Y- faces (printer interior).
 *
 * Pulley stack geometry (rear variant):
 *   Two 18 mm OD × 8.5 mm pulleys on an M5 axle bolt (inserted from bottom).
 *   Rod bottom-face → top belt gap is 8 mm; belt-to-belt gap is 4 mm; each belt 6 mm.
 *   Lower pulley bottom ≈ 7.0 mm, upper pulley top ≈ 25.5 mm.
 *
 * Shaft bore position (rear, X=17, Y=5):
 *   Rod bore axis at X=10.  Sum of bore radii = 6.8 mm; X=17 gives 7 mm clearance.
 *   Shaft bore stops 2 mm below rod bore floor — no Z overlap.
 *   Y=5 leaves 6 mm wall to the rear-extrusion face at Y=20.
 *   Wall from shaft bore edge to center-facing face: 25 - (17 + 2.65) = 5.35 mm.
 *
 * See upper-top-frame.scad for placement.
 */

include <shared-dims.scad>

// ---------------------------------------------------------------------------
// Block envelope
// ---------------------------------------------------------------------------
_yrm_w          = 25.0;   // 5 mm extra on center-facing side (was 20)
_yrm_d          = 20.0;
_yrm_h          = 50.0;

// ---------------------------------------------------------------------------
// Rod bore
// ---------------------------------------------------------------------------
_yrm_bore_x     = 10.0;                      // bore centre X — 10 mm from outer face
_yrm_bore_dia   = carriage_rod_dia + 0.3;    // 8.3 mm — 8 mm rod + 0.3 slip fit
_yrm_bore_depth = _yrm_d - 2;                // 18 mm — rod bottoms out 2 mm from far face
_yrm_air_dia    = 5.0;                        // air-escape through-hole diameter
_yrm_bore_z     = y_rod_z - utf_post_bot_z;  // 36.275 mm — rod centre, local to block

// ---------------------------------------------------------------------------
// Rear-variant idler pulley geometry
// ---------------------------------------------------------------------------
_pul_od         = 18.0;
_pul_h          = 8.5;
_pul_belt_w     = 6.0;

_belt_rod_gap   = 8.0;    // rod bottom face → top belt top face
_belt_belt_gap  = 4.0;    // top belt bottom face → bottom belt top face

_top_belt_top_z = _yrm_bore_z - carriage_rod_dia / 2 - _belt_rod_gap;
_top_belt_cz    = _top_belt_top_z - _pul_belt_w / 2;
_bot_belt_top_z = _top_belt_top_z - _pul_belt_w - _belt_belt_gap;
_bot_belt_cz    = _bot_belt_top_z - _pul_belt_w / 2;

_pul_bot_z      = _bot_belt_cz - _pul_h / 2;   // ≈ 7.0 mm — lower pulley bottom
_pul_top_z      = _top_belt_cz + _pul_h / 2;   // ≈ 25.5 mm — upper pulley top

_pul_r          = _pul_od / 2 + 0.6;            // 9.6 mm — pocket radius with clearance
_pul_pckt_bot   = _pul_bot_z - 0.5;
_pul_pckt_top   = _pul_top_z + 0.5;

_shaft_x        = 17.0;
_shaft_y        = 5.0;         // rear: pocket opens through Y=0 (interior) face
_shaft_y_front  = 15.0;        // front: pocket opens through Y=_yrm_d (interior) face
_shaft_dia      = 5.3;
_shaft_top_z    = _yrm_bore_z - _yrm_bore_dia / 2 - 2.0;

_m5_head_dia    = 9.5;
_m5_head_depth  = 4.0;
_m5_nut_dia     = 9.2;
_m5_nut_h       = 5.0;

// ---------------------------------------------------------------------------
// Front variant — bore enters from Y=_yrm_d (interior face); right side uses mirror([1,0,0])
// Both pulley pocket positions are present; only one is used per corner.
// ---------------------------------------------------------------------------
module y_rod_mount_front() {
    difference() {
        cube([_yrm_w, _yrm_d, _yrm_h]);
        // Rod bore: enters from the Y=_yrm_d face, bottoms out 2 mm from exterior face
        translate([_yrm_bore_x, _yrm_d + 0.1, _yrm_bore_z])
            rotate([90, 0, 0])
                cylinder(d = _yrm_bore_dia, h = _yrm_bore_depth + 0.1);
        // Air escape: through hole exits exterior face
        translate([_yrm_bore_x, _yrm_d + 0.1, _yrm_bore_z])
            rotate([90, 0, 0])
                cylinder(d = _yrm_air_dia, h = _yrm_d + 0.2);
        // Pulley pocket: opens through X+ and Y+ (interior) faces for belt routing
        translate([_shaft_x, _shaft_y_front, _pul_pckt_bot])
            cylinder(r = _pul_r, h = _pul_pckt_top - _pul_pckt_bot);
        // Shaft bore: bottom of block to just below rod bore floor
        translate([_shaft_x, _shaft_y_front, -0.1])
            cylinder(d = _shaft_dia, h = _shaft_top_z + 0.1);
        // M5 bolt-head counterbore at block bottom face
        translate([_shaft_x, _shaft_y_front, -0.1])
            cylinder(d = _m5_head_dia, h = _m5_head_depth + 0.1);
        // M5 nut seat above upper pulley
        translate([_shaft_x, _shaft_y_front, _pul_pckt_top])
            cylinder(d = _m5_nut_dia, h = _m5_nut_h);
    }
}

// ---------------------------------------------------------------------------
// Rear variant — bore from Y=0 (interior face) + stacked pulley pockets; right side uses mirror([1,0,0])
// ---------------------------------------------------------------------------
module y_rod_mount_rear() {
    difference() {
        cube([_yrm_w, _yrm_d, _yrm_h]);
        // Rod bore: enters from the Y=0 face
        translate([_yrm_bore_x, -0.1, _yrm_bore_z])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_bore_dia, h = _yrm_bore_depth + 0.1);
        // Air escape
        translate([_yrm_bore_x, -0.1, _yrm_bore_z])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_air_dia, h = _yrm_d + 0.2);
        // Pulley pocket: opens through X+ and Y- faces into printer interior
        translate([_shaft_x, _shaft_y, _pul_pckt_bot])
            cylinder(r = _pul_r, h = _pul_pckt_top - _pul_pckt_bot);
        // Shaft bore: bottom of block to just below rod bore floor
        translate([_shaft_x, _shaft_y, -0.1])
            cylinder(d = _shaft_dia, h = _shaft_top_z + 0.1);
        // M5 bolt-head counterbore at block bottom face
        translate([_shaft_x, _shaft_y, -0.1])
            cylinder(d = _m5_head_dia, h = _m5_head_depth + 0.1);
        // M5 nut seat above upper pulley
        translate([_shaft_x, _shaft_y, _pul_pckt_top])
            cylinder(d = _m5_nut_dia, h = _m5_nut_h);
    }
}

// Preview
y_rod_mount_front();
