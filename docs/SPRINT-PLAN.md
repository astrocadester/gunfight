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
