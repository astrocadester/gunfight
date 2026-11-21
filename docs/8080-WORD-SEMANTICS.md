# Gun Fight (1975) — indexed interpreter word semantics, pass 2

Source: original 4 KB 8080 image and native handler trace; vector base `$09AE`, dispatcher `$03A7`, script pointer RAM `$2000`, default script `$0821`, alternate `$089B`.

**Correction:** the previously published 30-entry count extended the vector read past the credible executable-handler region. Only indices `$00–$14` (21 native handler entries) are currently defensible. No numeric bound test occurs before indexing, but the bytes that decode as addresses for `$15–$1D` lead into apparent game data (`$091B`, `$0936` etc.), not a validated nine additional words. Do not claim 30 semantically decoded words.

| Op | Entry | Working descriptive name (not original) | Input and observed effect | Confidence |
|---|---|---|---|---|
| 00 | 0813 | WAIT_OR_REPEAT | Counter at `$20C5`; on nonzero counter, decrement `$2000` to re-execute a byte; otherwise return | M |
| 01 | 05E9 | DRAW_FORMATTED_DATA | Reads byte plus two little-endian pointers from script (5 bytes); walks source and destination under a character/positioning routine | M |
| 02 | 063D | SET_2003 | Reads 1 immediate byte, writes `$2003` | H |
| 03 | 0649 | SET_2015 | Reads 1 immediate byte, writes `$2015` | H |
| 04 | 0655 | CLEAR_DISPLAY_MEMORY | Disables interrupts, changes SP to `$400F`, pushes zeros across screen-address region, resets output port `$01`, restores `$2400` stack and resumes by saved PC | H |
| 05 | 068D | COPY_INLINE_15 | Reads destination16 and copies 15 following literal script bytes to RAM using helper `$0372` (`C=$0F`) | H |
| 06 | 069D | COPY_INLINE_9 | Reads destination16 and copies 9 following literal script bytes to RAM using helper `$0372` (`C=$09`) | H |
| 07 | 0670 | CLEAR_OBJECT_FLAGS | Reads address16; masks pointed byte with `$BF` and zeroes following byte | H |
| 08 | 06AD | TOGGLE_OBJECT_BITS | Reads address16; XORs pointed byte with `$60` | H |
| 09 | 0682 | GOTO_SCRIPT | Reads address16 and stores that address into `$2000` | H |
| 0A | 06BC | GAME_DISPLAY_SEQUENCE | Drives port `$02`, reads game state `$2002`, invokes drawing helper `$022D`, modifies `$2016` | M |
| 0B | 0749 | INITIALIZE_OBJECT | Reads address16 plus inline parameters and writes object fields, counters and pointers | M |
| 0C | 0738 | INCREMENT_BCD_AND_RESET | Reads address16, increments byte using `DAA` (packed decimal), calls `$05A3`; then falls through to object-init handler `$0749` | H |
| 0D | 0775 | OUTPUT_AND_SET_2014 | Reads two immediate bytes; outputs first to port `$01`, stores second at `$2014` | H |
| 0E | 0785 | FILL_RECTANGLE | Reads address16 as packed count/stride inputs; references `$201D`, invokes address helper `$0359`, writes repeated bytes in nested loop | M |
| 0F | 07AB | EXPAND_GRAPHICS_TABLE | Copies and bit-transforms packed table at ROM `$0BC4` into RAM starting `$2100` | M |
| 10 | 0807 | CONDITIONAL_GOTO_0882 | If `[$2008]!=0`, sets interpreter pointer to `$0882`; otherwise returns | H |
| 11 | 07E9 | DRAW_STATUS_203F | Selects `$203F`, then common draw path at `$07F2` | M |
| 12 | 07EF | DRAW_STATUS_202C | Selects `$202C`, then same draw path at `$07F2` | M |
| 13 | 05A3 | UPDATE_SCORE_TEXT | Refreshes digit characters from state starting `$2002` into RAM around `$201E`, then proceeds via `$05FB` | M |
| 14 | 03C9 | INPUT_AND_EVENT_DISPATCH | Executes wait helper, samples input ports `$00/$01`, uses state `$2017/$2018/$201C`, and may redirect `$2000` through table `$09D6` | M |

