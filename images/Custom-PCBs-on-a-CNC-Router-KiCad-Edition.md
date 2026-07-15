# Custom PCBs on a CNC Router — KiCad Edition

*A drop-in replacement for the Fritzing + FlatCAM half of the original Instructable. Everything downstream of "export the files" — mounting the stock, zeroing the Z axis with a multimeter, running the jobs, extricating the board — is identical to what you already do, so this guide focuses on the two pieces that change: **designing in KiCad** instead of Fritzing, and **generating gcode with pcb2gcode** instead of FlatCAM.*

---

## What changed, and why

Two tools get swapped. The design tool and the gerber-to-gcode tool. The router workflow does not change at all.

**Fritzing → KiCad.** KiCad is free, open source, cross-platform, and — unlike Eagle/Fusion — nobody is going to yank the license out from under hobbyists. It is a genuine step up from Fritzing: a real schematic editor, a real router, and a proper design-rule system. The latest release as of this writing is **KiCad 10.0.4** (the 10.0 series shipped March 2026; 10.0.4 is the current bug-fix release). The design → plot gerbers → generate drill files flow described here is stable across KiCad 7, 8, 9, and 10, so this will keep working through minor updates.

**FlatCAM → pcb2gcode.** This is the important one for you, because you're on macOS and FlatCAM on a Mac is the miserable virtual-machine dance the original guide complained about. `pcb2gcode` is a command-line gerber-to-gcode tool that installs natively on macOS with one Homebrew command, is open source, and — this is the part you'll love — stores **all** of its settings in a single plain-text `millproject` file. That means your "FlatCAM configuration" becomes a file you can version-control, diff, and drop next to any project. It maps perfectly onto your stated goal of *repeatability*: once the millproject is dialed in for your router and bits, converting a new design to gcode is literally one command. No clicking through dialogs, no "did I remember to set Travel Z again," no lost work because you forgot to save.

You're a software developer who already runs UGS on a Raspberry Pi. A CLI tool with a config file is not a downgrade for you — it's the natural home.

> **A note on GUIs.** If you ever want a graphical option, `pcb2gcodeGUI` exists, and **Carbide Copper** (a free browser-based tool from Carbide 3D) is the easiest zero-install path and handles full copper "rubout" nicely. But the command-line `pcb2gcode` + `millproject` combo is what this guide uses, because it's the most repeatable and the best fit for your setup.

The bits, stock, tape, multimeter, and router are all unchanged:

- **0.2 mm, 20°, V-shaped engraving bit** — isolation routing
- **0.5 mm straight bit** — drilling through-holes
- **1.5 mm straight bit** — clearing copper, drilling mounting holes, cutting the board out

---

## Step 1: Install the software

Three things: KiCad, pcb2gcode, and a gcode sender (you already have that).

### KiCad

Download the current release from **kicad.org/download** and install the macOS package (there are separate Apple-silicon and Intel builds — grab the one for your Mac). Open it once so it unpacks its libraries.

### pcb2gcode (via Homebrew)

If you don't already have Homebrew, install it from **brew.sh**. Then, in Terminal:

```bash
brew install pcb2gcode
```

That pulls in pcb2gcode and its dependencies (gerbv, boost, etc.) automatically. Verify it landed:

```bash
pcb2gcode --version
pcb2gcode --help | less
```

Keep that `--help` output handy. A few option names have drifted slightly between pcb2gcode's older and newer ("vectorial") cores, so if any parameter in the millproject below is rejected, `--help` (and the project wiki manual) will show the exact spelling for your installed build.

### A gcode sender

Whatever you already use — Universal Gcode Sender on the Pi is perfect. Nothing changes here.

---

## Step 2: Design the schematic in KiCad

This is the biggest philosophical change from Fritzing. In Fritzing you dragged parts onto a breadboard and skipped straight to the PCB view. KiCad wants you to draw a proper **schematic** first, then push that netlist into the board editor. It's one extra stage, but it's what gives you the design-rule checking and the "did I connect everything" safety net that Fritzing lacks. You've already made a layout and laid traces for your breakout board, so some of this will be familiar — here it is start to finish so nothing is missing.

