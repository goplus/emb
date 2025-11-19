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
mkdir -p "$(dirname "$TARGET_DIR")"

# Fully replace directory content
echo "Replacing directory content..."

# Step 1: Copy source to temporary location
TEMP_DIR="${TARGET_DIR}.tmp"
rm -rf "$TEMP_DIR"
cp -r "$SOURCE_DIR" "$TEMP_DIR"

# Step 2: Delete original target directory
rm -rf "$TARGET_DIR"

# Step 3: Rename temporary directory to target
mv "$TEMP_DIR" "$TARGET_DIR"

echo "✅ Directory replacement completed"

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
