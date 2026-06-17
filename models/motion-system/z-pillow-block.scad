/**
 * z-pillow-block.scad
 *
 * Z axis lead screw pillow block with integrated 8 mm linear-rod bore.
 *
 * Layout (from the outer/extrusion-facing face inward):
 *   z_lr_wall (5 mm) | 8 mm rod bore (Ø 8.2) | z_lr_wall (5 mm)
 *   | 608zz bearing bore (Ø 22.2) | pb_wall (5 mm) — inner face
 *
 * Total block depth: z_lr_block_depth = 45.4 mm
 *
 * The 8 mm rod bore is a blind hole opening from the inner (screw-access)
 * face, depth = z_lr_bore_depth = 13.2 mm per block so a 362 mm rod
 * bottoms out with 0.2 mm clearance on each end.
 * A 5 mm air-escape through-hole is coaxial with the rod bore.
 *
 * Parameters:
 *   bolts = "xy"  front corner orientation
 *   bolts = "xx"  rear centre orientation
 *   flip  = false lower block: bearing/rod pockets open at TOP
 *   flip  = true  upper block: bearing/rod pockets open at BOTTOM
 *
 * PLACEMENT (unchanged from before):
 *   Lower front-left:  translate([ex, ex, pb_lower_bot_z])  z_pillow_block("xy");
 *   Lower front-right: translate([bf_outer_x-ex, ex, pb_lower_bot_z])
 *                        mirror([1,0,0])  z_pillow_block("xy");
 *   Lower rear centre: translate([ls_rc_x-pb_block_xy/2, bf_rear_y_face-pb_block_xy, pb_lower_bot_z])
 *                        z_pillow_block("xx");
 *   Upper: same X/Y, replace pb_lower_bot_z with pb_upper_bot_z, add flip=true.
 */

include <../common/shared-dims.scad>

module z_pillow_block(bolts = "xy", flip = false) {

    r      = 2.0;
    cx     = pb_block_xy / 2;
    bolt_z = ex / 2;

    // Bearing and rod bore Y centres in block-local coordinates.
    // "xy" — outer face at local y = 0  (front extrusion)
    // "xx" — outer face at local y = pb_block_xy  (rear extrusion)
    bearing_cy = (bolts == "xy") ? z_lr_bearing_cy : pb_block_xy - z_lr_bearing_cy;
    rod_cy     = (bolts == "xy") ? z_lr_rod_cy      : pb_block_xy - z_lr_rod_cy;

    // Y start of the main body rectangle in local coords.
    // Single 2D footprint: organic body + mounting wings.
    //
    // "xy" (corner): L + circle — asymmetric bracket shape.
    //   Left half (full depth) + full-width band up to bearing centre + circle at bearing centre.
    //   → concave curve in the inner-right corner (between the two wings).
    //
    // "xx" (centre-rear): symmetric D-shape — same as original but deeper.
    //   Full-width band from bearing centre to outer face + semicircle at bearing centre.
    //   NO left half: both wings are on the outer face, shape is symmetric around x = cx.
    //
    // Triple offset rounds all convex corners and fillets wing-body junctions.
    module _footprint() {
        offset(r = r) offset(r = -2*r) offset(r = r)
            union() {
                if (bolts == "xy") {
                    // Left half: x∈[0,cx], full new depth
                    square([cx, z_lr_block_depth]);
                    // Full-width band from outer face to bearing centre
                    square([pb_block_xy, bearing_cy]);
                    // Circle at bearing centre — organic curve between wings
                    translate([cx, bearing_cy]) circle(r = cx);
                    // Wings
                    translate([pb_block_xy, 0])       square([wing_extend, wing_t]);
                    translate([0, z_lr_block_depth])  square([wing_t, wing_extend]);
                } else {
                    // Full-width band from bearing centre to outer face
                    translate([0, bearing_cy]) square([pb_block_xy, pb_block_xy - bearing_cy]);
                    // Semicircle at bearing centre — symmetric inward extension
                    translate([cx, bearing_cy]) circle(r = cx);
                    // Wings at outer face (both X sides)
                    translate([-wing_extend, pb_block_xy - wing_t]) square([wing_extend, wing_t]);
                    translate([pb_block_xy,  pb_block_xy - wing_t]) square([wing_extend, wing_t]);
                }
            }
    }

    // Bearing pocket Z extents (open on the inner/screw-access face)
    bore_z = flip ? -0.1 : pb_floor;
    bore_h = pb_block_h - pb_floor + 0.1;

    // Linear rod blind bore (opens from the same face as the bearing pocket)
    rod_bore_z = flip ? -0.1 : pb_block_h - z_lr_bore_depth - 0.1;
    rod_bore_h = z_lr_bore_depth + 0.1;

    difference() {
        linear_extrude(pb_block_h)
            _footprint();

        // Bearing pocket
        translate([cx, bearing_cy, bore_z])
            cylinder(d = pb_bearing_od, h = bore_h);

        // Lead screw through-bore
        translate([cx, bearing_cy, -0.1])
            cylinder(d = pb_bearing_id + 0.4, h = pb_block_h + 0.2);

        // Linear rod blind bore (bottoms out; opens from inner face)
        translate([cx, rod_cy, rod_bore_z])
            cylinder(d = z_lr_bore_dia, h = rod_bore_h);

        // Air-escape through-hole (coaxial with rod bore, full block height)
        translate([cx, rod_cy, -0.1])
            cylinder(d = 5.0, h = pb_block_h + 0.2);

        // Bolt holes (slotted ±2 mm in Z for vertical adjustability)
        if (bolts == "xy") {
            // X-direction wing bolt (outer face — shoots in -Y through wing_t)
            translate([pb_block_xy + wing_extend/2, wing_t + 0.1, bolt_z])
                rotate([90, 0, 0])
                    hull() {
                        translate([0, -2, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                        translate([0,  2, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                    }
            // Y-direction wing bolt (inner face, moved — shoots in -X through wing_t)
            translate([wing_t + 0.1, z_lr_block_depth + wing_extend/2, bolt_z])
                rotate([0, -90, 0])
                    hull() {
                        translate([-2, 0, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                        translate([ 2, 0, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                    }
        } else {
            translate([-wing_extend/2, pb_block_xy - wing_t - 0.1, bolt_z])
                rotate([-90, 0, 0])
                    hull() {
                        translate([0, -2, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                        translate([0,  2, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                    }
            translate([pb_block_xy + wing_extend/2, pb_block_xy - wing_t - 0.1, bolt_z])
                rotate([-90, 0, 0])
                    hull() {
                        translate([0, -2, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                        translate([0,  2, 0]) cylinder(d = m5_through_dia, h = wing_t + 0.2);
                    }
        }
    }
}

// ---------------------------------------------------------------------------
// Preview
// ---------------------------------------------------------------------------
// z_pillow_block(bolts = "xy", flip = false); // A. Front-left
// z_pillow_block(bolts = "xy", flip = true); // B. Front-right
z_pillow_block(bolts = "xx", flip = false); // C. Rear-center