1. **New project.** KiCad → *File → New Project*. Give it a folder. You get a `.kicad_sch` (schematic) and a `.kicad_pcb` (board) side by side.

2. **Open the Schematic Editor** and place your symbols. Press **A** (Add Symbol) or use the op-amp icon in the right toolbar. For your kind of project you'll pull in things like the ESP8266 module, a voltage regulator, capacitors, a terminal block, and pin headers. Use the search box; the built-in libraries are large. If a part doesn't exist, you can grab symbols from the KiCad libraries or make one, but for common breakout parts you'll usually find them.

3. **Wire them up.** Hover over a pin, press **W**, and draw wires between pins. Use **net labels** (press **L**) for power and ground instead of running long wires everywhere — label a wire `GND` or `+3V3` and every same-named label is connected. This is far cleaner than Fritzing's spaghetti.

4. **Assign footprints.** Each schematic symbol needs a physical footprint (the actual pads/holes on the board). Open *Tools → Assign Footprints*, or set the footprint in each symbol's properties. **This matters for milling:** pick **through-hole** footprints wherever you can. Through-hole parts are dramatically easier to solder on a single-sided milled board than surface-mount, and their larger pads are more forgiving of the ~0.68 mm isolation your V-bit leaves. For headers, use the THT pin-header footprints; for the regulator, a TO-220 THT footprint; and so on.

5. **Run ERC.** *Inspect → Electrical Rules Checker*. Fix anything real (unconnected pins you meant to connect, power pins with no source). This catches mistakes before you've cut a single board.

6. **Push to the board.** In the Schematic Editor, click **Update PCB from Schematic** (the icon that looks like a board with a curved arrow, or press **F8**). Your footprints arrive in the PCB Editor in a pile with thin "ratsnest" lines showing what connects to what.

---

## Step 3: Lay out and route the board

Now you're in the PCB Editor doing the part that most resembles Fritzing's PCB view — but with real tools.

### One-time board setup

Before routing, tell KiCad you're building a chunky single-sided board so its rules agree with reality.

- **Board Setup → Design Rules → Constraints / Net Classes.** Set a generous default **track width**. Your Fritzing rule of thumb was 48 mil (~1.2 mm) traces because thicker is better on a milled board — do the same here. Set the Default net class track width to around **1.0–1.2 mm** and clearance to at least **0.4–0.5 mm** so adjacent traces leave room for the isolation channel. Wider traces and clearances = fewer near-misses your 0.2 mm bit can't resolve.
- **Layers.** A single-sided milled board uses **one** copper layer. Keep the default two-layer stackup — you just won't route on the unused one.

### Which copper layer to route on (the mirroring question)

Same issue you solved in FlatCAM with "Mirror on Y." Here's the clean rule:

- **Route your traces on the bottom copper layer, `B.Cu`.** This is the traditional single-sided convention: components sit on top, copper and solder joints on the bottom.
- When you generate gcode later, you'll hand pcb2gcode the `B.Cu` gerber as the **back** layer, and pcb2gcode mirrors it automatically — exactly like FlatCAM's "Mirror on Y" step. You place the copper-clad stock **copper-side up**, mill, and the result comes out correctly oriented.

> *Alternative, if you prefer "what I see is what gets cut":* route on the top layer `F.Cu`, mount components on the copper side, and later feed pcb2gcode the gerber as the **front** layer (no mirror). Both work. The `B.Cu` + mirror approach matches your existing mental model, so this guide assumes it.

At the bottom of the PCB Editor, set the **active layer** to `B.Cu` so every trace you draw lands there.

### Placement and routing

1. **Place footprints.** Same advice as the original: grab your most awkward / largest / most-connected part (the ESP8266 module), drop it near the middle, and arrange everything else around it based on where power, ground, and I/O need to go. Press **M** to move, **R** to rotate.

2. **Draw the board outline.** Switch the active layer to **`Edge.Cuts`** and draw the rectangle (or whatever shape) that defines the physical board — this is your bounding box **and** your cutout line in one. Use the graphic-line tool. Leave a few millimetres of margin around your parts. Make sure it's a **closed** loop with no gaps, or the cutout step will misbehave.

