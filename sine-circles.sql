-- ---------------------------------
-- Sine Circles
--
-- psql -A -t -o sine-circles.svg  < sine-circles.sql
-- ---------------------------------

WITH
polar AS (SELECT  j, i,
                2.0 * pi() * i AS ang, 
                j + sin(30 * 2.0 * pi() * i + 5 * (j * 0.1) ^ 1) AS r
  FROM  generate_series(0.0, 1.0, 0.001) AS i(i), 
        generate_series(1, 60) AS j(j)
),
xy AS (SELECT j, i,
        r * cos(ang) AS cx, 
        r * sin(ang) AS cy FROM polar
),
circles AS (SELECT j,
            200 AS hue,
            50 + svgClamp(50 - j, 0, 50) AS light,
            ST_MakeLine( ST_Point( cx, cy ) ORDER BY i ) AS geom
    FROM xy
    GROUP BY j
),
shapes AS ( SELECT geom, svgShape( geom,
        style => svgStyle( 
                'stroke', svgHSL( hue, 80, light ))
         ) AS svg
    FROM circles
)
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#ffffff',
                --'stroke', '#0000ff',
                'stroke-width', '.2'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 1) )
  	) AS svg
  FROM shapes;
