// ============================================================
// Pulley Spacer
// Cylindrical spacer for GT2 pulley stacks on motion system
// ============================================================

$fa = 1.0;
$fs = 0.1;

// --- Dimensions (mm) ---
outer_dia = 10.0;
bore_dia  = 5.4;

// --- Modules ---

module pulley_spacer(height) {
    difference() {
        cylinder(h = height, d = outer_dia);
        translate([0, 0, -1])
            cylinder(h = height + 2, d = bore_dia);
    }
}

// --- Output ---
// pulley_spacer(height = 5);
pulley_spacer(height = 1.2);
// pulley_spacer(height = 10.0);
