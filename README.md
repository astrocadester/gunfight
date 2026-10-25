# Gun Fight

Gun Fight (1975) — Midway / Dave Nutting Associates, Intel 8080 arcade hardware.

![Gun Fight](images/gun-fight-15120-marquee.jpg)

## Reverse-engineering status

This repository preserves the original ROM archive and hardware references. **Executable disassembly, verified address ownership, and byte-exact reconstruction are pending.** Do not interpret a framebuffer or barrel-shifter routine as evidence of a bytecode interpreter without tracing its input stream and dispatch semantics.

| Area | Current evidence / next verification |
| --- | --- |
| ROM archive | `roms/original/gunfight.zip` (preserved; contents not yet enumerated in this baseline) |
| CPU | Intel 8080 |
| Disassembly | Pending extraction, ROM ordering, 8080 control-flow analysis |
| Game scheduling | Trace interrupt/event handoffs and per-frame state updates |
| Graphics | Identify hardware I/O versus software operations and shared native services |
| Interpreter hypothesis | Search for script pointer, byte fetch, bounds check, indexed dispatch, handler return/advance, and ROM-resident command packets |
| Memory ownership | Provisional map in `images/gunfight-memory-map.svg`; addresses not yet verified |
| Rebuild | `build.sh` / `build.bat` are prepared for `src/gunfight.asm`; they intentionally fail until a genuine recovered source exists |

## Project layout

| Path | Purpose |
| --- | --- |
| `roms/original/gunfight.zip` | Original ROM set |
| `docs/` | Contemporary hardware and game documentation |
| `images/` | Cabinet/PCB imagery and provisional memory diagram |
| `tools/zmac`, `tools/zmac.exe` | Bundled zmac 1.3 |
| `build.sh`, `build.bat` | Linux and Windows assembly entry points |
| `src/gunfight.asm` | Planned annotated, ROM-grounded Intel 8080 disassembly (not yet present) |

## Build

Linux: `./build.sh`. Windows: `build.bat`. Both scripts call the bundled zmac directly and place outputs in `build/`. They do **not** claim a byte-identical ROM rebuild yet. The assembler source must first be reconstructed from the original archive and checked against each chip's original bytes.

## DNA interpreter evolution

Gun Fight is the early 8080 baseline: test whether its native object, raster, collision and timing routines already form a reusable game framework. A hardware barrel shifter is a graphics accelerator, not automatically an instruction interpreter.

The confirmed comparative baseline is Tornado Baseball's 26-command indexed dispatcher, Double Play and Extra Inning's 28-command dispatchers, and Sea Wolf II's Z80 threaded TERSE execution. Similar services alone do not prove direct source lineage.

## RE acceptance criteria

Recover chip ordering and hashes; identify reset/interrupt vectors and all reachable native routines; annotate I/O and RAM accesses; locate or rule out the **specific indexed dispatch signature** (without claiming to exclude all other interpreters); reconstruct source; assemble with zmac 1.3; verify each rebuilt chip byte-for-byte; replace provisional map with ROM-supported address ranges.
