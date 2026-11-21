# Gun Fight — graphics and native display-data formats

The original 8080 rendering routines support two distinct data paths: a ten-row character renderer and a width/height-prefixed object pattern renderer. The source preserves their byte streams in assembly, with inline `#` / `.` bit previews. Controller-directed graphics selection and shot-position data are recovered separately in [Aim and fire](AIM-AND-FIRE.md).

## Bitmap pixel addressing

`VIDEO_ADDRESS_FROM_PACKED_COORDINATES` (`$0359`) accepts a packed coordinate in DE. It saves the low three bits of E in C and shifts the 16-bit coordinate right three places, then adds `$2400`. Thus a byte address is `$2400 + floor(coordinate/8)`, with C holding the bit phase. Actual display orientation is determined by hardware, not by this address conversion alone.

`DRAW_NATIVE_OBJECT_DATA` (`$022D`) consumes object-pattern data from DE. The first byte is the number of source bytes per row; the next supplies the stored height (combined with B for the native caller's offset handling). Pattern data is passed to hardware output port `$04`, read back from port `$03`, and written to successive display rows at a 32-byte stride.

## Structurally decoded original graphics

The following records are now expressed as typed inline byte rows in [`src/gunfight.asm`](../src/gunfight.asm). Addresses are source cross-reference locations, not arbitrary labels.

| Pattern | ROM | Header | Inline pixels |
| --- | --- | --- | --- |
| `PLAYER_FRAME_PATTERN_A_24X12` | `$0D8B` | `03 0C` | 3 bytes × 12 rows (24 stored bits/row) |
| `PLAYER_FRAME_PATTERN_B_24X12` | `$0DB1` | `03 0C` | 3 bytes × 12 rows |
| `PLAYER_FRAME_PATTERN_C_24X12` | `$0DD7` | `03 0C` | 3 bytes × 12 rows |
| `EVENT_OBJECT_PATTERN_24X32` | `$0DFD` | `03 20` | 3 bytes × 32 rows |
| `EVENT_OBJECT_PATTERN_32X11` | `$0E5F` | `04 0B` | 4 bytes × 11 rows |

The first three record boundaries are proven by the consecutive `$0D8B/$0DB1/$0DD7` native frame pointers at `$0349`, the two-byte dimensions, and the 38-byte separation. The following `$0DFD` and `$0E5F` boundaries follow the same packed record convention and sizes (98 and 46 bytes). The three 24x12 records are frame selections for the player animation tables. The 24x32 and 32x11 records are installed by the event scripts at $091B and $0929; their exact on-screen object identities remain under investigation.

The animation/frame-pointer tables at `$0349` and `$0351` each have four little-endian entries selected by `$2009` state bits. These are distinct from the controller aim-pointer tables at `$0EE2` and `$0EF0`. The first uses ROM frame patterns A, B, C, B; the second references RAM-based pattern/animation records. These are typed `DW` entries in the assembly.

### Inline pixel representation

For example, the first bytes of pattern A are the header `$03,$0C`, then one 24-bit row:

```asm
PLAYER_FRAME_PATTERN_A_24X12:
        DB $03,$0C          ; width=3 bytes, height=12 rows
        DB $F0,$3F,$00      ; ####.... ..###### ........
```

The pixel comments show *stored bit order, most significant bit first*. They are not a claim about hardware-screen position, shift register output, or in-game sprite identity.

## Score glyphs

`FONT_SCORE_DIGITS` begins at `$09F8`, with ten consecutive digit glyphs corresponding to `$30–$39`. Each glyph is 8 pixels wide and ten scanlines high. `DRAW_FORMATTED_TEXT` (`$05FB`) indexes the glyph table with character values minus `$30`, copies ten glyph bytes into the bitmap, and advances vertically by `$20` between scanlines. `UPDATE_SCORE_DISPLAY` (`$05A3`) builds the formatted character stream from packed score state.

The source displays each digit's ten literal bytes and eight-bit pixel row. No generated image replaces the stored graphics.

## Remaining graphics RE

The twelve-record expansion stream and its RAM destinations are now fully enumerated. The outstanding work is runtime display verification:

- Associate the two event graphics, the special object, and the three player animation frames with their exact on-screen appearances.
- Trace graphics ports $04 (write), $03 (read), and port $02 mode to establish rendered orientation, shifting, masking and compositing.
- Verify the seven direction choices and player-specific frame selections against actual gameplay.
- Document pixel clipping at row boundaries, including the extra zero-latch byte written by the native renderer.

The original aim-pointer tables and shot-offset pairs are already decoded in [Aim and fire](AIM-AND-FIRE.md). The outstanding work does not justify inventing sprite names or substituting graphics logic.

## ROM record boundaries recovered in v20261121-0005

The original drawing and VM expansion code now identifies these additional data structures:

- `$0A5C–$0B73`: 28 more ten-row font glyph slots following the numeric digits, indexed as character codes `$3A–$55`. They are presented individually with original scanline bits in ASM.
- `$0B74`: `SCENE_VERTICAL_STRIP_8X22` (header `01 16`), referenced by native scene draw lists at `$0F0E`, `$0F22` and `$0F36`.
- `$0B8C`: `SCENE_WIDE_SHAPE_16X27` (header `02 1B`), also selected by scene draw lists.
- `$0BC4–$0D8A`: seven consecutive `3 × 21` aim-direction patterns, 65 bytes each. These match the first player's seven ROM aim pointers and the second player's corresponding expanded RAM entries `$2100,$2141,...,$2286`.
- `$0D8B–$0DFD`: three 24x12 player animation/frame sources; selected by the first player in ROM and the second through the corresponding RAM-expanded copies.
- `$0DFD` and `$0E5F`: event-installed object graphics (24x32 and 32x11).
- `$0E8D`: zero terminator of the packed graphics expansion stream.
- `$0E8E`: special-object 24x28 pattern, referenced by the 15-byte initialization record at `$0F52`. Its last two stored bytes at `$0EE2–$0EE3` also form the unused `DW $2000` zero-index entry of the Player 1 aim table; source bytes are deliberately shared, not duplicated.
- `$0F0E/$0F22/$0F36`: destination/pattern 16-bit pointer pairs consumed by the scene-drawing routine.
- `$0F3A/$0F52/$0F61`: state setup, special-object initialization and encoded display text records.

These names document code-proven ownership and dimensions, rather than guessing historical DNA symbols or assigning unverified pictured-object identities.

## Encoded game messages

The display-message bytes at ROM `$0F61–$0FFF` have been divided into their actual source-pointer entry positions, not treated as independent zero-terminated ASCII strings. `TEXT_GAME_OVER` begins at `$0F61`, `TEXT_TITLE_BLANKS` at `$0F6D`, `TEXT_INSERT_COIN` at `$0F99`, and the ready/draw dialogue begins at `$0FAF`.

The `DRAW_FORMATTED_TEXT` routine handles codes `$30` and above by indexing the 10-byte glyph records from `$09F8`. Values below `$30` advance the bitmap position. The glyph codes are not a direct ASCII text encoding; for example, `$4B` is drawn as M and `$4F` as R in the ROM font. Consequently `$47,$41,$4B,$45` displays GAME. The indexed VM text word `$01` carries a glyph count, a 16-bit source pointer and a 16-bit display destination.

Decoded phrases include GAME OVER, GUN FIGHT, INSERT COIN, GET READY, DRAW, GOT ME, HEY PARDNER, YOU HAVE CREDIT and PUSH BUTTON. Positioning values and separator glyphs remain numeric in the byte-preserving ASM.

## GF-RE-003 — native graphics transformation and exact RAM ownership

### Twelve original source records and transformed RAM copies

VM word $0F, `EXPAND_PACKED_GRAPHICS` at $07AB, reads twelve successive original ROM patterns from $0BC4 and writes same-sized copies at RAM $2100. Each record contains a one-byte width (bytes per row), a one-byte height (rows), then exactly width × height raster bytes. The twelve headers and 713 original source bytes have been checked against the maintained assembly.

| Original source record | ROM | Width × height | Bytes | Expanded RAM | RAM ASM symbol |
| --- | --- | --- | ---: | --- | --- |
| `AIM_DIRECTION_PATTERN_0` | `$0BC4` | 3×21 | 65 | `$2100` | `EXPANDED_AIM_DIRECTION_0` |
| `AIM_DIRECTION_PATTERN_1` | `$0C05` | 3×21 | 65 | `$2141` | `EXPANDED_AIM_DIRECTION_1` |
| `AIM_DIRECTION_PATTERN_2` | `$0C46` | 3×21 | 65 | `$2182` | `EXPANDED_AIM_DIRECTION_2` |
| `AIM_DIRECTION_PATTERN_3` | `$0C87` | 3×21 | 65 | `$21C3` | `EXPANDED_AIM_DIRECTION_3` |
| `AIM_DIRECTION_PATTERN_4` | `$0CC8` | 3×21 | 65 | `$2204` | `EXPANDED_AIM_DIRECTION_4` |
| `AIM_DIRECTION_PATTERN_5` | `$0D09` | 3×21 | 65 | `$2245` | `EXPANDED_AIM_DIRECTION_5` |
| `AIM_DIRECTION_PATTERN_6` | `$0D4A` | 3×21 | 65 | `$2286` | `EXPANDED_AIM_DIRECTION_6` |
| `PLAYER_FRAME_PATTERN_A_24X12` | `$0D8B` | 3×12 | 38 | `$22C7` | `EXPANDED_PLAYER_FRAME_A` |
| `PLAYER_FRAME_PATTERN_B_24X12` | `$0DB1` | 3×12 | 38 | `$22ED` | `EXPANDED_PLAYER_FRAME_B` |
| `PLAYER_FRAME_PATTERN_C_24X12` | `$0DD7` | 3×12 | 38 | `$2313` | `EXPANDED_PLAYER_FRAME_C` |
| `EVENT_OBJECT_PATTERN_24X32` | `$0DFD` | 3×32 | 98 | `$2339` | `EXPANDED_EVENT_OBJECT_24X32` |
| `EVENT_OBJECT_PATTERN_32X11` | `$0E5F` | 4×11 | 46 | `$239B` | `EXPANDED_EVENT_OBJECT_32X11` |

The records occupy **ROM $0BC4–$0E8C, 713 bytes ($02C9)**. They become **RAM $2100–$23C8**, with exclusive end `EXPANDED_GRAPHICS_END = $23C9`. The original byte $00 at ROM $0E8D ends the transformation. The separate special-object pattern beginning at $0E8E is **not expanded to RAM** by this instruction stream.

### Exact row transformation in the original 8080

`EXPAND_GRAPHICS_NEXT_COLUMN` advances HL by the record width; its inner loop reads source bytes forward but decrements HL before each output store. The `RRA` (D) / `RLA` (E) pair, repeated eight times per byte, reverses each byte's bit order. Storing the bytes backward across the destination row also reverses their order. Together, **each complete stored raster row is mirrored horizontally**. Headers and total record size are unchanged.

For example, the first 3-byte row of ROM `PLAYER_FRAME_PATTERN_A_24X12` is `F0 3F 00`. The corresponding RAM row is `00 FC 0F` after reversing bit order and byte order. This is a deduction from native instructions, not a generated replacement for the original game data.

### Source-proven pointer and renderer relationships

- The aim-offset calculation at $042A/$043E selects a nonzero even byte offset into 16-bit player-specific tables. Player one aims using seven original ROM pointers; player two aims using the corresponding transformed RAM pointers. The table order is intentionally nonsequential and remains unchanged in the maintained ASM.
- The frame-table lookup at $0326 selects four slots using state `($2009 AND $0C) >> 1` as a byte offset. Player-one slots are ROM A/B/C/B; player-two slots are RAM A/B/C/B at $22C7/$22ED/$2313/$22ED.
- The event scripts rooted at $091B and $0929 install pointers directly to ROM `EVENT_OBJECT_PATTERN_24X32` and `EVENT_OBJECT_PATTERN_32X11`. Their transformed RAM copies exist but are not the pointers used by these two script packets.
- The scene drawing routine at $06BC uses the destination/ROM-source pointer tables at $0F0E, $0F22 and $0F36 to draw the separate 8×22 and 16×27 shapes.
- The special-object source at $0E8E follows the expander's zero terminator and is referenced in the original $0F52 initialization record. It remains an original ROM-rendered source; its last raster row shares bytes with the unused aim-table entry at $0EE2.

`DRAW_NATIVE_OBJECT_DATA` at $022D sends original pattern data to graphics port $04, reads processed bytes from $03, and writes rows of video RAM with a $20-byte stride. The IRQ can also composite source and existing video pixels. Thus the source-level **RAM mirroring is established**, but final displayed orientation and masking still require MAME/board evidence.

**Verification:** Twelve dimension headers and byte counts cross-checked against the maintained ASM; source instruction/data stream canonical comparison passed. No new MAME graphics-port trace was performed.
