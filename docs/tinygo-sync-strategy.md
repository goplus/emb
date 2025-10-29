# TinyGo Sync Strategy

## Goals

Establish a clear branch structure to enable us to:
- Track TinyGo official updates
- Clearly demonstrate our customizations on top of TinyGo
- Facilitate code review and maintenance

## Branch Structure

### `machine` Branch
- **Responsibility**: Pure mirror of TinyGo's official `src/machine` module
- **Update Source**: https://github.com/tinygo-org/tinygo (src/machine/)
- **Rules**: Sync only, no custom modifications
- **Commit Tag**: `[SYNC] Update machine to TinyGo <version>`

### `device` Branch
- **Responsibility**: Pure mirror of TinyGo's official `src/device` module
- **Update Source**: https://github.com/tinygo-org/tinygo (src/device/)
- **Rules**: Sync only, no custom modifications
- **Commit Tag**: `[SYNC] Update device to TinyGo <version>`

### `main` Branch
- **Responsibility**: Production code version (protected)
- **Composition**: Merged from `machine` and `device` branches + our custom modifications
- **Rules**: ⛔ No direct push, all changes must go through PR

## Workflow

### 1. Daily Development
- Create development branch from main
- Develop and commit
- Create PR to main
- Code review and merge
- Clean up development branch

### 2. Sync Upstream Updates
- Update machine/device branches (commit with `[SYNC]`)
- Create sync branch or directly create PR
- Resolve conflicts (if any)
- Code review and merge

## Practical Use Cases

### Case 1: Daily Feature Development

**Scenario**: Add new features or modifications

**Process**:
1. Create development branch
2. Develop and commit
3. Create PR to main
4. Review and merge

---

### Case 2: Merge Upstream Updates

**Scenario**: TinyGo releases new version, sync to our repository

**Notes**:
- Do not directly track upstream dev branch
- Track upstream minor version updates

**Process**:
1. Sync to machine branch (commit with `[SYNC]`)
2. Sync to device branch (commit with `[SYNC]`)
3. On main branch, sync files from machine and device branches
4. Apply our custom modifications on the updated base (if needed)
5. Create PR to main
