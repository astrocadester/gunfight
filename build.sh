#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p src/zout roms/build docs
python3 tools/recover_8080.py gunfight
python3 tools/interpreter_lineage.py
python3 tools/memory_map.py
./tools/zmac -c -o roms/build/gunfight.bin -x src/zout/gunfight.lst src/gunfight.asm
python3 tools/verify_rom.py
