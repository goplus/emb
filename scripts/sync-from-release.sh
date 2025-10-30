#!/bin/bash

set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <tinygo-version> <source-path> <target-folder>"
    echo "Example: $0 v0.39.0 src/device device"
    exit 1
fi

TINYGO_VERSION=$1
SOURCE_PATH=$2
TARGET_FOLDER=$3

VERSION_NUM="${TINYGO_VERSION#v}"

DOWNLOAD_URL="https://github.com/tinygo-org/tinygo/releases/download/${TINYGO_VERSION}/tinygo${VERSION_NUM}.linux-amd64.tar.gz"
TEMP_DIR=$(mktemp -d)
TEMP_ARCHIVE="${TEMP_DIR}/tinygo.tar.gz"

cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "Downloading TinyGo ${TINYGO_VERSION}..."
if ! wget --retry-connrefused --waitretry=1 --read-timeout=30 --timeout=30 -t 3 \
    -O "${TEMP_ARCHIVE}" "${DOWNLOAD_URL}"; then
    echo "Error: Failed to download TinyGo release"
    exit 1
fi

echo "Extracting ${SOURCE_PATH} from TinyGo release..."
mkdir -p "${TARGET_FOLDER}"

if ! tar -xzf "${TEMP_ARCHIVE}" -C "${TEMP_DIR}" "tinygo/${SOURCE_PATH}" --strip-components=1; then
    echo "Error: Failed to extract ${SOURCE_PATH} from archive"
    exit 1
fi

echo "Copying ${SOURCE_PATH} to ${TARGET_FOLDER}..."
rm -rf "${TARGET_FOLDER:?}"/*
cp -r "${TEMP_DIR}/${SOURCE_PATH}"/* "${TARGET_FOLDER}/"

echo "Sync completed successfully!"
echo "Synced: ${SOURCE_PATH} -> ${TARGET_FOLDER}"
echo "TinyGo version: ${TINYGO_VERSION}"
