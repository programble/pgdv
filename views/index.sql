CREATE OR REPLACE VIEW pgdv.index_sizes AS
  SELECT
    pg_class.relname AS index,
    pg_class.relpages AS pages,
    pg_size_pretty(pg_class.relpages::bigint * 8192) AS size
  FROM pg_class, pg_namespace
  WHERE pg_namespace.oid = pg_class.relnamespace
    AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_namespace.nspname !~ '^pg_toast'
    AND pg_class.relkind = 'i'
  ORDER BY pages DESC;

COMMENT ON VIEW pgdv.index_sizes IS 'size of each index';

CREATE OR REPLACE VIEW pgdv.index_sizes_total AS
  SELECT
    count(*) AS count,
    sum(pages) AS pages,
    pg_size_pretty(sum(pages::bigint * 8192)) AS size
  FROM pgdv.index_sizes;

COMMENT ON VIEW pgdv.index_sizes_total IS 'total size of all indexes';

CREATE OR REPLACE VIEW pgdv.index_usage AS
  SELECT
    relname AS table,
    n_live_tup AS rows,
    seq_scan AS seq_scans,
    idx_scan AS index_scans,
    (
      nullif(idx_scan, 0)::float / (seq_scan + idx_scan) * 100
    )::numeric(5, 2) AS percent_index_scan
  FROM pg_stat_user_tables
  ORDER BY rows DESC;

COMMENT ON VIEW pgdv.index_usage IS 'index / seq scan usage for each table';

CREATE OR REPLACE VIEW pgdv.index_usage_total AS
  SELECT
    sum(seq_scans) AS seq_scans,
    sum(index_scans) AS index_scans,
    (
      sum(index_scans)::float / sum(seq_scans + index_scans) * 100
    )::numeric(5, 2) AS percent_index_scan
  FROM pgdv.index_usage;

COMMENT ON VIEW pgdv.index_usage_total IS 'total index / seq scan usage';

CREATE OR REPLACE VIEW pgdv.index_cache_hits AS
  SELECT
    indexrelname AS index,
    idx_blks_read AS cache_misses,
    idx_blks_hit AS cache_hits,
    (
      idx_blks_hit::float / nullif(idx_blks_read + idx_blks_hit, 0) * 100
    )::numeric(5, 2) AS percent_cache_hit
  FROM pg_statio_user_indexes
  ORDER BY percent_cache_hit DESC NULLS LAST;

COMMENT ON VIEW pgdv.index_cache_hits IS 'index cache hits / misses';

CREATE OR REPLACE VIEW pgdv.index_cache_hits_total AS
  SELECT
    sum(cache_misses) AS cache_misses,
    sum(cache_hits) AS cache_hits,
    (
      sum(cache_hits)::float / sum(cache_misses + cache_hits) * 100
    )::numeric(5, 2) AS percent_cache_hit
  FROM pgdv.index_cache_hits;

COMMENT ON VIEW pgdv.index_cache_hits_total IS 'total index cache hits / misses';
