-- Verify schemas/app_jobs/triggers/tg_add_job_for_row  on pg

BEGIN;

SELECT verify_function ('app_jobs.tg_add_job_for_row');

ROLLBACK;
