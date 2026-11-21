# Gun Fight (1975) — gameplay, projectile, collision and round-control RE

**Tracking:** GF-RE-002 · **Source:** [`src/gunfight.asm`](../src/gunfight.asm), original four 1 KB 8080 ROM devices · **Revision:** v20261121-0001

This is a trace of the **original Intel 8080 machine code**, not a replacement gameplay implementation. Symbol names are descriptive RE names; original DNA symbol spelling is not established. Addresses, opcodes, register effects and RAM writes are supported by the maintained byte-exact assembly and the original ROM verification baseline. Where a high-level outcome or device signal is unproven, it is identified as an open check.

## 1. Execution-path overview

```text
input change (ports $00/$01)
  VM_INPUT_EVENT_DISPATCH $03C9
    -> DISPATCH_INPUT_TRANSITION $040D
       -> one of 24 INPUT_ACTION_VECTOR entries at $097E
          -> axis / aim / firing / round-input action
             fire: $04B0 or $0517
                 -> UPDATE_SHOT_STATE $04FA
                 -> CALCULATE_PROJECTILE_ORIGIN $037C
                 -> FIRE_INSTALL_PROJECTILE_FROM_DIRECTION
                    (one of four projectile records at $2063,$2075,$2087,$2099)

interrupt $0010
  alternates with bitmap work using phase at $20B9
  -> IRQ_SCAN_PROJECTILE_RECORDS
  -> IRQ_CHECK_PROJECTILE_SLOT
  -> IRQ_TEST_PROJECTILE_STATE_AND_BOUNDS
  -> IRQ_STORE_EVENT_SELECTOR ($201C)
  -> IRQ_UPDATE_VISIBLE_OBJECT_SLOT
  -> IRQ_STEP_OBJECT_CYCLE
  -> IRQ_ADVANCE_ROUND_TIMERS

next VM word $14
  -> VM_INPUT_EVENT_DISPATCH $03C9
  -> read/clear $201C
  -> index event-script pointers at $09D6
  -> write selected target to current script cursor $2000
  -> interpret native $00–$14 commands through dispatcher $03A7
```

The **VM** ($03A7), **native input action table** ($097E) and **IRQ object walks** are separate mechanisms. Each can modify shared game RAM. The VM can dispatch without a new input because its scripts also contain delays, drawing and unconditional/conditional branches.

## 2. Controls to native actions

`VM_INPUT_EVENT_DISPATCH` ($03C9) samples input ports `$00` and `$01` twice each, and calls `DISPATCH_INPUT_TRANSITION` ($040D) only when the two reads match. This comparison stabilizes a sample; the code does **not** establish any particular physical debounce time. Saved states are `$2017` and `$2018`, with per-bit action-vector bases `$097E` and `$098E`.

The transition helper computes `new XOR saved`, selects the first changed bit from low to high, updates that bit in saved RAM, and indirect-jumps through its 16-bit native action pointer. It is not a 24-word interpreter; the table also contains repeated no-op returns.

The eight axis entries write signed velocity components at player object offsets `+1` and `+5`, distinguishing press from release. Aiming uses `PLAYER_ONE_AIM_ACTION` ($042A) / `PLAYER_TWO_AIM_ACTION` ($043E): `(input AND $70)`, rotated three times, becomes an even table byte offset `$02..$0E`. Zero is rejected. `INSTALL_AIM_DESCRIPTOR` ($044F) writes the selected graphics pointer to player object offset `+$0B`; the original player object bases are `$202A` and `$203D`. See [AIM-AND-FIRE.md](AIM-AND-FIRE.md) for the seven exact pointer pairs and shared table entry.

## 3. Fire acceptance, shot counters and projectile installation

| Step | Player 1 | Player 2 | Original effect |
| --- | --- | --- | --- |
| Native entry | `PLAYER_ONE_FIRE_ACTION` ($04B0) | `PLAYER_TWO_FIRE_ACTION` ($0517) | `RET Z` immediately rejects the inactive transition |
| Projectile availability | `$2063`, alternate `$2075` | `$2087`, alternate `$2099` | Test bit 7 of each first byte; reject if both candidate slots are active |
| Fire guard | `$2012` | `$2013` | A nonzero guard rejects another shot |
| Counter | `$2010` | `$2011` | `UPDATE_SHOT_STATE` increments and redraws count |
| Display argument | `$3EA2` | `$3EB8` | Display destination passed to common shot-state service |
| Port $01 write | `$E2` | `$D2` | Output code written when a shot is accepted; physical signal meaning not yet proven |
| Player origin | `$202C` | `$203F` | Source for coordinate-adjustment helper |
| Direction | `$201A` | `$201B` | Even direction index for relative shot-coordinate lookup |
| Projectile initialization | `$C6` at selected slot start | same | Under `DI/EI`, installs status, coordinates and two additional fields |

