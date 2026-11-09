# Gun Fight — RE technical debt

The maintained 8080 source is `src/gunfight.asm`. The engineering rules and verification process are in [ENGINEERING-RULES.md](../ENGINEERING-RULES.md). Status reflects source evidence and tests actually executed.

## Current register

| ID | Status | Work remaining / exit evidence |
| --- | --- | --- |
| GF-RE-001 | In progress | Interpreter, word handlers, all eight directional input actions, no-op action vectors, text, sprite, shot and object helpers are named; additional internal native blocks still use address labels. Complete their cross-reference and register contracts. |
| GF-RE-002 | In progress | Both player aim, fire, shot counters, sprite/bitmap writer, score and event paths traced. Trace collision outcomes, full timer transitions, object lifetime and sound/cabinet outputs end to end. |
| GF-RE-003 | In progress | Ten 8×10 font glyphs and five width/height-prefixed patterns are now decoded inline. Resolve remaining graphics streams, animation names, hardware shift/orientation and object frame identities. |
| GF-RE-004 | Closed — static scope | Old bounded-prefix report reconciled with 82 statically decoded command sites; exact operand sizes and 21+9 vector split aligned across source, word catalog, interpreter JSON and ROM ownership. Dynamic native-installed scripts remain GF-RE-008. |
| GF-RE-005 | Closed — generator isolation | `recover_8080.py` writes to `src/zout/gunfight-recovered.asm`; the audit, interpreter and memory-map research tools write to `docs/generated/` instead of overwriting maintained source or reviewed docs. None is used in normal builds. |
| GF-RE-006 | Awaiting native execution | Run Linux/Windows bundled zmac builds, verify all four chip hashes, launch MAME; record actual results separately. Static ROM layout validation is not a substitute for this gate. |
| GF-RE-007 | Pending WB round-trip | After native assembly verification, reconcile any verified new Gun Fight architecture details into the WB runtime-variants document. |
| GF-RE-008 | Open | Trace interrupt scheduling and RAM-installed script/graphics state dynamically, including control paths not represented by static ROM-root traversal. |

## Pass v20261108-0003 — evidence

- **Native helper ABI corrected:** `TAKE_AND_CLEAR_OBJECT_POINTER` (`$02BD`) returns the saved pointer in HL and the address after the cleared field in DE, via `EX DE,HL`; the earlier description reversed these values.
- **Native handler/source alignment:** ten more word and rendering helpers named, eight axis-action entry points and six shared return-table positions identified, and all 82 script labels aligned with the word catalog.
- **Structured tables:** four-entry frame-pointer tables at `$0349` and `$0351` represented as `DW`, with original frame pointers expressed symbolically where decoded.
- **Inline graphics:** ten digit glyphs plus five header-bounded object patterns displayed as literal row bytes and stored-bit previews. See [GRAPHICS.md](GRAPHICS.md).
- **Tool safety:** RE generators now target separate generated files and preserve the human-maintained source and docs.
- **Static source-layout check executed:** 4 KB, contiguous `ORG $0000,$0400,$0800,$0C00`; expected named entry addresses verified; 310 unique source labels; no unresolved symbolic code references in this inspection.
- **Not executed:** zmac binary build, SHA-1 chip comparison, MAME, Windows build and physical hardware.

The retained original ROM and direct native assembler verification remain the final byte-identity gate. Do not mark GF-RE-006 closed on source-layout checks alone.
