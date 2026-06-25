include <../common/shared-dims.scad>
include <../common/shapes.scad>

$fn = 64;

// Overall plate dimensions
corner_radius   = 2;    // mm — rounded corner radius
plate_width     = 40;   // mm — X
plate_depth     = 40;   // mm — Y
plate_height    = 12.2;  // mm — Z

buried_m3_nut_depth = m3_nut_depth + 0.4;
buried_m5_nut_depth = m5_nut_depth + 5.0; // The surface is approximagtely 7.4mm.

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
                    cylinder(d = m5_nut_corner_dia, h = buried_m5_nut_depth, $fn = 6);
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
                cylinder(d = m5_nut_corner_dia, h = buried_m5_nut_depth, $fn = 6);
        }
    }
}

// Crossbar dimensions (must match front-crossbar.scad)
_cb_bar_width  = 12.0;   // bar body depth (Y in crossbar local)
_cb_bar_height =  6.0;   // bar body height (Z)
_cb_tol        =  0.1;   // fit tolerance

// Front crossbar starts at world x=72.5; bracket origin at world x=52.5 → local x=20
_fcb_local_x_start = 20.0;

// Blind M3 hole in the −Y (front) face of the bracket, 12 mm deep,
// centred at bracket local x=20 (pocket X centre), z=8.6 mm (arm wall Z centre).
// Aligns with _z_carriage_bracket_wall_hole() in z-carriage-sled.scad.
_flb_wall_hole_x = plate_width / 2;      // 20 mm
_flb_wall_hole_z = cb_wall_height / 2;   // 8.6 mm — centre of arm face height
_flb_wall_hole_d = 12.0;                 // blind depth into bracket

module front_left_bed_bracket() {
    difference() {
        corner_bracket();
        // Front crossbar slot: local y=0..12, z=0..4, starting at local x=20
        translate([_fcb_local_x_start, 0, -_cb_tol])
            cube([plate_width - _fcb_local_x_start + 1, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // Left crossbar slot: local x=0..12, z=0..4, spanning local y=20..40
        translate([-_cb_tol, 20, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - 20 + 1, _cb_bar_height + _cb_tol]);
        // M3 blind hole in −Y face, centred on pocket X and arm wall Z
        translate([_flb_wall_hole_x, -0.1, _flb_wall_hole_z])
            rotate([-90, 0, 0])
                cylinder(d = m3_through_dia, h = _flb_wall_hole_d + 0.1);
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

// Cable tie passthrough channel for the rear-right corner bracket only.
// Enters the x=0 face (2/3 toward rear, 2mm from top), exits the z=0 bottom face.
// Cross-section: 3 mm wide (Y-span of cable tie) × 2 mm (thickness).
// A quarter-torus swept from a rectangular profile gives constant cross-section
// around the bend, which a cable tie can slide through cleanly.
module _rr_cable_tie_bore() {
    ct_w = 3.0;  // cable tie width  (spans Y at entry, X at exit)
    ct_h = 2.0;  // cable tie height (spans Z at entry, Y at exit)
    ct_cy = 10;  // Y centre: 2/3 of the 30 mm face toward rear (y=0)
    // Z centre of entry opening: top of opening 2 mm from top face
    ct_cz = plate_height - 2 - ct_h / 2;   // = 9.2 mm
    // Bend radius = ct_cz so the quarter-arc lands exactly on z=0
    r = ct_cz;
    // rotate_extrude(angle=90) sweeps the 2D profile around Z (0°→+X, 90°→+Y).
    // rotate([90,0,0]) tips the sweep axis from Z to -Y, making the arc run in XZ.
    // rotate([0,0,180]) flips +X→-X and +Y→-Y so arc runs -X (entry) → -Z (exit).
    // Centre of curvature ends up at the origin before translate.
    // translate([r, ct_cy, ct_cz]): entry lands at (0, ct_cy, ct_cz), exit at (r, ct_cy, 0).
    translate([r, ct_cy, ct_cz])
        rotate([90, 0, 0])
            rotate([0, 0, 180])
                rotate_extrude(angle = 90, $fn = 64)
                    translate([r, 0, 0])
                        square([ct_h, ct_w], center = true);
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
        // Cable tie passthrough
        _rr_cable_tie_bore();
    }
}

module rear_right_bed_bracket() {
    rotate([0, 0, 180]) _rear_right_cut_bracket();
}

// corner_bracket();
// front_left_bed_bracket(); // A. front-left
// front_right_bed_bracket(); // B. front-right
// rear_left_bed_bracket(); // C. rear-left
rear_right_bed_bracket(); // D. rear-right
