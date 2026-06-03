/**
 * z-pillow-block.scad
 *
 * Z axis lead screw pillow block for two stacked 608zz bearings + flange spacer.
 * Block body footprint: square top half + semicircular bottom half, both
 * inscribed in pb_block_xy × pb_block_xy (32×32 mm), extruded to pb_block_h (20 mm).
 * The bearing pocket has pb_floor (4 mm) of material at each end, giving
 * 4 mm of lead-screw clearance beyond each bearing face.
 *
 * Parameters:
 *   bolts = "xy"  front corner orientation
 *   bolts = "xx"  rear center orientation
 *   flip  = false lower block: pocket open at TOP,  wings at Z = 0..ex
 *   flip  = true  upper block: pocket open at BOTTOM, wings at Z = pb_block_h..pb_block_h+ex
 *
 * PLACEMENT:
 *   Lower front-left:  translate([ex, ex, pb_lower_bot_z])  z_pillow_block("xy");
 *   Lower front-right: translate([bf_outer_x-ex, ex, pb_lower_bot_z])
 *                        mirror([1,0,0])  z_pillow_block("xy");
 *   Lower rear center: translate([ls_rc_x-pb_block_xy/2, bf_rear_y_face-pb_block_xy, pb_lower_bot_z])
 *                        z_pillow_block("xx");
 *   Upper: same X/Y, replace pb_lower_bot_z with pb_upper_bot_z, add flip=true.
 */

include <shared-dims.scad>

module z_pillow_block(bolts = "xy", flip = false) {

    r      = 2.0;
    cx     = pb_block_xy / 2;
    cy     = pb_block_xy / 2;
    bolt_z = ex / 2;

    // Single 2D footprint: block body + two wings as rectangles.
    // Triple offset(r) offset(-2r) offset(r) rounds convex corners AND adds
    // fillets at concave inside corners (wing-to-body junctions).
    //
    // "xy" (corner): right-half rect + top-half rect + inscribed circle.
    //   The L-shaped union fills all quadrants except the lower-left; the
    //   inscribed circle rounds only that free corner.  This keeps the
    //   right-side body material intact so Wing 1 (at y=0..wing_t) stays
    //   connected.
    //
    // "xx" (centre-rear): top-half rect + inscribed circle gives a full
    //   semicircular bottom.  Both wings sit at the top so no connectivity
    //   is lost.
    module _footprint() {
        offset(r = r) offset(r = -2*r) offset(r = r)
            union() {
                if (bolts == "xy") {
                    square([cx, pb_block_xy]);              // left half  — full height
                    square([pb_block_xy, cy]);              // bottom half — full width
                    translate([cx, cy]) circle(r = cx);    // rounds upper-right corner (open interior)
                } else {
                    translate([0, cy])  square([pb_block_xy, cy]);  // top half
                    translate([cx, cy]) circle(r = cx);             // semicircular bottom
                }
                if (bolts == "xy") {
                    translate([pb_block_xy, 0])              square([wing_extend, wing_t]);
                    translate([0,           pb_block_xy])    square([wing_t,      wing_extend]);
                } else {
                    translate([-wing_extend,   pb_block_xy - wing_t]) square([wing_extend, wing_t]);
                    translate([pb_block_xy,    pb_block_xy - wing_t]) square([wing_extend, wing_t]);
                }
            }
    }

    bore_z = flip ? -0.1 : pb_floor;
    bore_h = pb_block_h - pb_floor + 0.1;

    difference() {
        linear_extrude(pb_block_h)
            _footprint();

        // Bearing pocket
        translate([cx, cy, bore_z])
            cylinder(d = pb_bearing_od, h = bore_h);

        // Lead screw through-bore
        translate([cx, cy, -0.1])
            cylinder(d = pb_bearing_id + 0.4, h = pb_block_h + 0.2);

        // Bolt holes
        if (bolts == "xy") {
            translate([pb_block_xy + wing_extend/2, wing_t + 0.1, bolt_z])
                rotate([90, 0, 0])
                    cylinder(d = m5_through_dia, h = wing_t + 0.2);
            translate([wing_t + 0.1, pb_block_xy + wing_extend/2, bolt_z])
                rotate([0, -90, 0])
                    cylinder(d = m5_through_dia, h = wing_t + 0.2);
        } else {
            translate([-wing_extend/2, pb_block_xy - wing_t - 0.1, bolt_z])
                rotate([-90, 0, 0])
                    cylinder(d = m5_through_dia, h = wing_t + 0.2);
            translate([pb_block_xy + wing_extend/2, pb_block_xy - wing_t - 0.1, bolt_z])
                rotate([-90, 0, 0])
                    cylinder(d = m5_through_dia, h = wing_t + 0.2);
        }
    }
}

// ---------------------------------------------------------------------------
// Preview
// ---------------------------------------------------------------------------
// z_pillow_block(bolts = "xy", flip = false);
z_pillow_block(bolts = "xx", flip = false);
