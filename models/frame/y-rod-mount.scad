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
_yrm_h_rail     = 70.0;

// ---------------------------------------------------------------------------
// Rod bore
// ---------------------------------------------------------------------------
_yrm_bore_x     = yrm_bore_x;                // bore centre X — from shared-dims.scad
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
_pul_z_lift     = 5.1;
_pul_pckt_bot   = 6.0;   // fixed — decoupled from rod bore position
_pul_pckt_top   = 25.5;  // fixed — decoupled from rod bore position

_shaft_x        = 10.5;
_floor_ext      = 10.0;   // floor extension length toward printer center (mm)
_shaft_y        = 10.0;        // centred on the 20 mm rail (Y=_yrm_d/2)
_shaft_y_front  = 10.0;        // centred on the 20 mm rail (Y=_yrm_d/2)
_shaft_dia      = 5.3;
_shaft_top_z    = _yrm_bore_z + _yrm_bore_dia / 2;

_m5_head_dia    = 9.5;
_m5_head_depth  = 5.1;
_m5_nut_h       = 4.1;
_m5_hex_dia     = 9.6;   // M5 hex nut circumscribed dia + 0.3 mm clearance (8.0 mm AF → 9.24 mm AC)

// Corner-bracket mounting bolt (runs in X through the block)
_cbkt_bolt_z    = _yrm_h - 6.0;   // Z centre — above rod bore, 6 mm from top face
_cbkt_cbore_dia = 9.0;             // bolt head recess diameter
_cbkt_cbore_dep = 4.0;             // bolt head recess depth from interior (+X) face

