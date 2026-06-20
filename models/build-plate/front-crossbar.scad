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

// --- Dimensions (mm) ---
m3_through_dia = 3.4;  // M3 clearance bore

// Crossbar end hole offsets — two holes per end, offset ±2 mm from bar centre (y=6)
// Left end: x=4 and x=14 from local x=0
// Right end: mirrored → x=bar_length−4 and x=bar_length−14
_hole_y1   = bar_width / 2 - 2;  // 4 — closer to front face
_hole_y2   = bar_width / 2 + 2;  // 8 — closer to back edge
_hole_x1   = 4;
_hole_x2   = 14;

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
    difference() {
        union() {
            rounded_bar();
            front_wall();
        }
        // M3 through-holes at left end: x1 closer to front face, x2 closer to back edge
        translate([_hole_x1, _hole_y1, -1]) cylinder(d = m3_through_dia, h = bar_height + 2);
        translate([_hole_x2, _hole_y2, -1]) cylinder(d = m3_through_dia, h = bar_height + 2);
        // M3 through-holes at right end, mirrored in x
        translate([bar_length - _hole_x2, _hole_y1, -1]) cylinder(d = m3_through_dia, h = bar_height + 2);
        translate([bar_length - _hole_x1, _hole_y2, -1]) cylinder(d = m3_through_dia, h = bar_height + 2);
    }
}

// --- Output ---
front_crossbar();
