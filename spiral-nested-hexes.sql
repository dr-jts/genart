-- ---------------------------------
-- Spiralling nested hexagons
--
-- psql -A -t -o spiral-nested-hexes.svg  < spiral-nested-hexes.sql
-- ---------------------------------

WITH
pos AS (SELECT  i, 
                100.0 + 3 * cos( i * pi() / 15.0 ) AS cx, 
                100.0 + 3 * sin( i * pi() / 15.0 ) AS cy, 
                i AS r 
  FROM generate_series(41, 1, -1) AS i(i)
),
box AS (SELECT i,
            --360 * random() AS hue,
            280 - (2 * i) AS hue,
            CASE i % 2
              WHEN 0 THEN 0
              ELSE 45.0 + (i / 3.0) END AS light,
            --50 * (i % 2) AS light,
            ST_MakePolygon( ST_MakeLine(
                ARRAY[  ST_Point(cx - r,  cy), 
                        ST_Point(cx - r * cos(pi()/3),  cy + r * sin(pi()/3) ), 
                        ST_Point(cx + r * cos(pi()/3),  cy + r * sin(pi()/3) ), 
                        ST_Point(cx + r,  cy), 
                        ST_Point(cx + r * cos(pi()/3),  cy - r * sin(pi()/3) ), 
                        ST_Point(cx - r * cos(pi()/3),  cy - r * sin(pi()/3) ), 
                        ST_Point(cx - r,  cy) 
                    ] )) AS geom
    FROM pos
),
shapes AS ( SELECT geom, svgShape( geom,
        style => svgStyle( 
                'fill', svgHSL( hue, 100, light ))
        ) AS svg
    FROM box
)
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#ffffff' 
                --'stroke', '#000000',
                --'stroke-width', '.04'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 1) )
  	) AS svg
  FROM shapes;
