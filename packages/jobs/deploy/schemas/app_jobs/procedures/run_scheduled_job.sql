-- Deploy schemas/app_jobs/procedures/run_scheduled_job to pg
-- requires: schemas/app_jobs/schema
-- requires: schemas/app_jobs/tables/jobs/table
-- requires: schemas/app_jobs/tables/scheduled_jobs/table

BEGIN;
CREATE FUNCTION app_jobs.run_scheduled_job (id bigint)
  RETURNS app_jobs.jobs
  AS $$
DECLARE
  sj app_jobs.scheduled_jobs;
  j app_jobs.jobs;
BEGIN
  UPDATE
    app_jobs.scheduled_jobs ajsj
  SET
    last_scheduled = NOW()
  WHERE
    ajsj.id = run_scheduled_job.id
  RETURNING
    * INTO sj;
  INSERT INTO app_jobs.jobs (queue_name, task_identifier, payload, priority, max_attempts)
  SELECT
    queue_name,
    task_identifier,
    payload,
    priority,
    max_attempts
  FROM
    app_jobs.scheduled_jobs ajsj
  WHERE
    ajsj.id = run_scheduled_job.id
  RETURNING
    * INTO j;
  RETURN j;
END;
$$
LANGUAGE 'plpgsql'
VOLATILE;
COMMIT;

