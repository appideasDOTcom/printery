/**
 * strain-gauge-interface.scad
 *
 * Interface between the strain gauge and extruder frame.
 *
 * Example model - to be milled from aluminim
 */

include <../common/shared-dims.scad>

// Overall piece dimensions.
_sgi_height = 3.2;
_sgi_depth = 25.4;
_sgi_width = 50;

// Top-mount M3 bolt pass-through (2x2 grid).
_sgi_tm_throughhole_grid_width = 32;
_sgi_tm_throughhole_grid_depth = 16;
_sgi_tm_throughhole_diameter = m3_through_dia;

// Extruder mount bolt pass-through.
_sgi_em_throughhole_width = 43;

// Extruder mounting nut;

_sgi_constructed_body();

module _sgi_constructed_body() {

	difference() {
		{
			_sgi_main_body();
		}
		{
			_sgi_throughholes();
			_sgi_extruder_mount_throughholes();
			// _sgi_extruder_mount_nut_trap();
		}
	}

}


module _sgi_main_body() {
	cube( [_sgi_width, _sgi_depth, _sgi_height] );

}

module _sgi_extruder_mount_throughholes() {
	_x_offset = ((_sgi_width - _sgi_em_throughhole_width) /2 );
	translate([ _x_offset, _sgi_depth/2, -1 ]) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);
	translate([ _sgi_width - _x_offset, _sgi_depth/2, -1 ]) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);

}

module _sgi_extruder_mount_nut_trap() {

	// cylinder(d = m3_nut_corner_dia, h = _rmb_nut_depth + _rmb_nut_over, $fn = 6);
	_x_offset = ((_sgi_width - _sgi_em_throughhole_width) /2 );
	translate([ _x_offset, _sgi_depth/2, -1 ]) cylinder( d = m3_nut_corner_dia + 0.4, h = m3_nut_depth, $fn = 6);
	translate([ _sgi_width - _x_offset, _sgi_depth/2, -1 ]) cylinder( d = m3_nut_corner_dia + 0.4, h = m3_nut_depth, $fn = 6);

}

module _sgi_throughholes() {

	_X_offset = ((_sgi_width - _sgi_tm_throughhole_grid_width) / 2);
	_y_offset = ((_sgi_depth - _sgi_tm_throughhole_grid_depth) / 2);

	// Filament - unicorn heatbreak tube.
	translate([ (_sgi_width/2), (_sgi_depth/2), -1 ]) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);

	// Top-mount interface through-holes.
	// #translate( [_X_offset, _y_offset, -1] ) cube( [_sgi_tm_throughhole_grid_width, _sgi_tm_throughhole_grid_depth, _sgi_height + 2] );
	translate( [_X_offset, _y_offset, -1] ) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);
	translate( [_X_offset + _sgi_tm_throughhole_grid_width, _y_offset, -1] ) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);
	translate( [_X_offset, _y_offset + _sgi_tm_throughhole_grid_depth, -1] ) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);
	translate( [_X_offset + _sgi_tm_throughhole_grid_width, _y_offset + _sgi_tm_throughhole_grid_depth, -1] ) cylinder( d = _sgi_tm_throughhole_diameter, h = _sgi_height + 2);

}
