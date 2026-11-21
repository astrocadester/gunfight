#!/usr/bin/env bash
# Gun Fight original Intel 8080 ROM build — zmac v1.3; no Python.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
fail() { echo "ERROR: $*" >&2; exit 1; }
for cmd in dd sha1sum zip stat; do command -v "$cmd" >/dev/null 2>&1 || fail "Missing command: $cmd"; done
if [[ -n "${ZMAC:-}" ]]; then
    zmac_bin="$ZMAC"
elif [[ -x tools/zmac ]]; then
    zmac_bin=tools/zmac
else
    zmac_bin=zmac
fi
command -v "$zmac_bin" >/dev/null 2>&1 || fail 'zmac v1.3 not found (set ZMAC or use tools/zmac)'
[[ -f src/gunfight.asm ]] || fail 'Missing src/gunfight.asm'
[[ -f roms/original/gunfight.zip ]] || fail 'Missing reference roms/original/gunfight.zip'

rom_names=(7609h.bin 7609g.bin 7609f.bin 7609e.bin)
rom_sha1=(
    99d01313e251818d336281700e206d9003c71dae
    c177e3f72db9af17ab99b2481448ca26318184b9
    215b068663e431582591001cbe028929fa96d49f
    de3f2e6841122bbe6e2fda5b87d37842c072289a
)
echo 'Gun Fight original ROM build'
echo '[1/4] Prepare output'
mkdir -p build roms
rm -f build/gunfight.bin build/gunfight.lst roms/gunfight.zip
for name in "${rom_names[@]}"; do rm -f "build/$name"; done

echo '[2/4] Assemble native Intel 8080 source (zmac v1.3)'
"$zmac_bin" -c -o build/gunfight.bin -x build/gunfight.lst src/gunfight.asm || fail 'Assembly failed'
[[ -s build/gunfight.bin ]] || fail 'Assembler did not produce a binary image'
size=$(stat -c %s build/gunfight.bin)
(( size == 4096 )) || fail "Binary image is $size bytes; expected 4096"

echo '[3/4] Split and verify four 1 KB ROMs'
for i in 0 1 2 3; do
    name=${rom_names[i]}
    dd if=build/gunfight.bin of="build/$name" bs=1024 skip="$i" count=1 status=none
    size=$(stat -c %s "build/$name")
    (( size == 1024 )) || fail "$name is $size bytes; expected 1024"
    actual=$(sha1sum "build/$name"); actual=${actual%% *}
    if [[ "$actual" != "${rom_sha1[i]}" ]]; then
        echo "ERROR: $name SHA1 mismatch: expected ${rom_sha1[i]}, got $actual" >&2
        if command -v unzip >/dev/null 2>&1 && command -v cmp >/dev/null 2>&1; then
            echo 'First byte differences (device offset decimal, byte values octal):' >&2
            cmp -l <(unzip -p roms/original/gunfight.zip "$name") "build/$name" |
                awk 'NR<=30 {printf "  %6d  %8s  %9s\n", $1-1, $2, $3} END {printf "  Total differing bytes: %d\n", NR}' >&2 || true
        fi
        fail "ROM verification failed; original archive and assembled device are preserved"
    fi
    echo "  $name  OK  $actual"
done
echo '[4/4] Package roms/gunfight.zip'
(cd build && zip -q -X ../roms/gunfight.zip "${rom_names[@]}") || fail 'ROM packaging failed'
[[ -s roms/gunfight.zip ]] || fail 'ROM ZIP not created'
echo 'Build complete: roms/gunfight.zip'
