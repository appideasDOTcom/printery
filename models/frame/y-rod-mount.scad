/**
 * y-rod-mount.scad
 *
 * Y-axis carriage rod end-capture block.
 * Plain 20 x 20 x 50 mm rectangle with an 8 mm slip-fit bore running
 * along the 20 mm Y-depth dimension.  No other features.
 *
 * Bore centre: X = 10, Z = 25 (block midpoints in both axes).
 *
 * Place one block at each of the four UTF inner corners so the rod
 * sits entirely inside the frame.  See upper-top-frame.scad for the
 * exact translate() positions.
 */

include <shared-dims.scad>

_yrm_w        = 20.0;
_yrm_d        = 20.0;
_yrm_h        = 50.0;
_yrm_bore_dia = carriage_rod_dia + 0.2;   // 8.2 mm slip fit

module y_rod_mount() {
    difference() {
        cube([_yrm_w, _yrm_d, _yrm_h]);
        // Rod bore: enters from Y=0 face, bottoms out 2mm from far face
        translate([_yrm_w / 2, -0.1, _yrm_h / 2])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_bore_dia, h = _yrm_d - 2 + 0.1);
        // Air-escape hole: 5mm, full depth
        translate([_yrm_w / 2, -0.1, _yrm_h / 2])
            rotate([-90, 0, 0])
                cylinder(d = 5.0, h = _yrm_d + 0.2);
    }
}

// Preview
y_rod_mount();
