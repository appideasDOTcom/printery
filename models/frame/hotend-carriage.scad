/**
 * hotend-carriage.scad
 *
 * Hotend carriage / toolhead sled. Rides on both X gantry rods via RJ4JP
 * dry-polymer bearings (LM8UU footprint — NO lubrication).
 *
 * Front-top retainer: relief opens toward rear (+Y).
 * Rear-bottom retainer: identical body, relief opens toward front (−Y).
 *
 * Assembly placement: both retainers centred in X on the frame midpoint.
 */

include <shared-dims.scad>

// ---------------------------------------------------------------------------
// Front-top X rod retainer geometry
// ---------------------------------------------------------------------------
// Two bearings side-by-side along the rod (X axis).
// rj_base_y = 29 mm → one-bearing module length (named "y" from the sled's POV;
//   here it runs along X).
// Bearing pitch = rj_base_y; total two-bearing span = 2 * rj_base_y = 58 mm.
// Add 1 mm end margin each side → body_x = 60 mm.
ft_bearing_count  = 2;
ft_body_x         = ft_bearing_count * rj_base_y + 2;   // 60 mm — retainer X span
ft_body_y         = rj_bearing_od + rj_shell * 2;        // 23 mm — retainer Y depth (= sled_w)
ft_body_z         = rj_bearing_od + rj_shell * 2;        // 23 mm — retainer Z height

// Bore along X through body centre (Y and Z)
ft_bore_cy        = ft_body_y / 2;   // 11.5 mm
ft_bore_cz        = ft_body_z / 2;   // 11.5 mm

// Relief slot: opens through rear (+Y) face, rod dia tall, stops relief_above_axis
// mm short of bore centre (same geometry as yrod_relief in x-rod-sled.scad).
ft_relief_h       = carriage_rod_dia;   // 8 mm — slot height, rod passes; bearing stays trapped
ft_relief_above   = 5.0;               // slot inner face this far from bore centre (toward rear)

// ---------------------------------------------------------------------------
// Assembly placement on the front-top X rod (global frame coordinates)
// ---------------------------------------------------------------------------
// Rod centre: X = frame centre, Y = x_rod_front_y, Z = x_rod_front_z
// Body is centred in X on the rod's mid-span, front face of body at rod Y - ft_bore_cy.
_frame_cx         = bf_outer_x / 2;                     // 170 mm — frame X centre
_place_x          = _frame_cx - ft_body_x / 2;          // body left face X
_place_y          = x_rod_front_y - ft_bore_cy;         // body front face Y
_place_z          = x_rod_front_z - ft_bore_cz;         // body bottom face Z

// ---------------------------------------------------------------------------
// Bearing pocket module (one bearing, pocket axis along X)
// ---------------------------------------------------------------------------
module ft_rj4jp_pocket_piece() {
    // Thin bore — forms trap-ring faces
    rotate([0, 90, 0])
        cylinder(d = rj_bearing_od - rj_trap_ring_depth * 2, h = rj_base_y + 2);
    // Central clamp groove
    translate([rj_base_y / 2 - rj_trap_ring_spacing / 2 + 1, 0, 0])
        rotate([0, 90, 0])
            cylinder(d = rj_bearing_od, h = rj_trap_ring_spacing);
    // Entry relief (−X end) — starts 0.1 mm before pocket origin to guarantee open face
    translate([-0.1, 0, 0])
        rotate([0, 90, 0])
            cylinder(d = rj_bearing_od, h = rj_cutout_to_end + 0.1);
    // Exit relief (+X end) — extends 0.1 mm past pocket end to guarantee open face
    translate([rj_base_y - rj_cutout_to_end + 2, 0, 0])
        rotate([0, 90, 0])
            cylinder(d = rj_bearing_od, h = rj_cutout_to_end + 0.1);
}

// Two pockets along X, zero start margin so entry reliefs breach the −X face.
module ft_bearing_pocket() {
    for (off = [0, rj_base_y])
        translate([off, ft_bore_cy, ft_bore_cz])
            ft_rj4jp_pocket_piece();
}

// Relief slot through rear (+Y) face. Rod slides in from behind.
module ft_relief() {
    translate([-0.1, ft_bore_cy + ft_relief_above, ft_bore_cz - ft_relief_h / 2])
        cube([ft_body_x + 0.2, ft_body_y - ft_bore_cy - ft_relief_above + 0.1, ft_relief_h]);
}

// Relief slot through front (−Y) face. Rod slides in from the front.
module rr_relief() {
    translate([-0.1, -0.1, ft_bore_cz - ft_relief_h / 2])
        cube([ft_body_x + 0.2, ft_bore_cy - ft_relief_above + 0.1, ft_relief_h]);
}

// ---------------------------------------------------------------------------
// Retainer bodies — identical geometry, different relief direction
// ---------------------------------------------------------------------------
module front_top_retainer() {
    difference() {
        cube([ft_body_x, ft_body_y, ft_body_z]);
        ft_bearing_pocket();
        ft_relief();
    }
}

module rear_bottom_retainer() {
    difference() {
        cube([ft_body_x, ft_body_y, ft_body_z]);
        ft_bearing_pocket();
        rr_relief();
    }
}

// ---------------------------------------------------------------------------
// Rod-to-rod offsets (global, used to place rear retainer relative to front)
// ---------------------------------------------------------------------------
_rod_dy = x_rod_rear_y - x_rod_front_y;   // 45.7 mm — rear rod further in Y
_rod_dz = x_rod_rear_z - x_rod_front_z;   // −35.7 mm — rear rod lower in Z

// ---------------------------------------------------------------------------
// Assembly module — placed on the front-top X rod in global frame coordinates
// ---------------------------------------------------------------------------
module hotend_carriage() {
    // Front-top retainer
    translate([_place_x, _place_y, _place_z])
        front_top_retainer();
    // Rear-bottom retainer — same X, offset by rod spacing in Y and Z, rotated 180° around X to open rear
    translate([_place_x, _place_y + _rod_dy + ft_body_y, _place_z + _rod_dz + ft_body_z])
        rotate([180, 0, 0])
            rear_bottom_retainer();
}

// ---------------------------------------------------------------------------
// Preview — render at origin for easy inspection.
// ---------------------------------------------------------------------------
front_top_retainer();
translate([0, _rod_dy + ft_body_y, _rod_dz + ft_body_z])
    rotate([180, 0, 0])
        rear_bottom_retainer();
