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
