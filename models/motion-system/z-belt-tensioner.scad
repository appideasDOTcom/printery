/**
 * z-belt-tensioner.scad
 *
 * Z-axis belt tensioner — mounts flat against the inner face of the right Y
 * extrusion (global X = bf_outer_x − ex = 320 mm), immediately behind (in +Y)
 * the front-right lower Z pillow block.
 *
 * Physical layout:
 *   The bracket is a vertical plate that presses against the X=320 face.
 *   Two M5 T-nut bolts (in X) clamp it to the extrusion.
 *   An arm extends inward (−X) at the belt's Z height, carrying a vertical
 *   M5 pulley shaft.  The shaft slot runs in X so the pulley can be pushed
 *   inward to tension the belt, then locked with a nut.
 *
 * Belt geometry (pulley centres, r = 6 mm):
 *   Rear-centre (170, 377) → Front-right (312, 28).  ΔX=142, ΔY=−349.
 *   At Y = 75 mm (mid-bracket):  t = (377−75)/349 = 0.866
 *     belt centreline X = 170 + 142×0.866 = 293 mm
 *     belt surface X    = 293 + 6         = 299 mm
 *   Extrusion inner face at X=320 → belt is 21 mm inboard.
 *
 * Pulley travel:
 *   Slot start (first contact): pulley centre X = 299 mm → 21 mm from face
 *   Slot end   (+15 mm travel): pulley centre X = 284 mm → 36 mm from face
 *
 * Placement in top-frame.scad:
 *   translate([bf_outer_x - ex, ex + z_lr_block_depth, pb_lower_bot_z])
 *     z_belt_tensioner();
 *   (local X=0 is the extrusion inner face; body extends in −X)
 */

include <../common/shared-dims.scad>

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

// Back plate: presses flat against X=320 face
_plate_x   = 4.0;    // thickness in X (into the extrusion face)
_arm_y_start = 12.0;  // extension on each side of the arm
_plate_z   = ex;  // 20 mm — matches 2020 extrusion height

// Arm: extends inward (−X) from the back plate, at belt Z height.
// The arm is positioned at the REAR of the plate (away from the pillow block)
// so it does not overlap the pillow block in Y at all.
// Arm Z centre in local coords (local Z=0 = pb_lower_bot_z = 70 mm):
_arm_thick  = 10.0;  // arm height in Z
_arm_z_ctr  = ex - _arm_thick / 2;   // 15 mm — arm top flush with top of 20 mm extrusion
_arm_depth  = 42.0;  // arm reach in −X (must reach 36 mm for full slot travel)
_arm_y      = 18.0;  // arm front-to-back depth in Y (narrower than plate)
_plate_y    = _arm_y_start + _arm_y + _arm_y_start;  // 42 mm — equal extension on both sides of arm

// M5 pulley slot in the arm — vertical bolt (Z axis), slot runs in X
// Slot centre from the +X face (extrusion face):
//   first contact = 21 mm inboard → local X = −21  (arm local: 36 − 21 = 15 mm from tip)
//   end of travel = 36 mm inboard → local X = −36  (at arm tip)
// In arm-local coords (arm X=0 at plate back face, arm extends to X=−_arm_depth):
_slot_near   = 21.0;   // mm inboard from extrusion face for first belt contact
_slot_far    = 36.0;   // mm inboard for full 15 mm travel
_slot_r      = m5_through_dia / 2;  // 2.75 mm
_slot_len    = _slot_far - _slot_near;  // 15 mm
// Arm-local X of slot centre (arm X=0 at extrusion face, negative = inboard):
_slot_cx_arm = -(_slot_near + _slot_len / 2);  // −28.5 mm

// M5 head counterbore on top face of arm
_cbore_d     = m5_head_dia;    // 9 mm
_cbore_z     = m5_head_depth;  // 3.5 mm

// Two M5 T-nut bolts clamping plate to extrusion (bolt axis in X, into T-slot)
_bolt_y1     = _plate_y * 0.25;
_bolt_y2     = _plate_y * 0.75;
_bolt_z1     = _plate_z * 0.25;
_bolt_z2     = _plate_z * 0.75;

// ---------------------------------------------------------------------------
// Module — local origin at the extrusion inner face (X=0 here = global X=320)
//          body extends in −X; placed with translate so X=0 lands on the face
// ---------------------------------------------------------------------------
module z_belt_tensioner() {

    // Plate and arm both extend in −X from X=0
    difference() {
        union() {
            // Back plate against extrusion inner face
            translate([-_plate_x, 0, 0])
                cube([_plate_x, _plate_y, _plate_z]);

            // Arm extends inward (−X), starting at _arm_y_start from plate front
            translate([-_plate_x - _arm_depth, _arm_y_start, _arm_z_ctr - _arm_thick/2])
                cube([_arm_depth, _arm_y, _arm_thick]);
        }

        // M5 pulley slot — vertical (Z axis), slot runs in X
        // Y centred on the arm (rear portion of plate)
        _arm_cy = _arm_y_start + _arm_y / 2;
        translate([_slot_cx_arm - _plate_x, _arm_cy, _arm_z_ctr - _arm_thick/2 - 0.1])
            hull() {
                translate([-(_slot_len/2 - _slot_r), 0, 0])
                    cylinder(r = _slot_r, h = _arm_thick + 0.2);
                translate([ (_slot_len/2 - _slot_r), 0, 0])
                    cylinder(r = _slot_r, h = _arm_thick + 0.2);
            }

        // M5 through hole in rear plate extension — centre of rear section
        translate([0.1, _arm_y_start + _arm_y + _arm_y_start / 2, _plate_z / 2])
            rotate([0, -90, 0])
                cylinder(d = m5_through_dia, h = _plate_x + 0.2);

        // M5 through hole in front plate extension — centre of front section
        translate([0.1, _arm_y_start / 2, _plate_z / 2])
            rotate([0, -90, 0])
                cylinder(d = m5_through_dia, h = _plate_x + 0.2);

        // M5 head counterbore from bottom of arm
        translate([_slot_cx_arm - _plate_x, _arm_cy, _arm_z_ctr - _arm_thick/2 - 0.1])
            hull() {
                translate([-(_slot_len/2 - _slot_r), 0, 0])
                    cylinder(d = _cbore_d, h = _cbore_z + 0.1);
                translate([ (_slot_len/2 - _slot_r), 0, 0])
                    cylinder(d = _cbore_d, h = _cbore_z + 0.1);
            }

    }
}

// ---------------------------------------------------------------------------
// Preview
// ---------------------------------------------------------------------------
z_belt_tensioner();
