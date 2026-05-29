# Printery — CoreXY 3D Printer Build

## Project Overview

This project documents and implements a CoreXY 3D printer built from the ground up, reusing the bottom frame and most components from an existing cartesian-style printer. It spans hardware design, firmware configuration, and software implementation.

The reference cartesian printer project (hardware designs, Marlin firmware, OctoPrint config, WAP software) lives at `/Users/costmo/Documents/dev/printing/gitHub/printerx`. Consult that codebase for prior design decisions, OpenSCAD models, and configuration patterns before starting new work here.

## Hardware

### Frame

- Extrusion: 2020 aluminum rails, covered in CNC-finished wood panels
- Y axis span: 385 mm between rail midpoints
- X axis span: 320 mm between rail midpoints
- Available stock: 2020 rails (1 m lengths, cuttable)

### Motion System

- Type: CoreXY
- Linear rails: 8 mm round rod — 360 mm and 405 mm lengths
- Bearings: RJ4JP-01-08 solid polymer dry bearings (LM8UU footprint) — **no lubrication required or desired**
- Lead screws: T8, 350 mm
- Timing belts: 760-2GT (760 mm × 2 mm pitch)

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
- **3D models**: OpenSCAD (reference models in printerx codebase)

## Development Conventions

- OpenSCAD models should follow the patterns and shared-module conventions established in `printerx/Shared-modules.scad`
- Firmware changes must target the BTT SKR v2 board and 24 V supply; cross-reference `printerx/Marlin firmware/` for the prior working configuration
- WAP / captive-portal code lives separately from OctoPrint plugins; see `printerx/WAP/` for the existing implementation
- Hardware dimensions in this repo take precedence over the reference project wherever they differ
