# Device Directory

This directory contains device support packages synced from TinyGo.

**Current Status**: Initial structure created. Content sync pending.

## Sync Instructions

The TinyGo version is defined in `.github/workflows/validate-device-sync.yml` as `TINYGO_VERSION`.

To sync this directory with the configured TinyGo version, run:

```bash
./scripts/sync-from-release.sh v0.39.0 src/device device
```

After syncing, commit the changes:

```bash
git add device/
git commit -m "Sync device directory from TinyGo v0.39.0"
```

## CI Validation

The CI workflow automatically validates that the device directory content matches the TinyGo version specified in the workflow configuration file.

## Source

Device packages are synced from TinyGo official releases:
https://github.com/tinygo-org/tinygo/releases

Refer to `scripts/README.md` for detailed sync instructions.
