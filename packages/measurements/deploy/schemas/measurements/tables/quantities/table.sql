-- Deploy schemas/measurements/tables/quantities/table to pg

-- requires: schemas/measurements/schema

BEGIN;

CREATE TABLE measurements.quantities (
    id serial PRIMARY KEY,
    name text,
    label text,
    symbol text,
    unit_short_desc text,
    unit_desc text,
    description text
);

COMMIT;
