# Sync Scripts

This directory contains scripts for synchronizing content from TinyGo releases.

## sync-from-release.sh

Generic script to download TinyGo release packages and extract specified content.

### Usage

```bash
./scripts/sync-from-release.sh <tinygo-version> <source-path> <target-folder>
```

### Parameters

- `<tinygo-version>`: TinyGo version (e.g., `v0.39.0`)
- `<source-path>`: Source path within TinyGo package (e.g., `src/device`)
- `<target-folder>`: Target directory for extracted content (e.g., `device`)

### Examples

Sync device directory from TinyGo v0.39.0:
```bash
./scripts/sync-from-release.sh v0.39.0 src/device device
```

Sync machine directory from TinyGo v0.39.0:
```bash
./scripts/sync-from-release.sh v0.39.0 src/machine machine
```

### How it works

1. Downloads the specified TinyGo release from GitHub (linux-amd64 version)
2. Extracts the requested source path from the tarball
3. Copies the content to the target folder
4. Cleans up temporary files

### Notes

- The script uses the `linux-amd64` version of TinyGo releases, as the `src/device` and `src/machine` content is identical across all platforms
- Requires `wget` and `tar` utilities
- Includes retry logic (3 attempts with 30s timeout) for download reliability
