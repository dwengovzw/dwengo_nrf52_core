#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_VERSION="${1:-1.0.0}"
ARCHIVE_BASE="dwengo-nrf52-${CORE_VERSION}"
ARCHIVE_PATH="${ROOT_DIR}/releases/${ARCHIVE_BASE}.tar.bz2"

mkdir -p "${ROOT_DIR}/releases"

if [[ ! -d "${ROOT_DIR}/nrf52/${CORE_VERSION}" ]]; then
  echo "Missing platform folder: ${ROOT_DIR}/nrf52/${CORE_VERSION}" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

cp -a "${ROOT_DIR}/nrf52/${CORE_VERSION}" "${tmpdir}/${ARCHIVE_BASE}"
tar -cjf "${ARCHIVE_PATH}" -C "${tmpdir}" "${ARCHIVE_BASE}"

sha256="$(sha256sum "${ARCHIVE_PATH}" | awk '{print $1}')"
size="$(stat -c '%s' "${ARCHIVE_PATH}")"

echo "Archive: ${ARCHIVE_PATH}"
echo "SHA256: ${sha256}"
echo "Size: ${size}"
