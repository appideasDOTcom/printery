/**
 * z-pillow-block.scad
 *
 * Z axis lead screw pillow block for two stacked 608zz bearings + flange spacer.
 * Block body is pb_block_xy × pb_block_xy × pb_block_h (32×32×34 mm).
 * The bearing pocket has pb_floor (9 mm) of material at each end, giving
 * 9 mm of lead-screw clearance beyond each bearing face.
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

// wing_t and wing_extend come from shared-dims.scad

module z_pillow_block(bolts = "xy", flip = false) {

    cx = pb_block_xy / 2;
    cy = pb_block_xy / 2;

    // Wings are always at the block bottom (wing_z = 0), fully merged with the block body.
    // Lower block: wings bolt into the bottom-frame top horizontal extrusion (world Z = 70..90).
    // Upper block: wings bolt into the top of the vertical upright (world Z = 426..446).
    wing_z = 0;
    bolt_z = ex / 2;   // bolt center at mid-height of extrusion

    // -----------------------------------------------------------------------
    // Block body
    // -----------------------------------------------------------------------
    module _body() {
        cube([pb_block_xy, pb_block_xy, pb_block_h]);
    }

    // -----------------------------------------------------------------------
    // Bearing pocket + lead screw through-bore
    // flip=false: OD bore from pb_floor upward — open at top
    // flip=true:  OD bore from 0 upward to pb_block_h-pb_floor — open at bottom
    // -----------------------------------------------------------------------
    module _pocket() {
        bore_z = flip ? -0.1      : pb_floor;
        bore_h = flip ? pb_block_h - pb_floor + 0.1
                      : pb_block_h - pb_floor + 0.1;

        translate([cx, cy, bore_z])
            cylinder(d = pb_bearing_od, h = bore_h);

        // Through-bore for lead screw — full height
        translate([cx, cy, -0.1])
            cylinder(d = pb_bearing_id + 0.4, h = pb_block_h + 0.2);
    }

    // -----------------------------------------------------------------------
    // "xy" wings
    // Y-wing: back face at local Y=0 (front extrusion inner face), extends in +X
    // X-wing: back face at local X=0 (left rail inner face), extends in +Y
    // -----------------------------------------------------------------------
    module _wing_y() {
        translate([pb_block_xy, 0, wing_z])
            cube([wing_extend, wing_t, ex]);
    }
    module _wing_y_hole() {
        translate([pb_block_xy + wing_extend/2, wing_t + 0.1, bolt_z])
            rotate([90, 0, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    module _wing_x() {
        translate([0, pb_block_xy, wing_z])
            cube([wing_t, wing_extend, ex]);
    }
    module _wing_x_hole() {
        translate([wing_t + 0.1, pb_block_xy + wing_extend/2, bolt_z])
            rotate([0, -90, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    // -----------------------------------------------------------------------
    // "xx" wings
    // Both back faces at local Y=pb_block_xy (rear extrusion inner face)
    // Left wing extends in -X, right wing extends in +X
    // -----------------------------------------------------------------------
    module _wing_left() {
        translate([-wing_extend, pb_block_xy - wing_t, wing_z])
            cube([wing_extend, wing_t, ex]);
    }
    module _wing_left_hole() {
        translate([-wing_extend/2, pb_block_xy - wing_t - 0.1, bolt_z])
            rotate([-90, 0, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    module _wing_right() {
        translate([pb_block_xy, pb_block_xy - wing_t, wing_z])
            cube([wing_extend, wing_t, ex]);
    }
    module _wing_right_hole() {
        translate([pb_block_xy + wing_extend/2, pb_block_xy - wing_t - 0.1, bolt_z])
            rotate([-90, 0, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    // -----------------------------------------------------------------------
    // Assembly
    // -----------------------------------------------------------------------
    difference() {
        union() {
            _body();
            if (bolts == "xy") { _wing_y(); _wing_x(); }
            else                { _wing_left(); _wing_right(); }
        }
        _pocket();
        if (bolts == "xy") { _wing_y_hole(); _wing_x_hole(); }
        else                { _wing_left_hole(); _wing_right_hole(); }
    }
}

// ---------------------------------------------------------------------------
// Preview — lower block (flip=false, pocket open at top)
// ---------------------------------------------------------------------------
z_pillow_block(bolts = "xy", flip = false);
