# Marlin Configuration

Apply this skill whenever a task involves editing `Configuration.h` or `Configuration_adv.h`, setting any `#define` in Marlin, selecting a motherboard/driver/display/sensor, calibrating steps/mm or PID values, enabling/disabling features, or resolving build errors from conflicting defines.

## Mandatory Workflow

Follow these steps in order for every configuration task:

1. **Read the target section first.** Read the relevant region of `Configuration.h` or `Configuration_adv.h` before making any change. Never edit blindly.
2. **Identify the exact `#define` to change.** Grep for the define name to find its current value and line number.
3. **Check for dependencies.** Some defines require or conflict with others. Search for related defines before committing.
4. **Cross-reference the printerx working config.** Read the same define in `/Users/costmo/Documents/dev/printing/gitHub/printerx/Marlin firmware/` as a reference for the same board.
   - **Safe to carry forward:** pin assignments, driver type definitions, thermistor tables, power supply voltage settings
   - **Must recalculate for CoreXY:** stepper currents, microstepping, steps/mm, acceleration, jerk — do not copy these verbatim
5. **Make the targeted edit.** Change only the specific line(s) needed. Do not reformat surrounding code.
6. **Verify no new conflicts** by re-reading the surrounding context after editing.

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
- Steps/mm, acceleration, and jerk from the cartesian reference are **not valid** for CoreXY and must be recalculated.

## References

- Marlin docs: https://marlinfw.org/docs/configuration/configuration.html
- BTT SKR v2: https://github.com/bigtreetech/SKR-2
- BTT TFT24: https://github.com/bigtreetech/BIGTREETECH-TFT24-V1.1
- Teaching Tech calibration: https://teachingtechyt.github.io/calibration.html
