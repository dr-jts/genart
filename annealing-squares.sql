-- ---------------------------------
-- Annealing Squares
--
-- psql -A -t -o annealing-squares.svg  < annealing-squares.sql
-- ---------------------------------

WITH
pos AS (SELECT  x, y, 
                svgClamp( (y - 1) / 19.0, 0.0, 1.0)  AS f   -- fraction in [0, 1]
  FROM        generate_series(1, 20) AS x(x)
  CROSS JOIN  generate_series(1, 20) AS y(y)
),
box_param AS ( SELECT x, y, f,
        0.45 AS w,
        f * 1.0 * random() AS rot,
        f * random() AS dx,
        f * random() AS dy,
        0.5 * f * (0.5 - random()) AS skewx,
        0.5  * f * (0.5 - random()) AS skewy
    FROM pos
),
box AS (SELECT y, f, rot,
            ST_MakePolygon( ST_MakeLine(
                ARRAY[  ST_Point(x + dx - w + skewx,  y + dy - w + skewy), 
                        ST_Point(x + dx - w + 0.01*f*(0.5 - random()),  y + dy + w + 0.01*f*(0.5 - random())), 
                        ST_Point(x + dx + w + skewx,  y + dy + w + skewy), 
                        ST_Point(x + dx + w + skewx,  y + dy - w + skewy), 
                        ST_Point(x + dx - w + skewx,  y + dy - w + skewy) 
                    ] )) AS geom,
            ST_MakeEnvelope(x + dx - w + skewx, 
                            y + dy - w + skewy, 
                            x + dx + w + skewx, 
                            y + dy + w + skewy ) AS geom2
    FROM box_param
),
box_trans AS (SELECT f,
        ST_Rotate(geom, rot, ST_Centroid(geom)) geom
    FROM box
),
shapes AS ( SELECT geom, svgShape( geom,
        style => svgStyle( 
                'fill', svgRGBf( f, f * random(), 
                                1.0 - f ))
        ) AS svg
    FROM box_trans
)
SELECT svgDoc(  array_agg( svg ),
            style => svgStyle( 
                'background-color', '#000000', 
                'stroke', '#000000',
                'stroke-width', '.04'
            ),
  		    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 1) )
  	) AS svg
  FROM shapes;
