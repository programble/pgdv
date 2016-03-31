CREATE OR REPLACE VIEW pgdv.table_sizes AS
  SELECT
    pg_namespace.nspname AS schema,
    pg_class.relname AS table,
    pg_class.reltuples::numeric AS rows,
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
    sum(rows) AS rows,
    sum(size) AS size,
    pg_size_pretty(sum(size)) AS pretty_size
  FROM pgdv.table_sizes;

COMMENT ON VIEW pgdv.table_sizes_total IS 'total size of all tables';

CREATE OR REPLACE VIEW pgdv.table_seq_scans AS
  SELECT
    schemaname AS schema,
    relname AS table,
    n_live_tup AS rows,
    seq_scan AS seq_scans
  FROM pg_stat_user_tables
  ORDER BY seq_scans DESC;

COMMENT ON VIEW pgdv.table_seq_scans IS 'number of sequence scans on each table';

CREATE OR REPLACE VIEW pgdv.table_cache_hits AS
  SELECT
    schemaname AS schema,
    relname AS table,
    heap_blks_read AS cache_misses,
    heap_blks_hit AS cache_hits,
    (
      heap_blks_hit::float / nullif(heap_blks_read + heap_blks_hit, 0) * 100
    )::numeric(5, 2) AS percent_cache_hit
  FROM pg_statio_user_tables
  ORDER BY percent_cache_hit DESC NULLS LAST;

COMMENT ON VIEW pgdv.table_cache_hits IS 'table cache hits / misses';

CREATE OR REPLACE VIEW pgdv.table_cache_hits_total AS
  SELECT
    sum(cache_misses) AS cache_misses,
    sum(cache_hits) AS cache_hits,
    (
      sum(cache_hits)::float / sum(cache_misses + cache_hits) * 100
    )::numeric(5, 2) AS percent_cache_hit
  FROM pgdv.table_cache_hits;

COMMENT ON VIEW pgdv.table_cache_hits_total IS 'total table cache hits / misses';