The common `UPDATE_SHOT_STATE` routine ($04FA) increments the shot counter and compares with `$06`. On the threshold path it writes the count to the fire-guard byte, and changes the round-state byte `$2003` to `$11` or `$02`, depending on its preceding value. It then uses `DRAW_FORMATTED_TEXT` with source `$0FA4` to update the on-screen shot indicator. Those writes do not themselves establish that a score was awarded.

`FIRE_INSTALL_PROJECTILE_FROM_DIRECTION` uses `CALCULATE_PROJECTILE_ORIGIN` ($037C), but **this is the shot-position helper, not the graphics-pointer installation**. It reads a two-byte relative X/Y adjustment at `SHOT_PARAMETER_BASE + direction_offset`; the source table begins at `$0EFE`, with the seven effective pairs at `$0F00–$0F0D`. The helper combines them with player-origin bytes at offsets `+0` and `+4`. The firing tail then disables interrupts, stores the new projectile status/coordinates, reenables interrupts and sets `$2014=$02`.

The first `$0EFE–$0EFF` word is also the last Player 2 aim pointer. It is not accessed by valid, nonzero shot direction offsets.

## 4. IRQ projectile processing and event selection

The IRQ at `$0010` complements `$20B9`. One phase handles bitmap queues, while the other enters `IRQ_SCAN_PROJECTILE_RECORDS` and performs object motion and round-state work. Both return through `IRQ_SAMPLE_PORT2_AND_RESTORE` ($0218), which samples port `$02`, may dispatch an input transition, and restores the saved registers. The exact machine frame rate and ratio of RST $08 to RST $10 interrupts are **not** established by this code inspection.

The projectile scan begins at `$2063` and advances `$12` bytes per slot until the low address byte reaches `$AB`. Thus the four examined slots begin at `$2063`, `$2075`, `$2087` and `$2099`. Each slot is tested using its status/sign field, a coordinate threshold (`$70` or `$90` depending on the sign path), a nonzero field at the later record offset, and a further range check formed with `SUB $10` / `CP $C0`.

On the qualifying branch, the code:

1. Changes the projectile status byte to `$A0`.
2. Extracts one nibble from the projectile record.
3. Copies another field into `$201D`.
4. Builds an index into ROM `$0F3A`, including branch-dependent nibble selection.
5. Masks the selected table value with `$0F`, storing it in `$201C`.

This is a **bounded projectile-event qualification and selector construction** supported by source instructions. It is not yet sufficient to assert which screen pixels collide, which obstacle is struck, or which specific message every selector produces. In particular, the lookup at `$0F3A` is game-state data; assigning each entry a collision name requires traced input/state examples.

After the projectile pass, the code walks active moving objects at the same `$12` stride, calls `UPDATE_ACTIVE_OBJECT_COORDINATES`, stores converted bitmap address/phase in object records, and then walks the general player/object slots at `$13` stride. Work is queued into `$20AB` or `$20B2` via `QUEUE_OBJECT_BITMAP_UPDATE`; these pending jobs are consumed by the alternate IRQ video path.

## 5. Event selector to interpreted scripts

`VM_INPUT_EVENT_DISPATCH` at `$03C9` tests `$201C`; zero falls through to optional score display. A nonzero value is cleared, multiplied by two and used as a **word offset** from the pointer base `$09D6`. The selected pointer replaces `$2000`, the current interpreter script cursor. The table's `$09D6` word overlaps VM opcode `$14` and is not an additional event script.

