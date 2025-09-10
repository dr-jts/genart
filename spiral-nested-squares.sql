-- ---------------------------------
-- Spiralling nested squares
--
-- psql -A -t -o spiral-nested-squares.svg  < spiral-nested-squares.sql
-- ---------------------------------

WITH
pos AS (SELECT  i, 
                100.0 + 4 * cos( i * pi() / 15.0 ) AS cx, 
                100.0 + 4 * sin( i * pi() / 15.0 ) AS cy, 
                i AS r 
  FROM generate_series(60, 1, -1) AS i(i)
),
box AS (SELECT i,
            --360 * random() AS hue,
            200 + (i / 1.0) AS hue,
            CASE i % 2
              WHEN 0 THEN 0
              ELSE 45.0 + (i / 2.0) END AS light,
            --50 * (i % 2) AS light,
            ST_MakePolygon( ST_MakeLine(
                ARRAY[  ST_Point(cx + r,  cy + r), 
                        ST_Point(cx - r,  cy + r), 
                        ST_Point(cx - r,  cy - r), 
                        ST_Point(cx + r,  cy - r), 
                        ST_Point(cx + r,  cy + r) 
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
                'background-color', '#000000' 
                --'stroke', '#000000',
                --'stroke-width', '.04'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 1) )
  	) AS svg
  FROM shapes;
