CREATE OR REPLACE VIEW pgdv.indexes AS
  SELECT pg_class.*
  FROM pg_class, pg_namespace
  WHERE pg_namespace.oid = pg_class.relnamespace
    AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_namespace.nspname !~ '^pg_toast'
    AND pg_class.relkind = 'i';

COMMENT ON VIEW pgdv.indexes IS 'user indexes';

CREATE OR REPLACE VIEW pgdv.index_totals AS
  SELECT
    count(*) AS count,
    sum(relpages) AS pages,
    pg_size_pretty(sum(relpages::bigint * 8192)) AS size
  FROM pgdv.indexes;

COMMENT ON VIEW pgdv.index_totals IS 'total number and size of all indexes';

CREATE OR REPLACE VIEW pgdv.index_sizes AS
  SELECT
    relname AS index,
    relpages AS pages,
    pg_size_pretty(relpages::bigint * 8192) AS size
  FROM pgdv.indexes
  ORDER BY relpages DESC;

COMMENT ON VIEW pgdv.index_sizes IS 'size of each index';

CREATE OR REPLACE VIEW pgdv.index_usage AS
  SELECT
    relname AS table,
    n_live_tup AS rows,
    seq_scan AS seq_scans,
    idx_scan AS index_scans,
    (nullif(idx_scan, 0)::float / (seq_scan + idx_scan) * 100)::numeric(5, 2) AS percent_index_scan
  FROM pg_stat_user_tables
  ORDER BY rows DESC;

COMMENT ON VIEW pgdv.index_usage IS 'index / seq scan usage for each table';

CREATE OR REPLACE VIEW pgdv.index_cache_hits AS
  SELECT
    indexrelname AS index,
    idx_blks_read AS cache_misses,
    idx_blks_hit AS cache_hits,
    (idx_blks_hit::float / nullif(idx_blks_read + idx_blks_hit, 0) * 100)::numeric(5, 2) AS percent_cache_hit
  FROM pg_statio_user_indexes
  ORDER BY percent_cache_hit DESC NULLS LAST;
