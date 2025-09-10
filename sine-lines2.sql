-- ---------------------------------
-- Sine Lines
--
-- psql -A -t -o sine-lines2.svg  < sine-lines2.sql
-- ---------------------------------

WITH
xy AS (SELECT  x, y, 
                x / 20.0 AS cx, 
                --y + sin( 3 + 1 / (.008 + (0.0001 * x ^ 0.5) ) ) AS cy
                y + sin( (1.0 * x) ^ 0.55 ) AS cy
  FROM  generate_series(1, 1000) AS x(x), 
        generate_series(1, 50) AS y(y)
),
lines AS (SELECT y,
            ST_MakeLine( ST_Point( cx, cy ) ORDER BY x ) AS geom
    FROM xy
    GROUP BY y
),
shapes AS ( SELECT geom, svgShape( geom ) AS svg
    FROM lines
)
--SELECT geom FROM shapes;
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#ffffff',
                'stroke', '#ff0000',
                'stroke-width', '.3'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), -.5) )
  	) AS svg
  FROM shapes;
