# Gun Fight — native Intel 8080 RE plan

## v20261108-0001 — source and documentation modernization

The original 4 KB ROM set is authoritative. Maintain real Intel 8080 source. Follow [engineering rules](../ENGINEERING-RULES.md); any hardware/software substitution requires prior approval.

1. **Maintained ASM and build:** keep `src/gunfight.asm` as the committed reconstruction; run bundled zmac directly on Linux and Windows; verify all four original ROM device hashes and package the MAME set. Research tools must not rewrite the source during build.
2. **Native function RE:** replace verified generic `NATIVE_xxxx` entry labels with descriptive routine names; trace all callers, register contracts, shared fallthroughs, RAM state, and port effects. Add meaningful headers and inline comments only when they aid understanding.
3. **Interpreter and scripts:** reconcile 21 native handlers, 24 input-action pointers, event script destinations, inline literal widths and rooted packet counts. Keep original script bytes and native code distinguished.
4. **Gameplay trace:** map cold start, graphics setup, both cowboys, input/movement/firing, bullet/hit detection, scoring, sound and timing from original 8080 behavior.
5. **Graphic data RE:** trace packed graphics formats from native unpack/draw routines. Display bit previews inline; label sprite identity and dimensions only when evidenced by pointers, rendering behavior, or emulation.
6. **Round-trip documentation:** align dictionary, ASM symbols, memory-map, source references and WB runtime-variant discussion after each corrected finding.
7. **Separate verification:** source review, native assembler result, exact ROM equality, MAME execution, and physical hardware are distinct gates; record actual results, not anticipated outcomes.

## Scope of this commit

Maintained ASM has an initial semantic-label/header pass and raw inline graphics bit visualization; source comments no longer duplicate every ROM address. Original build invocation has been replaced by direct zmac + native host verification. Word $05/$06 and vector ownership documentation are reconciled. The remaining deep gameplay tracing and graphics decoding are future RE stages, not claimed complete.

**Verification status:** GitHub edits are committed; no local assembler run, emulator run or physical hardware test has been performed in this session.

## v20261108-0002 — additional native RE

- Updated README using **Sea Wolf II** rather than Sea Wolf / Missile; condensed mobile layout and removed repeated engineering-policy prose.
- Replaced the provisional memory-map SVG with original four ROM chip assignments, script/vector locations, RAM state, expanded graphics and display addressing.
- Traced packed-pixel address calculation at $0359, native drawing at $022D, score/font renderer at $05FB, input action table paths, player firing, and object-pointer helpers.
- Recovered ten 8×10 digit glyphs at ROM $09F8 directly in ASM with inline pixel rows; their bytes and order are preserved.
- Further native names/headers added; remaining generic branches and non-font sprite data are future hard RE work.
- Native build and MAME verification remain distinct unexecuted gates.


## v20261108-0003 — debt-reduction hard RE

- Corrected the returned-register contract for the native pointer-clearing helper at `$02BD` and updated the implementation notes.
- Recovered eight directional controller action entries and the shared no-op handler used by six input table positions.
- Named and documented additional VM handler entry points, native display/aim/shot services, and the four-entry frame pointer tables at `$0349` / `$0351`.
- Reconciled every one of the 82 statically decoded script labels with the 21-command dictionary; script jumps now reference the matching labels where available.
- Identified native pattern headers and row boundaries at `$0D8B`, `$0DB1`, `$0DD7`, `$0DFD`, and `$0E5F`; decoded all five patterns inline without introducing external graphics.
- Corrected `docs/interpreter.json` to 21 native handlers plus nine event-script pointers. Rewrote outdated data-provenance conclusions to reflect the native code already traced.
- Isolated Python RE generator outputs in `src/zout` and `docs/generated` so they no longer overwrite maintained ASM, README references, or the memory-map.
- Ran independent static source-layout inspection: 4 KB; four contiguous original ROM divisions; all expected key offsets and 310 defined labels resolved. Native assembler, ROM hashes, and MAME have not been executed in this session.

