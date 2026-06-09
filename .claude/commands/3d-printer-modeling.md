# 3D Printer Modeling (OpenSCAD)

Apply this skill whenever a task involves creating a new `.scad` model file, modifying an existing OpenSCAD model, or designing any mount, bracket, adapter, or custom part for the printer build.

## Before Writing Any Code

Check `/Users/costmo/Documents/dev/printing/gitHub/printerx/Shared-modules.scad` for existing shared modules that can be reused or adapted. Follow the patterns and conventions established there.

## Mandatory Practices

### Foundational

- Start with simple shapes and build or subtract from there. Do not overcomplicate things.
- Slightly rounded corners are preferable to right angles.

### High Render Quality

Always set `$fa` and `$fs` globally at the top of the file:

```scad
$fa = 1.0;  // Maximum angle per fragment (degrees)
$fs = 0.1;  // Minimum fragment size (mm)
```

Never leave these at OpenSCAD defaults. Do not use `$fn` for global quality control.

### Named Variables for All Measurements

Every physical dimension must be a named variable at the top of the file. No bare numeric literals inside modules or operations.

```scad
// --- Dimensions (all values in mm) ---
wall_thickness    = 3.0;
mount_width       = 40.0;
screw_hole_dia    = 3.2;   // M3 clearance
clearance         = 0.2;   // General fit tolerance
```

Tolerances and clearances must be explicit separate variables.

### Modules for Every Meaningful Shape

Encapsulate every distinct part or reusable shape in a module. Do not write a flat sequence of `difference()`, `union()`, and `translate()` at the top level.

Use modules for any shape used more than once, any shape with a clear physical identity, and all negative volumes (cutouts, holes).

Modules should be defined in a canonical position (centered, or with a consistent origin anchor). Position them at the call site, not inside the module definition.

### Composition at the End of the File

The final rendered output is a single call (or small set of calls) at the bottom of the file composing modules together.

### Avoid Deep Nesting

If a `difference()` or `union()` block has more than 3–4 children, break sub-groups into named modules.

## File Structure Template

```scad
// ============================================================
// [Part Name]
// [Brief description of what this part is and what it mounts to]
// ============================================================

$fa = 1.0;
$fs = 0.1;

// --- Dimensions (mm) ---
wall_thickness = 3.0;
// ...

// --- Tolerances ---
clearance = 0.2;

// --- Modules ---

module part_a() { ... }

module screw_hole(dia=3.2, depth=10) {
    cylinder(h=depth, d=dia);
}

// --- Output ---
difference() {
    part_a();
    screw_holes();
}
```

## Printer-Specific Dimensions

| Parameter | Value | Notes |
|---|---|---|
| Frame rail spacing (Y) | 385 mm | Between rail midpoints |
| Frame rail spacing (X) | 320 mm | Between rail midpoints |
| Linear rod diameter | 8 mm | RJ4JP-01-08 dry bearings (LM8UU footprint) |
| Extrusion profile | 2020 | Aluminum T-slot |
| Default wall thickness | 3.0 mm | Minimum for structural parts |
| Screw hole clearance | +0.2 mm over nominal | e.g., M3 = 3.2 mm dia |
| Press-fit clearance | -0.1 to 0 mm | Tune per material |
| Minimum feature size | 0.8 mm | = 2 × 0.4 mm nozzle width |
| Default fillet radius | 1.5–2.0 mm | On exterior edges |

### Common Fasteners

| Fastener | Clearance Hole | Counterbore Dia | Notes |
|---|---|---|---|
| M3 | 3.2 mm | 6.5 mm | Most common for BTT boards, brackets |
| M4 | 4.3 mm | 8.5 mm | Frame extrusion T-nuts |
| M5 | 5.3 mm | 10.0 mm | 2020 extrusion end caps |

The target build volume has not yet been confirmed — ask the user before sizing any part that depends on the print envelope.

## File Location

Place new models under `models/[Part Name]/[part-name].scad`. Do not place model files at the workspace root.

## References

- OpenSCAD docs: https://openscad.org/documentation.html
- OpenSCAD cheatsheet: https://openscad.org/cheatsheet/
