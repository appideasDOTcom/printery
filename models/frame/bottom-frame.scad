/**
 * Bottom Frame Assembly
 *
 * Models the existing bottom frame constructed from 2020 aluminum extrusions.
 *
 * Frame structure:
 *   - Bottom layer: two Y-axis extrusions running the full 405 mm length (no X cross-members)
 *   - Four 50 mm vertical corner posts separating bottom and top layers
 *   - Top layer: two Y-axis extrusions + two X-axis cross-members (300 mm, between Y rails)
 *
 * Coordinate origin is at the front-left-bottom corner of the assembled frame.
 * All extrusions are modeled with their flat face flush to the nearest origin plane.
 *
 * Include this file in assemblies that need to reference the frame geometry:
 *   use <bottom-frame.scad>
 *   bottom_frame();
 */

use <../common/2020-extrusion.scad>

$fa = 1.0;
$fs = 0.1;

// ---------------------------------------------------------------------------
// Frame dimensions (all values in mm)
// ---------------------------------------------------------------------------
ex_size            = 20.0;   // 2020 profile nominal size
y_rail_length      = 405.0;  // Full Y-axis extrusion length
x_rail_length      = 300.0;  // X cross-member length (fits between Y rails)
corner_post_height = 50.0;   // Height of the vertical corner posts

// ---------------------------------------------------------------------------
// Derived layout values
// ---------------------------------------------------------------------------

// Total outer footprint
frame_outer_x      = x_rail_length + 2 * ex_size;   // 340 mm

// Center X of left and right Y rails
left_rail_cx       = ex_size / 2;                    // 10 mm
right_rail_cx      = frame_outer_x - ex_size / 2;   // 330 mm

// Center Y of front and rear cross-members (at the ends of the Y rails)
front_cross_cy     = ex_size / 2;                    // 10 mm
rear_cross_cy      = y_rail_length - ex_size / 2;    // 395 mm

// Z center/start values for each layer
bottom_layer_cz    = ex_size / 2;                             //  10 mm (center of bottom layer)
corner_post_z      = ex_size;                                 //  20 mm (base of corner posts)
top_layer_cz       = ex_size + corner_post_height + ex_size / 2; //  80 mm (center of top layer)

// X start of the cross-members (inside face of left Y rail)
cross_x_start      = ex_size;                        // 20 mm


// ---------------------------------------------------------------------------
// Sub-assemblies
// ---------------------------------------------------------------------------

// Two Y-axis extrusions forming the bottom layer (no X cross-members)
module frame_bottom_layer() {
    // Left rail
    translate([left_rail_cx, 0, bottom_layer_cz])
        extrusion_2020(y_rail_length, "y");

    // Right rail
    translate([right_rail_cx, 0, bottom_layer_cz])
        extrusion_2020(y_rail_length, "y");
}

// Four 50 mm vertical posts at the frame corners
module frame_corner_posts() {
    // Front-left
    translate([left_rail_cx, front_cross_cy, corner_post_z])
        extrusion_2020(corner_post_height, "z");

    // Front-right
    translate([right_rail_cx, front_cross_cy, corner_post_z])
        extrusion_2020(corner_post_height, "z");

    // Rear-left
    translate([left_rail_cx, rear_cross_cy, corner_post_z])
        extrusion_2020(corner_post_height, "z");

    // Rear-right
    translate([right_rail_cx, rear_cross_cy, corner_post_z])
        extrusion_2020(corner_post_height, "z");
}

// Two Y-axis rails and two X-axis cross-members forming the top layer
module frame_top_layer() {
    // Left Y rail
    translate([left_rail_cx, 0, top_layer_cz])
        extrusion_2020(y_rail_length, "y");

    // Right Y rail
    translate([right_rail_cx, 0, top_layer_cz])
        extrusion_2020(y_rail_length, "y");

    // Front X cross-member (spans between the inner faces of the Y rails)
    translate([cross_x_start, front_cross_cy, top_layer_cz])
        extrusion_2020(x_rail_length, "x");

    // Rear X cross-member
    translate([cross_x_start, rear_cross_cy, top_layer_cz])
        extrusion_2020(x_rail_length, "x");
}


// ---------------------------------------------------------------------------
// Top-level module — use this when referencing in assemblies
// ---------------------------------------------------------------------------
module bottom_frame() {
    frame_bottom_layer();
    frame_corner_posts();
    frame_top_layer();
}


// ---------------------------------------------------------------------------
// Output (comment out when using as a library)
// ---------------------------------------------------------------------------
color( "green" ) bottom_frame();
