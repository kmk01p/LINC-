#!/bin/sh
set -e

wait_for_port() {
  host="$1"
  port="$2"
  label="${3:-$host:$port}"
  attempts=0
  max_attempts="${WAIT_MAX_ATTEMPTS:-60}"
  echo "Waiting for $label..."
  while ! nc -z "$host" "$port" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      echo "Timed out waiting for $label"
      exit 1
    fi
    sleep "${WAIT_INTERVAL_SECONDS:-2}"
  done
  echo "$label available."
}

wait_for_http() {
  url="$1"
  label="${2:-$url}"
  attempts=0
  max_attempts="${WAIT_MAX_ATTEMPTS:-60}"
  echo "Waiting for $label..."
  while ! curl -sS --max-time 2 "$url" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      echo "Timed out waiting for $label"
      exit 1
    fi
    sleep "${WAIT_INTERVAL_SECONDS:-2}"
  done
  echo "$label available."
}

# Default dependency endpoints
POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
SIDECAR_HEALTH="${SIDECAR_BASE:-http://sidecar:5001}/health"
METABASE_HEALTH="${MB_BASE_URL:-http://metabase:3000}/api/health"

wait_for_port "$POSTGRES_HOST" "$POSTGRES_PORT" "Postgres ($POSTGRES_HOST:$POSTGRES_PORT)"
wait_for_http "$SIDECAR_HEALTH" "XLSForm Sidecar"
wait_for_http "$METABASE_HEALTH" "Metabase"

echo "Starting gov-portal (Tomcat)..."
exec "$@"