3. **Route traces.** Back on `B.Cu`, press **X** and draw copper between the pads that the ratsnest says should connect. KiCad's push-and-shove router will help keep things tidy. Route until there are no ratsnest lines left. If two traces have to cross, that's your cue to move a component — same as before.

4. **Mounting holes (optional, recommended).** Place `MountingHole` footprints (press **A**, search "MountingHole") at the corners — the **3.2 mm** variant matches your M3 habit. Good news: the copper-ring trick you did in Fritzing to make the bounding box and copper region line up is **no longer necessary**. In this workflow the `Edge.Cuts` outline *is* the boundary, and pcb2gcode handles the cutout from it directly. Just place plain mounting holes where you want them.

5. **Run DRC.** *Inspect → Design Rules Checker*. Fix violations (traces too close, unconnected items). This is the KiCad equivalent of Fritzing's Design Rules Check, and it's stricter and more useful.

6. **Fill zones if you used any.** If you added a copper pour, refill it (**B**). For a plain single-sided breakout you probably didn't, and that's fine.

---

## Step 4: Export gerber and drill files from KiCad

This replaces "Export for PCB → Extended Gerber" in Fritzing. You need exactly **three** things for milling: the copper layer, the board outline, and the drill file.

1. In the PCB Editor: **File → Fabrication Outputs → Gerbers (.gbr)…** (In some builds this is simply *File → Plot* — same dialog.)

2. **Output directory:** make a dedicated folder for this board's gerbers. You'll run pcb2gcode from here.

3. **Select layers** (left side). For single-sided milling you only need:
   - **`B.Cu`** (your copper — traces and pads)
   - **`Edge.Cuts`** (the board outline / cutout)

   You can ignore mask, silk, and paste layers — the router doesn't cut those. (If you routed on `F.Cu` instead, select that.)

4. **General options:** using **Protel filename extensions** is convenient (it gives `B.Cu` the `.gbl` extension, `Edge.Cuts` the `.gm1`/`.gko` extension — easy to spot). Leave the defaults otherwise.

5. Click **Plot**. If KiCad warns about out-of-date zone fills, click **Refill** and continue.

6. **Drill file:** in the same dialog, click **Generate Drill Files…**. Set:
   - **Drill file format: Excellon**
   - **Units: Millimeters**
   - **Zeros format: Decimal**
   - **Drill origin: Absolute**
   - **Merge PTH and NPTH into one file: checked** (you want a single drill file for the router)

   Click **Generate Drill File**, then close both dialogs.

7. **Set a sane origin (do this once, ideally before plotting).** Use **Place → Drill/Place File Origin** and click the **lower-left corner** of your board outline. This makes the drill and gerber coordinates start near (0,0) at the bottom-left, which keeps your router out of negative-coordinate territory and makes zeroing predictable. If you forget, pcb2gcode's `zero-start` option (below) cleans it up anyway.

When you're done you should have three files in the folder, e.g.:

```
myboard-B_Cu.gbl        <- copper (traces + pads)
myboard-Edge_Cuts.gm1   <- board outline
myboard.drl             <- drill (Excellon)
```

That's the KiCad equivalent of the "keep only `_copperBottom.gbl`, `_drill.txt`, `_maskBottom.gbs`" cleanup from the original — except here you never generate the junk in the first place, and you don't need a mask layer because pcb2gcode derives everything it needs from the copper and outline.

---

## Step 5: Configure pcb2gcode (your new "FlatCAM settings")

This is the analog of the long "Configure FlatCAM" step — except instead of clicking through a hundred fields, you write them down once in a `millproject` file. Do this **once**, keep the file, and reuse/tweak it forever.

Create a file named **`millproject`** (no extension) **in the same folder as your gerbers**. pcb2gcode reads it automatically when you run the command from that folder. Here's a complete starting configuration tuned to your bits, your metric preference, and a **GRBL** controller (which is what BobsCNC-class routers use):

