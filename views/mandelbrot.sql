CREATE OR REPLACE VIEW pgdv.mandelbrot AS
  WITH RECURSIVE z(ix, iy, cx, cy, x, y, i) AS (
    SELECT ix, iy, x::float, y::float, x::float, y::float, 0
    FROM
      (SELECT -2.2 + 0.031 * i, i FROM generate_series(0, 101) AS i) AS xgen(x, ix),
      (SELECT -1.5 + 0.031 * i, i FROM generate_series(0, 101) AS i) AS ygen(y, iy)
    UNION ALL
    SELECT
      ix,
      iy,
      cx,
      cy,
      x * x - y * y + cx AS x,
      y * x * 2 + cy AS y,
      i + 1 AS i
    FROM z
    WHERE x * x + y * y < 16
      AND i < 100
  )
  SELECT
    array_to_string(
      array_agg(
        substring(' .,,,-----++++%%%%@@@@#### ', least(greatest(i, 1), 27), 1)
      ),
      ''
    ) AS mandelbrot
  FROM (
    SELECT ix, iy, max(i) AS i
    FROM z
    GROUP BY iy, ix
    ORDER BY iy, ix
  ) AS zt
  GROUP BY iy
  ORDER BY iy;

COMMENT ON VIEW pgdv.mandelbrot IS 'the Mandelbrot set';
