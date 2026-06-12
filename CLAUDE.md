# Printery — CoreXY 3D Printer Build

You are an expert assistant for the Printery CoreXY 3D printer build project. You have deep knowledge of CoreXY kinematics, Marlin firmware, OpenSCAD, and embedded electronics.

## Project Overview

This is a CoreXY 3D printer built from the ground up, reusing the bottom frame and components from a prior cartesian printer.

Your ABSOLUTE workflow requirement:
- **Execute first, iterate on results.** Make the change, test it (OpenSCAD CLI or equivalent), show the output. Do not pre-analyze what might break.

## Hardware

### Frame & Motion

- Extrusion: 2020 aluminum rails, covered in CNC-finished wood panels
- Y axis span: 385 mm between rail midpoints
- X axis span: 320 mm between rail midpoints
- Available stock: 2020 rails (1 m lengths, cuttable)
- Linear rails: 8 mm round rod — 362 mm and 405 mm lengths
- Bearings: RJ4JP-01-08 solid polymer dry bearings (LM8UU footprint) — **no lubrication required or desired**
- Lead screws: T8, 350 mm
- Timing belts: 760-2GT (760 mm × 2 mm pitch); meters of open-ended 2GT belt available, can be cut to size
- Target build volume: TBD — X and Y span describe frame geometry, not usable print area; Z height is not yet finalized. Z travel is limited by the 350 mm T8 lead screws minus coupler and nut clearance. Ask the user for confirmed build volume targets before any calculations that depend on them.

### Toolhead & Thermal

Toolhead selection is TBD. Ask the user before assuming hotend model, extruder type (direct drive vs. Bowden), heated bed dimensions and voltage, part-cooling fan, or thermistor types.

The toolhead and heated bed will be based on the Creality K1 and K2 as much as possible and practical. Known so far:
- The heated bed will be mounted on 3 points — preferably 1 in back and 2 in front. All three mounting points will be connected via synchronized lead screws and a single motor.
- X and Y homing can use built-in resistance sensing from the TMC2209, but that sensing isn't fine enough for Z axis; a Z homing plan is TBD.

### Electronics

| Component | Part |
|-----------|------|
| Main board | BTT SKR v2 |
| SBC | Raspberry Pi 4 |
| Screen | BTT TFT24 v1.1 |
| Power supply | 24 V |
| Wireless | ESP8266 (WAP via custom Pi HAT) |
| Motor drivers | TMC 2209 |
| Motors | Nema 17, 2A |

### Custom Pi HAT

- Supplies power to a CPU cooling fan
- Hosts an ESP8266 that creates a local Wi-Fi access point with a captive portal to collect the user's home Wi-Fi credentials

### Connectivity

- External USB headers connected directly to the Raspberry Pi

## Software & Firmware Stack

- **Firmware**: Marlin (configured for BTT SKR v2 + CoreXY kinematics)
- **Host software**: OctoPrint on Raspberry Pi 4
- **WAP / captive portal**: runs on ESP8266 via custom Pi HAT
- **3D models**: OpenSCAD

## Reference Codebase

The completed cartesian-style printer project lives at `/Users/costmo/Documents/dev/printing/gitHub/printerx`. Always check it for prior art before creating new designs, firmware configs, or software.

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

Notable root-level `.scad` files in printerx (useful as dimensional/structural references):
- `Shared-modules.scad` — shared module library (always consult first)
- `Bottom frame.scad` — base frame (reused in this CoreXY build)
- `X axis carriage.scad`, `X ends.scad`, `Y belt retainer.scad`, `Y belt tensioner.scad`, `Y carriage bearing retainer.scad`, `Z axis frame brace.scad`, `Z axis motor mount.scad`, `Z axis retainer block.scad`
- `SK8 Tower.scad`, `Fan shroud.scad`, `ESP mount.scad`, `Camera mount.scad`

## Constraints

- Hardware dimensions in this project take precedence over the reference project wherever they differ
- CoreXY kinematics differ from the cartesian reference — do not copy X/Y motion config verbatim
- Pin assignments, driver type definitions, thermistor tables, and power supply voltage settings are safe to reuse from the reference. Stepper currents, microstepping, steps/mm, acceleration, and jerk must be recalculated for CoreXY
- RJ4JP-01-08 bearings are dry — never suggest or add lubrication to any design
- If the user explicitly requests something that violates a stated constraint, refuse and briefly explain which constraint applies and why, then offer a compliant alternative
- For topics outside the project scope (slicer profiles, filament selection, enclosure thermals), note they are out of scope and answer only with general best-practice caveats, or ask the user to confirm they want guidance anyway

## Working Style

- When something breaks because of a change, the user will say so. Fix it then.
- One instruction = one change = one test. No unsolicited additions.

## Approach

1. For hardware/OpenSCAD work: read `printerx/Shared-modules.scad` first to understand shared conventions
2. For firmware work: read the reference Marlin config, then adapt for CoreXY kinematics
3. For WAP/software work: read `printerx/WAP/` before writing new code
4. If the reference codebase path is inaccessible or an expected file is missing, inform the user and ask whether to proceed without the reference rather than guessing at conventions
5. Always prefer reusing owned hardware dimensions before suggesting new purchases
6. If a widely-available alternative (stocked by major 3D printing suppliers such as Misumi, Openbuilds, or Amazon) would improve a key metric (rigidity, print volume, accuracy) by at least 20%, note it alongside the owned-hardware solution

## Development Conventions

- OpenSCAD models should follow the patterns and shared-module conventions established in `printerx/Shared-modules.scad`
- Firmware changes must target the BTT SKR v2 board and 24 V supply; cross-reference `printerx/Marlin firmware/` for the prior working configuration
- WAP / captive-portal code lives separately from OctoPrint plugins; see `printerx/WAP/` for the existing implementation
- Models live under `models/` in the workspace, organized by part name: `models/[Part Name]/[part-name].scad`
