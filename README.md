# Dwengo Arduino nRF52 Boards Package

This repository is a complete Arduino Boards Manager package for Dwengo nRF52 boards.

## Repository Contents

- `nrf52/1.0.0/`: full platform core content (boards, variants, cores, libraries, tools, bootloader)
- `releases/`: generated core archive for GitHub Releases
- `package_dwengo_index.json`: Boards Manager index file to publish via GitHub Pages
- `scripts/make_release_archive.sh`: builds the release tarball
- `scripts/update_index_from_release.sh`: updates index version/url/checksum/size



## User install in Arduino IDE

Add the URL above in:

`File -> Preferences -> Additional Boards Manager URLs`

Then open Boards Manager and install:

- `Dwengo nRF52 Boards`

## Notes

- `package_dwengo_index.json` currently includes tool dependencies and tool metadata under the `dwengo` packager so users only need this one index URL.
- The platform currently uses folder version `1.0.0`, while `platform.txt` still says `version=1.7.0`. Aligning these in a future release is recommended.


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
https://<org>.github.io/<repo>/package_dwengo_index.json
```