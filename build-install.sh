#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="/home/automaton/.local/bin/cliproxyapi"
IMAGE="cliproxyapi:dev"

echo "Building from $REPO_DIR ..."
docker build -t "$IMAGE" "$REPO_DIR"

cid=$(docker create "$IMAGE")
docker cp "$cid:/CLIProxyAPI/CLIProxyAPI" "$OUTPUT"
docker rm "$cid" > /dev/null

echo "Installed to $OUTPUT"
systemctl --user restart cliproxyapi && echo "Service restarted."
