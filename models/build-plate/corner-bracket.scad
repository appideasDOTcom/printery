include <../common/shared-dims.scad>
include <../common/shapes.scad>

$fn = 64;

// Overall plate dimensions
corner_radius   = 2;    // mm — rounded corner radius
plate_width     = 40;   // mm — X
plate_depth     = 40;   // mm — Y
plate_height    = 12.2;  // mm — Z

buried_m3_nut_depth = m3_nut_depth + 0.4;

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

// Crossbar dimensions (must match front-crossbar.scad)
_cb_bar_width  = 12.0;   // bar body depth (Y in crossbar local)
_cb_bar_height =  6.0;   // bar body height (Z)
_cb_tol        =  0.1;   // fit tolerance

// Front crossbar starts at world x=72.5; bracket origin at world x=52.5 → local x=20
_fcb_local_x_start = 20.0;

module front_left_bed_bracket() {
    difference() {
        corner_bracket();
        // Front crossbar slot: local y=0..12, z=0..4, starting at local x=20
        translate([_fcb_local_x_start, 0, -_cb_tol])
            cube([plate_width - _fcb_local_x_start + 1, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // Left crossbar slot: local x=0..12, z=0..4, spanning local y=20..40
        translate([-_cb_tol, 20, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - 20 + 1, _cb_bar_height + _cb_tol]);
        // M3 through-holes into front crossbar overlap (local x=20..40, y=0..12)
        translate([24, 4, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([34, 8, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 through-holes into left crossbar overlap (local x=0..12, y=20..40)
        translate([4, 34, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([8, 24, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 nut traps at top face
        translate([24, 4, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([34, 8, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([4, 34, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([8, 24, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
    }
}

module _front_right_cut_bracket() {
    difference() {
        corner_bracket();
        // Front crossbar slot: local x=0..12, y=20..40
        translate([-_cb_tol, 20, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - 20 + 1, _cb_bar_height + _cb_tol]);
        // Right crossbar slot (15mm inset): local x=20..40, y=15..27
        translate([20, 15, -_cb_tol])
            cube([plate_width - 20 + 1, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // M3 through-holes into front crossbar overlap (local x=0..12, y=20..40)
        translate([4, 34, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([8, 24, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 through-holes into right crossbar overlap (local x=20..40, y=15..27)
        translate([24, 19, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([34, 23, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 nut traps at top face
        translate([4,  34, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([8,  24, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([24, 19, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([34, 23, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
    }
}

module front_right_bed_bracket() {
    rotate([0, 0, 90]) _front_right_cut_bracket();
}

module _rear_left_cut_bracket() {
    difference() {
        corner_bracket();
        // Rear crossbar slot: local x=0..12, y=20..40 (bar starts at world x=72.5 → local_y=20)
        translate([-_cb_tol, 20, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - 20 + 1, _cb_bar_height + _cb_tol]);
        // Left crossbar slot: local x=20..40, y=0..12
        translate([20, -_cb_tol, -_cb_tol])
            cube([plate_width - 20 + 1, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // M3 through-holes into rear crossbar overlap (local x=0..12, y=20..40)
        translate([4, 34, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([8, 24, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 through-holes into left crossbar overlap (local x=20..40, y=0..12)
        translate([24, 4, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([34, 8, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 nut traps at top face
        translate([4,  34, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([8,  24, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([24,  4, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([34,  8, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
    }
}

module rear_left_bed_bracket() {
    rotate([0, 0, 270]) _rear_left_cut_bracket();
}

module _rear_right_cut_bracket() {
    difference() {
        corner_bracket(include_cutout = true);
        // Rear crossbar slot: local x=20..40, y=0..12
        translate([20, -_cb_tol, -_cb_tol])
            cube([plate_width - 20 + 1, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // Right crossbar slot (15mm inset): local x=15..27, y=20..40
        translate([15, 20, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - 20 + 1, _cb_bar_height + _cb_tol]);
        // M3 through-holes into rear crossbar overlap (local x=20..40, y=0..12)
        translate([24, 4, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([34, 8, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 through-holes into right crossbar overlap (local x=15..27, y=20..40)
        translate([19, 34, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        translate([23, 24, -1]) cylinder(d = m3_through_dia, h = plate_height + 2);
        // M3 nut traps at top face
        translate([24,  4, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([34,  8, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([19, 34, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
        translate([23, 24, plate_height - buried_m3_nut_depth]) cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + 1, $fn = 6);
    }
}

module rear_right_bed_bracket() {
    rotate([0, 0, 180]) _rear_right_cut_bracket();
}

// corner_bracket();
// front_left_bed_bracket(); // A. front-left
front_right_bed_bracket(); // B. front-right