```ini
# ================= millproject =================
# Run pcb2gcode from the folder that contains this file and your gerbers.

# ---- Input files (match your KiCad export filenames) ----
back=myboard-B_Cu.gbl          # copper layer, routed on B.Cu -> mirrored automatically
outline=myboard-Edge_Cuts.gm1  # board outline / cutout
drill=myboard.drl              # Excellon drill file

# ---- Global / controller ----
metric=true                    # all values below are in millimeters
metricoutput=true              # emit metric gcode
nog81=true                     # GRBL-friendly: no G81 canned drill cycle
zero-start=true                # shift so the job starts at (0,0), positive quadrant
zsafe=2                        # rapid/travel height above the board (mm)
zchange=5                      # height for tool changes (mm) -- keep this generous
spinup=1                       # dwell (s) to let the spindle come up to speed

# ---- Isolation routing (your 0.2 mm 20-degree V-bit) ----
mill-diameters=0.2             # tool diameter (mm)
milling-overlap=50%            # overlap between passes
extra-passes=4                 # widens the isolation channel (~5 passes total, like your FlatCAM setup)
zwork=-0.15                    # engraving depth into copper (start here; -0.20 to -0.25 if your bed varies)
mill-feed=200                  # X/Y feed for engraving (mm/min) -- keep it gentle for a tiny V-bit
mill-vertfeed=100              # plunge feed (mm/min)
mill-speed=30000               # spindle RPM (ignored by GRBL unless it controls the spindle)

# ---- Drilling (your 0.5 mm straight bit; mounting holes milled with the big bit) ----
zdrill=-1.7                    # ~0.1 mm past the back of the board (measure your stock!)
drill-feed=150                 # plunge feed for the fragile 0.5 mm bit (mm/min)
drill-speed=30000
zchange=5
milldrill=true                 # holes too big for the drill bit get MILLED instead of drilled
milldrill-diameter=1.5         # use the 1.5 mm bit to mill the large (mounting) holes

# ---- Board cutout (your 1.5 mm straight bit) ----
cutter-diameter=1.5
zcut=-1.7                      # cut all the way through, slightly past the board
cut-feed=350                   # X/Y feed for the sturdy 1.5 mm bit (mm/min)
cut-infeed=0.4                 # depth per pass -- your "Depth/pass 0.4" multi-depth setting
cut-speed=30000
# bridges=0                    # you use double-sided tape, so no holding tabs are needed
# ===============================================
```

### What each block is doing (and how it maps to your FlatCAM knowledge)

- **`metric` / `metricoutput`** — the "PLEASE switch to mm" step. Non-negotiable, and you already agree.
- **`nog81`** — GRBL doesn't understand the `G81` drilling cycle. This flag makes pcb2gcode emit plain `G0`/`G1` moves instead so your controller is happy. If you had a LinuxCNC/Mach controller you could drop this, but for GRBL leave it on.
- **`zsafe` / `zchange`** — the exact same lesson you learned the hard way in FlatCAM ("Travel Z: 5.0… because it scares me"). `zsafe` is your travel height; `zchange` is how high it lifts to swap tools. Generous values, cheap insurance against broken bits.
- **`extra-passes`** — this is your "Width (# passes): 5." Each extra pass widens the isolation channel by roughly half the tool width. Start at 4 and adjust: more passes = wider gaps between copper (easier soldering, less short risk) but longer runtime.
- **`zwork` = -0.15** — your "Geometry → Cut Z: -0.25/-0.15." A typical copper layer is ~0.035 mm, but you go deeper to compensate for an imperfect bed. Start at -0.15; if the outline test (Step 6/the router step) doesn't clear copper all the way around, either nudge this to -0.2/-0.25 **or**, better, adjust the Z-zero on the machine and re-run the test — same as you do today.
- **`milldrill` + `milldrill-diameter`** — this elegantly solves your "mounting holes are too big for the 0.5 mm bit, so I drill in two phases" problem. Any hole at or below the drill bit size gets drilled with the 0.5 mm bit; anything bigger (your M3 mounting holes) gets **milled** with the 1.5 mm bit automatically. One config, no manual two-phase juggling.
- **`cut-infeed` = 0.4** — your "Multi-Depth → Depth/pass: 0.4." Takes the cutout down in 0.4 mm bites instead of one deep plunge, which is what keeps you from snapping the 1.5 mm bit.
- **`bridges`** — left off, because your hold-down is double-sided tape, so you don't need holding tabs. (If you ever switch to a clamp-only setup, set `bridges` and `bridgesnum` to leave small tabs.)

