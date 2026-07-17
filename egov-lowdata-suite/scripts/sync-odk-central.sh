#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-v2025.2.3}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="${ROOT_DIR}/vendor/getodk-central"
REPO_URL="https://github.com/getodk/central.git"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Fetching ${REPO_URL} (tag: ${TAG})..."
git clone \
  --depth 1 \
  --recurse-submodules \
  --shallow-submodules \
  --branch "${TAG}" \
  "${REPO_URL}" "${TMP_DIR}" >/dev/null

git -C "${TMP_DIR}" submodule update --init --recursive --depth 1 --recommend-shallow >/dev/null

COMMIT_HASH=$(git -C "${TMP_DIR}" rev-parse HEAD)
CLIENT_HASH=$(git -C "${TMP_DIR}/client" rev-parse HEAD 2>/dev/null || echo "N/A")
SERVER_HASH=$(git -C "${TMP_DIR}/server" rev-parse HEAD 2>/dev/null || echo "N/A")
CLIENT_TAG=$(git -C "${TMP_DIR}/client" describe --tags 2>/dev/null || echo "unknown")
SERVER_TAG=$(git -C "${TMP_DIR}/server" describe --tags 2>/dev/null || echo "unknown")

STATIC_VERSION_FILE="${TMP_DIR}/files/prebuild/static-version.txt"
{
  echo "versions:"
  echo "${COMMIT_HASH} (${TAG})"
  if [ "${SERVER_HASH}" != "N/A" ]; then
    echo " ${SERVER_HASH} server (${SERVER_TAG})"
  fi
  if [ "${CLIENT_HASH}" != "N/A" ]; then
    echo " ${CLIENT_HASH} client (${CLIENT_TAG})"
  fi
} > "${STATIC_VERSION_FILE}"

echo "Cleaning git metadata..."
find "${TMP_DIR}" -name ".git" -type d -prune -exec rm -rf {} +
find "${TMP_DIR}" -name ".git" -type f -delete

rm -rf "${DEST_DIR}"
mkdir -p "${DEST_DIR}"
cp -a "${TMP_DIR}/." "${DEST_DIR}/"

cat > "${DEST_DIR}/files/prebuild/write-version.sh" <<'EOF'
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
EOF
chmod +x "${DEST_DIR}/files/prebuild/write-version.sh"

echo "Pinned getodk/central to ${TAG} (${COMMIT_HASH})."
[ "${CLIENT_HASH}" != "N/A" ] && echo "  client commit: ${CLIENT_HASH}"
[ "${SERVER_HASH}" != "N/A" ] && echo "  server commit: ${SERVER_HASH}"
