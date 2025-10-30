# TinyGo Automated Sync Workflow

## Objective

Create an automated workflow to monitor TinyGo official releases. When a new version is released, automatically sync to our `device` and `machine` branches and create PRs.

## Monitoring Rules

### Scheduled Checks

- Run automatically once per day

### Version Detection

1. Fetch the latest stable version from TinyGo official releases API
2. Read current version from the latest `[SYNC]` commit in `device` branch
3. Read current version from the latest `[SYNC]` commit in `machine` branch
4. Compare version numbers and trigger sync when new version is found
5. **Special Case**: If no commit matching `[SYNC] Sync {device|machine} from TinyGo vX.Y.Z` format is found in the branch, treat as initial state and trigger sync for any stable version

### Version Filter Rules

- ✅ **Accept**: Stable versions (format: `v{number}.{number}.{number}`)
  - Examples: `v0.38.0`, `v0.39.0`, `v0.39.1`, `v1.0.0`
- ❌ **Reject**: Pre-release versions
  - Examples: `v0.39.0-rc1`, `v0.39.0-beta`, `latest`

### Version Scope

- Monitor **major**, **minor**, and **patch** versions

## Workflow Structure

### Job 1: Check for updates

- Fetch latest TinyGo version
- Read current versions from `device` and `machine` branches
- Determine if update is needed

### Job 2 & 3: Sync device and machine (if new version available)

For each target (`device` and `machine`):

- Download new TinyGo version (linux-amd64)
- Extract `src/{target}` directory contents
- Create new branch `sync-{target}-vX.Y.Z`
- Sync files to `{target}/` directory
- Commit with message: `[SYNC] Sync {target} from TinyGo vX.Y.Z`
- Create PR to `{target}` branch

## PR Specifications

### Commit Message Format

```
[SYNC] Sync {device|machine} from TinyGo vX.Y.Z
```

### PR Title Format

```
[SYNC] Sync {device|machine} from TinyGo vX.Y.Z
```

### PR Body Should Include

- TinyGo version being synced
- File change statistics
- Link to TinyGo release notes

## Security Rules

- **No** auto-merge allowed
- PRs require manual review after creation
- PRs should clearly show which files were modified
