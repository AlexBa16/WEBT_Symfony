#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/_images"

usage() {
    echo "Usage: $0 [options] [app|all]"
    echo ""
    echo "Builds the Docker image for the Symfony app."
    echo "Default target: all"
    echo ""
    echo "Options:"
    echo "  -c, --clean     Clean build (no cache)"
    echo "  -e, --export    Export built image as .tar file to _images/"
    echo "  -h, --help      Show this help"
}

build_app() {
    echo "==> Building Symfony image..."
    docker build $CLEAN -t webt-symfony "$SCRIPT_DIR"
    echo "==> Symfony image built successfully."
}

export_image() {
    local name="$1"
    mkdir -p "$EXPORT_DIR"
    echo "==> Exporting $name to $EXPORT_DIR/$name.tar ..."
    docker save -o "$EXPORT_DIR/$name.tar" "$name"
    echo "==> Exported $name ($(du -h "$EXPORT_DIR/$name.tar" | cut -f1))"
}

CLEAN=""
EXPORT=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--clean)  CLEAN="--no-cache"; shift ;;
        -e|--export) EXPORT=true; shift ;;
        -h|--help)   usage; exit 0 ;;
        app|all)     TARGET="$1"; shift ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

TARGET="${TARGET:-all}"

case "$TARGET" in
    app|all)
        build_app
        $EXPORT && export_image webt-symfony
        ;;
esac
