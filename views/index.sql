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

COMMENT ON VIEW pgdv.index_totals IS 'total number and size of all indexes';

CREATE OR REPLACE VIEW pgdv.index_size AS
  SELECT
    pg_class.relname AS name,
    pg_class.relpages AS pages,
    pg_size_pretty(pg_class.relpages::bigint * 8192) AS size
  FROM pg_class
  LEFT JOIN pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
  WHERE pg_class.relkind = 'i'
    AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_namespace.nspname !~ '^pg_toast'
  ORDER BY pg_class.relpages DESC;

COMMENT ON VIEW pgdv.index_size IS 'size of each index';

CREATE OR REPLACE VIEW pgdv.index_usage AS
  SELECT
    relname AS table,
    n_live_tup AS rows,
    seq_scan AS seq_scans,
    idx_scan AS index_scans,
    CASE idx_scan
      WHEN 0 THEN NULL
      ELSE (idx_scan::float / (seq_scan + idx_scan) * 100)::numeric(5, 2)
    END AS percent_index_scan
  FROM pg_stat_user_tables
  ORDER BY rows DESC;

COMMENT ON VIEW pgdv.index_usage IS 'index vs. seq scan usage for each table';
