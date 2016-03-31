# PostgreSQL Diagnostic Views

A set of diagnostic (over)views of the statistics collected by PostgreSQL.

Many queries adapted from [heroku-pg-extras][pg-extras].

[pg-extras]: https://github.com/heroku/heroku-pg-extras

## Install

Some views depend on the extension `pg_stat_statements`.

The views are created in a `pgdv` schema by the `create.sql` file.

```
postgres=# CREATE EXTENSION pg_stat_statements;
postgres=# \i pgdv/create.sql
```

## Usage

The views are documented with `COMMENT` and can be listed through the
`pgdv.views` view of views.

```
postgres=# SELECT * FROM pgdv.views;
          view          |              description
------------------------+----------------------------------------
 index_cache_hits       | index cache hits / misses
 index_cache_hits_total | total index cache hits / misses
 index_scan_size_ratios | index scan / size ratios
 index_sizes            | size of each index
 index_sizes_total      | total size of all indexes
 index_usage            | index / seq scan usage for each table
 index_usage_total      | total index / seq scan usage
 mandelbrot             | the Mandelbrot set
 queries                | active queries
 query_blocks           | blocking / blocked queries
 query_calls            | query calls and total time
 query_locks            | granted and waiting query locks
 query_times            | query times
 table_cache_hits       | table cache hits / misses
 table_cache_hits_total | total table cache hits / misses
 table_seq_scans        | number of sequence scans on each table
 table_sizes            | size of each table
 table_sizes_total      | total size of all tables
 table_vacuums          | table vacuum times
 views                  | view of views
(20 rows)
```

## Uninstall

The views are dropped by the `drop.sql` file.

```
postgres=# \i pgdv/drop.sql
```

## License

Copyright © 2016, Curtis McEnroe <curtis@cmcenroe.me>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
