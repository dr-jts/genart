-- ---------------------------------
-- Spiralling nested N-gons
--
-- psql -A -t -o spiral-nested-polys.svg  < spiral-nested-polys.sql
-- ---------------------------------

WITH
pos AS (SELECT  i, 
                100.0 + 4 * cos( i * pi() / 15.0 ) AS cx, 
                100.0 + 4 * sin( i * pi() / 15.0 ) AS cy, 
                i AS r 
  FROM generate_series(61, 1, -1) AS i(i)
),
box AS (SELECT i,
            --360 * random() AS hue,
            280 - (2 * i) AS hue,
            CASE i % 2
              WHEN 0 THEN 0
              ELSE 45.0 + (i / 5.0) END AS light,
            --50 * (i % 2) AS light,
            ST_Buffer( ST_Point(cx,  cy), r, 20) AS geom
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
