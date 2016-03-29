#!/usr/bin/env bash

set errexit nounset pipefail

createdb pgdv_test
psql pgdv_test --command '\i create.sql'
psql pgdv_test --command '\i drop.sql'
dropdb pgdv_test