The next gate is native zmac compilation plus four-chip SHA-1 verification. Further RE focuses on full object/collision lifecycles, remaining non-font sprite boundaries, and interrupt scheduling.

## v20261108-0004 — WB / Gun Fight implementation cross-review

- Traced `PLAYER_ONE_AIM_ACTION`, `PLAYER_TWO_AIM_ACTION`, and `INSTALL_AIM_DESCRIPTOR`: `(input & $70)` rotated right three times yields **even byte offsets** `$02–$0E`; the seven effective entries are ordinary 16-bit pointers, not unaligned overlapping reads.
- Typed the player-one and player-two aim pointer tables at `$0EE2` and `$0EF0` using original `DW` values, including their single shared boundary entry.
- Identified `SHOT_PARAMETER_BASE=$0EFE` and seven non-pointer coordinate-adjustment byte pairs `$0F00–$0F0D`, used by `SELECT_AIM_DESCRIPTOR` at `$037C`. Corrected routine headers and source relationships. See [AIM-AND-FIRE.md](AIM-AND-FIRE.md).
- Updated README, native implementation notes and graphics documentation. The Gun Fight repo retains **no dependency/link to WB**; the introductory architecture establishes the 1975 starting point without asserting identical later machine-code reuse.
- Updated WB PR #45's 8080 chapter to explain the native input/table details, sprite/font recovery and Gun Fight's different dispatcher, with a compact local memory-map SVG. WB's outward source links remain to the Gun Fight repo's regular `main` paths, not to this development PR branch.
- **Verification:** Independent static comparison confirms all 1,024 bytes of data in `$0C00–$0FFF` are unchanged from the previous PR #4 checkpoint. Existing static script and word aliases remain 82/21. Native assembler, chip hashes, MAME and hardware remain unexecuted in this pass.

## v20261108-0005 — README and memory-map presentation

- Replaced the README's Midway advertisement image with the existing original gameplay screenshot at `images/gun-fight-27737.jpg`; retained the marquee image.
- Added a small marquee-inspired cowboy emblem within the header of `images/gunfight-memory-map.svg` without modifying the ROM, RAM or original device descriptions.
- Replaced the two gray memory-range headings with "Other address space" (`$4000–$FFFF`) and "No identified ROM or RAM" (`$1000–$1FFF`), retaining the relevant `$400F` screen-clear stack detail.
- Verified the referenced screenshot exists in `images/`, the README no longer points to the flyer, and SVG element tags are structurally balanced.
- This was a documentation/artwork-only update; no native build, ROM hash or MAME execution was performed.

## v20261108-0009 — full generic native-label RE pass

1. Recovered **all 92** remaining `NATIVE_xxxx` sites as descriptive named internal blocks within the original 8080 interrupt, object, VM, input, firing, score and graphics control paths. Kept callable routines distinct from loops, conditional targets, entry vectors and shared exits. Every block is indexed with its ROM address, observed local behavior and direct incoming branch count in [NATIVE-BLOCK-INVENTORY.md](NATIVE-BLOCK-INVENTORY.md).
2. Extended the source headers with entry/exit register, flag, RAM, I/O port and return conventions on real callable functions and interrupt vectors. Full connected flows are in [NATIVE-CONTROL-FLOW.md](NATIVE-CONTROL-FLOW.md).
3. Source-inspected the native IRQ phases from $0010 through $0218: bitmap job queue at $206F/$20A2, projectile/object-record scans at $2063, pending renderer slots $20AB/$20B2, event selector $201C, object movement, score/timer counters and input polling. Linked player control/shot paths to their existing native source records; unresolved physical effects remain explicitly open.
4. Renamed branch and call operands symbolically without changing original code, data or graphics. **Source structural comparison executed**: four contiguous ROM sections ending $1000, 314 defined symbols, no unresolved symbolic operands, 1,808 instruction/data statements canonicalized to **zero textual instruction/operand differences** against PR checkpoint preceding this pass. No claim of actual assembler byte equality.
5. Native bundled zmac compilation, original device SHA-1 checks, MAME gameplay, Windows build and physical board execution remain separately pending. No substitute language, compiler, interpreted gameplay or alternative hardware implementation was introduced.

