WITH series AS (
    SELECT i, 1.0 / (1.0 + 1.0/tan(0.1)) / sin(0.1) AS rfact
    FROM generate_series(0, 40) AS s(i)
),
startPts AS (
    SELECT  rfact^i AS fact,
            sqrt(2) * (rfact^i) * cos((i * 0.1 + 0.25 * pi()) ) AS x,
            sqrt(2) * (rfact^i) * sin((i * 0.1 + 0.25 * pi()) ) AS y
    FROM series
)
SELECT ST_MakePolygon( ST_MakeLine( ARRAY[
    ST_Point(x, y), ST_Point(-y, x), ST_Point(-x, -y), ST_Point(y, -x), ST_Point(x, y)
])) FROM startPts;
