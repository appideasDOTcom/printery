include <../common/shared-dims.scad>
use <../common/shapes.scad>

// --- Bearing retainer ---
zbr_od           = rj_bearing_od + 5.0;                // 20.1 mm
zbr_r            = zbr_od / 2;
zbr_h            = rj_base_y + 2;                      // 31 mm — one bearing pocket
zbr_relief_above = 5.0;

// --- Collar nut ---
zcn_od  = 27.0;
zcn_id  = 10.0 + 0.2;                                  // 10.2 mm lead screw bore
zcn_h   = 13.5;

// --- T8 anti-backlash nut flange interface (top of sled) ---
t8_flange_od     = 22.0;   // nut flange outer diameter
t8_flange_tol    = 0.4;    // clearance added to the flange recess
t8_flange_recess = 3.5;    // recess depth below the sled top face
t8_bolt_circle_r = 8.0;    // M3 flange-screw bolt circle radius
t8_screw_d_bot   = 2.6;    // press-fit minor diameter (bottom of taper)
t8_screw_d_top   = 3.6;    // tapered entry diameter (top)
t8_screw_taper_h = 3.0;    // taper depth from the top face

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
        _hx = t8_bolt_circle_r * cos(a);
        _hy = t8_bolt_circle_r * sin(a);
        // Tapered entry: t8_screw_d_top at top, t8_screw_d_bot at bottom, t8_screw_taper_h deep
        translate([_hx, _z_ls_offset + _hy, zbr_h - t8_screw_taper_h])
            cylinder(d1 = t8_screw_d_bot, d2 = t8_screw_d_top, h = t8_screw_taper_h + 0.1);
        // Straight bore through the remainder
        translate([_hx, _z_ls_offset + _hy, -0.1])
            cylinder(d = t8_screw_d_bot, h = zbr_h - t8_screw_taper_h + 0.2);
    }
}

// ---------------------------------------------------------------------------
// Bracket arm — connects sled cylinder to corner bracket
// ---------------------------------------------------------------------------

// Corner bracket dimensions (plate_width/plate_depth come from shared-dims.scad)
corner_radius = 2;        // local per-part rounding, matches corner-bracket.scad

// Crossbar geometry (must match front-crossbar.scad / corner-bracket.scad)
cb_bar_width  = 12.0;     // crossbar body depth — bracket slot width
cb_span       = 235.0;    // build-plate bracket corner-to-corner span
fcb_length    = 195.0;    // front crossbar length
cb_slot_start = plate_width / 2;   // 20 mm — crossbar meets the bracket midpoint
_fcb_front_offset = 2.0;  // bracket front face sits this far ahead of the rod-local brk_y

// Frame-level constants (matches placement in top-frame.scad / upper-top-frame.scad)
_arm_rod_cx   = ex + pb_block_xy / 2;             // 36 mm — front-left rod centre X (frame)
_arm_rod_cy   = ex + z_lr_rod_cy;                 // 29.1 mm — front-left rod centre Y (frame)
_cb_span      = cb_span;                          // build-plate bracket corner-to-corner span
_arm_brk_x    = bf_outer_x / 2 - _cb_span / 2;  // 52.5 mm — bracket outer-left X (frame)
_arm_brk_y    = bf_y_rail / 2 - _cb_span / 2;    // 85 mm — bracket front Y (frame)
_arm_fcb_x    = bf_outer_x / 2 - fcb_length / 2;       // 72.5 mm — front crossbar left end X (frame)

// Convert to local sled coordinates (origin = rod centre)
_arm_loc_brk_x  = _arm_brk_x  - _arm_rod_cx;    // 16.5 mm
_arm_loc_brk_y  = _arm_brk_y  - _arm_rod_cy;     // 55.9 mm
_arm_loc_fcb_x  = _arm_fcb_x  - _arm_rod_cx;     // 36.5 mm

// Arm Z extents in local sled space
_arm_z_bot = zbr_h - cb_wall_height;              // 13.8 mm — bracket / crossbar bottom
_arm_z_top = zbr_h;                               // 31.0 mm — flush with sled top
_arm_z_h   = cb_wall_height;                      // 17.2 mm

// Front crossbar inner end in local Y (front face of bracket = front face of crossbar body)
_arm_fcb_y0 = _arm_loc_brk_y - _fcb_front_offset;    // 55.9 mm — front face
_arm_fcb_y1 = _arm_fcb_y0 + cb_bar_width;       // 67.9 mm — rear face (bar_width)

