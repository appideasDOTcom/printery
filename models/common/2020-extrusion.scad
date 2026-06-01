/**
 * 2020 Aluminum T-Slot Extrusion Profile
 *
 * Provides a parametric 2020 T-slot aluminum extrusion shape for use
 * in assembly models and clearance calculations.
 *
 * Public modules:
 *   extrusion_2020_profile_2d()          — 2D cross-section, centered at origin;
 *                                          useful with linear_extrude for custom orientations.
 *   extrusion_2020(length, axis)         — 3D extrusion from 0 to `length` along
 *                                          "x", "y", or "z" (default "z").
 *
 * Usage from another file:
 *   use <../common/2020-extrusion.scad>
 *   extrusion_2020(length = 320, axis = "x");
 */

$fa = 1.0;
$fs = 0.1;

// --- Configurable dimensions (all values in mm) ---
extrusion_size       = 20.0;  // Overall cross-section width and height
corner_radius        = 1.5;   // Outer corner fillet radius
slot_opening_width   = 6.0;   // T-slot mouth width at the extrusion face
slot_cavity_width    = 8.2;   // T-slot internal nut groove width
slot_total_depth     = 4.3;   // Total T-slot depth from face inward
slot_lip_depth       = 1.5;   // Depth of narrow mouth before it widens
center_hole_dia      = 4.5;   // Central M4 through-hole diameter

// --- Internal derived values ---
_face         = extrusion_size / 2;
_lip_end      = _face - slot_lip_depth;
_cavity_end   = _face - slot_total_depth;
_half_opening = slot_opening_width / 2;
_half_cavity  = slot_cavity_width / 2;

// Internal: 2D profile of a single T-slot channel.
// The slot opening faces the +X direction.
module _tslot_2d() {
    polygon(points = [
        [_face + 0.1,  _half_opening],
        [_lip_end,     _half_opening],
        [_lip_end,     _half_cavity],
        [_cavity_end,  _half_cavity],
        [_cavity_end, -_half_cavity],
        [_lip_end,    -_half_cavity],
        [_lip_end,    -_half_opening],
        [_face + 0.1, -_half_opening]
    ]);
}

// 2D cross-section of a 2020 extrusion, centered at origin.
// Suitable for use with linear_extrude in custom orientations.
module extrusion_2020_profile_2d() {
    difference() {
        // Rounded outer square
        offset(r = corner_radius)
            square(
                [extrusion_size - 2 * corner_radius,
                 extrusion_size - 2 * corner_radius],
                center = true
            );

        // T-slot channels on all four faces
        _tslot_2d();                         // +X face
        rotate([0, 0,  90]) _tslot_2d();    // +Y face
        rotate([0, 0, 180]) _tslot_2d();    // -X face
        rotate([0, 0, 270]) _tslot_2d();    // -Y face

        // Central M4 through-hole
        circle(d = center_hole_dia);
    }
}

// 3D 2020 extrusion of the given length along the specified axis.
// The solid runs from 0 to `length` along the chosen axis.
//
// Parameters:
//   length  — extrusion length in mm (default 100)
//   axis    — orientation: "x", "y", or "z" (default "z")
module extrusion_2020(length = 100, axis = "z") {
    if (axis == "z") {
        linear_extrude(height = length)
            extrusion_2020_profile_2d();
    } else if (axis == "x") {
        rotate([0, 90, 0])
            linear_extrude(height = length)
                extrusion_2020_profile_2d();
    } else if (axis == "y") {
        rotate([-90, 0, 0])
            linear_extrude(height = length)
                extrusion_2020_profile_2d();
    }
}

// --- Preview output (comment out when using as a library) ---
// extrusion_2020(length = 100, axis = "z");
