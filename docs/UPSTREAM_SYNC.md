# Upstream Sync Guide

## Background

LLGo's embedded support uses TinyGo's base library implementations and APIs. To sync TinyGo upstream updates while maintaining our LLGo-specific adaptations.

## Branch Structure

| Branch | Purpose | Source | Modifications Allowed |
|--------|---------|--------|----------------------|
| `device` | TinyGo device module mirror | TinyGo official `src/device` | ❌ Sync only, no modifications |
| `machine` | TinyGo machine module mirror | TinyGo official `src/machine` | ❌ Sync only, no modifications |
| `main` | Uses device/machine + our adaptations | merge device/machine + custom modifications | ✅ Via PR only |

The `device` and `machine` branches automatically sync updates from TinyGo official modules. See [Automated Sync Mechanism](#automated-sync-mechanism) for details.

## Core Principles

By keeping the `device` and `machine` branches pristine, we can:

- ✅ Clearly show in PRs: what upstream updated + what we adapted
- ✅ Preserve complete update history through merge commits
- ✅ Simplify future upstream update workflows

## Workflows

### Upgrading TinyGo Version

When upgrading to a new TinyGo version (e.g., from v0.38.0 to v0.39.0):

#### 1. Wait for Automated Sync

The `device` and `machine` branches will automatically detect the new version and create sync PRs. Review and merge these PRs.

#### 2. Create Upgrade PR

Create an upgrade PR on your development branch. This PR will contain three commits:

```bash
# Ensure local device and machine branches are up to date
git checkout device
git pull upstream device
git checkout machine
git pull upstream machine

# Create upgrade branch from main
git checkout main
git pull upstream main
git checkout -b upgrade-tinygo-v0.39.0

# Commit 1: Merge device branch
git merge device

# Commit 2: Merge machine branch
git merge machine

# Commit 3: Apply our adaptation changes
# Modify code to adapt to the new version
# ... edit files ...
git add .
git commit -m "feat: Adapt to TinyGo v0.39.0"

# Push to your remote repository
git push origin upgrade-tinygo-v0.39.0
```

Then create a PR to the upstream repository's main branch on GitHub.

#### 3. PR Structure

This upgrade PR will clearly show:
- **Merge device commit**: Upstream updates to the device module
- **Merge machine commit**: Upstream updates to the machine module
- **Adaptation commit**: Changes we made to adapt to the new version

### Daily Feature Development

For feature development that doesn't involve TinyGo version upgrades:

```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/my-feature

# Develop
# ... edit files ...

# Commit changes
git add .
git commit -m "feat: Add new feature"

# Push and create PR
git push origin feature/my-feature
```

## Automated Sync Mechanism

The `device` and `machine` branches automatically sync updates from TinyGo official modules.

### Monitoring Rules

#### Scheduled Checks
- Runs automatically once per day

#### Version Detection
1. Fetch the latest stable version from TinyGo official releases API
2. Read current version from the latest `[SYNC]` commit in `device` branch
3. Read current version from the latest `[SYNC]` commit in `machine` branch
4. Compare version numbers and trigger sync when new version is found
5. **Special case**: If no commit matching `[SYNC] Sync {device|machine} from TinyGo vX.Y.Z` format is found in the branch, treat as initial state and trigger sync for any stable version

#### Version Filter Rules
- ✅ **Accept**: Stable versions (format: `v{number}.{number}.{number}`)
  - Examples: `v0.38.0`, `v0.39.0`, `v0.39.1`, `v1.0.0`
- ❌ **Reject**: Pre-release versions
  - Examples: `v0.39.0-rc1`, `v0.39.0-beta`, `latest`

#### Version Scope
- Monitor **major**, **minor**, and **patch** versions

### Automated Sync Process

When a new version is detected, GitHub Actions will automatically create upgrade PRs for `device` and `machine` branches:

- Download TinyGo new version (using linux-amd64 version, as `src/device` and `src/machine` content is identical across all platforms)
- Extract `src/device` and `src/machine` directory contents separately
- Create corresponding branches for each module: `sync-device-vX.Y.Z` and `sync-machine-vX.Y.Z`
- Sync files to corresponding directories
- Commit with message: `[SYNC] Sync {device|machine} from TinyGo vX.Y.Z`
- Create PRs to `device` and `machine` branches respectively

### Security Rules
- **No** auto-merge allowed
- PRs require manual review after creation
- PRs should clearly show which files were modified
