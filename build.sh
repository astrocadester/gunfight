#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
echo "Gun Fight original ROM reconstruction"
echo "Source: src/gunfight.asm"
mkdir -p src/zout roms/build
echo "[1/3] Assemble original 4 KB Intel 8080 image"
./tools/zmac -c -o roms/build/gunfight.bin -x src/zout/gunfight.lst src/gunfight.asm
test "$(wc -c < roms/build/gunfight.bin)" -eq 4096 || { echo "ERROR: expected 4096 bytes"; exit 1; }
echo "[2/3] Verify four ROM devices against original SHA-1"
names=(7609h.bin 7609g.bin 7609f.bin 7609e.bin)
hashes=(99d01313e251818d336281700e206d9003c71dae c177e3f72db9af17ab99b2481448ca26318184b9 215b068663e431582591001cbe028929fa96d49f de3f2e6841122bbe6e2fda5b87d37842c072289a)
for i in 0 1 2 3; do
  dd if=roms/build/gunfight.bin of="roms/build/${names[$i]}" bs=1024 skip="$i" count=1 status=none
  actual="$(sha1sum "roms/build/${names[$i]}" | cut -d' ' -f1)"
  printf "%s  %s\n" "$actual" "${names[$i]}"
  if [[ "$actual" != "${hashes[$i]}" ]]; then echo "ERROR: ROM mismatch: ${names[$i]}"; exit 1; fi
done
echo "PASS: Four original ROM devices match"
echo "[3/3] Package MAME ROM set"
rm -f roms/build/gunfight.zip
(cd roms/build && zip -q gunfight.zip "${names[@]}")
echo "PASS: roms/build/gunfight.zip"
echo "RE-only tools: python3 tools/audit_words.py (not part of build)"
