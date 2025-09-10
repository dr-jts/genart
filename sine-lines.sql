-- ---------------------------------
-- Sine Lines
--
-- psql -A -t -o sine-lines.svg  < sine-lines.sql
-- ---------------------------------

WITH
xy AS (SELECT  x, y, 
                x / 30.0 AS cx, 
                y + sin( (1.0 * x) / (4.0 * y) ) AS cy
  FROM  generate_series(0, 1000) AS x(x), 
        generate_series(1, 30) AS y(y)
),
lines AS (SELECT y,
            ST_MakeLine( ST_Point( cx, cy ) ORDER BY x ) AS geom
    FROM xy
    GROUP BY y
),
shapes AS ( SELECT geom, svgShape( geom ) AS svg
    FROM lines
)
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#ffffff',
                'stroke', '#ff0000',
                'stroke-width', '.1'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 1) )
  	) AS svg
  FROM shapes;
