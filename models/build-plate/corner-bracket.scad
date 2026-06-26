include <../common/shared-dims.scad>
include <../common/shapes.scad>

$fn = 64;

// Overall plate dimensions (plate_width/depth/height come from shared-dims.scad)
corner_radius   = 2;    // mm — rounded corner radius (local per-part rounding)

buried_m3_nut_depth = m3_nut_depth + 0.4;
buried_m5_nut_depth = m5_nut_depth + 5.0; // The surface is approximagtely 7.4mm.

// ---------------------------------------------------------------------------
// Derived / shared design constants (single source of truth for all variants)
// ---------------------------------------------------------------------------

// Crossbar engagement — crossbars meet at the bracket midpoint; the right
// crossbar is inset, and slots are cut slightly long so the bar bottoms out.
cb_slot_start   = plate_width / 2;   // 20 mm — slot start = bracket midpoint
cb_right_inset  = 15.0;              // mm — right crossbar sits inboard (matches right-crossbar.scad)
cb_slot_overrun = 1.0;               // mm — extra slot length for a clean seat

// M3 bolt-bore / nut-trap cut parameters (apply to every through-hole + trap)
_thru_z0      = -1.0;                // bore start, just below the bottom face
_thru_h       = plate_height + 2;    // bore length — fully through the plate
_nuttrap_over = 1.0;                 // nut-trap cut overrun above the pocket floor

// Bed-mount M5 bolt — fixed inset from the outer corner
m5_bolt_inset = 8.0;                 // mm in from the outer corner
m5_bolt_x     = plate_width - m5_bolt_inset;   // 32 mm
m5_bolt_y     = plate_depth - m5_bolt_inset;   // 32 mm

// Base-plate L-notch (inner step of the L profile)
l_notch_x = 15.0;   // X of the inner step
l_notch_y = 30.0;   // Y of the inner step

// Z-carriage connector features (front brackets only)
zc_conn_dia = 3.0;    // tight 3 mm connector through-hole (intentionally < m3 clearance)
zc_conn_len = 12.0;   // connector through-hole length
zc_conn_z   = 6.0;    // Z plane of the connector features

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
        // Bottom portion: full width, Y 0–l_notch_y
        rounded_rect(plate_width, l_notch_y, plate_height, corner_radius);
        // Right portion: X l_notch_x–plate_width, full height Y 0–plate_depth
        translate([l_notch_x, 0, 0])
            rounded_rect(plate_width - l_notch_x, plate_depth, plate_height, corner_radius);
    }
}

module corner_bracket(include_cutout = false) {
    if (include_cutout) {
        union() {
            difference() {
                base_plate(plate_width, plate_depth, plate_height, corner_radius);
                translate([m5_bolt_x, m5_bolt_y,_thru_z0])
                    cylinder(d = m5_through_dia, h = _thru_h);
                translate([m5_bolt_x, m5_bolt_y,0])
                    cylinder(d = m5_nut_corner_dia, h = buried_m5_nut_depth, $fn = 6);
            }
            // Concave fillet at the inner right-angle corner (X=l_notch_x, Y=l_notch_y)
            translate([l_notch_x - corner_radius, l_notch_y + corner_radius, 0])
                rotate([0, 0, 90])
                    inner_fillet(d = 4, l = plate_height);
        }
    } else {
        difference() {
            rounded_rect(plate_width, plate_depth, plate_height, corner_radius);
            translate([m5_bolt_x, m5_bolt_y,_thru_z0])
                cylinder(d = m5_through_dia, h = _thru_h);
            translate([m5_bolt_x, m5_bolt_y,0])
                cylinder(d = m5_nut_corner_dia, h = buried_m5_nut_depth, $fn = 6);
        }
    }
}

// Crossbar dimensions (must match front-crossbar.scad)
_cb_bar_width  = 12.0;   // bar body depth (Y in crossbar local)
_cb_bar_height =  6.0;   // bar body height (Z)
_cb_tol        =  0.1;   // fit tolerance

// M3 crossbar fastener grid — two staggered bolts per crossbar overlap.
// "along"  = distance from the slot-start (inner joint) end of the overlap.
// "across" = distance from a long edge of the bar, measured from the overlap's base.
// Coordinates derive from cb_slot_start / cb_right_inset so they track plate size.
m3_along_near = 4.0;                          // first bolt, from the inner-joint end
m3_along_far  = 14.0;                         // second bolt, from the inner-joint end
m3_edge_near  = 4.0;                          // bolt inset from the near long edge
m3_edge_far   = _cb_bar_width - m3_edge_near; // 8.0 mm — symmetric inset from the far edge

// Cut one M3 fastener: clearance bore fully through the plate plus a hex nut
// trap recessed into the top face. Through-hole and trap always share X/Y, so
// both live here and each fastener position is written exactly once.
module m3_fastener(x, y) {
    translate([x, y, _thru_z0])
        cylinder(d = m3_through_dia, h = _thru_h);
    translate([x, y, plate_height - buried_m3_nut_depth])
        cylinder(d = m3_nut_corner_dia, h = buried_m3_nut_depth + _nuttrap_over, $fn = 6);
}

