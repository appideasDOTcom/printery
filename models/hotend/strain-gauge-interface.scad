/**
 * strain-gauge-interface.scad
 *
 * Interface between the strain gauge and extruder frame.
 *
 * Example model - to be milled from aluminum.
 */

include <../common/shared-dims.scad>

_sgi_constructed_body();

module _sgi_constructed_body() {

	difference() {
		{
			_sgi_main_body();
		}
		{
			_sgi_throughholes();
			_sgi_extruder_mount_throughholes();
			_sgi_extruder_mount_nut_trap();
			_sgi_front_cutout();
		}
	}

}


module _sgi_main_body() {
	cube( [sgi_width, sgi_depth, sgi_height] );

}

module _sgi_front_cutout() {
	_x_offset = ((sgi_width - sgi_fc_width) /2 );
	translate( [_x_offset, -1, -1] ) cube( [sgi_fc_width, sgi_fc_depth + 1, sgi_height + 2] );

}

module _sgi_extruder_mount_throughholes() {
	_x_offset = ((sgi_width - sgi_em_throughhole_width) /2 );
	_y_offset = 2;
	translate([ _x_offset, sgi_depth/2 - _y_offset, -1 ]) cylinder( d = sgi_tm_throughhole_diameter, h = sgi_height + 2);
	translate([ sgi_width - _x_offset, sgi_depth/2 - _y_offset, -1 ]) cylinder( d = sgi_tm_throughhole_diameter, h = sgi_height + 2);

}

module _sgi_extruder_mount_nut_trap() {

	// cylinder(d = m3_nut_corner_dia, h = _rmb_nut_depth + _rmb_nut_over, $fn = 6);
	_x_offset = ((sgi_width - sgi_em_throughhole_width) /2 );
	_y_offset = 2;
	translate([ _x_offset, sgi_depth/2 - _y_offset, -1.5 ]) rotate([0, 0, 90] )  cylinder( d = m3_nut_corner_dia + 0.4, h = m3_nut_depth, $fn = 6);
	translate([ sgi_width - _x_offset, sgi_depth/2 - _y_offset, -1.5 ]) rotate([0, 0, 90] ) cylinder( d = m3_nut_corner_dia + 0.4, h = m3_nut_depth, $fn = 6);

}

module _sgi_throughholes() {

	_X_offset = ((sgi_width - sgi_tm_throughhole_grid_width) / 2);
	_y_offset = ((sgi_depth - sgi_tm_throughhole_grid_depth) / 2);

	// Filament - unicorn heatbreak tube.
	translate([ (sgi_width/2), (sgi_depth/2), -1 ]) cylinder( d = sgi_tm_throughhole_diameter, h = sgi_height + 2);

	// Top-mount interface through-holes.
	// #translate( [_X_offset, _y_offset, -1] ) cube( [sgi_tm_throughhole_grid_width, sgi_tm_throughhole_grid_depth, sgi_height + 2] );
	// Bottom mounting holes are inset 1mm compared to the top.
	for( _pos = [
			[_X_offset + 0.5, _y_offset],
			[_X_offset + sgi_tm_throughhole_grid_width - 0.5, _y_offset],
			[_X_offset, _y_offset + sgi_tm_throughhole_grid_depth],
			[_X_offset + sgi_tm_throughhole_grid_width, _y_offset + sgi_tm_throughhole_grid_depth]
		] ) {
		translate( [_pos[0], _pos[1], -1] ) cylinder( d = sgi_tm_throughhole_diameter, h = sgi_height + 2);
		translate( [_pos[0], _pos[1], 0] ) _sgi_countersink();
	}

}

// Conical countersink opening at the top surface (z = sgi_height).
// Tapers from the through-hole diameter up to the head opening over m3_cs_depth.
module _sgi_countersink() {
	_over = 0.2;   // break the top surface cleanly
	// Cone bottom sits at the through-hole diameter, opens to head dia at the top.
	translate( [0, 0, sgi_height - m3_cs_depth] )
		cylinder(
			h  = m3_cs_depth + _over,
			d1 = sgi_tm_throughhole_diameter,
			d2 = m3_cs_head_dia + 2 * _over * (m3_cs_head_dia - sgi_tm_throughhole_diameter) / (2 * m3_cs_depth)
		);
}
