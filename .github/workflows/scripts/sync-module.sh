#!/bin/bash

set -e

# Usage: sync-module.sh <module> <version> <source-dir> <target-dir> [platform]
# Example: sync-module.sh device v0.39.0 src/device device/

if [ $# -lt 4 ]; then
    echo "Usage: $0 <module> <version> <source-dir> <target-dir> [platform]"
    echo "Example: $0 device v0.39.0 src/device device/"
    exit 1
fi

MODULE="$1"
VERSION="$2"
SOURCE_DIR="$3"
TARGET_DIR="$4"
PLATFORM="${5:-linux-amd64}"

echo "========================================="
echo "Syncing $MODULE module"
echo "Version: $VERSION"
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo "Platform: $PLATFORM"
echo "========================================="

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Sync directory content using rsync
echo "Syncing directory content with rsync..."

# Use rsync to fully sync directories
# -a: archive mode (preserves permissions, timestamps, etc.)
# -v: verbose output
# --delete: delete files in dest that don't exist in source
rsync -av --delete "$SOURCE_DIR/" "$TARGET_DIR/"

echo "✅ Directory sync completed"

# Commit changes
echo "Committing changes..."
git add "$TARGET_DIR"

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "No changes to commit"
else
    git commit -m "[SYNC] Sync ${MODULE} from TinyGo ${VERSION}"
    echo "✅ Changes committed"
fi

echo "========================================="
echo "Sync completed successfully"
echo "========================================="
