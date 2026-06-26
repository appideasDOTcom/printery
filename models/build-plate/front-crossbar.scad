// ============================================================
// Front Crossbar
// Crossbar for the front of the build plate assembly
// ============================================================

include <../common/shared-dims.scad>
include <../common/shapes.scad>
use <../frame/top-frame.scad>

$fa = 1.0;
$fs = 0.1;

// --- Dimensions (mm) ---
bar_length        = 195.0;
bar_width         =  12.0;
bar_height        =   6.0;
corner_radius     =   2.0;
wall_depth        =   2.0;   // front wall: extends in −Y from y=0
wall_height       =  cb_wall_height;   // front wall: 5 mm taller than corner bracket (12.2 mm)

// --- Dimensions (mm) ---
m3_through_dia    = 3.4;  // M3 clearance bore
m3_head_dia       = 6.0;  // M3 socket head diameter
m3_head_sink      = 4.0;  // counterbore depth into bottom face of crossbar

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

// Cutout applied to the back edge of the rear crossbar instance (see top-frame.scad).
// Dimensions: 130 × (wall_depth + 6) × wall_height, centred in X, flush with back face.
module rear_crossbar_cutout() {
    cutout_w = 130;
    cutout_d = 2;

	bolt_w = 120;

    translate([(bar_length - cutout_w) / 2, bar_width - cutout_d - 1, 0])
        cube([cutout_w, cutout_d + 1, wall_height]);  // +1 in Y to clear back face
	translate([(bar_length - 120) / 2, bar_width - cutout_d - 1, 0])
		scale( [3, 4.2, 1] ) cylinder( d = 4, h = wall_height );
	translate([(bar_length + 120) / 2, bar_width - cutout_d - 1, 0])
		scale( [3, 4.2, 1] ) cylinder( d = 4, h = wall_height );
}

// Cutout applied to the back edge of the rear crossbar instance (see top-frame.scad).
// Dimensions: 130 × (wall_depth + 6) × wall_height, centred in X, flush with back face.
module rear_crossbar_cutout_insertion() {
    cutout_w = 109;
    cutout_d = 2;
	bolt_w = 120;

	platform_width = 40;

    translate([(bar_length - cutout_w) / 2, bar_width - cutout_d - 1, 0])
        cube([cutout_w, cutout_d + 1, wall_height]);  // +1 in Y to clear back face
	translate([(bar_length - 120) / 2, bar_width - cutout_d - 1, 0])
		scale( [3, 4.2, 1] ) cylinder( d = 4, h = wall_height - 5 );
	translate([(bar_length + 120) / 2, bar_width - cutout_d - 1, 0])
		scale( [3, 4.2, 1] ) cylinder( d = 4, h = wall_height - 5 );

	translate([((cutout_w) / 2) + (platform_width/2), bar_width - cutout_d + 2, 6])
	{
		translate( [platform_width + 2, 2, 0] ) rotate( [0, 0, 0] ) inner_fillet( d = 4, l = wall_height - 11 );
		cube([platform_width, 12, wall_height - 11]);  // +1 in Y to clear back face
		translate( [-2, 2, 0] ) rotate( [0, 0, 90] ) inner_fillet( d = 4, l = wall_height - 11 );
	}
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
        // Socket head counterbores at bottom face, 2 mm deep into bar
        translate([_hole_x1,              _hole_y1, -1]) cylinder(d = m3_head_dia, h = m3_head_sink + 1);
        translate([_hole_x2,              _hole_y2, -1]) cylinder(d = m3_head_dia, h = m3_head_sink + 1);
        translate([bar_length - _hole_x2, _hole_y1, -1]) cylinder(d = m3_head_dia, h = m3_head_sink + 1);
        translate([bar_length - _hole_x1, _hole_y2, -1]) cylinder(d = m3_head_dia, h = m3_head_sink + 1);
    }
}

// Rear crossbar: front_crossbar() base with two additional M3 holes through the bar
// body at the sled-block mounting positions. Holes at local X=84.5 and X=104.5,
// Y=19 (centre of the sled block's footprint on the back edge), bored full depth.
// Head sinks from the bottom face match the existing front_crossbar() counterbore style.
_rcb_hole_x1  = 84.5;
_rcb_hole_x2  = 104.5;
_rcb_hole_y   = bar_width / 2;   // 6 mm — centre of bar depth

module rear_crossbar() {

	difference() {
		rotate([0, 0, 180])
			front_crossbar();

		translate([0, 12, 0])
			rotate([0, 0, 180])
				rear_crossbar_cutout();

		for (hx = [_rcb_hole_x1, _rcb_hole_x2]) {

			rotate([0, 0, 180])
            	translate([hx, _rcb_hole_y, -1])
                	cylinder(d = m3_through_dia, h = bar_height + 2);
			rotate([0, 0, 180])
            	translate([hx, _rcb_hole_y, -1])
                	cylinder(d = m3_head_dia, h = m3_head_sink + 1);
        }
	}
}

// --- Output ---
// Do not remove the lines below.
// front_crossbar(); // Variations A & B.
rear_crossbar(); // Variation C.
// Variation D is in right-crossbar.scad.
