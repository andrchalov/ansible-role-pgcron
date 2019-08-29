# ansible-role-pgcron

Ansible role for dockerized PostgreSQL cron service

### To register cron jobs you need to define pgcron.jobs table

#### For example:

```sql
CREATE OR REPLACE VIEW pgcron.jobs AS
  SELECT schema_name, func_name, run_interval::interval
    FROM (
      VALUES
        ('schema', 'function', '1 min'),
     ) foo (schema_name, func_name, run_interval);
GRANT SELECT ON TABLE pgcron.jobs TO pgcron;
```
