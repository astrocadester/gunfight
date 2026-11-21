# Gun Fight — RE technical debt

The maintained 8080 source is `src/gunfight.asm`. The engineering rules and verification process are in [ENGINEERING-RULES.md](../ENGINEERING-RULES.md). Status reflects source evidence and tests actually executed.

## Current register

| ID | Status | Work remaining / exit evidence |
| --- | --- | --- |
| GF-RE-001 | Source-label and static-flow pass complete; behavioral confirmation open | All 92 former `NATIVE_xxxx` block labels now carry function-specific branch/loop names with original addresses and direct-branch xrefs; entry-point contracts are documented. Some object/collision relationships require runtime confirmation; do not interpret all 92 as independent functions. See [native control flow](NATIVE-CONTROL-FLOW.md) and [block inventory](NATIVE-BLOCK-INVENTORY.md). |
| GF-RE-002 | In progress | Both player aim, fire, shot counters, sprite/bitmap writer, score and event paths traced. Trace collision outcomes, full timer transitions, object lifetime and sound/cabinet outputs end to end. |
| GF-RE-003 | In progress | Ten 8×10 font glyphs and five width/height-prefixed patterns are now decoded inline. Resolve remaining graphics streams, animation names, hardware shift/orientation and object frame identities. |
| GF-RE-004 | Closed — static scope | Old bounded-prefix report reconciled with 82 statically decoded command sites; exact operand sizes and 21+9 vector split aligned across source, word catalog, interpreter JSON and ROM ownership. Dynamic native-installed scripts remain GF-RE-008. |
| GF-RE-005 | Closed — generator isolation | `recover_8080.py` writes to `src/zout/gunfight-recovered.asm`; the audit, interpreter and memory-map research tools write to `docs/generated/` instead of overwriting maintained source or reviewed docs. None is used in normal builds. |
| GF-RE-006 | Linux and MAME verified on PR #4; follow-up pending | User ran bundled zmac, verified four original 1 KB SHA-1 hashes, and ran the game in MAME on 2026-11-21. Retest relocated PR #5 build outputs; Windows native build and physical hardware remain unverified. |
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

## v20261108-0004 — cross-repo RE checkpoint

- Resolved the controller-table interpretation: each player's direction transform provides **even byte offsets**, and the zero case is rejected before the 16-bit aim-pointer lookup. Player-one last entry at `$0EF0` is also player-two's unused zero-index entry. This is a shared *entry*, not a misaligned/overlapping pointer fetch.
- Separated shot-coordinate adjustments (`$0F00–$0F0D`) from graphics pointer tables. The `$0EFE` entry is both player-two's last active graphic pointer and the firing lookup's unused zero slot.
- Data-byte verification performed: original 1 KB `$0C00–$0FFF` data is identical before and after typing the pointers and shot records.
- WB PR #45 documentation/graphic aligned, with Gun Fight independent of WB-private links.
- GF-RE-002 remains open for end-to-end collision, timing and sound execution; GF-RE-006 remains open for native zmac, device SHA-1 and emulator tests. No substitute compiler or gameplay logic has been used.

## v20261108-0009 — native function and internal-block RE

- Investigated each of the **92** remaining `NATIVE_xxxx` labels in the maintained source. The resulting names identify internal loops, conditionals, shared tails and branch targets; they do **not** promote every block to an independently callable routine. All original addresses are retained.
- Added register, flag, RAM, port and entry/exit contracts for primary callable/interrupt paths: two IRQ vectors and common exit, object axis update, pointer consumer, bitmap job queue, pixel-address translation, packed graphics drawing, script literal copy, native input dispatch, shot state, score/font renderer and graphics expansion.
- Recovered source-based relationships between IRQ projectile scan, event selector at $201C, object/bitmap job queues, timing and BCD state, player input vectors, firing/direction data and game display. Exact collision outcomes, sprite appearance, sound effects and full interrupt timing remain for emulator/hardware verification.
- Created [NATIVE-CONTROL-FLOW.md](NATIVE-CONTROL-FLOW.md) and a 92-entry [NATIVE-BLOCK-INVENTORY.md](NATIVE-BLOCK-INVENTORY.md) with direct-branch reference counts.
- **Static verification executed:** source has zero generic `NATIVE_xxxx` labels, 314 total defined labels, contiguous 1 KB `ORG` regions ending $1000, no undefined symbolic operands, and **zero canonical instruction/operand differences among 1,808 assembly statements** when compared against the prior PR checkpoint (after resolving renamed symbols back to their addresses).
- **Not executed:** zmac native build, four original ROM chip SHA-1 checks, MAME, Windows or real hardware. Byte-identical assembler output is not claimed by the static source comparison. GF-RE-006 remains open.

## v20261121-0001 — PR #4 merge and PR #5 build layout

- PR #4 merged as `81d37d2` after the user's Linux build verified SHA-1 identities for `7609h.bin`, `7609g.bin`, `7609f.bin`, `7609e.bin`, and the user confirmed MAME execution.
- New output layout: disposable and ignored `build/` for assembler listing, 4 KB binary, and split devices; ignored `roms/gunfight.zip` for MAME. `roms/original/gunfight.zip` stays tracked and authoritative.
- Previously committed `roms/build/` and `src/zout/` outputs are removed from the Git tree, along with the Python-based reconstruction action. Optional research utilities under `tools/` are retained; normal builds never call them.
- The rebuilt PR #5 branch intentionally retains PR #4's entire `src/gunfight.asm`, native graphics diagram, and research docs. The earlier PR #5 source rewrite and partial SVG were not carried forward.
- **Not yet executed:** the relocated output build scripts, MAME run with `-rompath roms`, Windows batch build, and physical hardware tests.

## v20261121-0003 — presentation and remaining data-ownership RE

- Source cosmetics/names refreshed to Checkmate style. IRQ labels retained because they identify actual internal control-flow blocks, not independent callable functions.
- Large ROM data regions near the score font, $0C00 device boundary and later game tables received bounded category headings without inventing original DNA routine names, sprite identity or record formats.
- Remaining task: derive exact glyph/graphics/text record boundaries from the native callers and verify rendering behavior in MAME; initial category comments are not proof of finer segmentation.
- Directive stream preservation checked statically (1812 directives), but **new source commit has not been assembled or tested in MAME**.

## v20261121-0005 — graphics/aim RE progress

- Seven 3x21 aim frames, two smaller scene shapes, 28 font slots, and a special 3x28 object pattern are now expressed as structured source data.
- Event object records and first/second-player frame sources have role-based names based on native caller paths. Exact appearance/obstacle identification remains open until visible draw-state verification.
- Source data reconstruction includes explicit original byte-preservation checks for the transformed sections. All original code bytes outside those data sections remain unchanged; assembly and MAME execution are not yet performed after this pass.

## v20261121-0006 — text RE and verification status

- Decoded byte-to-glyph mapping in game-message area, linked all original text source pointers to their VM $01 glyph counts, and corrected the terminology from generic format byte to glyph count.
- Updated ROM device roles in the memory map; the $0BC4-$0D8A aim records span the 7609f/7609e boundary and encoded text belongs to 7609e.
- User's native Linux build, original four-chip equality check and MAME playback PASSED on v20261121-0005. Latest symbol/annotation changes need a fresh check; Windows and physical hardware remain untested.