Because you routed on `B.Cu` and fed it as **`back=`**, pcb2gcode mirrors it on the Y axis for you. That's the entire "Double-Sided PCB Tool → Mirror Object" dance from the FlatCAM guide, reduced to one line.

> If pcb2gcode complains that an option name is unknown, run `pcb2gcode --help` and check the spelling for your installed version — a couple of these names differ slightly between the classic and vectorial cores (e.g. `mill-diameters` vs. an older `offset`-based syntax). The concepts are identical; only the keyword changes.

---

## Step 6: Generate the gcode

With the `millproject` and the three gerbers in one folder, `cd` into it and run:

```bash
cd /path/to/myboard-gerbers
pcb2gcode
```

That's it. pcb2gcode reads the millproject, parses the gerbers, and writes out a set of `.ngc` gcode files — one per operation. By default you'll get files along the lines of:

```
back.ngc        <- isolation routing (your 0.2 mm engraving pass)
drill.ngc       <- through-hole drilling (0.5 mm) + milled mounting holes (1.5 mm)
outline.ngc     <- board cutout (1.5 mm)
```

(You can control names/paths with output options; see `--help`. If you like your `01-`, `02-`… numbering scheme from the original guide for keeping run order straight, just rename the outputs after generating — `01-0.2mm-isolate.ngc`, `02-0.5mm-drill.ngc`, `03-1.5mm-cutout.ngc`.)

Mapping to your old seven-file workflow: pcb2gcode consolidates it. Isolation is one file, drilling (small holes + milled mounting holes) is one file, and the cutout is one file. The separate "outline test" passes you used to generate in FlatCAM aren't emitted as their own files — instead you do the depth test on the machine by running the **first inch or so** of the isolation file, or by jogging the bit around the board perimeter at cut depth before committing. More on that below.

**Preview before you cut.** Open the `.ngc` files in any gcode viewer (your UGS visualizer works, or **ncviewer.com** in a browser) and eyeball the toolpaths. Confirm the isolation surrounds your traces, the drill hits every pad, and the outline is where you expect. This is the cheap step that saves ruined boards.

### About clearing all the copper ("rubout")

Your FlatCAM workflow scraped away *all* the non-copper region with the 1.5 mm bit. pcb2gcode's default is **isolation only** — it cuts a channel around each trace and leaves the copper fields in between. For most boards this is actually the preferred modern approach: it's much faster, far easier on your bits, and the leftover copper is electrically harmless as long as the isolation channels fully separate your nets (verify with the multimeter, as always).

If you specifically want the clean, fully-cleared look you're used to, you have three options: (1) crank `extra-passes` way up so the channels widen toward each other and remove most of the field; (2) design an intentional ground pour in KiCad so the leftover copper is deliberate and grounded; or (3) for true wall-to-wall rubout with a GUI, run the same gerbers through **Carbide Copper** (free, browser-based, has a proper large-area rubout) — handy specifically for that one operation. For a simple breakout board, though, I'd try isolation-only first. You may never go back.

---

## Step 7: Cut it on the router — unchanged

From here, **everything is identical to your original Instructable.** Nothing about KiCad or pcb2gcode changes how the machine behaves. In brief, so this guide stands on its own:

