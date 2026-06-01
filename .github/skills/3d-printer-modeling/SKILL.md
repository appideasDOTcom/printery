---
name: 3d-printer-modeling
description: Expert skill for creating 3D printable models using OpenSCAD for the CoreXY printery build. Use this skill for any task involving designing, modifying, or generating OpenSCAD models — including brackets, mounts, adapters, enclosures, and mechanical parts. Always check printerx/Shared-modules.scad for existing shared modules before writing new ones. Emphasizes software-development practices: variables for dimensions, modules for reusability, and high render quality.
---

# 3D Printer Modeling Skill (OpenSCAD)

## When to Use This Skill

Apply this skill whenever a task involves:
- Creating a new `.scad` model file
- Modifying or extending an existing OpenSCAD model
- Designing a mount, bracket, adapter, or custom part for the printer build
- Generating a parametric model where dimensions may need tuning

---

## Reference Codebase

Before writing any new module, check `/Users/costmo/Documents/dev/printing/gitHub/printerx/Shared-modules.scad` for existing shared modules that can be reused or adapted. Follow the patterns and conventions established there.

---

## Mandatory Practices

These are non-negotiable for every model produced:

### 1. High Render Quality by Default

Always set `$fa` and `$fs` globally at the top of the file for smooth curves and arcs:

```scad
$fa = 1.0;  // Maximum angle per fragment (degrees) — smaller = smoother
$fs = 0.1;  // Minimum fragment size (mm) — smaller = higher detail
```

- `$fa` and `$fs` together produce resolution-independent smoothness that scales correctly with the size of each shape.
- Never leave these at their defaults (OpenSCAD defaults produce very coarse approximations).
- Do not use `$fn` for global quality control — it overrides both `$fa` and `$fs` and produces fixed segment counts regardless of shape size.

### 2. Named Variables for All Measurements

Every physical dimension must be a named variable at the top of the file. No bare numeric literals inside modules or operations.

```scad
// --- Dimensions (all values in mm) ---
wall_thickness    = 3.0;
mount_width       = 40.0;
mount_height      = 25.0;
mount_depth       = 15.0;
screw_hole_dia    = 3.2;   // M3 clearance
screw_hole_offset = 5.0;
fillet_r          = 1.5;
```

- Group related variables together with a comment header.
- Use descriptive names — `mount_width` not `w`.
- Tolerances and clearances must be explicit separate variables, not folded into other values.

### 3. Modules for Every Meaningful Shape

Use modules to encapsulate every distinct part or reusable shape. Do not write a flat sequence of `difference()`, `union()`, and `translate()` calls at the top level.

```scad
// Good — each part is named and isolated
module base_plate() { ... }
module screw_hole(dia, depth) { ... }
module mounting_tab() { ... }

// Final composition at the end of the file
base_plate();
```

Use modules for:
- Any shape used more than once (even twice — abstract it)
- Any shape that has a clear physical identity (a "tab", a "slot", a "boss")
- Negative volumes (cutouts, holes) — name them so intent is clear

### 4. Composition at the End of the File

The final rendered output should be a single call (or small set of calls) at the bottom of the file, composing modules together. This makes it easy to isolate and render individual parts during development.

```scad
// --- Output ---
difference() {
    base_plate();
    screw_holes();
}
```

Comment out individual module calls to preview sub-components without changing the model logic.

### 5. Implement simple details of form and function

Make sure that the final output contains easy-to-achieve aesthetic details, such as rounded corners — which allow faster printing and are more aesthetically pleasing.

### 6. Check your results

Make sure the final output is correct before accepting it as a solution. Check and double check. Make an iterable plan if necessary.

---

## File Structure Template

Every new `.scad` file must follow this structure:

```scad
// ============================================================
// [Part Name]
// [Brief description of what this part is and what it mounts to]
// ============================================================

$fa = 1.0;
$fs = 0.1;

// --- Dimensions (mm) ---
// [group name]
var_name = value;

// --- Tolerances ---
clearance = 0.2;  // General fit tolerance

// --- Modules ---

module part_a() {
    // ...
}

module part_b() {
    // ...
}

module screw_hole(dia=3.2, depth=10) {
    cylinder(h=depth, d=dia);
}

// --- Output ---
difference() {
    part_a();
    part_b();
}
```

---

## Module Design Guidelines

