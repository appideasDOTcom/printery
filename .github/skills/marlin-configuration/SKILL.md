---
name: marlin-configuration
description: Provides instructions for reading, editing, and validating Marlin firmware configuration files for the CoreXY printery build (BTT SKR v2, TMC2209, 24 V). Use this skill for any task involving board selection, stepper driver setup, motion settings, display configuration, endstops, or TMC driver tuning. NOTE: This skill is a placeholder — content will be expanded as the firmware configuration work begins.
---

# Marlin Configuration Skill

> **Status:** Placeholder. This skill will be expanded once firmware configuration work begins for the CoreXY build. The reference below covers the mandatory workflow and key context; specific values and defines will be added as they are confirmed.

## When to Use This Skill

Apply this skill whenever a task involves:
- Editing `Configuration.h` or `Configuration_adv.h`
- Setting or changing any `#define` in Marlin
- Selecting a motherboard, driver type, display, or sensor
- Calibrating steps/mm, feedrates, acceleration, or PID values
- Enabling or disabling Marlin features (e.g., ABL, linear advance, S-curve)
- Resolving build errors caused by conflicting defines

---

## Mandatory Workflow

Follow these steps in order for every configuration task:

1. **Read the target section first.** Use `read_file` on the relevant region of `Configuration.h` or `Configuration_adv.h` before making any change. Never edit blindly.
2. **Identify the exact `#define` to change.** Use `grep_search` with the define name to find its current value and line number.
3. **Check for dependencies.** Some defines require or conflict with others. Search for related defines before committing.
4. **Cross-reference the printerx working config.** Read the same define in `/Users/costmo/Documents/dev/printing/gitHub/printerx/Marlin firmware/` as a reference for the same board. Pin assignments, driver type definitions, thermistor tables, and power supply voltage settings are safe to carry forward. Stepper currents, microstepping, steps/mm, acceleration, and jerk must be recalculated for CoreXY — do not copy these verbatim.
5. **Make the targeted edit.** Change only the specific line(s) needed. Do not reformat surrounding code.
6. **Verify no new conflicts** by re-reading the surrounding context after editing.

---

## Board & Build Context

| Item | Value |
|---|---|
| Motherboard | BTT SKR v2 |
| Kinematics | CoreXY |
| Motor drivers | TMC 2209 |
| Power supply | 24 V |
| Display | BTT TFT24 v1.1 |
| SBC | Raspberry Pi 4 (OctoPrint) |

- Use `TMC2209` (not `TMC2209_STANDALONE`) to enable UART communication and full software control.
- CoreXY kinematics require `COREXY` defined in `Configuration.h`. Do not use cartesian X/Y motion config from the printerx reference.
- Steps/mm, acceleration, and jerk values from the cartesian reference are **not valid** for CoreXY and must be recalculated.

---

## Online Reference Sources

- **Marlin docs:** https://marlinfw.org/docs/configuration/configuration.html
- **BTT SKR v2 GitHub:** https://github.com/bigtreetech/SKR-2
- **BTT TFT24 GitHub:** https://github.com/bigtreetech/BIGTREETECH-TFT24-V1.1
- **Teaching Tech calibration:** https://teachingtechyt.github.io/calibration.html
