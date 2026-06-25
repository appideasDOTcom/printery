include <../common/shared-dims.scad>

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
// Bracket arm — connects sled cylinder to corner bracket
// ---------------------------------------------------------------------------

// Frame-level constants (matches placement in top-frame.scad / upper-top-frame.scad)
_arm_rod_cx   = ex + pb_block_xy / 2;             // 36 mm — front-left rod centre X (frame)
_arm_rod_cy   = ex + z_lr_rod_cy;                 // 29.1 mm — front-left rod centre Y (frame)
_cb_span      = 235;                              // build-plate bracket corner-to-corner span
_arm_brk_x    = bf_outer_x / 2 - _cb_span / 2;  // 52.5 mm — bracket outer-left X (frame)
_arm_brk_y    = bf_y_rail / 2 - _cb_span / 2;    // 85 mm — bracket front Y (frame)
_arm_fcb_x    = bf_outer_x / 2 - 195 / 2;       // 72.5 mm — front crossbar left end X (frame)

// Convert to local sled coordinates (origin = rod centre)
_arm_loc_brk_x  = _arm_brk_x  - _arm_rod_cx;    // 16.5 mm
_arm_loc_brk_y  = _arm_brk_y  - _arm_rod_cy;     // 55.9 mm
_arm_loc_fcb_x  = _arm_fcb_x  - _arm_rod_cx;     // 36.5 mm

// Arm Z extents in local sled space
_arm_z_bot = zbr_h - cb_wall_height;              // 13.8 mm — bracket / crossbar bottom
_arm_z_top = zbr_h;                               // 31.0 mm — flush with sled top
_arm_z_h   = cb_wall_height;                      // 17.2 mm

// Front crossbar inner end in local Y (front face of bracket = front face of crossbar body)
_arm_fcb_y0 = _arm_loc_brk_y - 2;                    // 55.9 mm — front face
_arm_fcb_y1 = _arm_fcb_y0 + 12.0;               // 67.9 mm — rear face (bar_width)

// Left crossbar: bracket local x=0..12, local y=20..40 → sled local x=16.5..28.5, y=75.9..95.9
_arm_lcb_x1 = _arm_loc_brk_x + 12.0;            // 28.5 mm — inner face of left crossbar slot
_arm_lcb_y0 = _arm_loc_brk_y + 20.0;            // 75.9 mm — left crossbar front face (bracket local y=20)

// Build the left-variant bracket arm using hull() for 45° mitered sides.
// The shape starts at the cylinder's +Y face and fans out to span both crossbar ends.
// Two control slabs define the 45° angled walls:
//   A) at the front-crossbar end: extends from cylinder +Y face to fcb_x at fcb_y0..fcb_y1
//   B) at the left-crossbar end:  extends from cylinder +Y face to lcb_x1 at lcb_y0
module _z_carriage_arm_left() {
    _e          = 0.01;
    _root_hw    = zcn_od / 2;
    _root_z_bot = zbr_h - zcn_h;        // 17.5 mm — bottom at root, flush with top of lower cylinder
    _root_z_h   = zbr_h - _root_z_bot;  // 13.5 mm — height at root (= zcn_h)
    hull() {
        // Root slab — top flat at zbr_h, bottom raised to meet the lower cylinder top
        translate([-_root_hw, _z_ls_offset - _e, _root_z_bot])
            cube([zcn_od, _e, _root_z_h]);

        // Front-crossbar end slab — full height, bottom at _arm_z_bot
        translate([-zbr_r, _arm_fcb_y0, _arm_z_bot])
            cube([_arm_loc_fcb_x + zbr_r, _arm_fcb_y1 - _arm_fcb_y0, _arm_z_h]);

        // Left-crossbar end slab — full height, bottom at _arm_z_bot
        translate([-zbr_r, _arm_lcb_y0, _arm_z_bot])
            cube([_arm_lcb_x1 + zbr_r, _e, _arm_z_h]);
    }
}

// ---------------------------------------------------------------------------
// Combined carriage pieces
// ---------------------------------------------------------------------------

// Base: bearing retainer + lead screw collar (no bracket arm)
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

// Left variant: base + bracket arm extending toward front-left corner bracket
module z_carriage_left() {
    union() {
        z_carriage_assembly();
        #_z_carriage_arm_left();
    }
}

z_carriage_left();
