--
-- pgcron.run()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgcron.run()
	RETURNS boolean
  LANGUAGE plpgsql
	SECURITY DEFINER
AS $function$
--
-- Выполнение следующего запланированого задания (если таковое имеется),
-- возвращает false, если заданий не найдено.
--
DECLARE
	v_exception_text text;
	v_exception_detail text;
	v_exception_hint text;
  v_exception_context text;
	v_error json;

  v_cronjob record;
  v_tmp int;
BEGIN
  SELECT j.* INTO v_cronjob
    FROM _pgcron.job j
    LEFT JOIN pgcron.lastrun r ON r.schema_name = j.schema_name AND r.func_name = j.func_name
    WHERE now() - r.runmo > j.run_interval
      OR r ISNULL
    ORDER BY r.runmo ASC
    LIMIT 1;
  --
  IF NOT found THEN
    RETURN false;
  END IF;

	BEGIN
    EXECUTE format($$
      SELECT %I.%I();
    $$, v_cronjob.schema_name, v_cronjob.func_name);

	EXCEPTION WHEN others THEN
		GET STACKED DIAGNOSTICS v_exception_text = MESSAGE_TEXT,
														v_exception_detail  = PG_EXCEPTION_DETAIL,
												 		v_exception_hint = PG_EXCEPTION_HINT,
                            v_exception_context = PG_EXCEPTION_CONTEXT;

		v_error = json_build_object(
			'text', v_exception_text,
			'detail', v_exception_detail,
			'hint', v_exception_hint,
      'context', v_exception_context
		);
	END;

	INSERT INTO pgcron.lastrun
    AS b (schema_name, func_name, runtime, error)
		VALUES (v_cronjob.schema_name, v_cronjob.func_name, pgcron.transaction_runtime(), v_error)
		ON CONFLICT (schema_name, func_name) DO UPDATE
		SET runmo = now(), runtime = pgcron.transaction_runtime(), error = v_error
		WHERE b.schema_name = EXCLUDED.schema_name AND b.func_name = EXCLUDED.func_name;

  RETURN true;
END;
$function$;
--------------------------------------------------------------------------------
