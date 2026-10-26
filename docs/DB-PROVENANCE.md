# Gun Fight — third-pass ROM data and word audit

This is a byte-preserving classification of the original 4,096-byte ROM source, not a blanket conversion of every `DB` to a purported machine instruction. The assembler remains authoritative for output identity.

## Static interpreter facts
- 8080 dispatch: `$03A7–$03C8`; saved script pointer `$2000`; initial root `$0821`.
- Byte at `$20C6` selects alternate stream `$089B`.
- Little-endian vector addresses begin at `$09AE`; **21 defensible native handlers**, opcodes `$00–$14` (42 vector bytes through `$09D7`).
- Extra pair-shaped bytes at `$09D8` onward are not confirmed callable words, despite the old report counting 30.
- Handler `$0682` can replace script pointer with an inline 16-bit target (opcode `$09`); handler `$0807` redirects conditionally to `$0882`.

## Raw DB provenance

From `src/gunfight.asm`, 2,395 original ROM bytes remain `DB` (208 grouped directives before this annotation pass). The largest contiguous spans are:

| ROM interval | DB bytes | Interpretation |
| --- | ---: | --- |
| `$042A–$05A2` | 377 | Native-unreached data area; contents still require individual table/reference decoding. Not evidence of an interpreter. |
| `$0821–$091A` | 250 | Script-bearing interval: bytecode, immediate operands, and nearby packed data. Do not linear-disassemble whole span. |
| `$091D–$0935` | 25 | Data immediately following a script-bearing region; opcodes not verified. |
| `$0965–$0FFF` | 1,691 | Mixed data: 21-entry vector table at `$09AE–$09D7`, multiple game tables and graphics. The portion `$0B00–$0FFF` has repeating bitmap/glyph patterns. |
| other isolated spans | 52 | Padding, gaps, and untraced small data blocks; needs xrefs rather than arbitrary native conversion. |

Data that contain numerically valid 8080 opcodes are **not** automatically executable code. A raw vector pair is **not** automatically a game word.

## Rooted packet audit (deterministic)

Run `python3 tools/audit_words.py` from either OS (standard Python 3; no third-party libraries). It reads the checked-in original ROM ZIP, emits `docs/word-audit.json`, and *stops* at unknown boundaries:

| Start | Safely parsed packets | Stop | Explanation |
| --- | ---: | --- | --- |
| `$0821` | 12 | `$0840` (`C3`) | 8080 jump-like byte; more source/control analysis required before treating it as a command. |
| `$089B` | 7 | `$08AE` (`C0`) | Beyond confirmed word indexes; possible embedded packed record or unresolved handler packet size. |
| `$0882` | 2 | `$088B` (`C3`) | Unknown boundary, not proof of opcode `C3`. |

The audit refuses to treat these raw bytes as game words. Counts are **only bounded-prefix evidence**, not whole-program usage frequencies.

## Remaining high-value RE

Trace `$0372` (words `$05/$06`) and `$05E9` (formatted draw `$01`) to their final pointer updates; resolve word `$0B/$0C` variable descriptors and every branch that replaces `$2000`. Only then is full script demarcation and word-frequency recovery defensible. Existing per-handler meaning and confidence remain in [8080-WORD-SEMANTICS.md](8080-WORD-SEMANTICS.md).
