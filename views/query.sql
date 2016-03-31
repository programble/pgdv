CREATE OR REPLACE VIEW pgdv.queries AS
  SELECT
    pid,
    application_name AS application,
    now() - query_start AS query_duration,
    query
  FROM pg_stat_activity
  WHERE state = 'active'
  ORDER BY query_duration DESC;

COMMENT ON VIEW pgdv.queries IS 'active queries';

CREATE OR REPLACE VIEW pgdv.query_locks AS
  SELECT
    pg_locks.pid AS pid,
    pg_locks.mode AS mode,
    pg_class.relname AS relation,
    pg_locks.granted AS granted,
    now() - pg_stat_activity.query_start AS query_duration,
    pg_stat_activity.query AS query
  FROM pg_locks, pg_class, pg_stat_activity
  WHERE pg_class.oid = pg_locks.relation
    AND pg_stat_activity.pid = pg_locks.pid
    AND pg_locks.mode != 'AccessShareLock';

COMMENT ON VIEW pgdv.query_locks IS 'granted and waiting query locks';

CREATE OR REPLACE VIEW pgdv.query_blocks AS
  SELECT
    blocking_locks.pid AS blocking_pid,
    blocked_locks.pid AS blocked_pid,
    blocking_locks.mode AS blocking_mode,
    blocked_locks.mode AS blocked_mode,
    now() - blocking_queries.query_start AS blocking_duration,
    now() - blocked_queries.query_start AS blocked_duration,
    blocking_queries.query AS blocking_query,
    blocked_queries.query AS blocked_query
  FROM
    pg_locks blocking_locks,
    pg_locks blocked_locks,
    pg_stat_activity blocking_queries,
    pg_stat_activity blocked_queries
  WHERE blocking_queries.pid = blocking_locks.pid
    AND blocked_queries.pid = blocked_locks.pid
    AND blocked_locks.relation = blocking_locks.relation
    AND blocked_locks.pid != blocking_locks.pid
    AND NOT blocked_locks.granted
  ORDER BY blocked_duration DESC;

COMMENT ON VIEW pgdv.query_blocks IS 'blocking / blocked queries';

CREATE OR REPLACE VIEW pgdv.query_calls AS
  SELECT
    calls,
    total_time * interval '1 millisecond' AS total_time,
    (total_time / sum(total_time) OVER () * 100)::numeric(5, 2) AS percent_total_time,
    query
  FROM pg_stat_statements
  WHERE calls > 1
  ORDER BY calls DESC;

COMMENT ON VIEW pgdv.query_calls IS 'query calls and total time';

CREATE OR REPLACE VIEW pgdv.query_times AS
  SELECT
    min_time * interval '1 millisecond' AS min_time,
    max_time * interval '1 millisecond' AS max_time,
    total_time * interval '1 millisecond' AS total_time,
    calls,
    mean_time * interval '1 millisecond' AS mean_time,
    query
  FROM pg_stat_statements
  ORDER BY mean_time DESC;

COMMENT ON VIEW pgdv.query_times IS 'query times';
