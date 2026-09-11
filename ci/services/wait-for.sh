#!/usr/bin/env bash
# Block until every host:port argument accepts a TCP connection, or give up after WAIT_FOR_SECS.
set -u
deadline=$(( $(date +%s) + ${WAIT_FOR_SECS:-180} ))
for target in "$@"; do
  host=${target%:*}; port=${target#*:}
  until (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
      echo "wait-for: $target not reachable after ${WAIT_FOR_SECS:-180}s" >&2
      exit 1
    fi
    sleep 1
  done
  exec 3>&- 2>/dev/null
  echo "wait-for: $target is up"
done