| Nonzero selector | Pointer entry | Script entry | Verified role |
| ---: | --- | --- | --- |
| 1 | `$09D8` | `$091B` | Interpreted event-script start |
| 2 | `$09DA` | `$0936` | Interpreted event-script start |
| 3 | `$09DC` | `$093C` | Interpreted event-script start |
| 4 | `$09DE` | `$0942` | Interpreted event-script start |
| 5 | `$09E0` | `$0948` | Interpreted event-script start |
| 6 | `$09E2` | `$094E` | Interpreted event-script start |
| 7 | `$09E4` | `$0954` | Interpreted event-script start |
| 8 | `$09E6` | `$095A` | Interpreted event-script start |
| 9 | `$09E8` | `$0963` | Interpreted event-script start |

These destinations are bytecode, **not 8080 callable subroutines**. Their individual scripts use the same VM words for display, rectangle clearing, state changes, object initialization and BCD operations. See [decoded-scripts.md](decoded-scripts.md) for packet boundaries. No claim is made that every selector value is reachable from every game state.

## 6. Object motion, bitmap update and rendering

`UPDATE_ACTIVE_OBJECT_COORDINATES` ($025E) calls `STEP_OBJECT_AXIS` ($0280) for both axes. The axis helper accumulates position with velocity, compares against limits, and either writes the updated position or adjusts/reverses/stops the component according to control mode. Its return status can be `$00`, `$10`, `$40` or `$60`.

`QUEUE_OBJECT_BITMAP_UPDATE` ($02C9) decides which pending bitmap slot receives the updated source pointer, converted display address, bit phase and graphics link. The drawing phase consumes links with `TAKE_AND_CLEAR_OBJECT_POINTER`, so queued pointers are cleared when taken. `DRAW_NATIVE_OBJECT_DATA` ($022D) interprets width/height-prefixed ROM/RAM patterns, sends bytes to port `$04`, reads port `$03`, and writes to display RAM using a `$20`-byte row stride. This is original graphics-hardware interaction, not ordinary direct pixel copying.

The ROM has distinct player frame selection (`PLAYER_ONE_FRAME_POINTERS` / `PLAYER_TWO_FRAME_POINTERS`) and aiming-direction graphics tables. The first uses `$2009` bits to select one of four frame pointers; the second uses controller direction. An event object at `$2050` is initialized with a 15-byte record from ROM `$0F52` when needed.

## 7. Round timing, score and outputs

Following a full general object cycle, the native IRQ checks `$2014`. If nonzero it decrements the byte, and writes `$00` to output port `$01` when the value reaches zero. It then decrements `$2009`; a negative result reloads `$22` and can advance the BCD/timer logic.

The code updates `$2004` and `$2003` using `ADD $99` and `DAA`, may modify `$20C4`, decrements delay `$2015`, and finally advances the VM wait/repeat state `$20C5`. The VM's `WAIT_OR_REPEAT_COMMAND` ($0813) can rewind the saved script cursor one byte until the wait condition clears.

`ADVANCE_ROUND_EVENT_COUNTER` (native path at `$0549`) writes `$04` to `$2014` and port `$01`, advances `$2007`, and uses configuration bits at `$2006` to change `$2008`. The connected `UPDATE_ROUND_STATE` ($056C) can decrement `$2008`, derive a mode/speed value from `$2006`, clear selected score state, and decrement alternate-script state `$20C6`.

`UPDATE_SCORE_DISPLAY` ($05A3) formats four packed-decimal RAM fields starting at `$2002` into the text buffer at `$201E` and renders eight glyphs into display RAM starting at `$2405`. VM word `$0C` performs a BCD increment at an address supplied by the script and then falls through to object initialization. **Event scripting is therefore involved in score changes; a raw projectile-status write is not itself proof of a score.**

### Original I/O operations observed

| Port | Original use | Limits of current interpretation |
| --- | --- | --- |
| Input `$00`, `$01` | Stable-read player input and native input-vector dispatch | Physical joystick/button wiring still requires board mapping |
| Input `$02` | Shared IRQ transition sampling | Specific cabinet switch role not confirmed |
| Output `$01` | Player fire codes `$E2` / `$D2`, event code `$04`, mode/state writes and `$00` | Cannot assign each bit to a sound/electrical function without hardware evidence |
| Output `$02` | Graphics/display mode selection | Mode signaling established; board-level meaning of each bit pending |
| Output `$04`, input `$03` | Graphics data/shift/latch pipeline | Pixel order, clipping and final on-screen composition require emulator/hardware verification |

