/**
 * z-pillow-block.scad
 *
 * Z axis lead screw pillow block for two stacked 608zz bearings.
 *
 * The block body is a plain rectangle. Two wing tabs extend OUTWARD past the
 * block body edges and press flat against the adjacent extrusion inner faces.
 * M5 bolts pass through each wing tab perpendicular to the extrusion face,
 * threading into T-nuts in the T-slot.
 *
 * Bearing pocket is open at the top so bearings drop in after printing.
 *
 *  bolts = "xy"  — front corner orientation (default: front-left)
 *    Y-wing: extends in +X past the block's +X edge, pressed against the
 *            front X cross-member inner face (-Y extrusion face).
 *            Bolt goes in -Y direction into that extrusion's T-slot.
 *    X-wing: extends in +Y past the block's +Y edge, pressed against the
 *            left Y-rail inner face (-X extrusion face).
 *            Bolt goes in -X direction into that rail's T-slot.
 *
 *  bolts = "xx"  — rear center orientation
 *    Two wings extend in ±X past the block's +X and -X edges.
 *    Both press against the rear X cross-member inner face (+Y face).
 *    Bolts go in +Y direction into that extrusion's T-slot.
 *
 * PLACEMENT in assemblies (no wing_t offset needed on the block translate):
 *   Front-left:  translate([ex, ex, Z])  z_pillow_block(bolts="xy");
 *   Front-right: translate([bf_outer_x - ex, ex, Z])
 *                  mirror([1,0,0])  z_pillow_block(bolts="xy");
 *   Rear center: translate([ls_rc_x - pb_block_xy/2, bf_rear_y_face - pb_block_xy, Z])
 *                  z_pillow_block(bolts="xx");
 */

include <shared-dims.scad>

// wing_t and wing_extend come from shared-dims.scad

module z_pillow_block(bolts = "xy") {

    cx = pb_block_xy / 2;
    cy = pb_block_xy / 2;

    // -----------------------------------------------------------------------
    // Block body — plain rectangle
    // -----------------------------------------------------------------------
    module _body() {
        cube([pb_block_xy, pb_block_xy, pb_block_h]);
    }

    // -----------------------------------------------------------------------
    // Bearing pocket — open at the top for insertion.
    // Floor at pb_wall. Lead screw through-bore passes the full height.
    // -----------------------------------------------------------------------
    module _pocket() {
        // Bearing OD bore: from floor to top of block (open top)
        translate([cx, cy, pb_wall])
            cylinder(d = pb_bearing_od, h = pb_block_h - pb_wall + 0.1);

        // Lead screw through-bore: full height with small overrun
        translate([cx, cy, -0.1])
            cylinder(d = pb_bearing_id + 0.4, h = pb_block_h + 0.2);
    }

    // -----------------------------------------------------------------------
    // "xy" wings — for front corner block
    // -----------------------------------------------------------------------

    // Y-wing: back face flush with block's -Y face (local Y=0 = extrusion inner face).
    // Wing protrudes INTO the frame interior toward +Y.
    // Bolt goes in -Y direction from inside the frame through the wing into the T-slot.
    module _wing_y() {
        translate([pb_block_xy, 0, 0])
            cube([wing_extend, wing_t, ex]);
    }

    module _wing_y_hole() {
        translate([pb_block_xy + wing_extend/2, wing_t + 0.1, ex/2])
            rotate([90, 0, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    // X-wing: back face flush with block's -X face (local X=0 = extrusion inner face).
    // Wing protrudes INTO the frame interior toward +X.
    // Bolt goes in -X direction from inside the frame through the wing into the T-slot.
    module _wing_x() {
        translate([0, pb_block_xy, 0])
            cube([wing_t, wing_extend, ex]);
    }

    module _wing_x_hole() {
        translate([wing_t + 0.1, pb_block_xy + wing_extend/2, ex/2])
            rotate([0, -90, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    // -----------------------------------------------------------------------
    // "xx" wings — for rear center block
    // Both press against the rear X cross-member inner face (block +Y face).
    // -----------------------------------------------------------------------

    // Left wing: back face flush with block's +Y face (local Y=pb_block_xy = rear extrusion inner face).
    // Wing protrudes into the frame interior toward -Y (lower Y values).
    // Bolt goes in +Y direction from inside the frame through the wing into the T-slot.
    module _wing_left() {
        translate([-wing_extend, pb_block_xy - wing_t, 0])
            cube([wing_extend, wing_t, ex]);
    }

    module _wing_left_hole() {
        translate([-wing_extend/2, pb_block_xy - wing_t - 0.1, ex/2])
            rotate([-90, 0, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    // Right wing: same but on the +X side.
    module _wing_right() {
        translate([pb_block_xy, pb_block_xy - wing_t, 0])
            cube([wing_extend, wing_t, ex]);
    }

    module _wing_right_hole() {
        translate([pb_block_xy + wing_extend/2, pb_block_xy - wing_t - 0.1, ex/2])
            rotate([-90, 0, 0])
                cylinder(d = m5_through_dia, h = wing_t + 0.2);
    }

    // -----------------------------------------------------------------------
    // Assembly
    // -----------------------------------------------------------------------
    difference() {
        union() {
            _body();
            if (bolts == "xy") {
                _wing_y();
                _wing_x();
            } else {
                _wing_left();
                _wing_right();
            }
        }
        _pocket();
        if (bolts == "xy") {
            _wing_y_hole();
            _wing_x_hole();
        } else {
            _wing_left_hole();
            _wing_right_hole();
        }
    }
}

// ---------------------------------------------------------------------------
// Preview
// ---------------------------------------------------------------------------
z_pillow_block(bolts = "xy");
