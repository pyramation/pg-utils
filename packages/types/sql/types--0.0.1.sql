\echo Use "CREATE EXTENSION types" to load this file. \quit
CREATE DOMAIN email AS citext CHECK ( ((value) ~ ('^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')) );

COMMENT ON DOMAIN email IS E'@name launchqlInternalTypeEmail';

CREATE DOMAIN hostname AS text CHECK ( ((value) ~ ('^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$')) );

COMMENT ON DOMAIN hostname IS E'@name launchqlInternalTypeHostname';

CREATE DOMAIN url AS text CHECK ( ((value) ~ ('^(https?)://[^\s/$.?#].[^\s]*$')) );

COMMENT ON DOMAIN url IS E'@name launchqlInternalTypeUrl';