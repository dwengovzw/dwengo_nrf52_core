#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <github-org> <github-repo> <version>" >&2
  echo "Example: $0 dwengo dwengo-arduino-nrf52 1.0.0" >&2
  exit 1
fi

ORG="$1"
REPO="$2"
VERSION="$3"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX_PATH="${ROOT_DIR}/package_dwengo_index.json"
ARCHIVE_NAME="dwengo-nrf52-${VERSION}.tar.bz2"
ARCHIVE_PATH="${ROOT_DIR}/releases/${ARCHIVE_NAME}"

if [[ ! -f "${INDEX_PATH}" ]]; then
  echo "Missing index file: ${INDEX_PATH}" >&2
  exit 1
fi

if [[ ! -f "${ARCHIVE_PATH}" ]]; then
  echo "Missing release archive: ${ARCHIVE_PATH}" >&2
  exit 1
fi

SHA256="$(sha256sum "${ARCHIVE_PATH}" | awk '{print $1}')"
SIZE="$(stat -c '%s' "${ARCHIVE_PATH}")"
URL="https://github.com/${ORG}/${REPO}/releases/download/${VERSION}/${ARCHIVE_NAME}"

URL_ESCAPED="${URL//\//\\/}"

# Update package/repo placeholders globally.
sed -i "s|https://github.com/YOUR_ORG/YOUR_REPO|https://github.com/${ORG}/${REPO}|g" "${INDEX_PATH}"

# Update only the first platform block values, not tool version fields.
sed -i "0,/\"version\": \"[0-9][0-9.]*\"/s//\"version\": \"${VERSION}\"/" "${INDEX_PATH}"
sed -i "0,/\"url\": \"https:\\/\\/github.com\\/.*\\/releases\\/download\\/.*\\/dwengo-nrf52-.*\\.tar\\.bz2\"/s//\"url\": \"${URL_ESCAPED}\"/" "${INDEX_PATH}"
sed -i "0,/\"archiveFileName\": \"dwengo-nrf52-.*\\.tar\\.bz2\"/s//\"archiveFileName\": \"${ARCHIVE_NAME}\"/" "${INDEX_PATH}"
sed -i "0,/\"checksum\": \"SHA-256:[a-f0-9]*\"/s//\"checksum\": \"SHA-256:${SHA256}\"/" "${INDEX_PATH}"
sed -i "0,/\"size\": \"[0-9]*\"/s//\"size\": \"${SIZE}\"/" "${INDEX_PATH}"

echo "Updated ${INDEX_PATH}"
echo "  version=${VERSION}"
echo "  url=${URL}"
echo "  checksum=SHA-256:${SHA256}"
echo "  size=${SIZE}"
