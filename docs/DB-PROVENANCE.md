# Gun Fight — native code, script and data ownership

The 4 KB ROM is organized as executable Intel 8080 code, indexed interpreter streams, native and event-vector tables, character patterns, and packed graphics. Sections below use the currently traced native entry points and the root-traversed command inventory.

## Dispatch and vectors

- Dispatcher `$03A7–$03C8`; saved 16-bit script cursor at RAM `$2000`.
- Native words: 21 entries at `$09AE–$09D7`, command bytes `$00–$14`.
- Native input actions: 24 entries at `$097E–$09AD`, including repeated entries and no-op returns.
- Event selector: ten entries from `$09D6–$09E9`. Slot zero shares the native input/event word at `$09D6`; nine following entries at `$09D8–$09E9` point to bytecode scripts, not native words.
- The current [interpreter JSON](interpreter.json), [native vector ownership](ROM-VECTOR-OWNERSHIP.md), and [ASM](../src/gunfight.asm) now use the same count.

## Native code versus script payloads

The old third-pass audit described a raw `DB` region at `$042A–$05A2`. The newer native trace identifies this region as **executable controller and projectile routines**, including input actions at `$042A/$043E` and firing handlers at `$04B0/$0517`. It is not a 377-byte unresolved data block.

The script-root traversal now identifies **82 distinct statically decoded packet locations**, including the initial `$0821` sequence, alternative `$089B` setup, conditional scene `$0882`, and the event scripts from `$091B` through `$0963`. The previous early-prefix audit stopped at `$0840/$08AE/$088B` because copied literal bytes looked like native opcodes. The corrected command widths are:

- `$01`: 5 operand bytes (format8, source16, destination16).
- `$05`: 17 operand bytes (RAM destination16 plus 15 literal bytes).
- `$06`: 11 operand bytes (RAM destination16 plus 9 literal bytes).
- `$0B`: 5 operand bytes (destination16, flags8, pointer16).
- `$0C`: 7 operand bytes (BCD counter16 followed by the `$0B` payload).
- `$09`: target16, with execution resuming at that destination rather than the following ROM byte.

The 82 sites are a **static rooted inventory**, not a count of executed commands or proof that every possible RAM-installed script path has been observed. [Decoded scripts](decoded-scripts.md) provides per-site details.

## Structured native data

- `$0349–$0358`: two four-entry, little-endian frame-pointer tables. The handler at `$0326` extracts two bits of `$2009` to choose one of the four words. The first table points to ROM graphic data; the other points to RAM-expanded objects.
- `$09F8`: ten score-digit glyphs, each 8 pixels wide by 10 rows. The source now represents all 100 glyph bytes individually with inline pixel rows.
- `$0BC4`: packed graphics input read by VM word `$0F`, which transforms data into RAM beginning at `$2100`.
- `$0EE2` and `$0EF0`: two player-specific aim/graphics pointer sources used by native actions at `$042A` and `$043E`.

Only sections with established structure are promoted from anonymous `DB` groups to typed `DW` or named glyph records. The remaining packed bitstream previews are stored-bit views, not verified sprite silhouettes.

## RE tools

Ordinary builds assemble the maintained source and perform chip checks. RE tools are optional and write generated drafts to `src/zout/` or `docs/generated/`, without replacing reviewed assembly, memory-map artwork, or command documentation.

Recommended independent investigations: trace other packed graphics to object dimensions and draw calls; enumerate native interrupts and object-table cycles; run actual zmac and MAME verification. Source-level findings should be reconciled with native output before merge.

## Projectile and event-table use

[Gameplay and collision RE](GAMEPLAY-AND-COLLISION-RE.md) documents the original projectile IRQ lookup into scene-state bytes at `$0F3A` and the selected event pointer indexing at `$09D6`. The nine selectors at `$09D8–$09E9` are bytecode script targets, not additional native interpreter words.
