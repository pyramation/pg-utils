-- Revert schemas/app_jobs/triggers/tg_add_job_for_row from pg

BEGIN;

DROP FUNCTION app_jobs.tg_add_job_for_row;

COMMIT;
