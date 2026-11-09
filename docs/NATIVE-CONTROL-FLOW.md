# Gun Fight — native 8080 control flow and contracts

This document follows the maintained [8080 assembly](../src/gunfight.asm) and describes the actual *native* call/branch structure. Internal block labels are **not** separate functions. [Native block inventory](NATIVE-BLOCK-INVENTORY.md) enumerates the former 92 `NATIVE_xxxx` labels by ROM address and describes their branch/loop role.

The interpreter, interrupts, object walkers, player controller actions, pixel hardware, and formatted text share the 4 KB program; none is an independent synthesized implementation.

## Native entry classes

- **Hardware entry vectors:** `RESET_ENTRY` ($0000), `INTERRUPT_VECTOR_08` ($0008), `INTERRUPT_VECTOR_10` ($0010). These use the original stack/register conventions.
- **Callable subroutines:** `DRAW_NATIVE_OBJECT_DATA` ($022D), `UPDATE_ACTIVE_OBJECT_COORDINATES` ($025E), `STEP_OBJECT_AXIS` ($0280), `TAKE_AND_CLEAR_OBJECT_POINTER` ($02BD), `QUEUE_OBJECT_BITMAP_UPDATE` ($02C9), `VIDEO_ADDRESS_FROM_PACKED_COORDINATES` ($0359), `COPY_SCRIPT_LITERAL_BLOCK` ($0372), `SELECT_AIM_DESCRIPTOR` ($037C), `DISPATCH_INPUT_TRANSITION` ($040D), `INSTALL_AIM_DESCRIPTOR` ($044F), `UPDATE_SHOT_STATE` ($04FA), and `DRAW_FORMATTED_TEXT` ($05FB). Some tail-call rather than return normally.
- **Interpreter entry and word handlers:** `VM_DISPATCH_NEXT` ($03A7) and the 21 indexed native commands at table $09AE. Native word handlers generally return via the continuation address pushed by the dispatcher.
- **Internal branches and loops:** the remaining 92 prior address-only labels describe loop entries, conditional branches, shared tails, and state-specific continuations. They are named *within* the owning routine in the assembly. Their source locations and direct xrefs are indexed separately.

## Interrupt scheduling and gameplay-state processing

Both interrupts push HL, DE, BC, AF on entry and converge at `IRQ_SAMPLE_PORT2_AND_RESTORE` ($0218), which samples input port $02 twice, dispatches stable changes via `DISPATCH_INPUT_TRANSITION`, restores the four saved registers, enables interrupts and returns. The $0010 vector complements RAM $20B9, selecting alternating phases.

The **bitmap-job phase** starts with a slot walker at $206F, uses 18-byte strides and `TAKE_AND_CLEAR_OBJECT_POINTER` to consume queued source/destination pointers. A second walker at $20A2 combines graphics-port results with existing display bytes. The shared processing from $0087 also handles clear/draw jobs and can invoke `DRAW_NATIVE_OBJECT_DATA` twice for paired patterns. This is a native rendering pipeline rather than an interpreted VM word.

The **moving-object phase** starts at $2063 and walks 18-byte projectile records; it tests status and coordinate windows, uses a ROM lookup around $0F3A and writes the low-nibble event selector to RAM $201C. **The exact on-screen hit outcome for every selector remains a dynamic-verification target.** A subsequent visible-object pass calls `UPDATE_ACTIVE_OBJECT_COORDINATES`; the general object walker follows 19-byte records and can queue a bitmap update at $20AB or $20B2 through `QUEUE_OBJECT_BITMAP_UPDATE`.

The round/timer tail checks output state $2014 and the frame or round count at $2009, uses DAA to adjust packed-decimal fields at $2004 and $2003, decrements the delay at $2015 and may decrement interpreter repeat/wait counter $20C5. The interrupt exit therefore connects object movement, display updates, game-event selection, and VM pacing.

### Object axis and drawing contracts

| Routine | Entry | Observed exit/effects |
| --- | --- | --- |
| `UPDATE_ACTIVE_OBJECT_COORDINATES` $025E | HL=object base; A=object control flags | Calls axis helper twice; updates motion/control fields; restores HL to object base; clears bit 6 when both velocity components are zero |
| `STEP_OBJECT_AXIS` $0280 | HL=axis field; A=control bits | Accumulates/limits position; returns axis byte in D and a status value in A (`$00/$10/$40/$60`), flags updated |
| `TAKE_AND_CLEAR_OBJECT_POINTER` $02BD | HL=RAM address of little-endian pointer | Clears both pointer bytes; **HL=old pointer, DE=address after cleared field**; B=0; zero flag says whether pointer was null |
| `QUEUE_OBJECT_BITMAP_UPDATE` $02C9 | HL=object slot, D=axis coordinate from preceding update | Constructs one pending job at $20AB or $20B2; stores converted bitmap location and graphics state; selected exits clear or reuse object frame data |
| `VIDEO_ADDRESS_FROM_PACKED_COORDINATES` $0359 | DE=packed coordinate | DE=$2400+(coordinate shifted right 3); C=low 3 bits; HL preserved; A/B/flags altered |
| `DRAW_NATIVE_OBJECT_DATA` $022D | DE=width/height-prefixed graphic source, HL=display destination, B=height bias | Writes width-byte rows through OUT $04 / IN $03, advances destination by 32 bytes/row; sets B to height+bias; uses RAM $20BC |

