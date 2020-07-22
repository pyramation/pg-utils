-- Deploy schemas/app_jobs/procedures/remove_job to pg
-- requires: schemas/app_jobs/schema
-- requires: schemas/app_jobs/tables/jobs/table

BEGIN;
CREATE FUNCTION app_jobs.remove_job (job_key text)
  RETURNS app_jobs.jobs
  LANGUAGE sql
  STRICT
  AS $$
  DELETE FROM app_jobs.jobs
  WHERE KEY = job_key
    AND locked_at IS NULL
  RETURNING
    *;
$$;
COMMIT;

