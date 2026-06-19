// ============================================================
// Shapes
// Re-usable shapes
// ============================================================

// Concave quarter-cylinder fillet for rounding right angle junctions.
// Improves structural integrity and high speed print quality. Looks nicer, too.
// Place the origin at the corner, rotate to the target face, then union into the parent.
// d: fillet diameter (concave curve radius is d/2); l: length of the produced output.
module inner_fillet( d, l )
{
	xDimension = d;
	yDimension = d;
	zDimension = l;

	difference()
	{
		{
			translate( [(-1 * (xDimension / 2)), (-1 * (yDimension / 2)), 0] )
			{
				cube( [xDimension, yDimension, zDimension] );
			}
		}
		{
			translate( [ 0, 0, -1 ] )
			{
				translate( [0, (-1 * yDimension), 0] )
				{
					cube( [xDimension, yDimension * 2, (zDimension + 2)] );
				}
				translate( [(-1 * xDimension), 0, 0] )
				{
					cube( [xDimension, yDimension, (zDimension + 2)] );
				}

				linear_extrude( height=(zDimension + 2), twist=0, scale=[1, 1], center=false)
				{
					circle(r=(xDimension / 2));
				}

			}

		}

	}
}

// Example:
// inner_fillet( d = 10, l = 20 );