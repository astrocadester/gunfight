# Gun Fight — graphics and native display-data formats

The original 8080 rendering routines support two distinct data paths: a ten-row character renderer and a width/height-prefixed object pattern renderer. The source preserves their byte streams in assembly, with inline `#` / `.` bit previews. Controller-directed graphics selection and shot-position data are recovered separately in [Aim and fire](AIM-AND-FIRE.md).

## Bitmap pixel addressing

`VIDEO_ADDRESS_FROM_PACKED_COORDINATES` (`$0359`) accepts a packed coordinate in DE. It saves the low three bits of E in C and shifts the 16-bit coordinate right three places, then adds `$2400`. Thus a byte address is `$2400 + floor(coordinate/8)`, with C holding the bit phase. Actual display orientation is determined by hardware, not by this address conversion alone.

`DRAW_NATIVE_OBJECT_DATA` (`$022D`) consumes object-pattern data from DE. The first byte is the number of source bytes per row; the next supplies the stored height (combined with B for the native caller's offset handling). Pattern data is passed to hardware output port `$04`, read back from port `$03`, and written to successive display rows at a 32-byte stride.

## Structurally decoded original graphics

The following records are now expressed as typed inline byte rows in [`src/gunfight.asm`](../src/gunfight.asm). Addresses are source cross-reference locations, not arbitrary labels.

| Pattern | ROM | Header | Inline pixels |
| --- | --- | --- | --- |
| `OBJECT_PATTERN_24X12_A` | `$0D8B` | `03 0C` | 3 bytes × 12 rows (24 stored bits/row) |
| `OBJECT_PATTERN_24X12_B` | `$0DB1` | `03 0C` | 3 bytes × 12 rows |
| `OBJECT_PATTERN_24X12_C` | `$0DD7` | `03 0C` | 3 bytes × 12 rows |
| `OBJECT_PATTERN_24X32` | `$0DFD` | `03 20` | 3 bytes × 32 rows |
| `OBJECT_PATTERN_32X11` | `$0E5F` | `04 0B` | 4 bytes × 11 rows |

The first three record boundaries are proven by the consecutive `$0D8B/$0DB1/$0DD7` native frame pointers at `$0349`, the two-byte dimensions, and the 38-byte separation. The following `$0DFD` and `$0E5F` boundaries follow the same packed record convention and sizes (98 and 46 bytes). Pattern identity (cowboy, obstacle, animation frame, etc.) is deliberately not assigned until graphics call sites establish it.

The animation/frame-pointer tables at `$0349` and `$0351` each have four little-endian entries selected by `$2009` state bits. These are distinct from the controller aim-pointer tables at `$0EE2` and `$0EF0`. The first uses ROM frame patterns A, B, C, B; the second references RAM-based pattern/animation records. These are typed `DW` entries in the assembly.

### Inline pixel representation

For example, the first bytes of pattern A are the header `$03,$0C`, then one 24-bit row:

```asm
OBJECT_PATTERN_24X12_A:
        DB $03,$0C          ; width=3 bytes, height=12 rows
        DB $F0,$3F,$00      ; ####.... ..###### ........
```

The pixel comments show *stored bit order, most significant bit first*. They are not a claim about hardware-screen position, shift register output, or in-game sprite identity.

## Score glyphs

`FONT_SCORE_DIGITS` begins at `$09F8`, with ten consecutive digit glyphs corresponding to `$30–$39`. Each glyph is 8 pixels wide and ten scanlines high. `DRAW_FORMATTED_TEXT` (`$05FB`) indexes the glyph table with character values minus `$30`, copies ten glyph bytes into the bitmap, and advances vertically by `$20` between scanlines. `UPDATE_SCORE_DISPLAY` (`$05A3`) builds the formatted character stream from packed score state.

The source displays each digit's ten literal bytes and eight-bit pixel row. No generated image replaces the stored graphics.

## Remaining graphics RE

- Determine which in-game objects and animation frames use each recovered ROM pattern, using caller and drawing-state trace.
- Separate the later compressed graphics section and the expanded RAM patterns at `$2100` according to the native `$07AB` algorithm.
- The two player aim-pointer tables at `$0EE2/$0EF0` are now decoded as even-byte-offset `DW` vectors, with one shared boundary entry. The adjoining shot-position records at `$0F00` are byte pairs, not pointers. See [Aim and fire](AIM-AND-FIRE.md).
- Confirm on-screen orientation, left/right shifts, and hardware-specific pixel composition against the original board or MAME.

This analysis is limited to original code/data relationships and does not imply an executed emulator trace.
