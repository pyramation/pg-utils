-- Deploy schemas/app_jobs/tables/scheduled_jobs/table to pg
-- requires: schemas/app_jobs/schema

BEGIN;
CREATE TABLE app_jobs.scheduled_jobs (
  id bigserial PRIMARY KEY,
  queue_name text DEFAULT (public.gen_random_uuid ()) ::text,
  task_identifier text NOT NULL,
  payload json DEFAULT '{}' ::json NOT NULL,
  priority integer DEFAULT 0 NOT NULL,
  run_at timestamptz DEFAULT now() NOT NULL,
  max_attempts integer DEFAULT 25 NOT NULL,
  -- date, recurrence rule
  schedule_type int NOT NULL DEFAULT 0,
  schedule_value text NOT NULL,
  last_scheduled timestamptz
);
COMMIT;