// Front crossbar starts at world x=72.5; bracket origin at world x=52.5 → local x=cb_slot_start
_fcb_local_x_start = cb_slot_start;

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
            cube([plate_width - _fcb_local_x_start + cb_slot_overrun, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // Left crossbar slot: local x=0..12, z=0..4, spanning local y=20..40
        translate([-_cb_tol, cb_slot_start, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - cb_slot_start + cb_slot_overrun, _cb_bar_height + _cb_tol]);
        // // M3 blind holes in -Y face for z_carriage_left() screws
        // translate([1, 0, 8.6])  rotate([-90, 0, 0]) cylinder(d = m3_through_dia, h = 12);
        // translate([9, 0, 8.6])  rotate([-90, 0, 0]) cylinder(d = m3_through_dia, h = 12);
        // M3 fasteners — front crossbar overlap (X-bar, base y=0)
        m3_fastener(cb_slot_start + m3_along_near, m3_edge_near);
        m3_fastener(cb_slot_start + m3_along_far,  m3_edge_far);
        // M3 fasteners — left crossbar overlap (Y-bar, base x=0)
        m3_fastener(m3_edge_near, cb_slot_start + m3_along_far);
        m3_fastener(m3_edge_far,  cb_slot_start + m3_along_near);

		// Z-carriage connector throughholes.
		translate([11, 13, zc_conn_z]) rotate([-90,0,90]) cylinder(d=zc_conn_dia, h=zc_conn_len);
		translate([10, 0, zc_conn_z]) rotate([-90,0,0]) cylinder(d=zc_conn_dia, h=zc_conn_len);

		translate([4.6, 13, zc_conn_z]) {
			rotate( [0, 0, 90] ) m3_slot();
		}
		translate([10, 3, zc_conn_z]) {
			m3_slot();
		}
    }





}

module m3_slot() {

	hull() {
		rotate([-90,90,0]) cylinder(d=6.8, h=2.8, $fn=6);
		translate([0, 0, -15]) rotate([-90,90,0]) cylinder(d=6.3, h=2.6, $fn=6);
	}

}

module _front_right_cut_bracket() {
    difference() {
        corner_bracket();
        // Front crossbar slot: local x=0..12, y=20..40
        translate([-_cb_tol, cb_slot_start, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - cb_slot_start + cb_slot_overrun, _cb_bar_height + _cb_tol]);
        // Right crossbar slot (15mm inset): local x=20..40, y=15..27
        translate([cb_slot_start, cb_right_inset, -_cb_tol])
            cube([plate_width - cb_slot_start + cb_slot_overrun, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // M3 fasteners — front crossbar overlap (Y-bar, base x=0)
        m3_fastener(m3_edge_near, cb_slot_start + m3_along_far);
        m3_fastener(m3_edge_far,  cb_slot_start + m3_along_near);
        // M3 fasteners — right crossbar overlap (X-bar, base y=cb_right_inset)
        m3_fastener(cb_slot_start + m3_along_near, cb_right_inset + m3_edge_near);
        m3_fastener(cb_slot_start + m3_along_far,  cb_right_inset + m3_edge_far);

		// Z-carriage connector throughholes.
		translate([11, 10, zc_conn_z]) rotate([-90,0,90]) cylinder(d=zc_conn_dia, h=zc_conn_len);
		translate([13, 0, zc_conn_z]) rotate([-90,0,0]) cylinder(d=zc_conn_dia, h=zc_conn_len);

		translate([4.6, 10, zc_conn_z]) {
			rotate( [0, 0, 90] ) m3_slot();
		}

		translate([13, 3, zc_conn_z]) {
			m3_slot();
		}
    }
}

module front_right_bed_bracket() {
    rotate([0, 0, 90]) _front_right_cut_bracket();
}

module _rear_left_cut_bracket() {
    difference() {
        corner_bracket();
        // Rear crossbar slot: local x=0..12, y=20..40 (bar starts at world x=72.5 → local_y=20)
        translate([-_cb_tol, cb_slot_start, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - cb_slot_start + cb_slot_overrun, _cb_bar_height + _cb_tol]);
        // Left crossbar slot: local x=20..40, y=0..12
        translate([cb_slot_start, -_cb_tol, -_cb_tol])
            cube([plate_width - cb_slot_start + cb_slot_overrun, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // M3 fasteners — rear crossbar overlap (Y-bar, base x=0)
        m3_fastener(m3_edge_near, cb_slot_start + m3_along_far);
        m3_fastener(m3_edge_far,  cb_slot_start + m3_along_near);
        // M3 fasteners — left crossbar overlap (X-bar, base y=0)
        m3_fastener(cb_slot_start + m3_along_near, m3_edge_near);
        m3_fastener(cb_slot_start + m3_along_far,  m3_edge_far);
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
        translate([cb_slot_start, -_cb_tol, -_cb_tol])
            cube([plate_width - cb_slot_start + cb_slot_overrun, _cb_bar_width + _cb_tol, _cb_bar_height + _cb_tol]);
        // Right crossbar slot (15mm inset): local x=15..27, y=20..40
        translate([cb_right_inset, cb_slot_start, -_cb_tol])
            cube([_cb_bar_width + _cb_tol, plate_depth - cb_slot_start + cb_slot_overrun, _cb_bar_height + _cb_tol]);
        // M3 fasteners — rear crossbar overlap (X-bar, base y=0)
        m3_fastener(cb_slot_start + m3_along_near, m3_edge_near);
        m3_fastener(cb_slot_start + m3_along_far,  m3_edge_far);
        // M3 fasteners — right crossbar overlap (Y-bar, base x=cb_right_inset)
        m3_fastener(cb_right_inset + m3_edge_near, cb_slot_start + m3_along_far);
        m3_fastener(cb_right_inset + m3_edge_far,  cb_slot_start + m3_along_near);
        // Cable tie passthrough
        _rr_cable_tie_bore();
    }
}

module rear_right_bed_bracket() {
    rotate([0, 0, 180]) _rear_right_cut_bracket();
}

// Do not remove the lines below.
front_left_bed_bracket(); // Variation A
// front_right_bed_bracket(); // Variation B.
// rear_left_bed_bracket(); // Variation C.
// rear_right_bed_bracket(); // Variation D.

