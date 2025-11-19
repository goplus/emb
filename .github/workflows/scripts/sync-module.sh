#!/bin/bash

set -e

# Usage: sync-module.sh <module> <version> <temp-dir> <source-dir> <target-dir> [platform]
# Example: sync-module.sh device v0.39.0 tinygo_temp src/device device/

if [ $# -lt 5 ]; then
    echo "Usage: $0 <module> <version> <temp-dir> <source-dir> <target-dir> [platform]"
    echo "Example: $0 device v0.39.0 tinygo_temp src/device device/"
    exit 1
fi

MODULE="$1"
VERSION="$2"
TEMP_DIR="$3"
SOURCE_DIR="$4"
TARGET_DIR="$5"
PLATFORM="${6:-linux-amd64}"

echo "========================================="
echo "Syncing $MODULE module"
echo "Version: $VERSION"
echo "Temp directory: $TEMP_DIR"
echo "Source directory: $SOURCE_DIR"
echo "Target directory: $TARGET_DIR"
echo "Platform: $PLATFORM"
echo "========================================="

# Prepare download URL
VERSION_NUM=${VERSION#v}
DOWNLOAD_URL="https://github.com/tinygo-org/tinygo/releases/download/${VERSION}/tinygo${VERSION_NUM}.${PLATFORM}.tar.gz"

# Download TinyGo release
echo "Downloading TinyGo from: $DOWNLOAD_URL"
curl -L -o tinygo.tar.gz "$DOWNLOAD_URL"

# Extract to temporary directory
echo "Extracting archive to $TEMP_DIR..."
mkdir -p "$TEMP_DIR"
tar -xzf tinygo.tar.gz -C "$TEMP_DIR"

# Full path to source in extracted archive
FULL_SOURCE_PATH="${TEMP_DIR}/${SOURCE_DIR}"

# Verify source directory exists
if [ ! -d "$FULL_SOURCE_PATH" ]; then
    echo "Error: Source directory $FULL_SOURCE_PATH does not exist in downloaded archive"
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
rsync -av --delete "$FULL_SOURCE_PATH/" "$TARGET_DIR/"

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
