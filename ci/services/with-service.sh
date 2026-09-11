#!/usr/bin/env bash
# Start a service, wait for its ports, run a command, then stop the service.
#   with-service.sh azurite <blobPort> <queuePort> <tablePort> -- <command...>
#   with-service.sh redis|postgres|nats -- <command...>
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kind=$1; shift
case "$kind" in
  azurite)
    b=$1; q=$2; t=$3; shift 3
    azurite --silent --skipApiVersionCheck --location "/tmp/orleans-azurite-$b" --blobPort "$b" --queuePort "$q" --tablePort "$t" &
    ports="127.0.0.1:$b 127.0.0.1:$q 127.0.0.1:$t" ;;
  redis)
    redis-server --port 6379 --bind 127.0.0.1 --save '' --appendonly no >/dev/null &
    ports="127.0.0.1:6379" ;;
  postgres)
    bash "$here/postgres/start.sh" >/dev/null 2>&1 &
    ports="127.0.0.1:5432" ;;
  nats)
    nats-server --js --port 4222 --http_port 8222 >/dev/null 2>&1 &
    ports="127.0.0.1:4222" ;;
  *) echo "with-service: unknown service $kind" >&2; exit 2 ;;
esac
svc=$!
[ "$1" = "--" ] && shift
trap 'kill "$svc" 2>/dev/null; pkill -P "$svc" 2>/dev/null; wait "$svc" 2>/dev/null' EXIT
"$here/wait-for.sh" $ports || exit 1
"$@"