// Left crossbar: bracket local x=0..12, local y=20..40 → sled local x=16.5..28.5, y=75.9..95.9
_arm_lcb_x1 = _arm_loc_brk_x + cb_bar_width;    // 28.5 mm — inner face of left crossbar slot
_arm_lcb_y0 = _arm_loc_brk_y + cb_slot_start;   // 75.9 mm — left crossbar front face (bracket local y=20)

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

        // Left-crossbar end slab — full height, rounded at left corner
        translate([-zbr_r + corner_radius, _arm_lcb_y0 - corner_radius, _arm_z_bot])
            cylinder(r = corner_radius, h = _arm_z_h);
        translate([-zbr_r + corner_radius, _arm_lcb_y0, _arm_z_bot])
            cube([_arm_lcb_x1 + zbr_r - corner_radius, _e, _arm_z_h]);
    }
}

// ---------------------------------------------------------------------------
// Combined carriage pieces
// ---------------------------------------------------------------------------

// All subtractions that apply to every variant
module _z_carriage_cuts() {
    _zbr_pocket();
    _zbr_relief();
    _zbr_outer_clip();
    translate([0, _z_ls_offset, -0.1])
        cylinder(d = zcn_id, h = zbr_h + 0.2);
    translate([0, _z_ls_offset, zbr_h - t8_flange_recess])
        cylinder(d = t8_flange_od + t8_flange_tol, h = t8_flange_recess + 0.1);
    _t8_nut_screws();
}

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
        _z_carriage_cuts();
    }
}

// Cutout: bracket footprint that intercepts the arm, with rounded outer corner
module _z_carriage_brk_cutout() {
    _r   = corner_radius;          // 2 mm — matches corner-bracket.scad
    _w   = plate_width;            // 40 mm
    _d   = plate_depth;            // 40 mm
    _bx  = _arm_loc_brk_x;        // 16.5 mm — bracket left edge in sled local X
    _by  = _arm_loc_brk_y;        // 55.9 mm — bracket front edge in sled local Y
    // Full arm height + epsilon top/bottom to ensure clean cut
    translate([_bx, _by, _arm_z_bot - 0.1])
        hull() {
            // Rounded outer corner at bracket [0,0]
            translate([_r, _r, 0]) cylinder(r = _r, h = _arm_z_h + 0.2);
            // Other three corners — sharp (large rectangles flush to edges)
            translate([0,      0,  0]) cube([_r,  _r,  _arm_z_h + 0.2]);
            translate([_w - _r, 0,  0]) cube([_r,  _r,  _arm_z_h + 0.2]);
            translate([0,  _d - _r, 0]) cube([_r,  _r,  _arm_z_h + 0.2]);
            translate([_w - _r, _d - _r, 0]) cube([_r, _r, _arm_z_h + 0.2]);
        }
}

module _z_carriage_hollow() {

