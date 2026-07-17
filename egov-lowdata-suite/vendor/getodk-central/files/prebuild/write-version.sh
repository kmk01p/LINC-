#!/bin/bash -eu
set -o pipefail
shopt -s inherit_errexit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATIC_VERSION_FILE="${SCRIPT_DIR}/static-version.txt"

if git rev-parse HEAD >/dev/null 2>&1; then
  {
    echo "versions:"
    echo "$(git rev-parse HEAD) ($(git describe --tags))"
    git submodule foreach --quiet --recursive \
      "commit=\$(git rev-parse HEAD); \
       tag=\$(git describe --tags); \
       printf ' %s %s (%s)\n' \"\$commit\" \"\$path\" \"\$tag\""
  } > /tmp/version.txt
elif [ -f "${STATIC_VERSION_FILE}" ]; then
  cp "${STATIC_VERSION_FILE}" /tmp/version.txt
else
  {
    echo "versions:"
    echo "${CENTRAL_VERSION_OVERRIDE:-unknown}"
  } > /tmp/version.txt
fi