**Widths** refer to bytes after the opcode, not total packet size. For words `$05/$06`, the width is respectively 17 and 11 bytes **after the command** (destination16 plus literal payload). For mixed graphics words (`01`, `0A`, `0B`, `0E`), additional source-level record structure is not yet completely established. The table does not claim original historical word spellings.

## Important control-flow evidence

The zero handler at `$0813` is **not** a simple frame scheduler handoff like the zero-byte path in Desert Gun. The `$03C4–$03C8` dispatcher pushes continuation `$03A6`, so ordinary handler `RET` resumes interpreter execution. Words `09`, `10` and `14` actively change the command stream; `04` temporarily repurposes the hardware stack while clearing display memory.

## False-positive word entries

The original 30-entry extraction advanced 18 extra bytes beyond the last defensible native vector at index `$14`. For example, candidate `$15 → $091B` and `$16 → $0936` decode to inconsistent control flow and data-looking sequences (including stray `DB` bytes). These are **not** established command words. Establish true maximum script opcode by parsing all command packets, not merely by extending table decoding.

---
# DNA 8080 indexed-command evolution — second semantic pass

Scope: **8080 arcade games only**. The Z80/TERSE generation is excluded.

## Chronological evidence

| Game | Date | Architecture established | Meaningful contrast |
|---|---|---|---|
| Gun Fight | 1975 | byte-indexed native dispatch; pointer `$2000`; vector base `$09AE` | command words combine memory mutation, display preparation, interrupt/I/O management and game-state handling |
| Tornado Baseball | 1976 | 26-command indexed interpreter; pointer `$2000`; frame handoff `$1A` | larger game-action vocabulary and explicit scheduled frame transition |
| Boot Hill | 1977 | 16 nonzero command vectors; pointer `$2006`; zero scheduler handoff | related architecture, but changed pointer convention; direct source ancestry not established |
| Desert Gun | 1977 | 12 nonzero command vectors; pointer `$2000`; zero scheduler handoff | small, specialized game-word set; follows later dispatcher/scheduler organization |
| Double Play | 1977 | 28 command positions; pointer `$2000` | extensible 28-position baseball command family |
| Extra Inning | 1978 | 28 command positions; pointer `$2000` | strong continuity with Double Play in ordered command packets |

**What is established:** the 1975 Gun Fight ROM implements a one-byte index into native addresses at `$09AE`, and the 1977 Desert Gun ROM similarly indexes `$0F61`. This pushes bytecode-style native dispatch earlier than Tornado Baseball. A shared word name or direct reuse of source must be supported by matching native behavior and operand ABI; corresponding opcode numbers alone are not evidence.

## Two execution styles, not a monotonic command count

Gun Fight dispatch (`$03A7–$03C8`) takes the next byte from the ROM script, stores the advanced pointer at `$2000`, doubles the index into the little-endian vector table, pushes a continuation (`$03A6`) and transfers by `PCHL`. A byte at `$20C6` can redirect command fetch to alternate stream `$089B`. The dispatcher has no obvious bounds check. **Only vectors `$00–$14` have defensible native code targets.** Apparent entries `$15–$1D` after this section point into byte sequences that look like structured game data rather than independently valid handlers. The earlier “30 words” assertion was therefore overcounted.

Desert Gun dispatch (`$11D0–$11E9`) tests opcode zero before table lookup. **Zero invokes the frame scheduler at `$11EA`** rather than the table's `$0FAB` return stub. Nonzero values dispatch through `$0F61`, with a saved bytecode pointer at `$2000`; 12 nonzero handlers are tabulated. This arrangement resembles the scheduler handoff in several later 8080 games, but the exact inheritance chain is unresolved.

## Word-analysis method

Distinguish **slot** (index addressable by dispatch), **handler** (native code with a reachable entry), **word** (defined machine-state effect and operand format), and **invoked word** (actually found in decoded game scripts). The attached catalogs use confidence labels: **H** = direct machine-state semantics and operand width identifiable; **M** = operation established but high-level game meaning incomplete; **L** = partial semantics only. “Handler exists” must not be counted as a fully understood source-language word. In particular, no speculative friendly label is treated as an original DNA name.

Next RE checks: trace actual script packet boundaries from script roots, build per-word frequency and calls-to-native-services maps, distinguish game-local words from reusable runtime services, and cross-reference operand addresses with hardware documentation.
