CREATE OR REPLACE VIEW pgdv.index_total_size AS
  SELECT pg_size_pretty(sum(pg_class.relpages::bigint * 8192)) AS size
  FROM pg_class
  LEFT JOIN pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
  WHERE pg_class.relkind = 'i'
    AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_namespace.nspname !~ '^pg_toast';

COMMENT ON VIEW pgdv.index_total_size IS 'Shows the total size of all indexes.';
