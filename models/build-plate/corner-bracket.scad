include <../common/shared-dims.scad>
include <../common/shapes.scad>

$fn = 64;

// Overall plate dimensions
corner_radius   = 2;    // mm — rounded corner radius
plate_width     = 40;   // mm — X
plate_depth     = 40;   // mm — Y
plate_height    = 8;    // mm — Z

// Rounded rectangle helper
module rounded_rect(w, d, h, r) {
    hull() {
        for (x = [r, w - r])
            for (y = [r, d - r])
                translate([x, y, 0])
                    cylinder(r = r, h = h);
    }
}

// L-shape: union of two rounded rectangles
module base_plate(plate_width, plate_depth, plate_height, corner_radius) {
    union() {
        // Bottom portion: full width, Y 0–30
        rounded_rect(plate_width, 30, plate_height, corner_radius);
        // Right portion: X 15–40, full height Y 0–40
        translate([15, 0, 0])
            rounded_rect(plate_width - 15, plate_depth, plate_height, corner_radius);
    }
}

module corner_bracket(include_cutout = false) {
    if (include_cutout) {
        union() {
            difference() {
                base_plate(plate_width, plate_depth, plate_height, corner_radius);
                translate([32, 32, -1])
                    cylinder(d = m5_through_dia, h = plate_height + 2);
                translate([32, 32, 0])
                    cylinder(d = m5_nut_corner_dia, h = m5_nut_depth, $fn = 6);
            }
            // Concave fillet at the inner right-angle corner (X=15, Y=30)
            translate([15 - corner_radius, 30 + corner_radius, 0])
                rotate([0, 0, 90])
                    inner_fillet(d = 4, l = plate_height);
        }
    } else {
        difference() {
            rounded_rect(plate_width, plate_depth, plate_height, corner_radius);
            translate([32, 32, -1])
                cylinder(d = m5_through_dia, h = plate_height + 2);
            translate([32, 32, 0])
                cylinder(d = m5_nut_corner_dia, h = m5_nut_depth, $fn = 6);
        }
    }
}

module front_left_bed_bracket() {
	corner_bracket();
}

module front_right_bed_bracket() {
	rotate([0, 0, 90])
            corner_bracket();
}

module rear_left_bed_bracket() {
	rotate([0, 0, 270])
            corner_bracket();
}

module rear_right_bed_bracket() {
	rotate([0, 0, 180])
            corner_bracket(include_cutout = true);
}

corner_bracket();
