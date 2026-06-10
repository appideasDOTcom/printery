/**
 * x-rod-sled.scad
 *
 * Y-axis carriage sled. Rides on one Y rod via two RJ4JP (LM8UU-footprint,
 * dry polymer — NO lubrication) bearings trapped in a retainer pocket near the
 * top of the sled. Rod + bearings load from the outer (−X) face side slot.
 * Captures both X gantry rods lower in the body.
 *
 * Envelope: sled_w x sled_d x sled_h = 23 (X) x 60 (Y) x 50 (Z) mm.
 *   - X grew 20 -> 23 to give the full RJ4JP retainer shell (matches the
 *     printerx 23 mm retainer shaft OD).
 *   - Y grew 50 -> 60 to fit the two-bearing retainer span.
 *   - Z fixed at 50; top is flush with the Y-rod-mount top (sled_top_z).
 *
 * The Y-rod bearing pocket (clamp groove + trap rings) is copied verbatim
 * from the printerx "X axis carriage" / "Y carriage bearing retainer" — a
 * tested RJ4JP clamp. Do not alter the rj_* dimensions (in shared-dims.scad).
 *
 * Placement (see upper-top-frame.scad): centred on the Y rod in X, centred
 * on the frame in Y, top flush with the UTF post tops.
 */

include <shared-dims.scad>

// --- Local feature positions (sled frame: origin front-left-bottom) ---
yrod_x        = sled_w / 2;                 // 11.5 — Y rod / bearing centre in X
yrod_z        = y_rod_z - sled_bot_z;       // 36.275 — Y rod centre in Z (rides high)
xrod_z        = x_rod_z - sled_bot_z;       // 18.45 — X rod capture bores in Z
xrod_front_y  = sled_d / 2 + (x_rod_front_y - x_rod_mid_y);   // 10
xrod_rear_y   = sled_d / 2 + (x_rod_rear_y  - x_rod_mid_y);   // 50

x_bore_dia    = carriage_rod_dia + 0.2;     // 8.2 mm slip fit for the X rod capture

// --- Bearing rod-insertion relief (opens through the outer −X face) ---
relief_w          = carriage_rod_dia;       // 8 mm — slot height, rod passes, bearing stays trapped
relief_above_axis = 5.0;                    // slot floor this far from the rod axis (toward −X)

// --- Two-bearing spacing along the rod ---
bearing_pitch = rj_base_y;                  // 29 — origin-to-origin of the two pocket modules

// --- Outer-edge rounding (top & bottom on the OUTER −X side) ---
// The sled top sits flush against the upper-top frame, so the outer top edge
// is rounded down following the bearing-pocket contour, keeping the same wall
// thickness. The bottom-outer edge gets the mirror of that shape for frame
// clearance below. Inner (+X) edges stay square. Mirror the whole part for
// right-hand sleds (see upper-top-frame.scad).
outer_wall   = sled_h - (yrod_z + rj_bearing_od / 2);   // 6.175 — wall above the pocket (= gap A/B)
round_r      = rj_bearing_od / 2 + outer_wall;          // 13.725 — outer contour radius (tangent to top)
round_eps    = 0.1;

// --- Modules ---

// ONE bearing's retainer pocket, built along the local +Z axis.
// Verbatim printerx profile: a full-length thin bore leaves two inward trap
// rings that snap into the bearing's circumferential grooves, flanked by
// wider relief bores at the entry, centre, and exit.
module rj4jp_pocket_piece() {
    // thin inner bore — forms the trap-ring faces
    cylinder(d = rj_bearing_od - rj_trap_ring_depth * 2, h = rj_base_y + 2);
    // central clamp groove
    translate([0, 0, rj_base_y / 2 - rj_trap_ring_spacing / 2 + 1])
        cylinder(d = rj_bearing_od, h = rj_trap_ring_spacing);
    // entry relief
    cylinder(d = rj_bearing_od, h = rj_cutout_to_end);
    // exit relief
    translate([0, 0, rj_base_y - rj_cutout_to_end + 2])
        cylinder(d = rj_bearing_od, h = rj_cutout_to_end);
}

// Two pockets in line along +Y, breaching both faces so the Y rod runs through.
module yrod_bearing_pocket() {
    for (off = [0, bearing_pitch])
        translate([yrod_x, off, yrod_z])
            rotate([-90, 0, 0])
                rj4jp_pocket_piece();
}

// Slot from the outer (−X) face inward to relief_above_axis from the rod axis,
// so the rod + bearings slide in from the side. Height = rod dia; bearings are
// held radially by the pocket. Top face is left smooth/closed.
module yrod_relief() {
    translate([-0.1, -0.1, yrod_z - relief_w / 2])
        cube([yrod_x - relief_above_axis + 0.1, sled_d + 0.2, relief_w]);
}

// Full-width X-rod capture bore at height xrod_z.
module x_rod_bore(bore_y) {
    translate([-0.1, bore_y, xrod_z])
        rotate([0, 90, 0])
            cylinder(d = x_bore_dia, h = sled_w + 0.2);
}

// Outer corner waste: everything on the outer (−X) half that lies beyond a
// round_r arc centred at (yrod_x, arc_cz). `box_lo`/`box_hi` confine it to the
// top corner (above the arc) or the bottom corner (below the arc).
module _outer_corner_round(arc_cz, box_lo, box_hi) {
    difference() {
        translate([-round_eps, -round_eps, box_lo])
            cube([yrod_x + round_eps, sled_d + 2 * round_eps, box_hi - box_lo]);
        translate([yrod_x, -2 * round_eps, arc_cz])
            rotate([-90, 0, 0])
                cylinder(r = round_r, h = sled_d + 4 * round_eps);
    }
}

module x_rod_sled() {
    difference() {
        cube([sled_w, sled_d, sled_h]);
        yrod_bearing_pocket();
        yrod_relief();
        x_rod_bore(xrod_front_y);
        x_rod_bore(xrod_rear_y);
        // Top-outer round: arc concentric with the pocket, forms the smooth bearing-arc cap at the top face
        _outer_corner_round(yrod_z, yrod_z, sled_h + round_eps);
        // Bottom-outer round: same shape mirrored to the bottom (tangent to it)
        _outer_corner_round(sled_h - yrod_z, -round_eps, sled_h - yrod_z);
    }
}

// Preview
x_rod_sled();
