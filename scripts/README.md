# Sync Scripts

## sync-from-release.sh

Generic script to download TinyGo release packages and extract specified content to target folders.

### Usage

```bash
./scripts/sync-from-release.sh <tinygo-version> <source-path> <target-folder>
```

### Parameters

- `tinygo-version`: TinyGo version to download (e.g., `v0.39.0`)
- `source-path`: Path in TinyGo package to extract (e.g., `src/device`)
- `target-folder`: Target directory to extract to (e.g., `device/`)

### Examples

#### Sync device directory

```bash
./scripts/sync-from-release.sh v0.39.0 src/device device
```

This command:
1. Downloads `tinygo0.39.0.linux-amd64.tar.gz` from GitHub releases
2. Extracts `src/device` content
3. Copies it to `device/` directory in the repository

#### Sync machine directory

```bash
./scripts/sync-from-release.sh v0.39.0 src/machine machine
```

### Download Source

The script downloads from TinyGo's official GitHub releases:
```
https://github.com/tinygo-org/tinygo/releases/download/v{VERSION}/tinygo{VERSION}.linux-amd64.tar.gz
```

**Note**: All platform packages (linux-amd64, darwin-amd64, etc.) contain identical `src/device` and `src/machine` directories, so we use `linux-amd64` by default.

### Error Handling

The script includes:
- Automatic retry (up to 3 attempts) for downloads
- Validation that source path exists in TinyGo package
- Automatic cleanup of temporary files
- Clear error messages for troubleshooting

### Requirements

- `wget`: For downloading releases
- `tar`: For extracting archives
- `curl` alternative: The script can be modified to use `curl` instead of `wget`

### Design Philosophy

This script is designed to be:
- **Generic**: Works for any TinyGo version and source path
- **Reusable**: Used by both manual sync and CI validation
- **Reliable**: Includes retry logic and comprehensive error handling
- **Clean**: Automatically removes temporary files
