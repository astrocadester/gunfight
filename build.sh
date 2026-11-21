#!/usr/bin/env bash
# Gun Fight original Intel 8080 ROM build — project zmac v1.3; no Python.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
fail() { echo "ERROR: $*" >&2; exit 1; }

for cmd in dd sha1sum zip stat; do command -v "$cmd" >/dev/null 2>&1 || fail "Missing command: $cmd"; done
if [[ -n "${ZMAC:-}" ]]; then
    zmac_bin="$ZMAC"
elif [[ -x tools/zmac ]]; then
    zmac_bin=tools/zmac
else
    fail 'Project assembler tools/zmac is missing (or set ZMAC explicitly)'
fi
[[ -x "$zmac_bin" ]] || command -v "$zmac_bin" >/dev/null 2>&1 || fail "Assembler unavailable: $zmac_bin"
[[ -f src/gunfight.asm ]] || fail 'Missing RE source: src/gunfight.asm'
[[ -f roms/original/gunfight.zip ]] || fail 'Missing original ROM archive: roms/original/gunfight.zip'

names=(7609h.bin 7609g.bin 7609f.bin 7609e.bin)
sha1=(
    99d01313e251818d336281700e206d9003c71dae
    c177e3f72db9af17ab99b2481448ca26318184b9
    215b068663e431582591001cbe028929fa96d49f
    de3f2e6841122bbe6e2fda5b87d37842c072289a
)

echo 'Gun Fight native ROM build'
mkdir -p build roms
rm -f build/gunfight.bin build/gunfight.lst roms/gunfight.zip
for name in "${names[@]}"; do rm -f "build/$name"; done

echo '[1/3] Assemble src/gunfight.asm with zmac v1.3'
"$zmac_bin" -c -o build/gunfight.bin -x build/gunfight.lst src/gunfight.asm || fail 'Assembly failed'
[[ -s build/gunfight.bin ]] || fail 'Assembler produced no ROM image'
size=$(stat -c %s build/gunfight.bin)
(( size == 4096 )) || fail "Expected 4096-byte binary; got $size"

echo '[2/3] Split and verify four 1 KB devices'
for i in 0 1 2 3; do
    name=${names[i]}
    dd if=build/gunfight.bin of="build/$name" bs=1024 skip="$i" count=1 status=none
    size=$(stat -c %s "build/$name")
    (( size == 1024 )) || fail "$name size $size, expected 1024"
    actual=$(sha1sum "build/$name"); actual=${actual%% *}
    [[ "$actual" == "${sha1[i]}" ]] || fail "$name SHA-1 mismatch: expected ${sha1[i]}, got $actual"
    echo "  PASS $name  $actual"
done
echo '[3/3] Package original MAME device filenames'
(cd build && zip -q -X ../roms/gunfight.zip "${names[@]}") || fail 'ZIP packaging failed'
[[ -s roms/gunfight.zip ]] || fail 'ZIP output missing'
echo 'PASS: roms/gunfight.zip'
