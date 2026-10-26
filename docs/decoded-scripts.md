# gunfight — decoded 8080 game-command scripts

Distinct statically decoded packet sites: 82

| ROM | Word | Operand bytes | Length |
|---|---|---|---:|
| 0821 | 04 |  | 1 |
| 0822 | 13 |  | 1 |
| 0823 | 01 | 0C610F0A24 | 6 |
| 0829 | 10 |  | 1 |
| 082A | 0F |  | 1 |
| 082B | 03 | 5A | 2 |
| 082D | 00 |  | 1 |
| 082E | 01 | 296D0F0026 | 6 |
| 0834 | 03 | 5A | 2 |
| 0836 | 00 |  | 1 |
| 0837 | 01 | 0B990F143D | 6 |
| 083D | 05 | 2A20C30100004000660BAA8B0D4A0D8B0D | 18 |
| 084F | 03 | 5A | 2 |
| 0851 | 00 |  | 1 |
| 0852 | 06 | 6320C6035400FE027800C8 | 12 |
| 085E | 03 | 4B | 2 |
| 0860 | 00 |  | 1 |
| 0861 | 01 | 0BA40F143D | 6 |
| 0867 | 03 | 3C | 2 |
| 0869 | 00 |  | 1 |
| 086A | 05 | 3D20C2FF400060006627A0C7220021C722 | 18 |
| 087C | 03 | 40 | 2 |
| 087E | 00 |  | 1 |
| 087F | 09 | 2108 | 3 |
| 0882 | 01 | 27D50F012A | 6 |
| 0888 | 05 | 2A20C30200004000A00BAA8B0D4A0D8B0D | 18 |
| 089A | 00 |  | 1 |
| 089B | 04 |  | 1 |
| 089C | 13 |  | 1 |
| 089D | 0F |  | 1 |
| 089E | 0A |  | 1 |
| 089F | 01 | 09AF0F0C2E | 6 |
| 08A5 | 01 | 0CB80FA23E | 6 |
| 08AB | 05 | 2A20C0010000480066139A8B0D870C8B0D | 18 |
| 08BD | 05 | 3D20C0FFE7A0480066139AC722C321C722 | 18 |
| 08CF | 06 | 632006000004F800000AC8 | 12 |
| 08DB | 06 | 752006000004F800000AC8 | 12 |
| 08E7 | 06 | 872006000004F800000AC8 | 12 |
| 08F3 | 06 | 992006000004F800000AC8 | 12 |
| 08FF | 03 | 1E | 2 |
| 0901 | 00 |  | 1 |
| 0902 | 01 | 09C50F0C2E | 6 |
| 0908 | 03 | 0A | 2 |
| 090A | 07 | 2A20 | 3 |
| 090D | 07 | 3D20 | 3 |
| 0910 | 00 |  | 1 |
| 0911 | 01 | 05A40F0E2E | 6 |
| 0917 | 14 |  | 1 |
| 0918 | 09 | 9B08 | 3 |
| 091B | 0C | 05202A2020FD0D | 8 |
| 0923 | 0D | C202 | 3 |
| 0926 | 03 | 0F | 2 |
| 0928 | 00 |  | 1 |
| 0929 | 0B | 2A20105F0E | 6 |
| 092F | 12 |  | 1 |
| 0930 | 03 | 2D | 2 |
| 0932 | 00 |  | 1 |
| 0933 | 09 | 9B08 | 3 |
| 0936 | 0E | 6010 | 3 |
| 0939 | 09 | 5D09 | 3 |
| 093C | 0E | 6050 | 3 |
| 093F | 09 | 5D09 | 3 |
| 0942 | 0E | 6090 | 3 |
| 0945 | 09 | 5D09 | 3 |
| 0948 | 0E | 7810 | 3 |
| 094B | 09 | 5D09 | 3 |
| 094E | 0E | 9010 | 3 |
| 0951 | 09 | 5D09 | 3 |
| 0954 | 0E | 9050 | 3 |
| 0957 | 09 | 5D09 | 3 |
| 095A | 0E | 9090 | 3 |
| 095D | 0D | B202 | 3 |
| 0960 | 09 | 1709 | 3 |
| 0963 | 0C | 02203D20D03923 | 8 |
| 096B | 0D | B202 | 3 |
| 096E | 03 | 0A | 2 |
| 0970 | 00 |  | 1 |
| 0971 | 0B | 3D20D09B23 | 6 |
| 0977 | 11 |  | 1 |
| 0978 | 03 | 2D | 2 |
| 097A | 00 |  | 1 |
| 097B | 09 | 9B08 | 3 |

## Root traversal

| Root | Packets | Stop |
|---|---:|---|
| 0821 | 24 | cycle at 0821 |
| 089B | 22 | cycle at 089B |
| 0882 | 3 | joins-known-script at 089B |
| 091B | 9 | joins-known-script at 089B |
| 0936 | 4 | joins-known-script at 0917 |
| 093C | 2 | joins-known-script at 095D |
| 0942 | 2 | joins-known-script at 095D |
| 0948 | 2 | joins-known-script at 095D |
| 094E | 2 | joins-known-script at 095D |
| 0954 | 2 | joins-known-script at 095D |
| 095A | 1 | joins-known-script at 095D |
| 0963 | 9 | joins-known-script at 089B |

## Distinct ROM word use

| Word | Sites |
|---|---:|
| 00 | 13 |
| 01 | 9 |
| 03 | 12 |
| 04 | 2 |
| 05 | 5 |
| 06 | 5 |
| 07 | 2 |
| 09 | 11 |
| 0A | 1 |
| 0B | 2 |
| 0C | 2 |
| 0D | 3 |
| 0E | 7 |
| 0F | 2 |
| 10 | 1 |
| 11 | 1 |
| 12 | 1 |
| 13 | 2 |
| 14 | 1 |

## Gun Fight input-event destination pointers

Event pointers share the last native handler word at $09D6; the subsequent nine values are script targets, NOT more interpreter native words.

- 0: $03C9 (native service)
- 1: $091B (bytecode stream)
- 2: $0936 (bytecode stream)
- 3: $093C (bytecode stream)
- 4: $0942 (bytecode stream)
- 5: $0948 (bytecode stream)
- 6: $094E (bytecode stream)
- 7: $0954 (bytecode stream)
- 8: $095A (bytecode stream)
- 9: $0963 (bytecode stream)

Opcode $05 (Gun Fight) copies 15 inline bytes after a 16-bit destination; opcode $06 copies nine. They are not two-byte-only operands.

This is static rooted decoding; it is not a complete emulation of interrupt-driven execution.

