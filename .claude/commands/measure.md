# OpenSCAD Measurement

Use this skill whenever asked for a concrete dimensional value from any `.scad` model — Z positions, heights, offsets, spans, or any derived value that comes from expressions across multiple files.

## Mandatory Procedure

Never derive measurements by doing arithmetic over source files by hand. Always use the OpenSCAD CLI to echo the computed value directly.

### Steps

1. Identify every `.scad` file involved in the expression (the model file, any `include`d dims files, any `use`d modules that contribute geometry).
2. Write a minimal throwaway `.scad` snippet that `include`s the relevant dims file(s) and `echo`s the value(s) in question.
3. Run it:
   ```bash
   openscad -o /dev/null --export-format echo /tmp/measure.scad 2>&1 | grep ECHO
   ```
4. Report the value from the CLI output, not from mental arithmetic.

### Example

To find the top Z of the front crossbar wall in `top-frame.scad`:

```scad
// /tmp/measure.scad
include <../models/common/shared-dims.scad>

_cb_sled_z = (pb_lower_top_z + pb_upper_bot_z) / 2 - (rj_base_y + 2) / 2;
_cb_z      = _cb_sled_z + 31 - 2 - 12.2;
wall_top   = _cb_z + 14.2;

echo("crossbar wall top Z =", wall_top);
echo("sled top Z =", _cb_sled_z + 31);
```

```bash
openscad -o /dev/null --export-format echo /tmp/measure.scad 2>&1 | grep ECHO
```

## Why

Mental arithmetic across multiple `include` chains produces wrong answers. The CLI is the ground truth — it uses the same evaluation path OpenSCAD uses when rendering.