// ---------------------------------------------------------------------------
// Front variant — bore enters from Y=_yrm_d (interior face); right side uses mirror([1,0,0])
// Both pulley pocket positions are present; only one is used per corner.
// ---------------------------------------------------------------------------
module y_rod_mount_front() {
    difference() {
        union() {
            cube([_yrm_w, _yrm_d, _yrm_h]);
            translate([-20, -3, -20]) cube([_yrm_w + 20, 3, _yrm_h + 40]);
        }
        // Rod bore: enters from the Y=_yrm_d face, bottoms out 2 mm from exterior face
        translate([_yrm_bore_x, _yrm_d + 0.1, _yrm_bore_z])
            rotate([90, 0, 0])
                cylinder(d = _yrm_bore_dia, h = _yrm_bore_depth + 0.1);
        // Air escape: through hole exits exterior face
        translate([_yrm_bore_x, _yrm_d + 0.1, _yrm_bore_z])
            rotate([90, 0, 0])
                cylinder(d = _yrm_air_dia, h = _yrm_d + 3.2);
        // Pulley pocket: opens through X+ and Y+ (interior) faces for belt routing
        translate([_shaft_x, _shaft_y_front, _pul_pckt_bot])
            cylinder(r = _pul_r, h = _pul_pckt_top - _pul_pckt_bot);
        // Belt escape: remove inner (+X) wall — from pocket edge to inner Y face, outer face preserved
        translate([_shaft_x, _shaft_y_front - _pul_r, _pul_pckt_bot])
            cube([_yrm_w - _shaft_x + 0.1, _yrm_d - (_shaft_y_front - _pul_r) + 0.1, _pul_pckt_top - _pul_pckt_bot]);
        // Belt escape: remove inner Y wall (Y=_yrm_d side) of pulley pocket
        translate([_shaft_x - _pul_r, _shaft_y_front, _pul_pckt_bot])
            cube([2 * _pul_r, _yrm_d - _shaft_y_front + 0.1, _pul_pckt_top - _pul_pckt_bot]);
        // Shaft bore: bottom of block to just below rod bore floor
        translate([_shaft_x, _shaft_y_front, -0.1])
            cylinder(d = _shaft_dia, h = _shaft_top_z + 0.1);
        // M5 bolt-head counterbore at block bottom face
        translate([_shaft_x, _shaft_y_front, -0.1])
            cylinder(d = _m5_head_dia, h = _m5_head_depth + 0.1);
        // M5 hex nut trap above upper pulley — $fn=6 prevents nut spinning during tightening
        translate([_shaft_x, _shaft_y_front, _pul_pckt_top - 0.1])
            cylinder(d = _m5_hex_dia, h = _m5_nut_h + 0.1, $fn = 6);
        // M5 frame-mount hole
        hull() { translate([-10.5, -3.1, _yrm_h/2]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); translate([-9.5, -3.1, _yrm_h/2]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); }
		hull() { translate([10, -3.1, _yrm_h_rail - 10.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); translate([10, -3.1, _yrm_h_rail - 9.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); }
		hull() { translate([10, -3.1, -10.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); translate([10, -3.1, -9.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); }
    }
}

// ---------------------------------------------------------------------------
// Rear variant — bore from Y=0 (interior face) + stacked pulley pockets; right side uses mirror([1,0,0])
// ---------------------------------------------------------------------------
module y_rod_mount_rear() {
    difference() {
        union() {
            cube([_yrm_w, _yrm_d, _yrm_h]);
            translate([-20, _yrm_d, -20]) cube([_yrm_w + 20, 3, _yrm_h + 40]);
        }
        // Rod bore: enters from the Y=0 face
        translate([_yrm_bore_x, -0.1, _yrm_bore_z])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_bore_dia, h = _yrm_bore_depth + 0.1);
        // Air escape
        translate([_yrm_bore_x, -0.1, _yrm_bore_z])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_air_dia, h = _yrm_d + 3.2);
        // Pulley pocket: opens through X+ and Y- faces into printer interior
        translate([_shaft_x, _shaft_y, _pul_pckt_bot])
            cylinder(r = _pul_r, h = _pul_pckt_top - _pul_pckt_bot);
        // Belt escape: remove inner (+X) wall — from inner Y face to pocket edge, outer face preserved
        translate([_shaft_x, -0.1, _pul_pckt_bot])
            cube([_yrm_w - _shaft_x + 0.1, _shaft_y + _pul_r + 0.1, _pul_pckt_top - _pul_pckt_bot]);
        // Belt escape: remove inner Y wall (Y=0 side) of pulley pocket
        translate([_shaft_x - _pul_r, -0.1, _pul_pckt_bot])
            cube([2 * _pul_r, _shaft_y + 0.1, _pul_pckt_top - _pul_pckt_bot]);
        // Shaft bore: bottom of block to just below rod bore floor
        translate([_shaft_x, _shaft_y, -0.1])
            cylinder(d = _shaft_dia, h = _shaft_top_z + 0.1);
        // M5 bolt-head counterbore at block bottom face
        translate([_shaft_x, _shaft_y, -0.1])
            cylinder(d = _m5_head_dia, h = _m5_head_depth + 0.1);
        // M5 hex nut trap above upper pulley — $fn=6 prevents nut spinning during tightening
        translate([_shaft_x, _shaft_y, _pul_pckt_top - 0.1])
            cylinder(d = _m5_hex_dia, h = _m5_nut_h + 0.1, $fn = 6);

		hull() { translate([-10.5, -3.1, _yrm_h/2]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); translate([-9.5, -3.1, _yrm_h/2]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); }
		hull() { translate([10, -3.1, _yrm_h_rail - 10.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); translate([10, -3.1, _yrm_h_rail - 9.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); }
		hull() { translate([10, -3.1, -10.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); translate([10, -3.1, -9.5]) rotate([-90,0,0]) cylinder(d=5.5, h=_yrm_d+6.2); }
    }
}

// Preview
// Four variations:
// y_rod_mount_front();                 // A. Front left
// mirror([1,0,0]) y_rod_mount_front(); // B. Front right
// y_rod_mount_rear();                  // C. Rear left
mirror([1,0,0]) y_rod_mount_rear();     // D. Rear right
