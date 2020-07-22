-- Deploy schemas/app_jobs/tables/jobs/table to pg
-- requires: schemas/app_jobs/schema

BEGIN;
CREATE TABLE app_jobs.jobs (
  id bigserial PRIMARY KEY,
  queue_name text DEFAULT (public.gen_random_uuid ()) ::text,
  task_identifier text NOT NULL,
  payload json DEFAULT '{}' ::json NOT NULL,
  priority integer DEFAULT 0 NOT NULL,
  run_at timestamp with time zone DEFAULT now() NOT NULL,
  attempts integer DEFAULT 0 NOT NULL,
  max_attempts integer DEFAULT 25 NOT NULL,
  last_error text,
  key text,
  locked_at timestamp with time zone,
  locked_by text,
  CONSTRAINT jobs_key_check CHECK ((length(KEY) > 0)),
  UNIQUE (KEY)
);
COMMIT;

