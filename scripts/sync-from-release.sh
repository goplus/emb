#!/bin/bash

set -e

VERSION=""
SOURCE_PATH=""
TARGET_FOLDER=""

usage() {
    echo "Usage: $0 -v <version> -s <source_path> -t <target_folder>"
    echo ""
    echo "Options:"
    echo "  -v <version>       TinyGo version (e.g., v0.39.0)"
    echo "  -s <source_path>   Source path in TinyGo package (e.g., src/device)"
    echo "  -t <target_folder> Target folder in repository (e.g., device/)"
    echo ""
    echo "Example:"
    echo "  $0 -v v0.39.0 -s src/device -t device/"
    exit 1
}

while getopts "v:s:t:h" opt; do
    case $opt in
        v) VERSION="$OPTARG" ;;
        s) SOURCE_PATH="$OPTARG" ;;
        t) TARGET_FOLDER="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

if [ -z "$VERSION" ] || [ -z "$SOURCE_PATH" ] || [ -z "$TARGET_FOLDER" ]; then
    echo "Error: All parameters are required."
    usage
fi

VERSION_NUMBER="${VERSION#v}"
DOWNLOAD_URL="https://github.com/tinygo-org/tinygo/releases/download/${VERSION}/tinygo${VERSION_NUMBER}.linux-amd64.tar.gz"
TEMP_DIR=$(mktemp -d)
ARCHIVE_FILE="${TEMP_DIR}/tinygo.tar.gz"

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "Downloading TinyGo ${VERSION}..."
if ! wget -q --show-progress --timeout=60 --tries=3 -O "$ARCHIVE_FILE" "$DOWNLOAD_URL"; then
    echo "Error: Failed to download TinyGo release from $DOWNLOAD_URL"
    exit 1
fi

echo "Extracting archive..."
tar -xzf "$ARCHIVE_FILE" -C "$TEMP_DIR"

EXTRACTED_PATH="${TEMP_DIR}/tinygo/${SOURCE_PATH}"

if [ ! -d "$EXTRACTED_PATH" ]; then
    echo "Error: Source path '$SOURCE_PATH' not found in TinyGo package"
    exit 1
fi

echo "Syncing to ${TARGET_FOLDER}..."
mkdir -p "$TARGET_FOLDER"
rm -rf "${TARGET_FOLDER:?}"/*
cp -r "$EXTRACTED_PATH"/* "$TARGET_FOLDER"/

echo "Sync completed successfully!"
echo "  Version: ${VERSION}"
echo "  Source: ${SOURCE_PATH}"
echo "  Target: ${TARGET_FOLDER}"
