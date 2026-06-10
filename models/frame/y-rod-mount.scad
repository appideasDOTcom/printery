/**
 * y-rod-mount.scad
 *
 * Y-axis carriage rod end-capture block. Nothing more than a solid
 * 20 x 20 x 50 mm rectangle with a rod bore: 8.3 mm to the point where the
 * rod bottoms out, plus a 5 mm air-escape hole all the way through.
 *
 * Bore centre: X = 10 (block midpoint); Z driven by y_rod_z so the rod rides
 * level with the Y-rod bearings in the sled.
 *
 * One block at each of the four UTF inner corners. See upper-top-frame.scad
 * for the placements.
 */

include <shared-dims.scad>

_yrm_w          = 20.0;
_yrm_d          = 20.0;
_yrm_h          = 50.0;
_yrm_bore_dia   = carriage_rod_dia + 0.3;   // 8.3 mm — 8 mm rod + 0.3 slip fit
_yrm_bore_depth = _yrm_d - 2;               // 18 mm — rod bottoms out 2 mm from the far face
_yrm_air_dia    = 5.0;                       // air-escape hole behind the rod
_yrm_bore_z     = y_rod_z - utf_post_bot_z;  // 36.275 mm — rod height, local to the block

module y_rod_mount() {
    difference() {
        cube([_yrm_w, _yrm_d, _yrm_h]);
        // Rod bore: enters from the Y=0 face, bottoms out 2 mm from the far face
        translate([_yrm_w / 2, -0.1, _yrm_bore_z])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_bore_dia, h = _yrm_bore_depth + 0.1);
        // Air blow-hole: 5 mm, all the way through
        translate([_yrm_w / 2, -0.1, _yrm_bore_z])
            rotate([-90, 0, 0])
                cylinder(d = _yrm_air_dia, h = _yrm_d + 0.2);
    }
}

// Preview
y_rod_mount();
