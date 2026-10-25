#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
SRC="src/gunfight.asm"
if [[ ! -f "$SRC" ]]; then
  echo "RE incomplete: $SRC has not yet been recovered from the original ROM." >&2
  exit 2
fi
mkdir -p build
chmod +x tools/zmac
./tools/zmac --zmac -o "build/gunfight.bin" "$SRC"
echo "Assembled build/gunfight.bin; chip-by-chip ROM identity is not yet verified."
