# Dwengo Arduino nRF52 Boards Package

This repository is a complete Arduino Boards Manager package for Dwengo nRF52 boards.

## Repository Contents

- `nrf52/1.0.1/`: full platform core content (boards, variants, cores, libraries, tools, bootloader)
- `releases/`: generated core archive for GitHub Releases
- `package_dwengo_index.json`: Boards Manager index file to publish via GitHub Pages
- `scripts/make_release_archive.sh`: builds the release tarball
- `scripts/make_release_archive.ps1`: Windows/PowerShell version of the above (`.\scripts\make_release_archive.ps1 1.0.1`)
- `scripts/update_index_from_release.sh`: updates index version/url/checksum/size
- `scripts/sync_dwengo_libraries.sh`: refreshes the bundled Dwengo libraries from `Blockly-for-Dwenguino`

## Bundled Dwengo libraries

`DwengoCompatibilityLayer`, `HalberdGripper` and `HalberdGripperSensor` live in `nrf52/1.0.1/libraries/`.
Everything in that folder is installed together with the core by the Boards Manager, so users don't need to install these libraries separately.
They are available (including their examples) whenever a Dwengo nRF52 board is selected.

To update them before a release, run `./scripts/sync_dwengo_libraries.sh`, then rebuild the release archive and update the index.



## User install in Arduino IDE

```text
https://dwengovzw.github.io/dwengo_nrf52_core/package_dwengo_index.json
```

Add the URL above in:

`File -> Preferences -> Additional Boards Manager URLs`

Then open Boards Manager and install:

- `Dwengo nRF52 Boards`

## Notes

- `package_dwengo_index.json` currently includes tool dependencies and tool metadata under the `dwengo` packager so users only need this one index URL.
- The platform currently uses folder version `1.0.1`, while `platform.txt` still says `version=1.7.0`. Aligning these in a future release is recommended.


## One-time setup for publishing

1. Create a GitHub repository and push this folder as the repository root.
2. Upload `releases/dwengo-nrf52-1.0.0.tar.bz2` as a GitHub Release asset with tag `1.0.0`.
3. Run:

```bash
./scripts/update_index_from_release.sh <org> <repo> 1.0.0
```

4. Commit and push the updated `package_dwengo_index.json`.
5. Enable GitHub Pages for the repo (branch `main`, root folder).
6. Share this Boards Manager URL:

```text
https://dwengovzw.github.io/dwengo_nrf52_core/package_dwengo_index.json
```