-- Deploy schemas/app_jobs/triggers/tg_add_job_with_row_id to pg
-- requires: schemas/app_jobs/schema

BEGIN;
CREATE FUNCTION app_jobs.tg_add_job_with_row_id ()
  RETURNS TRIGGER
  AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
    PERFORM
      app_jobs.add_job (tg_argv[0], json_build_object('id', NEW.id));
    RETURN NEW;
  END IF;
  IF (TG_OP = 'DELETE') THEN
    PERFORM
      app_jobs.add_job (tg_argv[0], json_build_object('id', OLD.id));
    RETURN OLD;
  END IF;
END;
$$
LANGUAGE plpgsql
VOLATILE;
COMMENT ON FUNCTION app_jobs.tg_add_job_with_row_id IS E'Useful shortcut to create a job on insert or update. Pass the task name as the trigger argument, and the record id will automatically be available on the JSON payload.';
COMMIT;
