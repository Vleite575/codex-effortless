#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN="$ROOT/CodexEffortlessOverlay"
swiftc "$ROOT/CodexEffortlessOverlay.swift" -o "$BIN" -framework AppKit -framework CoreGraphics
exec "$BIN"
