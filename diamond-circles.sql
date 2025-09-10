-- ---------------------------------
-- Diamonds rotated around nested circles
--
-- psql -A -t -o diamond-circles.svg  < diamond-circles.sql
-- ---------------------------------

WITH
const AS (SELECT    radians(15) AS angDel,  -- alternate rings are offset 15 deg
                    sin(radians(135)) / sin(radians(30)) AS r2f,
                    1 + sqrt(2) * sin(radians(15)) / sin(radians(30)) AS r3f
),
param AS (SELECT ir, id, angDel,
                 id * radians(30) + (ir % 2) * angDel AS ang,
                 r2f ^ (ir - 1) AS r,
                 r2f ^ ir AS r2,
                 r2f ^ (ir-1) * r3f  AS r3
  FROM generate_series(1, 15) AS ir(ir),
       generate_series(1, 12) AS id(id),
       const
),
box AS (SELECT ir, id,
            -- H spirals CW against angle
            CASE (( (ir-1)/2 * 24 + id) % 23) % 2 WHEN 0 THEN 40 ELSE 200 END AS hue,
            -- L spirals CCW with angle
            CASE (id + ir / 2) % 2 WHEN 0 THEN 30 ELSE 60 END AS light,
            ST_MakePolygon( ST_MakeLine(
                ARRAY[  ST_Point( r  * cos(ang),           r  * sin(ang) ), 
                        ST_Point( r2 * cos(ang + angDel),  r2 * sin(ang + angDel) ), 
                        ST_Point( r3 * cos(ang),           r3 * sin(ang) ), 
                        ST_Point( r2 * cos(ang - angDel),  r2 * sin(ang - angDel) ), 
                        ST_Point( r  * cos(ang),           r  * sin(ang) ) 
                    ] )) AS geom
    FROM param
),
shapes AS ( SELECT geom, svgShape( geom,
        style => svgStyle( 
                'fill', svgHSL( hue, 100, light ),
                'stroke', '#000000',
                'stroke-width', '.02')
        ) AS svg
    FROM box
    UNION ALL SELECT geom, 
            svgText( ST_Centroid(geom), '(' || ir || ',' || id || ')',
            style => svgStyle( 'font', '0.3px sans-serif')
        ) AS svg
    FROM box
)
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#ffffff'
                --'fill', '#ff0000',
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 10) )
  	) AS svg
  FROM shapes;