### Parameters Over Hardcoding
Modules that represent reusable shapes (holes, slots, fillets) should accept parameters with sensible defaults:

```scad
module countersunk_hole(dia=3.2, depth=10, head_dia=6.5, head_depth=3) {
    union() {
        cylinder(h=depth, d=dia);
        cylinder(h=head_depth, d=head_dia);
    }
}
```

### Avoid Deep Nesting
If a `difference()` or `union()` block has more than 3–4 children, break sub-groups into named modules. Deep nesting is hard to debug and maintain.

### Use `translate()` and `rotate()` at the Call Site
Modules should be defined in a canonical position (centered, or with a consistent origin anchor). Position them when calling, not inside the module — unless the position is intrinsic to the part.

```scad
// Define centered
module screw_hole(dia=3.2, depth=10) {
    cylinder(h=depth, d=dia, center=true);
}

// Position at call site
translate([mount_width/2 - screw_hole_offset, 0, 0])
    screw_hole();
```

---

## Printer-Specific Constraints

Parts are designed for the CoreXY printery build. The target build volume has not yet been confirmed — ask the user before sizing any part that depends on the print envelope.

| Parameter | Value | Notes |
|---|---|---|
| Print bed size | TBD | Ask the user; do not assume Ender 3 dimensions |
| Frame rail spacing (Y) | 385 mm | Between rail midpoints |
| Frame rail spacing (X) | 320 mm | Between rail midpoints |
| Linear rod diameter | 8 mm | RJ4JP-01-08 dry bearings (LM8UU footprint) |
| Extrusion profile | 2020 | Aluminum T-slot |
| Default wall thickness | 3.0 mm | Minimum for structural parts |
| Screw hole clearance | +0.2 mm over nominal | e.g., M3 = 3.2 mm dia |
| Press-fit clearance | -0.1 to 0 mm | Tune per material |
| Minimum feature size | 0.8 mm | = 2 × 0.4 mm nozzle width |
| Layer height (reference) | 0.2 mm | For designing snap-fits or layer-aligned features |
| Default fillet radius | 1.5–2.0 mm | On exterior edges for strength and appearance |

### Mounting Hardware Reference (BTT SKR v2 / 2020 Extrusion)

Common fasteners used in this printer build:

| Fastener | Clearance Hole | Counterbore Dia | Notes |
|---|---|---|---|
| M3 | 3.2 mm | 6.5 mm | Most common for BTT boards, brackets |
| M4 | 4.3 mm | 8.5 mm | Frame extrusion T-nuts |
| M5 | 5.3 mm | 10.0 mm | 2020 extrusion end caps |

---

## Common Patterns

### Rectangular Body with Screw Holes
```scad
$fa = 1.0;
$fs = 0.1;

body_w = 40.0;
body_h = 20.0;
body_d = 5.0;
hole_dia = 3.2;
hole_inset = 5.0;

module body() {
    cube([body_w, body_h, body_d]);
}

module screw_hole(dia=hole_dia, depth=body_d) {
    cylinder(h=depth, d=dia);
}

module screw_holes() {
    positions = [
        [hole_inset, hole_inset, 0],
        [body_w - hole_inset, hole_inset, 0],
        [hole_inset, body_h - hole_inset, 0],
        [body_w - hole_inset, body_h - hole_inset, 0]
    ];
    for (p = positions)
        translate(p) screw_hole();
}

difference() {
    body();
    screw_holes();
}
```

### Cylinder with Axial Hole (Spacer / Boss)
```scad
$fa = 1.0;
$fs = 0.1;

outer_dia = 10.0;
inner_dia = 3.2;
height    = 8.0;

module spacer() {
    difference() {
        cylinder(h=height, d=outer_dia);
        cylinder(h=height, d=inner_dia);
    }
}

spacer();
```

---

## Workspace Layout

Models live under `models/` in the workspace, organized by part name:

```
models/
  [Part Name]/
    [part-name].scad    # OpenSCAD source
```

When creating a new model, create the folder and `.scad` file under `models/`. Do not place model files at the workspace root.

---

## Online Reference Sources

- **OpenSCAD documentation:** https://openscad.org/documentation.html
- **OpenSCAD cheatsheet:** https://openscad.org/cheatsheet/
- **Thingiverse (reference models):** https://www.thingiverse.com
- **Printables (reference models):** https://www.printables.com
