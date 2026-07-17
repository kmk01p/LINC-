#!/bin/bash -eu
set -o pipefail
shopt -s inherit_errexit

flag_upgradeCompletedOk="$PGDATA/../.postgres14-upgrade-successful"

logPrefix="$(basename "$0")"
log() {
  echo "$(TZ=GMT date) [$logPrefix] $*"
}

if ! [[ -f "$flag_upgradeCompletedOk" ]]; then
  log "Upgrade flag not found; assuming fresh install."
  mkdir -p "$(dirname "$flag_upgradeCompletedOk")"
  touch "$flag_upgradeCompletedOk"
else
  log "Upgrade previously completed."
fi

log "Starting postgres..."
# call ENTRYPOINT + CMD from parent Docker image
exec docker-entrypoint.sh postgres "$@"
