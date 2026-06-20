// ============================================================
// Front Crossbar
// Crossbar for the front of the build plate assembly
// ============================================================

$fa = 1.0;
$fs = 0.1;

// --- Dimensions (mm) ---
bar_length        = 195.0;
bar_width         =  12.0;
bar_height        =   4.0;
corner_radius     =   2.0;
wall_depth        =   2.0;   // front wall: extends in −Y from y=0
wall_height       =  10.0;   // front wall: 2 mm taller than corner bracket (8 mm)

// --- Modules ---

module rounded_bar() {
    hull() {
        // Front edge (y=0): square corners — thin rectangles flush to the edge
        for (x = [0, bar_length - corner_radius * 2]) {
            translate([x, 0, 0])
                cube([corner_radius * 2, corner_radius, bar_height]);
        }
        // Back edge (y=bar_width): rounded corners
        for (x = [corner_radius, bar_length - corner_radius]) {
            translate([x, bar_width - corner_radius, 0])
                cylinder(r = corner_radius, h = bar_height);
        }
    }
}

module front_wall() {
    // Flat wall on the front face: spans full length, extends −Y, rises to wall_height
    translate([0, -wall_depth, 0])
        cube([bar_length, wall_depth, wall_height]);
}

module front_crossbar() {
    union() {
        rounded_bar();
        front_wall();
    }
}

// --- Output ---
front_crossbar();
