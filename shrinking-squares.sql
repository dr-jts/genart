-- ---------------------------------
-- Op-Art: Shrinking Squares
--
-- psql -A -t -o shrinking-squares.svg  < shrinking-squares.sql
-- ---------------------------------

WITH
pos AS (SELECT x, y, 
                0.1 * x AS w
  FROM        generate_series(1, 10) AS x(x)
  CROSS JOIN  generate_series(1, 10) AS y(y)
)
SELECT svgDoc(  array_agg(
		              svgPolygon( ARRAY[ x + w, y,   x, y - w,   x - w, y,   x, y + w ]) ),
          style => svgStyle( 'background-color', '#0000ff', 'fill', '#000000' ),
  		    viewbox => '1 1 9 9'
  	) AS svg
  FROM pos;