Next gate: run the actual `./build.sh` with zmac 1.3 and verify all four 1 KB original device hashes. Continue deeper dynamic object/collision, sound, and graphics hardware behavior RE only after the static findings have been checked against a running game.

## v20261121-0001 — Checkmate-style build and tracked-artifact cleanup

- PR #4 native source and research merged; the 92 named internal control-flow blocks, 21 VM words and graphics/source annotations remain authoritative.
- Source builds directly with zmac v1.3 without Python. Linux and Windows scripts now put intermediate binary, listing and four chip images in ignored root `build/`, and package the play-ready set at ignored `roms/gunfight.zip`.
- Remove previously committed output from `roms/build/` and `src/zout/`, the obsolete reconstruction action, and the redundant older SVG in `docs/`. The maintained map remains `images/gunfight-memory-map.svg`; original ROM remains tracked.
- **Verified by user on PR #4 (2026-11-21):** Linux native assembly, all four original SHA-1 chip comparisons and MAME game execution passed.
- **PR #5 changes remain to be verified:** new build output paths, Linux/Windows script execution and MAME loading from `roms/`. Hardware testing remains open.

## v20261121-0002 — 280-ZZZAP build pattern alignment

- Adopt the user-supplied 280-ZZZAP Linux and Windows build-script pattern, using four original Gun Fight 1 KB devices, a 4096-byte image, the existing Gun Fight SHA-1 checks, and bundled zmac v1.3.
- Output remains root `build/` for temporary devices/listing and `roms/gunfight.zip` for MAME; neither `roms/build/` nor `src/zout/` is created or tracked.
- Include the six JPEG images and Git cleanup pushed to the former PR #4 branch after its merge. The reviewed native 8080 assembly and memory-map SVG remain unchanged.
- **Verification still required:** run the new Linux and Windows scripts and MAME against the relocated archive. PR #4 Linux ROM identity and MAME verification remain on record.

## v20261121-0003 — source presentation and semantic labeling

- Match Checkmate's standard source header and blank-line style without changing instructions or DB/DW values.
- Reformat indexed script packets with preceding descriptive comment headers instead of repetitive inline opcode text.
- Rename ROM table labels by their actual role: INPUT_ACTION_VECTOR, VM_WORD_VECTOR, EVENT_SCRIPT_VECTOR. Rename VM_WORD alias labels and dimension-only graphics patterns.
- Wrap IRQ internal-block comments to readable widths while retaining existing precisely traced interrupt loop labels.
- Add conservative region headings for larger font-like/packed-graphics/table byte spans; full sprite identity and sub-record boundaries remain RE work.
- Clarify player aim DW entries, even-byte controller offsets, shared table boundary, and RAM descriptor destination.
- **Static preservation:** all 1812 assembler instructions/data directives retained in original order, with only explicitly documented symbol-prefix substitutions. Native zmac, ROM SHA-1 and MAME must be rechecked after this source formatting pass.

## v20261121-0005 — deeper original data ownership and aim-table cleanup

- Decode 28 additional 8x10 font slot records, scene patterns 1x22 and 2x27, and seven 3x21 aim-direction ROM patterns, using original record-header lengths and original pointer references.
- Decode scene draw-list pointer pairs ($0F0E/$0F22/$0F36), state records ($0F3A), special-object initialization ($0F52), and source-record boundaries in encoded text ($0F61 onward).
- Interpret $0E8D as VM packed-graphics terminator and $0E8E as a 3x28 special-object pattern whose last two bytes deliberately overlap the unused first-player aim-table entry at $0EE2.
- Keep byte-for-byte original DB/DW data. All rebuilt data sections were checked for identical emitted byte sequences in memory before publishing. Native zmac, four-chip hashes and MAME need separate execution after this source change.
