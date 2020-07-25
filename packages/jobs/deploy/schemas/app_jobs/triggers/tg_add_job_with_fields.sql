-- Deploy schemas/app_jobs/triggers/tg_add_job_with_fields to pg
-- requires: schemas/app_jobs/schema
-- requires: schemas/app_jobs/helpers/json_build_object_apply

BEGIN;
CREATE FUNCTION app_jobs.trigger_job_with_fields ()
  RETURNS TRIGGER
  AS $$
DECLARE
  arg text;
  fn text;
  i int;
  args text[];
BEGIN
  FOR i IN
  SELECT
    *
  FROM
    generate_series(1, TG_NARGS) g (i)
    LOOP
      IF (i = 1) THEN
        fn = TG_ARGV[i - 1];
      ELSE
        args = array_append(args, TG_ARGV[i - 1]);
        EXECUTE format('SELECT ($1).%s::text', TG_ARGV[i - 1])
        USING NEW INTO arg;
        args = array_append(args, arg);
      END IF;
    END LOOP;
  PERFORM
    app_jobs.add_job (fn, app_jobs.json_build_object_apply (args));
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;
COMMIT;

