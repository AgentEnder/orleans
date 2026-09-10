#!/usr/bin/env bash
# Initialise a throwaway cluster and run postgres in the foreground on 5432.
set -euo pipefail
data=${PGDATA_DIR:-/tmp/orleans-postgres}
rm -rf "$data"
initdb --username=postgres --auth=trust --pgdata="$data" >/dev/null
exec postgres -D "$data" -p 5432 -c listen_addresses=127.0.0.1
