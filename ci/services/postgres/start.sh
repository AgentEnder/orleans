#!/usr/bin/env bash
# Initialise a throwaway cluster and run postgres in the foreground on 5432.
set -euo pipefail

# The conda-forge build keeps libpq beside the binaries under <prefix>/lib, and the
# Linux loader does not look there on its own.
prefix=$(mise where conda:postgresql 2>/dev/null || dirname "$(dirname "$(command -v initdb)")")
export LD_LIBRARY_PATH="$prefix/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

data=${PGDATA_DIR:-/tmp/orleans-postgres}
rm -rf "$data"
initdb --username=postgres --auth=trust --encoding=UTF8 --locale=C --pgdata="$data" >/dev/null
exec postgres -D "$data" -p 5432 -c listen_addresses=127.0.0.1
