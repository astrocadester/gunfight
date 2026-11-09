# Gun Fight — native implementation of the indexed game words

## Native hard RE — v20261108-0002

These details come from tracing native 8080 instructions in `src/gunfight.asm`, including dispatch operands, ROM pointer tables, and RAM writes. The original 8080 logic and ROM data remain unchanged.

### Interpreter and input selection

`VM_DISPATCH_NEXT` at `$03A7` loads the script cursor from `$2000` and conditionally substitutes `$089B` when `$20C6` is active. It fetches one byte into E, advances `$2000`, doubles the word index into `$09AE`, loads the little-endian native address, pushes the interpreter continuation `$03A6`, and transfers through `JP (HL)`. The unusual hand-built continuation means ordinary handlers use `RET` to re-enter the interpreter.

`VM_INPUT_EVENT_DISPATCH` at `$03C9` samples ports `$00` and `$01` twice to detect stable values, then calls the shared `DISPATCH_INPUT_TRANSITION` at `$040D` with RAM input state and an action table. The two tables start at `$097E` and `$098E`. The action helper selects a changed control bit and jumps indirectly to its native address. The first player's firing vector points at `$04B0`; the second player's at `$0517`. The two paths each check projectile availability, update the shot counter through `$04FA`, write port `$01`, and load a player-specific object record.

### Player-specific native routines

| First player | Second player | Purpose |
| --- | --- | --- |
| `$042A` | `$043E` | Select input-dependent aim data from the ROM tables at `$0EE2` and `$0EF0`, then update `$202A` or `$203D` |
| `$04B0` | `$0517` | Validate shot state, start fire/update work, and populate player projectile state |
| `$202A` | `$203D` | Player object record bases |
| `$2063` | `$2087` | Projectile/state flags read on the firing paths |
| `$2012` | `$2013` | Fire guard counters checked before launching |
| `$3EA2` | `$3EB8` | Display-related destination addresses passed to the common shot update |

These are recovered operand and control-flow relationships; further screen-level tracing is needed to establish every visual and collision consequence.

### Bitmap coordinate and drawing mechanics

`VIDEO_ADDRESS_FROM_PACKED_COORDINATES` at `$0359` separates E's low three bits as bit-phase C and shifts the remaining 16-bit DE coordinate three places to the right, then adds the display base `$2400`. The result is a packed-pixel byte address in DE plus a bit-phase in C. The native sprite copier at `$022D` reads its shape source through DE, uses port `$04` to supply function/shift data and port `$03` for the returned pixel value, writes into video memory, and advances each row by `$20` bytes.

`DRAW_FORMATTED_TEXT` at `$05FB` is a separate character renderer. It takes A as the number of characters and reads a byte stream through HL. Bytes below `$30` are positioning controls; nonnegative character indexes after subtracting `$30` select 10-byte glyph records from ROM `$09F8`. The routine copies each glyph as 10 rows into display memory using a `$20` stride. `UPDATE_SCORE_DISPLAY` at `$05A3` converts packed score digits into the byte stream before entering that renderer.

### Inline graphics recovery

The numeric font begins at `$09F8` and the first ten records are the glyphs for digits `0–9`. The source now expresses each record as ten individual byte rows with the corresponding eight-pixel on/off pattern as an inline comment. For example, digit zero is:

```asm
FONT_SCORE_DIGITS:
        ; digit 0 — 8 pixels wide by 10 rows
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
```

This is inline ROM graphics rather than an external replacement image. Five further width/height-prefixed ROM patterns, including three 24×12 frames, are now decoded in the source. See [graphics and display formats](GRAPHICS.md) for boundaries and native renderer evidence.

### Compact object pointer helper

The helper at `$02BD` reads a two-byte pointer from RAM address HL and clears those pointer bytes. Its final `EX DE,HL` returns the **old pointer in HL** and the **address after the cleared field in DE**. B is zero and Z reflects whether the old pointer was zero. The timer/interrupt engine repeatedly calls it while walking object pools. The object-coordinate updater at `$025E` uses the axis-step logic at `$0280`, tracks active-state flags, and may clear an object's activity bit when its motion ends.



This report is generated from the original-ROM-reconstructed assembly at this PR's head. It distinguishes **native vector slots**, their **ROM command packet occurrences**, and the **initial native instructions** at each entry. Names are descriptive reconstructed identifiers, not original DNA spellings.