The graphics-port contract is a real hardware interaction: port $04 supplies the source/shift operation and port $03 supplies the resulting byte. Rendering effects must be validated on the actual board or its implementation in an emulator, not inferred solely from the unshifted data bits.

## VM dispatch and player controls

`VM_DISPATCH_NEXT` at $03A7 reads the 16-bit script pointer in RAM $2000, uses $20C6 to select the alternate script $089B when active, fetches the next 8-bit command, and indexes the native command table at $09AE by adding the offset twice. It pushes the continuation $03A6 and transfers with `JP (HL)`. The native handler returns into the VM; the dispatcher has no explicit opcode bounds check.

`VM_INPUT_EVENT_DISPATCH` at $03C9 double-samples controller ports $00/$01, passing each stable sample to `DISPATCH_INPUT_TRANSITION` ($040D) along with stored state $2017/$2018 and the 16-bit action vectors at $097E/$098E.

**Input-action contract:** on entry `A` is the new stable port byte, `HL` points to its saved state, and `DE` points to the relevant native action-vector table. The helper computes the changed bits, scans the bit mask, updates only the selected state bit, then jumps indirectly into the native handler. The handler's `RET` returns to the VM caller. The 24 vector slots do not represent 24 distinct routines; six slots share a one-byte `RET` no-op.

**Player motion and firing:** Eight directional action entries write signed axis component bytes at offset +1 or +5 in the player records at $202A or $203D. The aim actions at $042A/$043E convert controller bits $70 into even byte offsets $02–$0E, then use `INSTALL_AIM_DESCRIPTOR` at $044F to store one of the two player-specific 16-bit graphics pointers at object offset +$0B.

The firing actions at $04B0 and $0517 check projectile state at $2063/$2087 and fire guards $2012/$2013, then call `UPDATE_SHOT_STATE` at $04FA. A common firing tail at $04DF calls `SELECT_AIM_DESCRIPTOR` ($037C) with the saved direction index to derive relative projectile coordinates from seven two-byte adjustment records at $0F00–$0F0D, writes projectile data with interrupts disabled and updates $2014. The graphics-pointer selection and projectile-coordinate lookup are different original data formats. Full tables are in [AIM-AND-FIRE.md](AIM-AND-FIRE.md).

## Score text, bitmap graphics, and scene control

`UPDATE_SCORE_DISPLAY` at $05A3 formats four packed-decimal fields from RAM $2002+ into the text buffer at $201E. `DRAW_FORMATTED_TEXT` at $05FB accepts `A` character count, `HL` formatted-source stream and `DE` bitmap destination. Values under $30 act as horizontal spacing controls; other bytes index ten-byte glyph records at ROM $09F8. Each glyph is transferred as ten scanlines, using 32-byte display stride.

`CLEAR_BITMAP_DISPLAY` ($0655) uses a special calling contract: it disables interrupts, pops the saved return address, uses SP=$400F and repeated zero `PUSH BC` operations to clear the screen, restores SP=$2400, enables interrupts, and jumps to the saved continuation. This is **not** an ordinary leaf routine and must not be rewritten as one.

`RUN_GAME_DISPLAY_SEQUENCE` ($06BC) selects ROM graphics based on game state $2002/$2005 and state bits at $2016. It calls `DRAW_NATIVE_OBJECT_DATA` and can initialize the special object record at $2050.

`FILL_DISPLAY_RECTANGLE` ($0785) uses `VIDEO_ADDRESS_FROM_PACKED_COORDINATES` to locate output bytes, fills each span, and advances 32 bytes per row. `EXPAND_PACKED_GRAPHICS` ($07AB) consumes packed ROM data beginning at $0BC4, rotates source byte bits into an expanded arrangement, and writes RAM from $2100 onward. This supports RAM-based graphics references used by the second player.

### Verification and remaining work

- **Source checked:** 92 internal labels identified by control-flow position; 4 KB program layout remains contiguous with no missing label operands. Symbol-normalized instruction listing was compared with the prior PR revision to confirm the instruction/operand text was unchanged.
- **Not yet run:** native zmac assembly, all four original chip SHA-1 checks, MAME gameplay, real hardware.
- **Open behavioral work:** exact collision-event consequences, screen positioning and compositing at hardware ports, sound/output signals, complete interrupt cadence, and every object animation frame. Do not treat static control-flow interpretation as executed-game verification.

The architecture and native routines are original 8080; host-side RE assistance has not substituted program logic or original toolchain behavior.