1. **Mount the stock.** Two strips of Scotch/3M 15 lb outdoor double-sided tape (never one — it'll rock), copper-side **up**, lined up on your spoil-board reference lines. Press it down with a rag to keep skin oil off the copper.

2. **Load the 0.2 mm V-bit and zero.** Rough-in X/Y a few millimetres inside the board so FlatCAM-style origin creep doesn't cost you a corner. Then zero **Z** with the multimeter in continuity mode: clip one lead to the bit, touch the other to the copper, lower in 0.1 mm then 0.01 mm steps until you get a steady reading, and set that as Z-zero. Same trick, same precision.

3. **Test the depth, then isolate.** Run a quick perimeter/depth check at cut depth (jog around, or run the opening moves of the isolation file). If it doesn't cut copper all the way around, drop Z by 0.1 mm, re-zero, and re-test — exactly your old loop. When it's good, run **`back.ngc`** (isolation) start to finish.

4. **Swap to the 0.5 mm bit, re-zero Z, drill.** Run **`drill.ngc`**. It drills the small holes and mills the mounting holes in one file (thanks to `milldrill`). Watch the fragile bit; the low `drill-feed` is there to protect it.

5. **Swap to the 1.5 mm bit, re-zero Z, cut out.** Run **`outline.ngc`**. Multi-depth `cut-infeed` keeps the bit alive.

6. **Extricate and clean up.** Power off before your hands go anywhere near the head. Peel the waste copper first, then work the board loose with a screwdriver you *pull up on* (never pry against the bed). Clean any leftover copper slivers between traces with a rotary tool if you left rubout off, and knock down burrs gently with a buffing pad.

7. **Test every trace with the multimeter.** Continuity end-to-end on each net. Twenty seconds. Do it every time — you know why.

Then populate and solder. Done.

---

## Step 8: Revise, repeat — now even faster

Here's where the swap pays off. Your #1 goal was repeatability, and this toolchain nails it:

- **KiCad** keeps schematic and layout in sync. Change a value or move a part in the schematic, press **F8**, re-route the delta, re-run DRC. Version-to-version edits are a pleasure, not a from-scratch redo.
- **pcb2gcode** is one command against a config file you already trust. Re-export the three gerbers from KiCad, run `pcb2gcode`, and you have fresh gcode in seconds — no re-clicking a single setting. Commit your `millproject` to git next to the project and your "machine setup" travels with the design.

Iterating from v4 to v8 in an afternoon was already your reality with Fritzing + FlatCAM. With KiCad + pcb2gcode on macOS — no virtual machine, no lost work, a text-file config you can diff — it's smoother still.

---

## Quick reference

| Task | Old (Fritzing / FlatCAM) | New (KiCad / pcb2gcode) |
|---|---|---|
| Schematic | (skipped in Fritzing) | Schematic Editor → symbols, wire, footprints, ERC |
| Layout & route | Fritzing PCB view | PCB Editor → place, route on `B.Cu`, `Edge.Cuts` outline, DRC |
| Trace width | 48 mil | ~1.0–1.2 mm default net class |
| Mirror for milling | FlatCAM Double-Sided Tool, Mirror Y | `back=` in millproject (automatic) |
| Export | Export → Extended Gerber | File → Fabrication Outputs → Gerbers + Generate Drill Files |
| Files needed | `_copperBottom.gbl`, `_drill.txt`, `_maskBottom.gbs` | `B.Cu` gerber, `Edge.Cuts` gerber, `.drl` |
| Gerber → gcode config | Click through FlatCAM options | `millproject` text file |
| Generate gcode | 7 files, many clicks | `pcb2gcode` — one command, 3 files |
| Isolation width | Width (# passes): 5 | `extra-passes=4` |
| Drill deep | Cut Z: -1.7, multi-depth | `zdrill=-1.7`, `milldrill=true` |
| Cutout | 1.5 mm, depth/pass 0.4 | `cutter-diameter=1.5`, `cut-infeed=0.4` |
| Controller quirk | n/a | `nog81=true` for GRBL |
| Send to router | UGS on Raspberry Pi | UGS on Raspberry Pi (unchanged) |

---

*Software versions referenced: KiCad 10.0.4 (current stable, June 2026); pcb2gcode via Homebrew. Menu paths shown are stable across KiCad 7–10. If a pcb2gcode option name is rejected, confirm the spelling with `pcb2gcode --help` for your installed build.*
