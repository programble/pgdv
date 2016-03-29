CREATE OR REPLACE VIEW pgdv.index_totals AS
  SELECT
    count(*) AS count,
    sum(pg_class.relpages) AS pages,
    pg_size_pretty(sum(pg_class.relpages::bigint * 8192)) AS size
  FROM pg_class
  LEFT JOIN pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
  WHERE pg_class.relkind = 'i'
    AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_namespace.nspname !~ '^pg_toast';

COMMENT ON VIEW pgdv.index_totals IS 'Shows the total number and size of all indexes.';
