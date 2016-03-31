CREATE SCHEMA IF NOT EXISTS pgdv;
COMMENT ON SCHEMA pgdv IS 'PostgreSQL diagnostic views';

\ir views/index.sql
\ir views/mandelbrot.sql
\ir views/query.sql
\ir views/table.sql

CREATE OR REPLACE VIEW pgdv.views AS
  SELECT
    pg_class.relname AS view,
    obj_description(pg_class.oid, 'pg_class') AS description
  FROM pg_class, pg_namespace
  WHERE pg_namespace.oid = pg_class.relnamespace
    AND pg_namespace.nspname = 'pgdv'
  ORDER BY view;

COMMENT ON VIEW pgdv.views IS 'view of views';
