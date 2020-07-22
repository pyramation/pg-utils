-- Deploy schemas/app_jobs/procedures/add_job to pg
-- requires: schemas/app_jobs/schema
-- requires: schemas/app_jobs/tables/jobs/table
-- requires: schemas/app_jobs/tables/job_queues/table

BEGIN;
CREATE FUNCTION app_jobs.add_job (identifier text, payload json DEFAULT NULL, queue_name text DEFAULT NULL, run_at timestamptz DEFAULT NULL, max_attempts integer DEFAULT NULL, job_key text DEFAULT NULL, priority integer DEFAULT NULL)
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
  IF job_key IS NOT NULL AND length(job_key) > 512 THEN
    RAISE exception 'Job key is too long (max length: 512).'
      USING errcode = 'GWBJK';
  END IF;
  IF max_attempts < 1 THEN
    RAISE exception 'Job maximum attempts must be at least 1'
      USING errcode = 'GWBMA';
  END IF;
  IF job_key IS NOT NULL THEN
    -- Upsert job
    INSERT INTO app_jobs.jobs (task_identifier, payload, queue_name, run_at, max_attempts, KEY, priority)
      VALUES (identifier, coalesce(payload, '{}'::json), queue_name, coalesce(run_at, now()), coalesce(max_attempts, 25), job_key, coalesce(priority, 0))
    ON CONFLICT (KEY)
      DO UPDATE SET
        task_identifier = excluded.task_identifier, payload = excluded.payload, queue_name = excluded.queue_name, max_attempts = excluded.max_attempts, run_at = excluded.run_at, priority = excluded.priority,
        -- always reset error/retry state
        attempts = 0, last_error = NULL
      WHERE
        jobs.locked_at IS NULL
      RETURNING
        * INTO v_job;
    -- If upsert succeeded (insert or update), return early
    IF NOT (v_job IS NULL) THEN
      RETURN v_job;
    END IF;
    -- Upsert failed -> there must be an existing job that is locked. Remove
    -- existing key to allow a new one to be inserted, and prevent any
    -- subsequent retries by bumping attempts to the max allowed.
    UPDATE
      app_jobs.jobs
    SET
      KEY = NULL,
      attempts = jobs.max_attempts
    WHERE
      KEY = job_key;
  END IF;
  -- insert the new job. Assume no conflicts due to the update above
  INSERT INTO app_jobs.jobs (task_identifier, payload, queue_name, run_at, max_attempts, KEY, priority)
    VALUES (identifier, coalesce(payload, '{}'::json), queue_name, coalesce(run_at, now()), coalesce(max_attempts, 25), job_key, coalesce(priority, 0))
  RETURNING
    * INTO v_job;
  RETURN v_job;
END;
$$
LANGUAGE 'plpgsql'
VOLATILE
SECURITY DEFINER;
COMMIT;

