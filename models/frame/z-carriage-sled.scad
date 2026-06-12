include <shared-dims.scad>

// --- Bearing retainer ---
zbr_od           = rj_bearing_od + 5.0;                // 20.1 mm
zbr_r            = zbr_od / 2;
zbr_h            = rj_base_y + 2;                      // 31 mm — one bearing pocket
zbr_relief_above = 5.0;

// --- Collar nut ---
zcn_od  = 27.0;
zcn_id  = 10.0 + 0.2;                                  // 10.2 mm lead screw bore
zcn_h   = 13.5;

// --- Shared offset: lead screw centre relative to rod centre ---
_z_ls_offset = z_lr_bearing_cy - z_lr_rod_cy;          // 20.2 mm

// ---------------------------------------------------------------------------
// Internal subtractions
// ---------------------------------------------------------------------------

module _zbr_pocket() {
    cylinder(d = rj_bearing_od - rj_trap_ring_depth * 2, h = zbr_h);
    translate([0, 0, rj_base_y / 2 - rj_trap_ring_spacing / 2 + 1])
        cylinder(d = rj_bearing_od, h = rj_trap_ring_spacing);
    cylinder(d = rj_bearing_od, h = rj_cutout_to_end);
    translate([0, 0, rj_base_y - rj_cutout_to_end + 2])
        cylinder(d = rj_bearing_od, h = rj_cutout_to_end);
}

module _zbr_relief() {
    translate([-carriage_rod_dia / 2, -(zbr_r + 0.1), -0.1])
        cube([carriage_rod_dia, zbr_r - zbr_relief_above + 0.1, zbr_h + 0.2]);
}

// Clip the outer arc flat — 2 mm clearance from frame inner face (which is z_lr_rod_cy from rod centre)
zbr_frame_clearance = 2.0;
_zbr_clip_y         = z_lr_rod_cy - zbr_frame_clearance;   // 7.1 mm from rod centre

module _zbr_outer_clip() {
    translate([-(zbr_r + 0.1), -(zbr_r + 0.1), -0.1])
        cube([zbr_od + 0.2, zbr_r - _zbr_clip_y + 0.1, zbr_h + 0.2]);
}

// 4 M3 press-fit holes for the T8 nut flange — 8 mm radius, 45° start, every 90°
module _t8_nut_screws() {
    for (a = [45, 135, 225, 315]) {
        _hx = 8.0 * cos(a);
        _hy = 8.0 * sin(a);
        // Tapered entry: 3.6 mm at top, 2.6 mm at bottom, 3 mm deep
        translate([_hx, _z_ls_offset + _hy, zbr_h - 3])
            cylinder(d1 = 2.6, d2 = 3.6, h = 3.1);
        // Straight bore through the remainder
        translate([_hx, _z_ls_offset + _hy, -0.1])
            cylinder(d = 2.6, h = zbr_h - 3 + 0.2);
    }
}

// ---------------------------------------------------------------------------
// Combined carriage piece
// ---------------------------------------------------------------------------

module z_carriage_assembly() {
    difference() {
        union() {
            // Lower section: plain bearing retainer cylinder
            cylinder(d = zbr_od, h = zbr_h - zcn_h);
            // Upper section: hull of both cylinders fills the concave gap with a smooth fillet
            translate([0, 0, zbr_h - zcn_h])
                hull() {
                    cylinder(d = zbr_od, h = zcn_h);
                    translate([0, _z_ls_offset, 0])
                        cylinder(d = zcn_od, h = zcn_h);
                }
        }
        // Bearing pocket, rod entry relief, and outer face clip
        _zbr_pocket();
        _zbr_relief();
        _zbr_outer_clip();
        // Lead screw bore through the collar nut section
        translate([0, _z_ls_offset, -0.1])
            cylinder(d = zcn_id, h = zbr_h + 0.2);
        // Collar nut counterbore at top face
        translate([0, _z_ls_offset, zbr_h - 3.5])
            cylinder(d = 22.0 + 0.4, h = 3.5 + 0.1);
        // M3 fastener holes for T8 nut flange
        _t8_nut_screws();
    }
}

z_carriage_assembly();
