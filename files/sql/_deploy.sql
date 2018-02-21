
--------------------------------------------------------------------------------
CREATE SCHEMA pgcron AUTHORIZATION pgcron;
REVOKE ALL ON SCHEMA pgcron FROM PUBLIC;
--------------------------------------------------------------------------------

SET SESSION AUTHORIZATION pgcron;

\ir jobs.sql
\ir run.sql
\ir lastrun.sql
\ir transaction_runtime.sql

RESET SESSION AUTHORIZATION;
