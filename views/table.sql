CREATE OR REPLACE VIEW pgdv.table_sizes AS
  SELECT
    pg_namespace.nspname AS schema,
    pg_class.relname AS table,
    pg_relation_size(pg_class.oid) AS size,
    pg_size_pretty(pg_relation_size(pg_class.oid)) AS pretty_size
  FROM pg_class, pg_namespace
  WHERE pg_namespace.oid = pg_class.relnamespace
    AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_namespace.nspname !~ '^pg_toast'
    AND pg_class.relkind = 'r'
  ORDER BY size DESC;

COMMENT ON VIEW pgdv.table_sizes IS 'size of each table';

CREATE OR REPLACE VIEW pgdv.table_sizes_total AS
  SELECT
    count(*) AS count,
    sum(size) AS size,
    pg_size_pretty(sum(size)) AS pretty_size
  FROM pgdv.table_sizes;

COMMENT ON VIEW pgdv.table_sizes_total IS 'total size of all tables';
