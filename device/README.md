# Device Directory

This directory contains device support packages synced from TinyGo.

**Current Status**: Initial structure created. Content sync pending.

## Sync Instructions

To populate this directory with TinyGo v0.39.0 device content, run:

```bash
./scripts/sync-from-release.sh v0.39.0 src/device device
```

After syncing, commit the changes with:

```bash
git add device/
git commit -m "[SYNC] Update device to TinyGo v0.39.0"
```

## Source

Device packages are synced from TinyGo official releases:
https://github.com/tinygo-org/tinygo/releases

Refer to `scripts/README.md` for detailed sync instructions.