- Original ROM image size: 4096 bytes.
- Native instruction starts identified: 1264, native byte coverage: 2064 bytes.
- Bounded unique bytecode packet sites: 82 (not a dynamic invocation count).
- Native words: 21 indexed slots. The apparent later vectors following $09D6 are event-script destinations, not nine additional native words.

## Native word entry table

| Word | Descriptive name | Entry | Statically decoded ROM command sites |
|---|---|---|---:|
| `$00` | `WAIT_REPEAT` | `$0813` | 13 |
| `$01` | `DRAW_FORMATTED_DATA` | `$05E9` | 9 |
| `$02` | `SET_RAM_2003` | `$063D` | 0 |
| `$03` | `SET_RAM_2015` | `$0649` | 12 |
| `$04` | `CLEAR_DISPLAY` | `$0655` | 2 |
| `$05` | `COPY_INLINE_15` | `$068D` | 5 |
| `$06` | `COPY_INLINE_9` | `$069D` | 5 |
| `$07` | `CLEAR_OBJECT_FLAGS` | `$0670` | 2 |
| `$08` | `TOGGLE_OBJECT_FLAGS` | `$06AD` | 0 |
| `$09` | `BRANCH_SCRIPT` | `$0682` | 11 |
| `$0A` | `GAME_DISPLAY` | `$06BC` | 1 |
| `$0B` | `INIT_OBJECT` | `$0749` | 2 |
| `$0C` | `BCD_INCREMENT_INIT` | `$0738` | 2 |
| `$0D` | `SET_OUTPUT_AND_RAM` | `$0775` | 3 |
| `$0E` | `FILL_RECTANGLE` | `$0785` | 7 |
| `$0F` | `EXPAND_GRAPHICS` | `$07AB` | 2 |
| `$10` | `BRANCH_IF_STATE` | `$0807` | 1 |
| `$11` | `DRAW_STATUS_A` | `$07E9` | 1 |
| `$12` | `DRAW_STATUS_B` | `$07EF` | 1 |
| `$13` | `UPDATE_SCORE_TEXT` | `$05A3` | 2 |
| `$14` | `INPUT_EVENT_DISPATCH` | `$03C9` | 1 |

## ROM-native handler entry instructions

Each section shows the first native instructions at a handler entry, stopping at an unconditional `RET` or `JP` or after twelve instructions. This is a *bounded entry trace*, not a claim that all conditional paths or called services are semantically resolved. Detailed argument analysis is in [8080-WORD-SEMANTICS.md](8080-WORD-SEMANTICS.md).

### $00 — WAIT_OR_REPEAT ($0813)

13 known ROM command packet site(s). Native entry:

```asm
LD HL,$20C5  ; ROM $0813: 21 C5 20
INC (HL)  ; ROM $0816: 34
RET Z  ; ROM $0817: C8
```

### $01 — DRAW_FORMATTED_DATA ($05E9)

9 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $05E9: 2A 00 20
LD A,(HL)  ; ROM $05EC: 7E
INC HL  ; ROM $05ED: 23
LD E,(HL)  ; ROM $05EE: 5E
INC HL  ; ROM $05EF: 23
LD D,(HL)  ; ROM $05F0: 56
INC HL  ; ROM $05F1: 23
PUSH DE  ; ROM $05F2: D5
LD E,(HL)  ; ROM $05F3: 5E
INC HL  ; ROM $05F4: 23
LD D,(HL)  ; ROM $05F5: 56
INC HL  ; ROM $05F6: 23
```

### $02 — SET_2003 ($063D)

0 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $063D: 2A 00 20
LD A,(HL)  ; ROM $0640: 7E
INC HL  ; ROM $0641: 23
LD ($2000),HL  ; ROM $0642: 22 00 20
LD ($2003),A  ; ROM $0645: 32 03 20
RET  ; ROM $0648: C9
```

### $03 — SET_2015 ($0649)

