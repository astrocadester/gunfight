# Gun Fight: 8080 indexed bytecode interpreter

Source: original gunfight.zip, SHA256 b1dee22902ce8b8ebd3b5c85293cc350ed789c1088a02442db54184563428343

## Runtime identity

- Script-pointer RAM: `$2000`
- Native command dispatcher: `$03A7`
- Vector table: `$09AE`
- Indexed native entries: 21 defensible native handlers ($00–$14); raw table continuation past that is not proven code
- Initial ROM command stream: `$0821`

The dispatcher fetches a bytecode from its saved program counter, advances the pointer, indexes 16-bit native handler entries, and transfers control indirectly. For recovered operand conventions and side-effects, see [the second semantic pass](8080-WORD-SEMANTICS.md). Rows $15–$1D below are historically over-read candidates pointing into likely data, NOT confirmed commands.

| Index | Native handler | First 8 bytes at handler |
|---:|---:|---|
| `$00` | `$0813` | `21 C5 20 34 C8 35 2A 00` |
| `$01` | `$05E9` | `2A 00 20 7E 23 5E 23 56` |
| `$02` | `$063D` | `2A 00 20 7E 23 22 00 20` |
| `$03` | `$0649` | `2A 00 20 7E 23 22 00 20` |
| `$04` | `$0655` | `F3 E1 01 00 00 11 00 00` |
| `$05` | `$068D` | `2A 00 20 5E 23 56 23 0E` |
| `$06` | `$069D` | `2A 00 20 5E 23 56 23 0E` |
| `$07` | `$0670` | `2A 00 20 5E 23 56 23 22` |
| `$08` | `$06AD` | `2A 00 20 5E 23 56 23 22` |
| `$09` | `$0682` | `2A 00 20 5E 23 56 EB 22` |
| `$0A` | `$06BC` | `21 0E 0F AF D3 02 3A 02` |
| `$0B` | `$0749` | `2A 00 20 5E 23 56 23 F3` |
| `$0C` | `$0738` | `2A 00 20 5E 23 56 23 22` |
| `$0D` | `$0775` | `2A 00 20 7E D3 01 23 7E` |
| `$0E` | `$0785` | `2A 00 20 3A 1D 20 5E 23` |
| `$0F` | `$07AB` | `21 00 21 11 C4 0B 1A A7` |
| `$10` | `$0807` | `3A 08 20 A7 C8 21 82 08` |
| `$11` | `$07E9` | `21 3F 20 C3 F2 07 21 2C` |
| `$12` | `$07EF` | `21 2C 20 5E 01 04 00 09` |
| `$13` | `$05A3` | `AF 32 03 20 0E 04 21 1E` |
| `$14` | `$03C9` | `CD 13 08 DB 00 47 DB 00` |
| `$15` | `$091B` | `0C 05 20 2A 20 20 FD 0D` |
| `$16` | `$0936` | `0E 60 10 09 5D 09 0E 60` |
| `$17` | `$093C` | `0E 60 50 09 5D 09 0E 60` |
| `$18` | `$0942` | `0E 60 90 09 5D 09 0E 78` |
| `$19` | `$0948` | `0E 78 10 09 5D 09 0E 90` |
| `$1A` | `$094E` | `0E 90 10 09 5D 09 0E 90` |
| `$1B` | `$0954` | `0E 90 50 09 5D 09 0E 90` |
| `$1C` | `$095A` | `0E 90 90 0D B2 02 09 17` |
| `$1D` | `$0963` | `0C 02 20 3D 20 D0 39 23` |

## Historical interpretation

Gun Fight (1975) directly demonstrates DNA's early indexed native-command interpreter. Common interpreter mechanics alone do not prove that the individual handler implementations or source files were identical across games.

## Verification boundaries

This table is read directly from the original ROM. Native handler semantics, script operand sizes, interrupt cadence, and full address ownership require instruction- and data-flow analysis.
