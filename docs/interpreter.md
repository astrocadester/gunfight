# Gun Fight: 8080 indexed bytecode interpreter

Source: original gunfight.zip, SHA256 b1dee22902ce8b8ebd3b5c85293cc350ed789c1088a02442db54184563428343

## Runtime identity

- Script-pointer RAM: `$2000`
- Native command dispatcher: `$3A7`
- Vector table: `$9AE`
- Established native handler entries: 21 (tokens $00–$14)
- Initial ROM command stream: `$821`

The dispatcher fetches a bytecode from its saved program counter, advances the pointer, indexes 16-bit native handler entries, and transfers control indirectly. Entry count does not imply each command has identical operands.

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


The remaining pointer-shaped values at `$09D8–$09E9` are nine **event-script destinations**, not native words. The `$09D6` word `$14` entry is also reused as the first input/event selection pointer. The input-action table at `$097E–$09AD` has 24 native entries. See [ROM vector ownership](ROM-VECTOR-OWNERSHIP.md).

## Historical interpretation

Gun Fight (1975) directly demonstrates DNA's early indexed native-command interpreter. Common interpreter mechanics alone do not prove that the individual handler implementations or source files were identical across games.

## Verification boundaries

This table is read directly from the original ROM. Native handler semantics and script operand widths are documented in the [reconciled word catalog](8080-WORD-SEMANTICS.md); interrupt cadence and remaining data formats still need instruction- and data-flow tracing.
