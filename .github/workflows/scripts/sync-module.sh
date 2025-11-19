#!/bin/bash

set -e

# Usage: sync-module.sh <module> <version> [platform]
# Example: sync-module.sh device v0.39.0 [linux-amd64]

if [ $# -lt 2 ]; then
    echo "Usage: $0 <module> <version> [platform]"
    echo "Example: $0 device v0.39.0"
    exit 1
fi

MODULE="$1"
VERSION="$2"
PLATFORM="${3:-linux-amd64}"

echo "========================================="
echo "Syncing $MODULE module"
echo "Version: $VERSION"
echo "Platform: $PLATFORM"
echo "========================================="

# Prepare paths
VERSION_NUM=${VERSION#v}
DOWNLOAD_URL="https://github.com/tinygo-org/tinygo/releases/download/${VERSION}/tinygo${VERSION_NUM}.${PLATFORM}.tar.gz"
TEMP_DIR="tinygo_temp"
SOURCE_DIR="${TEMP_DIR}/tinygo/src/${MODULE}"
TARGET_DIR="${MODULE}/"

# Download TinyGo release
echo "Downloading TinyGo from: $DOWNLOAD_URL"
curl -L -o tinygo.tar.gz "$DOWNLOAD_URL"

# Extract to temporary directory
echo "Extracting archive..."
mkdir -p "$TEMP_DIR"
tar -xzf tinygo.tar.gz -C "$TEMP_DIR"

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist in downloaded archive"
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