	_wall_offset    = 4;     // inset of the pocket walls from the control points
	_hollow_tube_d  = 4;     // diameter of each hull pillar (governs corner radius)
	_hollow_z_shift = -3;    // drop the pocket below the arm bottom for a clean cut
	// NOTE: the X/Y control points below were placed empirically to trace the
	// underside pocket; they are intentionally left as literals.
	translate( [0, 0, _hollow_z_shift] ) {

		hull() {
			translate([-10 + _wall_offset,  32 + _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
			translate([ 23 - _wall_offset,  32 + _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
			translate([ 34 - _wall_offset,  56 - _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
			translate([ 16 - _wall_offset,  56 - _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
		}

		hull() {
			translate([-10 + _wall_offset,  32 + _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
			translate([ 16 - _wall_offset,  56 - _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
			translate([-10 + _wall_offset,  76 - _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
			translate([ 16 - _wall_offset,  76 - _wall_offset, _arm_z_bot]) cylinder(d = _hollow_tube_d, h = _arm_z_h);
		}
	}

}

// Left variant: base + bracket arm extending toward front-left corner bracket
// M3 through-hole through the -Y face of the bracket pocket step.
// Wall face is at Y = _arm_loc_brk_y. Hole bores in +Y through the arm.
module _z_carriage_bracket_wall_hole() {
    _hx = (-zbr_r + _arm_loc_brk_x) / 2;  // 3.2 mm — X centre of wall material
    _hz = _arm_z_bot + _arm_z_h / 2;       // 22.4 mm — Z centre of wall height
    _hole_z   = _arm_z_bot + _arm_z_h / 2 - 2.6;       // 19.8 mm — fastener bore Z
    _fcb_mid  = (_arm_fcb_y0 + _arm_fcb_y1) / 2;       // Y midline of the front crossbar pocket
    _access_d = 5;                                     // allen-wrench access bore diameter
    translate([_arm_loc_brk_x + 1, _fcb_mid + 9, _hole_z])
        rotate([0, -90, 0])
            cylinder(d = m3_through_dia, h = plate_width);
	// Cutout for allen wrench access.
	translate([_arm_loc_brk_x -10, _fcb_mid + 9, _hole_z])
        rotate([0, -90, 0])
            cylinder(d = _access_d, h = plate_width);

	translate([_arm_loc_brk_x + 1 + 9, _fcb_mid + 3, _hole_z])
        rotate([90, -90, 0])
            cylinder(d = m3_through_dia, h = plate_width);
	translate([_arm_loc_brk_x + 1 + 9, _fcb_mid + 3 - 12, _hole_z])
        rotate([90, -90, 0])
            cylinder(d = _access_d, h = plate_width);



}

module z_carriage_left() {
    union() {
        difference() {
            union() {
                z_carriage_assembly();
                _z_carriage_arm_left();
            }
            _z_carriage_brk_cutout();
            _z_carriage_cuts();
			_z_carriage_hollow();
            _z_carriage_bracket_wall_hole();
        }
        // Inner fillet at the pocket's 90° corner (bracket outer corner in sled local coords)
        // Concave curve faces +X,+Y (into the pocket); rotate 180° so the solid quadrant
        // sits in the −X,−Y material and the curve opens toward the empty pocket space.
        translate([_arm_loc_brk_x + 2, _arm_loc_brk_y + 2, _arm_z_bot])
            rotate([0, 0, 0])
                inner_fillet(d = 4, l = _arm_z_h);


    }
}

// Right variant: mirror of left along X axis (rod centre is the mirror axis)
module z_carriage_right() {
    mirror([1, 0, 0]) z_carriage_left();
}

use <../build-plate/front-crossbar.scad>

// ---------------------------------------------------------------------------
// Rear carriage connector — triangular web joining bearing pillar to crossbar
// ---------------------------------------------------------------------------

// Crossbar piece placement (must match the translate below)
_rcb_x      = -97.5;   // left edge of crossbar piece in sled local X
_rcb_y      =  44.0;   // front face of crossbar piece in sled local Y
_rcb_z      =  13.8;   // bottom of crossbar piece in sled local Z
_rcb_width  = 195.0;   // total crossbar span (bar_length from front-crossbar.scad)
_rcb_cw     = 109.0;   // cutout_w — material spans ±54.5 mm from bar centre (X=0)

// Triangle base extents: stay within the solid material of the crossbar piece
_tri_base_hw  = _rcb_cw / 2;                  // 54.5 mm — half-width of base
_tri_base_x_l = -_tri_base_hw;                // -54.5 mm
_tri_base_x_r =  _tri_base_hw;                //  54.5 mm
_tri_base_y   = _rcb_y;                       //  44 mm — front face of crossbar
_tri_apex_y   = _z_ls_offset;                 //  20.2 mm — lead screw bore centre Y

// Z extents: top flush with sled, bottom tapers via hull
_tri_top_z    = zbr_h;                        // 31 mm
_tri_apex_bot = zbr_h - zcn_h;               // 17.5 mm — bottom of nut collar at apex
_tri_base_bot = _rcb_z;                       // 13.8 mm — bottom of crossbar piece

// Apex slab: narrow, at lead screw Y, bottom = collar bottom
_tri_apex_hw  = zcn_od / 2;                   // 13.5 mm half-width

// Base slab thickness in Y so it mates flush to the crossbar front face
_tri_slab_t   = 2.0;

module _z_carriage_rear_web() {
    hull() {
        // Apex slab — sits against the lead screw collar, bottom at collar base
        translate([-_tri_apex_hw, _tri_apex_y, _tri_apex_bot])
            cube([zcn_od, _tri_slab_t, _tri_top_z - _tri_apex_bot]);

        // Left base corner — at crossbar front face, full height, slightly rounded
        translate([_tri_base_x_l, _tri_base_y, _tri_base_bot])
            cube([_tri_slab_t, _tri_slab_t, _tri_top_z - _tri_base_bot]);

        // Right base corner — mirror of left
        translate([_tri_base_x_r - _tri_slab_t, _tri_base_y, _tri_base_bot])
            cube([_tri_slab_t, _tri_slab_t, _tri_top_z - _tri_base_bot]);
    }
}

module z_carriage_rear() {
    difference() {
        union() {
            z_carriage_assembly();
            translate([_rcb_x, _rcb_y, _rcb_z])
                rear_crossbar_cutout_insertion();
            _z_carriage_rear_web();
        }
        _z_carriage_cuts();
    }
}

// z_carriage_left();
// z_carriage_right();


z_carriage_rear();