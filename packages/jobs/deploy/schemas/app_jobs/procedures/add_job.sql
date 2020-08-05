-- Deploy schemas/app_jobs/procedures/add_job to pg
-- requires: schemas/app_jobs/schema
-- requires: schemas/app_jobs/tables/jobs/table
-- requires: schemas/app_jobs/tables/job_queues/table

BEGIN;
CREATE FUNCTION app_jobs.add_job (identifier text, payload json DEFAULT NULL, queue_name text DEFAULT NULL, run_at timestamptz DEFAULT NULL, max_attempts integer DEFAULT NULL, priority integer DEFAULT NULL)
  RETURNS app_jobs.jobs
  AS $$
DECLARE
  v_job app_jobs.jobs;
BEGIN
  -- Apply rationality checks
  IF length(identifier) > 128 THEN
    RAISE exception 'Task identifier is too long (max length: 128).'
      USING errcode = 'GWBID';
  END IF;
  IF queue_name IS NOT NULL AND length(queue_name) > 128 THEN
    RAISE exception 'Job queue name is too long (max length: 128).'
      USING errcode = 'GWBQN';
  END IF;
  IF max_attempts < 1 THEN
    RAISE exception 'Job maximum attempts must be at least 1'
      USING errcode = 'GWBMA';
  END IF;
  INSERT INTO app_jobs.jobs (task_identifier, payload, queue_name, run_at, max_attempts, priority)
    VALUES (identifier, coalesce(payload, '{}'::json), queue_name, coalesce(run_at, now()), coalesce(max_attempts, 25), coalesce(priority, 0))
  RETURNING
    * INTO v_job;
  RETURN v_job;
END;
$$
LANGUAGE 'plpgsql'
VOLATILE
SECURITY DEFINER;
COMMIT;

