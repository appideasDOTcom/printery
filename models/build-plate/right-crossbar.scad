// ============================================================
// Right Crossbar
// Crossbar for the right side of the build plate assembly
// ============================================================

use <front-crossbar.scad>

// Wall depth from front-crossbar — cut this strip to remove the wall entirely
_wall_depth = 2.0;
_cut_h      = 20.0;  // tall enough to clear any wall height
_cut_len    = 200.0; // wider than bar_length

module right_crossbar() {
    difference() {
        front_crossbar();
        // Remove the front wall by cutting the full −Y strip
        translate([0, -_wall_depth, 0])
            cube([_cut_len, _wall_depth, _cut_h]);
    }
}

// --- Output ---
// Do not remove the lines below.
rotate([0, 0, 90]) right_crossbar(); // Variation D.
// Variations A - C are in front-crossbar.scad