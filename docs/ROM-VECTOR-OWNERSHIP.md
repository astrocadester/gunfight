# Gun Fight (1975) — typed 8080 interpreter and event tables

These ranges are confirmed by the original chip bytes and are emitted by `tools/recover_8080.py` as named **`DW` little-endian pointer entries**, not anonymous `DB`. This does not reclassify graphic or script bytes as native code.

| ROM range | Entries | Ownership |
|---|---:|---|
| `$097E–$09AD` | 24 | 24-entry native event-action address table ($097E–$09AD) |
| `$09AE–$09D7` | 21 | 21-entry interpreter handler address table ($09AE–$09D7) |
| `$09D8–$09E9` | 9 | nine additional event-script roots ($09D8–$09E9); the first event slot reuses the final game-word vector at $09D6 |

The byte at `$03C8` is `PCHL`: it dispatches to the 21 native handlers. At `$09D6` the final **game word** entry (`$14 → $03C9`) is also the first **event-script selector** entry. The nine pairs that follow it do not add words to the dictionary. In addition, `$097E–$09AD` supplies 24 *native event-action selectors* used outside ordinary game-word dispatch; repeated pointers are intentional.

## Interpreter-level semantic distinctions

- Word `$05`: address16 plus 15 literal RAM-copy bytes; `$06`: address16 plus 9 literal RAM-copy bytes. Common copy helper `$0372` performs the transfer. Inline payload bytes must never be decoded as standalone opcodes.
- Word `$0B` installs an object descriptor, while `$0C` updates a packed-decimal counter (`DAA`) and falls through into the descriptor initializer.
- Event script origins come from the selector table rather than an inflated extension of the word dictionary.
- ROM script decode currently identifies 82 distinct rooted packet sites; other native-selected flows may exist.

## Reproduction

`build.sh` and `build.bat` regenerate `src/*.asm`, assemble with the bundled zmac, and compare reconstructed ROM bytes to the original ZIP. A pointer entry remains `DW` only when its original two bytes produce a ROM-resident address; the generator asserts there are no overlaps with traced native code or decoded script bytes.
