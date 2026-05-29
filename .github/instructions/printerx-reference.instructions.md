---
description: "Use when referencing prior hardware designs, OpenSCAD models, Marlin firmware config, OctoPrint setup, or WAP/captive-portal code from the existing cartesian printer. Covers the printerx reference codebase structure and what each area contains."
---
# printerx Reference Codebase

The completed cartesian-style printer project lives at `/Users/costmo/Documents/dev/printing/gitHub/printerx`.
Before creating new designs, firmware configs, or software, check here for prior patterns to reuse or adapt.

## Key Areas

| Path | Contents |
|------|----------|
| `Shared-modules.scad` | Reusable OpenSCAD modules — follow these patterns for all new models |
| `Marlin firmware/` | Prior working Marlin configuration for the same board (BTT SKR v2, 24 V) |
| `WAP/` | ESP8266 WAP + captive-portal implementation |
| `diskimage/` | Raspberry Pi disk image / OctoPrint configuration |
| `thirdparty/` | Third-party dependencies and vendor libraries |
| `vendor docs/` | Datasheets and reference documentation for hardware components |
| `output/` | Compiled/exported artifacts (STLs, binaries) |
| `support/` | Supporting scripts and utilities |

## OpenSCAD Models (root-level `.scad` files)

Individual part models for the cartesian printer — useful as dimensional and structural references:

- `Shared-modules.scad` — shared module library (always consult first)
- `Bottom frame.scad` — base frame (reused in this CoreXY build)
- `X axis carriage.scad`, `X ends.scad` — X-axis assemblies
- `Y belt retainer.scad`, `Y belt tensioner.scad`, `Y carriage bearing retainer.scad` — Y-axis belt and carriage parts
- `Z axis frame brace.scad`, `Z axis motor mount.scad`, `Z axis retainer block.scad` — Z-axis components
- `SK8 Tower.scad` — linear rail tower
- `Fan shroud.scad` — hotend/part cooling
- `ESP mount.scad` — ESP8266 mounting bracket
- `Camera mount.scad` — OctoPrint camera mount

## Usage Notes

- Hardware dimensions in the printery project take precedence over printerx wherever they differ
- CoreXY kinematics require different X/Y motion logic than the cartesian reference — do not copy motion config verbatim
- The BTT SKR v2 pinout and 24 V supply are the same; electrical configs are safe to reuse