12 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0649: 2A 00 20
LD A,(HL)  ; ROM $064C: 7E
INC HL  ; ROM $064D: 23
LD ($2000),HL  ; ROM $064E: 22 00 20
LD ($2015),A  ; ROM $0651: 32 15 20
RET  ; ROM $0654: C9
```

### $04 — CLEAR_DISPLAY_MEMORY ($0655)

2 known ROM command packet site(s). Native entry:

```asm
DI  ; ROM $0655: F3
POP HL  ; ROM $0656: E1
LD BC,$0000  ; ROM $0657: 01 00 00
LD DE,$0000  ; ROM $065A: 11 00 00
LD A,$10  ; ROM $065D: 3E 10
LD SP,$400F  ; ROM $065F: 31 0F 40
```

### $05 — COPY_INLINE_15 ($068D)

5 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $068D: 2A 00 20
LD E,(HL)  ; ROM $0690: 5E
INC HL  ; ROM $0691: 23
LD D,(HL)  ; ROM $0692: 56
INC HL  ; ROM $0693: 23
LD C,$0F  ; ROM $0694: 0E 0F
CALL $0372  ; ROM $0696: CD 72 03
LD ($2000),HL  ; ROM $0699: 22 00 20
RET  ; ROM $069C: C9
```

### $06 — COPY_INLINE_9 ($069D)

5 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $069D: 2A 00 20
LD E,(HL)  ; ROM $06A0: 5E
INC HL  ; ROM $06A1: 23
LD D,(HL)  ; ROM $06A2: 56
INC HL  ; ROM $06A3: 23
LD C,$09  ; ROM $06A4: 0E 09
CALL $0372  ; ROM $06A6: CD 72 03
LD ($2000),HL  ; ROM $06A9: 22 00 20
RET  ; ROM $06AC: C9
```

### $07 — CLEAR_OBJECT_FLAGS ($0670)

2 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0670: 2A 00 20
LD E,(HL)  ; ROM $0673: 5E
INC HL  ; ROM $0674: 23
LD D,(HL)  ; ROM $0675: 56
INC HL  ; ROM $0676: 23
LD ($2000),HL  ; ROM $0677: 22 00 20
LD A,(DE)  ; ROM $067A: 1A
AND $BF  ; ROM $067B: E6 BF
LD (DE),A  ; ROM $067D: 12
INC DE  ; ROM $067E: 13
XOR A  ; ROM $067F: AF
LD (DE),A  ; ROM $0680: 12
```

### $08 — TOGGLE_OBJECT_BITS ($06AD)

0 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $06AD: 2A 00 20
LD E,(HL)  ; ROM $06B0: 5E
INC HL  ; ROM $06B1: 23
LD D,(HL)  ; ROM $06B2: 56
INC HL  ; ROM $06B3: 23
LD ($2000),HL  ; ROM $06B4: 22 00 20
LD A,(DE)  ; ROM $06B7: 1A
XOR $60  ; ROM $06B8: EE 60
LD (DE),A  ; ROM $06BA: 12
RET  ; ROM $06BB: C9
```

### $09 — GOTO_SCRIPT ($0682)

11 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0682: 2A 00 20
LD E,(HL)  ; ROM $0685: 5E
INC HL  ; ROM $0686: 23
LD D,(HL)  ; ROM $0687: 56
EX DE,HL  ; ROM $0688: EB
LD ($2000),HL  ; ROM $0689: 22 00 20
RET  ; ROM $068C: C9
```

### $0A — GAME_DISPLAY_SEQUENCE ($06BC)

1 known ROM command packet site(s). Native entry:

```asm
LD HL,$0F0E  ; ROM $06BC: 21 0E 0F
XOR A  ; ROM $06BF: AF
OUT ($02),A  ; ROM $06C0: D3 02
LD A,($2002)  ; ROM $06C2: 3A 02 20
```

### $0B — INITIALIZE_OBJECT ($0749)

2 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0749: 2A 00 20
LD E,(HL)  ; ROM $074C: 5E
INC HL  ; ROM $074D: 23
LD D,(HL)  ; ROM $074E: 56
INC HL  ; ROM $074F: 23
DI  ; ROM $0750: F3
LD A,$80  ; ROM $0751: 3E 80
LD (DE),A  ; ROM $0753: 12
INC DE  ; ROM $0754: 13
INC DE  ; ROM $0755: 13
LD A,(HL)  ; ROM $0756: 7E
INC HL  ; ROM $0757: 23
```

### $0C — INCREMENT_BCD_AND_RESET ($0738)

2 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0738: 2A 00 20
LD E,(HL)  ; ROM $073B: 5E
INC HL  ; ROM $073C: 23
LD D,(HL)  ; ROM $073D: 56
INC HL  ; ROM $073E: 23
LD ($2000),HL  ; ROM $073F: 22 00 20
LD A,(DE)  ; ROM $0742: 1A
INC A  ; ROM $0743: 3C
DAA  ; ROM $0744: 27
LD (DE),A  ; ROM $0745: 12
CALL $05A3  ; ROM $0746: CD A3 05
```

