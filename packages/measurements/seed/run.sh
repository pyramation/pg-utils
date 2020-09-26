#!/bin/bash

psql measurements <<EOF
\copy measurements.quantities(name, symbol, label, description, unit_short_desc, unit_desc) FROM '/Users/dlynch/code/launchql/pg-utils/packages/measurements/seed/quant.csv' DELIMITER ',' CSV
EOF

pg_dump --column-inserts --data-only  measurements