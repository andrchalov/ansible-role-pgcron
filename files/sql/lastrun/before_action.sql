--
-- pgcron.lastrun_before_action()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgcron.lastrun_before_action()
  RETURNS trigger
	LANGUAGE plpgsql AS
$function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.runcount = 1;
    NEW.runtimemax = NEW.runtime;
    NEW.runtimeavg = NEW.runtime;
  ELSIF TG_OP = 'UPDATE' AND NEW.runmo IS DISTINCT FROM OLD.runmo THEN
    IF OLD.runtime < NEW.runtime THEN
      NEW.runtimemax = NEW.runtime;
    END IF;

    NEW.runtimeavg = (NEW.runtimeavg::bigint * NEW.runcount + NEW.runtime) / (NEW.runcount + 1);
    NEW.runcount = NEW.runcount + 1;
    NEW.runinterval = NEW.runmo - OLD.runmo;
  END IF;

	RETURN NEW;
END;
$function$;
--------------------------------------------------------------------------------