### $0D — OUTPUT_AND_SET_2014 ($0775)

3 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0775: 2A 00 20
LD A,(HL)  ; ROM $0778: 7E
OUT ($01),A  ; ROM $0779: D3 01
INC HL  ; ROM $077B: 23
LD A,(HL)  ; ROM $077C: 7E
INC HL  ; ROM $077D: 23
LD ($2000),HL  ; ROM $077E: 22 00 20
LD ($2014),A  ; ROM $0781: 32 14 20
```

### $0E — FILL_RECTANGLE ($0785)

7 known ROM command packet site(s). Native entry:

```asm
LD HL,($2000)  ; ROM $0785: 2A 00 20
LD A,($201D)  ; ROM $0788: 3A 1D 20
LD E,(HL)  ; ROM $078B: 5E
INC HL  ; ROM $078C: 23
LD D,(HL)  ; ROM $078D: 56
INC HL  ; ROM $078E: 23
LD ($2000),HL  ; ROM $078F: 22 00 20
SUB D  ; ROM $0792: 92
LD L,$02  ; ROM $0793: 2E 02
LD H,A  ; ROM $0795: 67
CALL $0359  ; ROM $0796: CD 59 03
EX DE,HL  ; ROM $0799: EB
```

### $0F — EXPAND_GRAPHICS_TABLE ($07AB)

2 known ROM command packet site(s). Native entry:

```asm
LD HL,$2100  ; ROM $07AB: 21 00 21
LD DE,$0BC4  ; ROM $07AE: 11 C4 0B
```

### $10 — CONDITIONAL_GOTO_0882 ($0807)

1 known ROM command packet site(s). Native entry:

```asm
LD A,($2008)  ; ROM $0807: 3A 08 20
AND A  ; ROM $080A: A7
RET Z  ; ROM $080B: C8
```

### $11 — DRAW_STATUS_203F ($07E9)

1 known ROM command packet site(s). Native entry:

```asm
LD HL,$203F  ; ROM $07E9: 21 3F 20
JP $07F2  ; ROM $07EC: C3 F2 07
```

### $12 — DRAW_STATUS_202C ($07EF)

1 known ROM command packet site(s). Native entry:

```asm
LD HL,$202C  ; ROM $07EF: 21 2C 20
```

### $13 — UPDATE_SCORE_TEXT ($05A3)

2 known ROM command packet site(s). Native entry:

```asm
XOR A  ; ROM $05A3: AF
LD ($2003),A  ; ROM $05A4: 32 03 20
```

### $14 — INPUT_AND_EVENT_DISPATCH ($03C9)

1 known ROM command packet site(s). Native entry:

```asm
CALL $0813  ; ROM $03C9: CD 13 08
IN A,($00)  ; ROM $03CC: DB 00
LD B,A  ; ROM $03CE: 47
IN A,($00)  ; ROM $03CF: DB 00
CP B  ; ROM $03D1: B8
LD HL,$2017  ; ROM $03D2: 21 17 20
LD DE,$097E  ; ROM $03D5: 11 7E 09
CALL Z,$040D  ; ROM $03D8: CC 0D 04
IN A,($01)  ; ROM $03DB: DB 01
LD B,A  ; ROM $03DD: 47
IN A,($01)  ; ROM $03DE: DB 01
CP B  ; ROM $03E0: B8
```

## RE boundary

Remaining raw `DB` sections include graphics, vector tables, command packets, native-unreached data, and potentially code copied into RAM. Do not call them 'unknown interpreter words' merely because their bytes resemble opcodes. Source-generation provenance and unresolved ranges are recorded in [DB-PROVENANCE.md](DB-PROVENANCE.md). Regenerating the source must preserve the original chip SHA-1s.
