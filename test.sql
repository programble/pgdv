\set ON_ERROR_STOP on

DROP DATABASE IF EXISTS pgdv_test;
CREATE DATABASE pgdv_test;
\connect pgdv_test

\ir create.sql
\ir drop.sql

\connect postgres
DROP DATABASE pgdv_test;
