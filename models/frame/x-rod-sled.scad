/**
 * x-rod-sled.scad
 *
 * Y-axis carriage sled. Rides on one Y rod via two RJ4JP (LM8UU-footprint,
 * dry polymer — NO lubrication) bearings trapped in a retainer pocket near the
 * top of the sled. Rod + bearings load from the outer (−X) face side slot.
 * Captures both X gantry rods: front-top corner and rear-bottom corner.
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

x_bore_dia    = carriage_rod_dia + 0.3;   // 8.3 mm slip fit for the X rod capture

// Front-top and rear-bottom X rod capture positions (sled-local, origin front-left-bottom)
xrod_front_y  = x_rod_local_edge_gap + x_bore_dia / 2;              // 16.15 — from front face
xrod_front_z  = x_rod_front_local_z;    // from shared-dims — matches assembly rod placement
xrod_rear_y   = sled_d - x_rod_local_edge_gap - x_bore_dia / 2;    // 43.85 — from front
xrod_rear_z   = x_rod_local_edge_gap + x_bore_dia / 2 + 5;         // 21.15 — from bottom

// Blind bore depth from shared-dims: rod stops 2 mm short of the yrod_relief opening.
x_bore_depth  = x_rod_bore_depth;   // 14.5 mm — from inner face (see shared-dims.scad)
x_air_dia     = 5.0;                // air-escape hole diameter

// Belt pass clearance on outer (−X) face
// Pulley centre at global X = 30.5 mm; belt outer edge at 24.5 mm; sled outer face at 22 mm.
// Need sled clear to 24.5 + 2 mm margin = 26.5 mm → 4.5 mm depth from outer face.
belt_pass_depth = 4.5;
belt_pass_h     = 30.0;   // covers both belt-run heights (~12–28 mm local Z) with margin

// --- Front-face idler pulley pocket ---
// Outside of this pulley's belt path aligns with the inside of the y-rod-mount front
// pulley's belt path. Offset from the y-rod-mount shaft (+X toward center) = 7.5 mm.
// y-rod-mount shaft at global X = ex + _shaft_x = 20 + 10.5 = 30.5; sled outer face at 22.
// New shaft local X = (30.5 + 7.5) - 22 = 16 mm.
fp_pul_od        = 18.0;
fp_pul_r         = fp_pul_od / 2 + 0.6;   // 9.6 mm — pocket radius with clearance (matches y-rod-mount)
fp_shaft_x_offset = 7.5;                   // X offset toward center vs. y-rod-mount shaft
fp_shaft_x       = (30.5 + fp_shaft_x_offset) - 22;   // 16.0 mm — local sled X
fp_shaft_y       = 10.0;                   // Y from front face — centred on the 20 mm rail (matches y-rod-mount)
fp_shaft_dia     = 5.3;                    // M5 clearance bore
fp_pckt_bot      = 6.0;                    // matches y-rod-mount _pul_pckt_bot
fp_pckt_top      = 25.5;                   // matches y-rod-mount _pul_pckt_top
fp_m5_head_dia   = 9.5;
fp_m5_head_depth = 5.1;
fp_m5_hex_dia    = 9.6;
fp_m5_nut_h      = 4.1;
fp_shaft_top_z   = yrod_z + (carriage_rod_dia + 0.3) / 2;  // stops just below Y-rod bore floor

// --- Rear-face idler pulley pocket ---
// 18 mm behind and 15 mm outside the front pulley shaft; same Z extents.
rp_shaft_x       = fp_shaft_x - 15.0;   // 1.0 mm — local sled X
rp_shaft_y       = fp_shaft_y + 18.0;   // 28.0 mm — local sled Y
rp_pckt_bot      = fp_pckt_bot;         // 6.0 mm — same Z as front pocket
rp_pckt_top      = fp_pckt_top;         // 25.5 mm
rp_shaft_top_z   = fp_shaft_top_z;      // same shaft height

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
corner_r     = 2.0;   // fillet on the 4 vertical (X-running) edges of the sled body

// --- Modules ---

// Sled body with rounded vertical (X-running) edges so the print head traces a
// smooth path rather than a sharp 90° corner at each layer.  Both flat faces
// (inner +X and outer -X) remain perfectly flat.
module sled_body() {
    hull()
        for (y = [corner_r, sled_d - corner_r])
            for (z = [corner_r, sled_h - corner_r])
                translate([0, y, z])
                    rotate([0, 90, 0])
                        cylinder(r = corner_r, h = sled_w);
}

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

// Blind X-rod capture bore. Rod inserts from inner (+X) face, bottoms out 2 mm short of yrod_relief.
// Air escape opens from outer face to the bore floor (depth = x_rod_air_depth from shared-dims).
module x_rod_bore(bore_y, bore_z) {
    // Rod bore: blind, 8.3 mm dia, from inner face inward
    translate([sled_w + 0.1, bore_y, bore_z])
        rotate([0, -90, 0])
            cylinder(d = x_bore_dia, h = x_bore_depth + 0.1);
    // Air escape: 5 mm dia, from outer face through full sled width to guarantee no wall at bore junction
    translate([-0.1, bore_y, bore_z])
        rotate([0, 90, 0])
            cylinder(d = x_air_dia, h = sled_w + 0.2);
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

// Front-face idler pulley pocket. Opens through the front (Y=0) face and the
// inner (+X) face. Shaft bore runs from bottom to just below the Y-rod bore floor.
module front_pulley_pocket() {
    // Cylindrical pocket volume
    translate([fp_shaft_x, fp_shaft_y, fp_pckt_bot])
        cylinder(r = fp_pul_r, h = fp_pckt_top - fp_pckt_bot);
    // Belt escape: open inner (+X) wall from pocket edge to sled inner face
    translate([fp_shaft_x, fp_shaft_y - fp_pul_r, fp_pckt_bot])
        cube([sled_w - fp_shaft_x + 0.1, fp_pul_r * 2, fp_pckt_top - fp_pckt_bot]);

	// Remove the wall between pockets so that we can print without supports.
	translate([fp_shaft_x - 12, fp_shaft_y - fp_pul_r - 2, fp_pckt_bot])
        cube([sled_w - fp_shaft_x + 0.1 + 12, fp_pul_r * 2 + 2, fp_pckt_top - fp_pckt_bot]);

    // Belt escape: open front (Y=0) wall of pocket
    translate([fp_shaft_x - fp_pul_r, -0.1, fp_pckt_bot])
        cube([fp_pul_r * 2, fp_shaft_y + 0.1, fp_pckt_top - fp_pckt_bot]);
    // Shaft bore: bottom of sled to just below Y-rod bore floor
    translate([fp_shaft_x, fp_shaft_y, -0.1])
        cylinder(d = fp_shaft_dia, h = fp_shaft_top_z - 12);
    // M5 bolt-head counterbore at sled bottom face
    translate([fp_shaft_x, fp_shaft_y, -0.1])
        cylinder(d = fp_m5_head_dia, h = fp_m5_head_depth + 0.1);
    // M5 hex nut trap above upper pulley
    translate([fp_shaft_x, fp_shaft_y, fp_pckt_top - 0.1])
        cylinder(d = fp_m5_hex_dia, h = fp_m5_nut_h + 0.1, $fn = 6);
}

// Rear-face idler pulley pocket. Same geometry as front_pulley_pocket(); opens through
// the outer (−X) face and rear (Y=sled_d) face.
module rear_pulley_pocket() {
    // Cylindrical pocket volume
    translate([rp_shaft_x, rp_shaft_y, rp_pckt_bot])
        cylinder(r = fp_pul_r, h = rp_pckt_top - rp_pckt_bot);
    // Belt escape: open inner (+X) wall
    translate([rp_shaft_x, rp_shaft_y - fp_pul_r, rp_pckt_bot])
        cube([sled_w - rp_shaft_x + 0.1, fp_pul_r * 2, rp_pckt_top - rp_pckt_bot]);
    // Shaft bore: bottom of sled to just below Y-rod bore floor
    translate([rp_shaft_x, rp_shaft_y, -0.1])
        cylinder(d = fp_shaft_dia, h = rp_shaft_top_z + 0.1 - 9);
    // M5 bolt-head counterbore at sled bottom face
    translate([rp_shaft_x, rp_shaft_y, -0.1])
        cylinder(d = fp_m5_head_dia, h = fp_m5_head_depth + 0.1);
    // M5 hex nut trap above upper pulley
    translate([rp_shaft_x, rp_shaft_y, rp_pckt_top - 0.1])
        cylinder(d = fp_m5_hex_dia, h = fp_m5_nut_h + 0.1, $fn = 6);
}

// Clears the outer (−X) face for the GT2 belt running along the Y-axis wall.
// Top-inner corner is rounded with a hull+cylinder fillet.
belt_pass_fillet_r = 3.0;
module _belt_pass_clearance() {
    hull() {
        translate([-0.1, -0.1, -0.1])
            cube([belt_pass_depth - belt_pass_fillet_r, sled_d + 0.2, belt_pass_h + 0.2]);
        translate([-0.1, -0.1, -0.1])
            cube([belt_pass_depth + 0.2, sled_d + 0.2, belt_pass_h - belt_pass_fillet_r]);
        translate([belt_pass_depth - belt_pass_fillet_r, -0.1, belt_pass_h - belt_pass_fillet_r])
            rotate([-90, 0, 0])
                cylinder(r = belt_pass_fillet_r, h = sled_d + 0.2);
    }
}

module x_rod_sled() {
    union() {
        difference() {
            sled_body();
            yrod_bearing_pocket();
            yrod_relief();
            x_rod_bore(xrod_front_y, xrod_front_z);
            x_rod_bore(xrod_rear_y, xrod_rear_z);
            _outer_corner_round(yrod_z, yrod_z, sled_h + round_eps);
            _outer_corner_round(sled_h - yrod_z, -round_eps, sled_h - yrod_z);
            _belt_pass_clearance();
            front_pulley_pocket();
            rear_pulley_pocket();
        }
        // Floor disc and bridge — outside the difference so nothing erases them.
        // Shaft bore and bolt-head counterbore subtracted here.
        difference() {
            union() {
                translate([rp_shaft_x, rp_shaft_y, 1.4])
                    cylinder(d = 12.0, h = rp_pckt_bot - 1.4);
                translate([1, rp_shaft_y - 6.0, 1.4])
                    cube([rp_shaft_x + 6.0, 12.0, rp_pckt_bot - 1.4]);
            }
            translate([rp_shaft_x, rp_shaft_y, -0.1])
                cylinder(d = fp_shaft_dia, h = rp_pckt_bot + 0.2);
            translate([rp_shaft_x, rp_shaft_y, -0.1])
                cylinder(d = fp_m5_head_dia, h = fp_m5_head_depth + 0.1);
        }
        // Rear pulley boss: top flush with the shelf left by the lower bearing relief.
        // Shelf top = yrod_z - relief_w / 2; cylinder top = same.
        difference() {
            translate([rp_shaft_x, rp_shaft_y, yrod_z - relief_w / 2 - 9.7])
                cylinder(d = 15.0, h = 9.7);
            yrod_bearing_pocket();
            translate([rp_shaft_x, rp_shaft_y, yrod_z - relief_w / 2 - 9.7 - 0.1])
                cylinder(d = fp_m5_hex_dia, h = fp_m5_nut_h + 0.1, $fn = 6);
            translate([rp_shaft_x, rp_shaft_y, yrod_z - relief_w / 2 - 9.7 - 0.1])
                cylinder(d = fp_shaft_dia, h = 7.7 + 0.1);
        }
    }
}

// Preview
x_rod_sled();                   // LEFT
// mirror([1, 0, 0]) x_rod_sled(); // RIGHT
