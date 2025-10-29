#!/bin/bash

set -e

usage() {
    echo "Usage: $0 <tinygo-version> <source-path> <target-folder>"
    echo ""
    echo "Example: $0 v0.39.0 src/device device/"
    echo ""
    echo "Arguments:"
    echo "  tinygo-version  TinyGo version (e.g., v0.39.0)"
    echo "  source-path     Path in TinyGo package to extract (e.g., src/device)"
    echo "  target-folder   Target directory to extract to (e.g., device/)"
    exit 1
}

if [ $# -ne 3 ]; then
    usage
fi

TINYGO_VERSION=$1
SOURCE_PATH=$2
TARGET_FOLDER=$3

VERSION_NUM=${TINYGO_VERSION#v}
DOWNLOAD_URL="https://github.com/tinygo-org/tinygo/releases/download/${TINYGO_VERSION}/tinygo${VERSION_NUM}.linux-amd64.tar.gz"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Downloading TinyGo ${TINYGO_VERSION} from ${DOWNLOAD_URL}..."
if ! wget --timeout=30 --tries=3 -O "$TEMP_DIR/tinygo.tar.gz" "$DOWNLOAD_URL"; then
    echo "Error: Failed to download TinyGo ${TINYGO_VERSION}"
    exit 1
fi

echo "Extracting ${SOURCE_PATH} to ${TARGET_FOLDER}..."
mkdir -p "$TEMP_DIR/extract"
tar -xzf "$TEMP_DIR/tinygo.tar.gz" -C "$TEMP_DIR/extract"

SOURCE_FULL_PATH="$TEMP_DIR/extract/tinygo/${SOURCE_PATH}"
if [ ! -d "$SOURCE_FULL_PATH" ]; then
    echo "Error: Source path ${SOURCE_PATH} not found in TinyGo package"
    exit 1
fi

rm -rf "$TARGET_FOLDER"
mkdir -p "$(dirname "$TARGET_FOLDER")"
cp -r "$SOURCE_FULL_PATH" "$TARGET_FOLDER"

echo "Successfully synced ${SOURCE_PATH} from TinyGo ${TINYGO_VERSION} to ${TARGET_FOLDER}"
