#!/usr/bin/env bash
# Refreshes the Dwengo libraries bundled with the platform from the Blockly-for-Dwenguino repo.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_VERSION="${1:-1.0.1}"
BRANCH="${2:-unified}"
LIB_DIR="${ROOT_DIR}/nrf52/${CORE_VERSION}/libraries"
BASE_URL="https://raw.githubusercontent.com/dwengovzw/Blockly-for-Dwenguino/refs/heads/${BRANCH}/backend/compilation/hardware/dwengo/nrf52/1.0.0/libraries"
LIBS=(DwengoCompatibilityLayer HalberdGripper HalberdGripperSensor)

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

for lib in "${LIBS[@]}"; do
  curl -fsSL "${BASE_URL}/${lib}/${lib}.zip" -o "${tmpdir}/${lib}.zip"
  if command -v unzip >/dev/null; then
    unzip -q "${tmpdir}/${lib}.zip" -d "${tmpdir}/${lib}"
  else
    python3 -m zipfile -e "${tmpdir}/${lib}.zip" "${tmpdir}/${lib}"
  fi
  if [[ ! -f "${tmpdir}/${lib}/${lib}/library.properties" ]]; then
    echo "Unexpected archive layout for ${lib}" >&2
    exit 1
  fi
  rm -rf "${LIB_DIR:?}/${lib}"
  cp -a "${tmpdir}/${lib}/${lib}" "${LIB_DIR}/${lib}"
  echo "Synced ${lib} ($(grep '^version=' "${LIB_DIR}/${lib}/library.properties" | tr -d '\r'))"
done
