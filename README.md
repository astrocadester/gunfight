# Gun Fight

![Gun Fight](images/gun-fight-15120-marquee.jpg)

Gun Fight (1975) is an Intel 8080 Midway/Dave Nutting Associates arcade game. This repository preserves the original ROM set, reconstructs native executable instructions, and documents an indexed-bytecode interpreter present in its program ROM.

## Interpreter and DNA history

The native dispatcher at `$3A7` obtains game commands via the script pointer in RAM `$2000`, selects native handlers using the table at `$9AE`, and transfers control through an indirect jump. The table has **30 entries**. The first known program stream starts at `$821`.

See [recovered command vectors](docs/interpreter.md) and [machine-readable trace](docs/recovery.json). This is earlier than the 26-command Tornado Baseball interpreter and establishes an interpreter-based DNA arcade architecture in 1975. Do not confuse command-vector counts with a count of fully semantically decoded game words.

## Project layout

| Path | Purpose |
|---|---|
| `roms/original/gunfight.zip` | Original ROM devices; source of truth |
| `src/gunfight.asm` | Annotated native reconstruction generated from original ROM |
| `src/zout/gunfight.lst` | zmac assembler listing |
| `tools/recover_8080.py` | Reset/IRQ, branch, and command-vector traced native 8080 recovery |
| `tools/interpreter_lineage.py` | Native bytecode vector inventory |
| `tools/verify_rom.py` | Byte-for-byte rebuilt ROM verification, SHA hashes and MAME ROM ZIP |
| `docs/memory-map.svg` | Dark-theme device/region map with evidence caveats |
| `build.sh`, `build.bat` | Linux and Windows reproducible build scripts using bundled zmac 1.3 |

## Build

Linux: `./build.sh`; Windows: `build.bat`. Both regenerate source from the preserved original chips, assemble with the repository's bundled zmac 1.3, split the resulting binary into original chip devices, and fail if **any ROM byte differs**. Built ROM devices and the MAME ZIP are written to `roms/build/`.

## Research status

Confirmed: native indexed dispatch, original device ordering/hashes and target handlers. Native reconstruction follows reset/interrupt vectors, branch targets and dispatch-table entries; unrecovered/ambiguous bytes remain `DB` rather than being misrepresented as reachable code. The map marks candidate board RAM/video addresses separately from verified ROM ranges. Detailed command operand types and all alternate native entry paths remain subjects for deeper RE.
