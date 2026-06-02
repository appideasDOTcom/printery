/**
 * rod-end-capture.scad
 *
 * Rod end capture block for 8 mm linear rod.
 * Clamps the end of a Y-axis or X-axis carriage rod to the inside face of a
 * 2020 top-frame extrusion. The rod passes through a close-tolerance bore and
 * is locked by an M3 pinch screw on the side.
 *
 * Mounts to the extrusion T-slot via two M5 T-nut bolts on the back face.
 *
 * The rod bore is oriented along the module's local Y axis.
 * Rotate 90° around Z to mount on a cross-member.
 *
 * All dimensions come from shared-dims.scad.
 *
 * Usage:
 *   include <shared-dims.scad>
 *   use <rod-end-capture.scad>
 *   rod_end_capture();
 */

include <shared-dims.scad>

// ---------------------------------------------------------------------------
// Local dimensions
// ---------------------------------------------------------------------------
rod_dia          = carriage_rod_dia;  // 8 mm
rod_bore_dia     = rod_dia + 0.2;     // slip fit
rod_bore_depth   = 15.0;             // how deep the rod sits in the block

wall             = 5.0;
block_w          = rod_dia + wall * 2;   // 18 mm wide
block_d          = rod_bore_depth + wall; // 20 mm deep
block_h          = ex;                   // 20 mm tall — flush with extrusion face
block_r          = 2.0;                  // corner fillet

// M3 pinch screw — passes through the side wall, compresses on the rod
m3_dia           = 3.3;
m3_head_dia      = 5.5;
m3_head_depth    = 3.0;

// M5 T-nut mounting bolts on the back face (into the extrusion)
// Spaced so both are inside a 300 mm or 405 mm extrusion and clear elbow connectors
tnut_spacing     = block_w;   // two bolts, one each side of center, spread = block_w
tnut_y_inset     = m5_head_depth + 2.0;  // from back face

module rod_end_capture() {
    block_cx = block_w / 2;
    block_cy = block_d / 2;

    module _body() {
        minkowski() {
            cube([block_w - 2*block_r,
                  block_d - 2*block_r,
                  block_h - block_r]);
            translate([block_r, block_r, 0])
                cylinder(r = block_r, h = block_r);
        }
    }

    module _rod_bore() {
        // Rod bore along Y, entering from front face (y=0), going back rod_bore_depth
        translate([block_cx, -0.1, block_h / 2])
            rotate([-90, 0, 0])
                cylinder(d = rod_bore_dia, h = rod_bore_depth + 0.1);
    }

    module _pinch_slot() {
        // Thin slot from top surface down to rod center — allows slight compression
        translate([block_cx - 0.4, -0.1, block_h / 2])
            cube([0.8, rod_bore_depth + 0.1, block_h / 2 + 0.1]);
    }

    module _pinch_screw() {
        // M3 screw entering from the right side (+X), threading into the left side
        translate([block_w + 0.1, rod_bore_depth / 2, block_h / 2])
            rotate([0, -90, 0]) {
                cylinder(d = m3_dia, h = block_w + 0.2);
                // Head recess on right face
                translate([0, 0, block_w - m3_head_depth + 0.2])
                    cylinder(d = m3_head_dia, h = m3_head_depth + 0.1);
            }
    }

    module _tnut_bolts() {
        // Two M5 bolts on back face (+Y), entering toward the extrusion T-slot
        for (bx = [block_cx - tnut_spacing/2, block_cx + tnut_spacing/2])
            translate([bx, block_d + 0.1, block_h / 2])
                rotate([90, 0, 0]) {
                    cylinder(d = m5_through_dia, h = block_d + 0.2);
                    translate([0, 0, block_d - m5_head_depth + 0.2])
                        cylinder(d = m5_head_dia, h = m5_head_depth + 0.1);
                }
    }

    difference() {
        _body();
        _rod_bore();
        _pinch_slot();
        _pinch_screw();
        _tnut_bolts();
    }
}

// ---------------------------------------------------------------------------
// Preview (remove when using as library)
// ---------------------------------------------------------------------------
rod_end_capture();