## 8. Verification status and trace plan

**Completed source checks:** entry and continuation paths were inspected in `src/gunfight.asm`; original ROM tables, constants, player records and selector indices are enumerated above. This documentation pass does not alter any executable instructions, source directives or ROM data. No new MAME debugger trace was run in this pass.

**Previously reported by user (PR #5, 2026-11-21):** Linux bundled zmac build produced four matching original ROM SHA-1 hashes and the resulting game ran in MAME for source revision v20261121-0005. Later source-string revisions require their own four-chip identity check; a graphics/documentation-only edit does not prove or invalidate that gate.

### Reproducible dynamic investigation

Run native MAME with `-debug` and the built `roms/gunfight.zip`. Inspect the following breakpoints/watchpoints **without altering gameplay**:

1. **Fire guard:** `$04B0`, `$0517`, `$04FA`, `$037C`; record player, pressed/released state, guard `$2012/$2013`, selected slot and prior/final shot count.
2. **Projectile write:** shared `FIRE_INSTALL_PROJECTILE_FROM_DIRECTION`; record slot first byte `$C6`, X/Y adjustment, resulting field bytes and the output to port `$01`.
3. **Projectile IRQ:** `IRQ_SCAN_PROJECTILE_RECORDS` and `IRQ_STORE_EVENT_SELECTOR`; record each candidate field and the exact ROM `$0F3A` index/value for every accepted and rejected boundary.
4. **VM event switch:** breakpoint `$03C9`, watch `$201C` and `$2000`. Record selector `1..9`, resulting script destination, and next VM packets.
5. **Score and round:** watch `$2002..$2009`, `$2014`, `$2015`, `$20C5`; record score changes, BCD transitions, round completion and repeat scheduling.
6. **Rendering and output:** watch `$20AB/$20B2` and output to `$01/$02/$04`; correlate port writes with visible gunshot, hit, obstacles and text. Validate hardware meanings against MAME implementation or original schematics.

Recommended test cases: P1 fires with a free slot; P1 fires with both slots active; P2 equivalents; fire while guard is nonzero; direction offsets `$02` and `$0E`; projectile leaving each boundary; obstacle interception; player hit; last allowed shot; score/round transition; new round reset. Capture an execution log for each case before assigning final gameplay names to event codes.

## 9. Open evidence and completion criteria

| Question | Current evidence | Exit condition |
| --- | --- | --- |
| Which exact condition constitutes a hit? | IRQ status/bounds tests and event table at `$0F3A` | Dynamic state trace showing position, object target and resulting selector |
| Which event selector yields which visible message/result? | Nine script targets, known VM effects and decoded message sources | Selector-to-script-to-screen trace for all reachable selectors |
| When do shots disappear and slots become reusable? | Four slot statuses and queued rendering paths | Track each slot from `$C6` launch to inactive state |
| What is the exact interrupt cadence? | IRQ phase bit `$20B9`, two entry vectors | Emulator/hardware trace of vectors over successive frames |
| Which port bits drive sound/cabinet hardware? | Native `IN/OUT` values and call paths | Original wiring/MAME hardware implementation cross-reference |
| Which score/round transition corresponds to each event? | `DAA` counters, `$2008/$2009`, scripts | Gameplay trace through win, loss, draw and reset |

**GF-RE-002 status: source-path reconstruction implemented; behavioral completion still in progress.** Closing the task requires the above runtime-supported state and hardware mappings. These obligations should not be silently reassigned to GF-RE-008 or called complete solely because the ROM rebuild passes.

## v20261121-0002 — maintained assembly integration

GF-RE-002 findings now have corresponding source symbols in [`src/gunfight.asm`](../src/gunfight.asm): `CALCULATE_PROJECTILE_ORIGIN` names the $037C direction-based coordinate helper, `PROJECTILE_EVENT_LOOKUP_RECORDS` names the $0F3A IRQ-indexed table, and nonallocating `EQU` aliases identify four projectile slots, two fire guards, two shot counters, event selector/context, and output latch timer. This distinguishes coordinate calculation from `INSTALL_AIM_DESCRIPTOR` at $044F, which selects player aiming graphics. Existing native instruction/data bytes are unchanged. Selector-to-visible-hit and physical output semantics remain unverified.
