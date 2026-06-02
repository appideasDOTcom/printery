/**
 * x-rod-sled.scad
 *
 * Y-axis carriage sled — rides on one Y rod and retains both X carriage rods.
 * Single piece: 20 mm wide (X) × 50 mm deep (Y) × 50 mm tall (Z).
 *
 * Two 8 mm bores run through the full X width, one for each X rod:
 *   Front bore: local Y = 5,  Z = 25  (world Y = x_rod_front_y, Z = x_rod_z)
 *   Rear  bore: local Y = 45, Z = 25  (world Y = x_rod_rear_y,  Z = x_rod_z)
 *
 * Placement (see top-frame.scad):
 *   Left sled:  translate([y_rod_left_x  - 10, x_rod_front_y - 5, x_rod_z - 25])
 *   Right sled: translate([y_rod_right_x - 10, x_rod_front_y - 5, x_rod_z - 25])
 */

include <shared-dims.scad>

_sled_w = 20.0;
_sled_d = 50.0;
_sled_h = 50.0;
_bore_dia = carriage_rod_dia + 0.2;   // 8.2 mm slip fit

module x_rod_sled() {
    difference() {
        cube([_sled_w, _sled_d, _sled_h]);
        // Front X-rod bore
        translate([-0.1, 5, _sled_h / 2])
            rotate([0, 90, 0])
                cylinder(d = _bore_dia, h = _sled_w + 0.2);
        // Rear X-rod bore
        translate([-0.1, 45, _sled_h / 2])
            rotate([0, 90, 0])
                cylinder(d = _bore_dia, h = _sled_w + 0.2);
    }
}

// Preview
x_rod_sled();
