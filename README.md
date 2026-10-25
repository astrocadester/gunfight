# Gun Fight

![Gun Fight](images/gun-fight-15120-marquee.jpg)

Gun Fight (1975) is an Intel 8080 Midway/Dave Nutting Associates arcade game. This repository preserves the original ROM set, reconstructs native executable instructions, and documents an indexed-bytecode interpreter present in its program ROM.

## Interpreter and DNA 8080 history

The native dispatcher at `$03A7` fetches indexed 8080 game commands through script pointer `$2000` and vector table `$09AE`; the initial script begins at `$0821`. Second-pass word decoding establishes **21 defensible native handler entries ($00–$14); the earlier 30-entry extrapolation included likely data**. Gun Fight predates Tornado Baseball's indexed game-command runtime.

See [per-word native effects and operand formats](docs/8080-WORD-SEMANTICS.md), [original recovered vectors](docs/interpreter.md), and [machine-readable trace](docs/recovery.json). Working names in the semantic catalog describe recovered machine behavior; they are not claimed as the original DNA source-language spellings.

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
