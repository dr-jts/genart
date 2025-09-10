-- ---------------------------------
-- Spiral Sine Curve
--
-- psql -A -t -o spiral-sine.svg  < spiral-sine.sql
-- ---------------------------------

WITH
polar AS (SELECT  i, 
                i * 0.01 AS ang, 
                i * 0.005 + 0.01 * (i ^ 0.6) * sin(1.005 * i * 0.2) AS r
  FROM  generate_series(0, 20000) AS inc(i)
),
xy AS (SELECT i, 
        r * cos(ang) AS cx, 
        r * sin(ang) AS cy FROM polar
),
lines AS (SELECT 
            ST_MakeLine( ST_Point( cx, cy ) ORDER BY i ) AS geom
    FROM xy
),
shapes AS ( SELECT geom, svgShape( geom ) AS svg
    FROM lines
)
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#ffffff',
                'stroke', '#0000ff',
                'stroke-width', '1'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 1) )
  	) AS svg
  FROM shapes;
