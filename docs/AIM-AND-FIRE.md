# Gun Fight — controller direction, aim tables, and projectile placement

## Native direction decoding

The two native input actions at `$042A` and `$043E` read the changed control value through DE. They apply `AND $70` followed by three `RRCA` instructions. Because the masked high nibble has its low three bits clear, the result is a **byte offset** `$00,$02,$04,$06,$08,$0A,$0C,$0E` into a table of 16-bit little-endian values. Each caller performs `AND A` / `RET Z`, so only the seven nonzero offsets reach the shared `INSTALL_AIM_DESCRIPTOR` routine at `$044F`.

```asm
PLAYER_ONE_AIM_ACTION:
        LD A,(DE)
        AND $70
        RRCA
        RRCA
        RRCA
        AND A
        RET Z
        LD ($201A),A
        LD HL,PLAYER_ONE_AIM_POINTERS
        LD DE,$202A
        JP INSTALL_AIM_DESCRIPTOR
```

The second player's code is the same transform, with saved direction `$201B`, aim table `PLAYER_TWO_AIM_POINTERS` and object base `$203D`.

## Native aim-table layout

The input-derived offsets are **even**, so `INSTALL_AIM_DESCRIPTOR` reads complete 16-bit pointer entries through `ADD HL,BC`, `LD C,(HL)`, `INC HL`, `LD B,(HL)`. It writes `$C0` at the start of the selected player object and stores the pointer at object offset `+$0B`.

| Offset | Player one, base `$0EE2` | Player two, base `$0EF0` |
| --- | --- | --- |
| `$00` | `$2000` — unused | `$0CC8` — unused for player two |
| `$02` | `$0D4A` | `$2286` |
| `$04` | `$0C46` | `$2182` |
| `$06` | `$0C87` | `$21C3` |
| `$08` | `$0BC4` | `$2100` |
| `$0A` | `$0D09` | `$2245` |
| `$0C` | `$0C05` | `$2141` |
| `$0E` | `$0CC8` | `$2204` |

The entry at `$0EF0` is **simultaneously player one's final entry and player two's unused zero-index entry**. Both are the same two physical ROM bytes, not two overlapping two-byte *reads*. The zero input branch prevents the player-two handler from reading its `$0EF0` entry. This layout saves two ROM bytes.

The first player's selected values point into ROM graphics/data. Several values for the second player point into RAM graphics beginning at `$2100`, populated by command `$0F`. Determining the exact corresponding sprite frame at every direction remains a rendering-trace task.

## Projectile placement uses different data

The firing handlers begin at `$04B0` and `$0517`. Both load the saved direction from `$201A` or `$201B`, then use the common `SELECT_AIM_DESCRIPTOR` helper at `$037C` with lookup base `$0EFE`.

That **is not another aim-pointer lookup**. The helper treats the indexed bytes as relative coordinate components and combines them with the player object position:

```asm
        PUSH DE                  ; player projectile object address
        LD E,A                   ; even direction offset
        LD D,$00
        ADD HL,DE                ; $0EFE + offset
        LD A,B                   ; caller's X-side bias
        LD B,(HL)                ; first packed byte
        INC HL
        LD D,(HL)                ; second packed byte
        POP HL                   ; target object
        ADD A,(HL)
        LD E,A                   ; X-side result
        INC HL
        INC HL
        INC HL
        INC HL
        LD A,(HL)
        ADD A,D
        LD D,A                   ; Y-side result
        RET
```

The seven two-byte shot records begin at `$0F00` (offset `$02` from `$0EFE`):

| Direction offset | Relative bytes |
| --- | --- |
| `$02` | `$06,$1A` |
| `$04` | `$FF,$08` |
| `$06` | `$00,$0C` |
| `$08` | `$FA,$FE` |
| `$0A` | `$03,$16` |
| `$0C` | `$FD,$02` |
| `$0E` | `$01,$14` |

The `$0EFE–$0EFF` bytes are simultaneously the second player's final aim pointer (`$2204`) and the unused zero-index position of the shot-parameter lookup. Native instruction flow distinguishes these two data interpretations.

## Why this matters

The VM installs game object records while native controller actions update their chosen graphics pointers. On firing, the same direction index selects a small coordinate adjustment instead of a graphics pointer. This explains how script-level object initialization connects to player-specific aiming and shot placement, without changing the game program or requiring guessed source-language names.

### Source cross references

- `src/gunfight.asm`: `PLAYER_ONE_AIM_ACTION`, `PLAYER_TWO_AIM_ACTION`, `INSTALL_AIM_DESCRIPTOR`, `PLAYER_ONE_AIM_POINTERS`, `PLAYER_TWO_AIM_POINTERS`, `SHOT_PARAMETER_BASE`, `SHOT_DIRECTION_DELTAS` and `SELECT_AIM_DESCRIPTOR`.
- [Native implementation notes](NATIVE-WORD-IMPLEMENTATIONS.md)
- [Graphics structures](GRAPHICS.md)
- [Command scripts](decoded-scripts.md)

**Verification:** This contract is established by direct 8080 instruction and source-data inspection. Native zmac byte-identity and emulator validation remain separate checks.

## Source formatting and overlap, v20261121-0005

The ASM aim tables now list one `DW` per entry without redundant per-line comments. The shared offsets and the owner of each pointer are documented in the table above. First-player active graphics entries use their identified ROM symbols `AIM_DIRECTION_PATTERN_0` through `AIM_DIRECTION_PATTERN_6`; second-player active entries continue to refer to their actual RAM locations.

The unused Player 1 zero-offset word at `$0EE2` also supplies the last two stored bytes of `SPECIAL_OBJECT_PATTERN_24X28`, whose declared 3-by-28 raster begins at `$0E8E`. The original code does not select the unused zero-offset entry, so its address value is incidental to aiming while still meaningful as source bitmap data.

The seven shot adjustment pairs are kept as `DB` pairs in ascending direction-offset order, with a single header explaining coordinate arithmetic. They are not 16-bit pointers and do not receive speculative compass direction names.

## Complete gameplay path cross-reference

The source-grounded fire-acceptance, projectile-slot lifecycle, IRQ selector and scoring paths are documented in [Gameplay and collision RE](GAMEPLAY-AND-COLLISION-RE.md). The seven direction-offset records here are inputs to the shared projectile-installation routine and should not be mistaken for hit-result or sound-code tables.
