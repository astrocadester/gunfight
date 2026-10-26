; Original gunfight Intel 8080 ROM, source reconstructed from original bytes.
; Native instruction mnemonics are executable; uncertain regions retain DB.
; Original byte offsets are preserved; zmac v1.3 must rebuild exactly.

        ORG $0000
; Device 7609h.bin, SHA1 99d01313e251818d336281700e206d9003c71dae
NATIVE_0000:
        NOP  ; ROM $0000: 00
        NOP  ; ROM $0001: 00
        LD SP,$2400  ; ROM $0002: 31 00 24
        JP $0390  ; ROM $0005: C3 90 03
NATIVE_0008:
        PUSH HL  ; ROM $0008: E5
        PUSH DE  ; ROM $0009: D5
        PUSH BC  ; ROM $000A: C5
        PUSH AF  ; ROM $000B: F5
        JP $0087  ; ROM $000C: C3 87 00
        DB $00 ; ROM $000F unclassified
NATIVE_0010:
        PUSH HL  ; ROM $0010: E5
        PUSH DE  ; ROM $0011: D5
        PUSH BC  ; ROM $0012: C5
        PUSH AF  ; ROM $0013: F5
        LD HL,$20B9  ; ROM $0014: 21 B9 20
        LD A,(HL)  ; ROM $0017: 7E
        CPL  ; ROM $0018: 2F
        LD (HL),A  ; ROM $0019: 77
        AND A  ; ROM $001A: A7
        JP M,$00EA  ; ROM $001B: FA EA 00
        LD HL,$206F  ; ROM $001E: 21 6F 20
NATIVE_0021:
        PUSH HL  ; ROM $0021: E5
        CALL $02BD  ; ROM $0022: CD BD 02
        JP Z,$0038  ; ROM $0025: CA 38 00
NATIVE_0028:
        LD A,(DE)  ; ROM $0028: 1A
        INC DE  ; ROM $0029: 13
        LD (HL),A  ; ROM $002A: 77
        INC HL  ; ROM $002B: 23
        LD A,(DE)  ; ROM $002C: 1A
        INC DE  ; ROM $002D: 13
        LD (HL),A  ; ROM $002E: 77
        LD A,B  ; ROM $002F: 78
        LD C,$1F  ; ROM $0030: 0E 1F
        ADD HL,BC  ; ROM $0032: 09
        DEC B  ; ROM $0033: 05
        AND A  ; ROM $0034: A7
        JP Z,$0028  ; ROM $0035: CA 28 00
NATIVE_0038:
        POP HL  ; ROM $0038: E1
        LD DE,$0012  ; ROM $0039: 11 12 00
        ADD HL,DE  ; ROM $003C: 19
        LD A,L  ; ROM $003D: 7D
        CP $B7  ; ROM $003E: FE B7
        JP NZ,$0021  ; ROM $0040: C2 21 00
        LD HL,$20A2  ; ROM $0043: 21 A2 20
NATIVE_0046:
        PUSH HL  ; ROM $0046: E5
        CALL $02BD  ; ROM $0047: CD BD 02
        JP Z,$0076  ; ROM $004A: CA 76 00
        LD A,(DE)  ; ROM $004D: 1A
        INC DE  ; ROM $004E: 13
        EX DE,HL  ; ROM $004F: EB
        LD (HL),E  ; ROM $0050: 73
        INC HL  ; ROM $0051: 23
        LD (HL),D  ; ROM $0052: 72
        INC HL  ; ROM $0053: 23
        EX DE,HL  ; ROM $0054: EB
        OUT ($02),A  ; ROM $0055: D3 02
NATIVE_0057:
        LD A,(HL)  ; ROM $0057: 7E
        LD (DE),A  ; ROM $0058: 12
        INC DE  ; ROM $0059: 13
        LD A,$03  ; ROM $005A: 3E 03
        OUT ($04),A  ; ROM $005C: D3 04
        IN A,($03)  ; ROM $005E: DB 03
        OR (HL)  ; ROM $0060: B6
        LD (HL),A  ; ROM $0061: 77
        INC HL  ; ROM $0062: 23
        LD A,(HL)  ; ROM $0063: 7E
        LD (DE),A  ; ROM $0064: 12
        INC DE  ; ROM $0065: 13
        XOR A  ; ROM $0066: AF
        OUT ($04),A  ; ROM $0067: D3 04
        IN A,($03)  ; ROM $0069: DB 03
        OR (HL)  ; ROM $006B: B6
        LD (HL),A  ; ROM $006C: 77
        LD A,B  ; ROM $006D: 78
        LD C,$1F  ; ROM $006E: 0E 1F
        ADD HL,BC  ; ROM $0070: 09
        DEC B  ; ROM $0071: 05
        AND A  ; ROM $0072: A7
        JP Z,$0057  ; ROM $0073: CA 57 00
NATIVE_0076:
        POP HL  ; ROM $0076: E1
        LD DE,$FFEE  ; ROM $0077: 11 EE FF
        ADD HL,DE  ; ROM $007A: 19
        LD A,L  ; ROM $007B: 7D
        CP $5A  ; ROM $007C: FE 5A
        JP NZ,$0046  ; ROM $007E: C2 46 00
        LD HL,$20B2  ; ROM $0081: 21 B2 20
        JP $0091  ; ROM $0084: C3 91 00
NATIVE_0087:
        LD A,($20B9)  ; ROM $0087: 3A B9 20
        AND A  ; ROM $008A: A7
        JP M,$0218  ; ROM $008B: FA 18 02
        LD HL,$20AB  ; ROM $008E: 21 AB 20
NATIVE_0091:
        CALL $02BD  ; ROM $0091: CD BD 02
        PUSH DE  ; ROM $0094: D5
        JP Z,$00B4  ; ROM $0095: CA B4 00
        CALL $02BD  ; ROM $0098: CD BD 02
        EX DE,HL  ; ROM $009B: EB
        PUSH DE  ; ROM $009C: D5
        CALL $02BD  ; ROM $009D: CD BD 02
        POP DE  ; ROM $00A0: D1
        JP Z,$00B4  ; ROM $00A1: CA B4 00
NATIVE_00A4:
        PUSH HL  ; ROM $00A4: E5
        LD C,E  ; ROM $00A5: 4B
NATIVE_00A6:
        LD (HL),B  ; ROM $00A6: 70
        INC HL  ; ROM $00A7: 23
        DEC C  ; ROM $00A8: 0D
        JP NZ,$00A6  ; ROM $00A9: C2 A6 00
        POP HL  ; ROM $00AC: E1
        LD C,$20  ; ROM $00AD: 0E 20
        ADD HL,BC  ; ROM $00AF: 09
        DEC D  ; ROM $00B0: 15
        JP NZ,$00A4  ; ROM $00B1: C2 A4 00
NATIVE_00B4:
        POP HL  ; ROM $00B4: E1
        CALL $02BD  ; ROM $00B5: CD BD 02
        JP Z,$0218  ; ROM $00B8: CA 18 02
        LD A,(DE)  ; ROM $00BB: 1A
        INC DE  ; ROM $00BC: 13
        OUT ($02),A  ; ROM $00BD: D3 02
        PUSH DE  ; ROM $00BF: D5
        EX (SP),HL  ; ROM $00C0: E3
        CALL $02BD  ; ROM $00C1: CD BD 02
        LD E,(HL)  ; ROM $00C4: 5E
        INC HL  ; ROM $00C5: 23
        LD D,(HL)  ; ROM $00C6: 56
        INC HL  ; ROM $00C7: 23
        EX (SP),HL  ; ROM $00C8: E3
        LD ($20BA),HL  ; ROM $00C9: 22 BA 20
        LD B,$00  ; ROM $00CC: 06 00
        CALL $022D  ; ROM $00CE: CD 2D 02
        EX (SP),HL  ; ROM $00D1: E3
        LD E,(HL)  ; ROM $00D2: 5E
        INC HL  ; ROM $00D3: 23
        LD D,(HL)  ; ROM $00D4: 56
        INC HL  ; ROM $00D5: 23
        EX (SP),HL  ; ROM $00D6: E3
        CALL $022D  ; ROM $00D7: CD 2D 02
        LD HL,($20BA)  ; ROM $00DA: 2A BA 20
        EX (SP),HL  ; ROM $00DD: E3
        INC C  ; ROM $00DE: 0C
        LD (HL),C  ; ROM $00DF: 71
        INC HL  ; ROM $00E0: 23
        LD (HL),B  ; ROM $00E1: 70
        INC HL  ; ROM $00E2: 23
        POP DE  ; ROM $00E3: D1
        LD (HL),E  ; ROM $00E4: 73
        INC HL  ; ROM $00E5: 23
        LD (HL),D  ; ROM $00E6: 72
        JP $0218  ; ROM $00E7: C3 18 02
NATIVE_00EA:
        LD HL,$2063  ; ROM $00EA: 21 63 20
NATIVE_00ED:
        LD A,(HL)  ; ROM $00ED: 7E
        AND A  ; ROM $00EE: A7
        PUSH HL  ; ROM $00EF: E5
        JP P,$0151  ; ROM $00F0: F2 51 01
        INC HL  ; ROM $00F3: 23
        LD A,(HL)  ; ROM $00F4: 7E
        AND A  ; ROM $00F5: A7
        INC HL  ; ROM $00F6: 23
        LD A,(HL)  ; ROM $00F7: 7E
        JP M,$0103  ; ROM $00F8: FA 03 01
        CP $70  ; ROM $00FB: FE 70
        JP NC,$0108  ; ROM $00FD: D2 08 01
        JP $0151  ; ROM $0100: C3 51 01
NATIVE_0103:
        CP $90  ; ROM $0103: FE 90
        JP NC,$0151  ; ROM $0105: D2 51 01
NATIVE_0108:
        LD DE,$000C  ; ROM $0108: 11 0C 00
        ADD HL,DE  ; ROM $010B: 19
        LD A,(HL)  ; ROM $010C: 7E
        AND A  ; ROM $010D: A7
        JP Z,$0151  ; ROM $010E: CA 51 01
        LD DE,$FFF8  ; ROM $0111: 11 F8 FF
        ADD HL,DE  ; ROM $0114: 19
        LD A,(HL)  ; ROM $0115: 7E
        SUB $10  ; ROM $0116: D6 10
        CP $C0  ; ROM $0118: FE C0
        JP NC,$0151  ; ROM $011A: D2 51 01
        POP HL  ; ROM $011D: E1
        PUSH HL  ; ROM $011E: E5
        LD (HL),$A0  ; ROM $011F: 36 A0
        INC HL  ; ROM $0121: 23
        INC HL  ; ROM $0122: 23
        LD A,(HL)  ; ROM $0123: 7E
        RRA  ; ROM $0124: 1F
        RRA  ; ROM $0125: 1F
        RRA  ; ROM $0126: 1F
        RRA  ; ROM $0127: 1F
        AND $0F  ; ROM $0128: E6 0F
        LD C,A  ; ROM $012A: 4F
        INC HL  ; ROM $012B: 23
        INC HL  ; ROM $012C: 23
        INC HL  ; ROM $012D: 23
        INC HL  ; ROM $012E: 23
        LD A,(HL)  ; ROM $012F: 7E
        LD ($201D),A  ; ROM $0130: 32 1D 20
        SUB $10  ; ROM $0133: D6 10
        RRA  ; ROM $0135: 1F
        RRA  ; ROM $0136: 1F
        AND $30  ; ROM $0137: E6 30
        OR C  ; ROM $0139: B1
        RRA  ; ROM $013A: 1F
        LD E,A  ; ROM $013B: 5F
        LD D,$00  ; ROM $013C: 16 00
        LD HL,$0F3A  ; ROM $013E: 21 3A 0F
        ADD HL,DE  ; ROM $0141: 19
        LD A,C  ; ROM $0142: 79
        RRA  ; ROM $0143: 1F
        LD A,(HL)  ; ROM $0144: 7E
        JP NC,$014C  ; ROM $0145: D2 4C 01
        RRA  ; ROM $0148: 1F
        RRA  ; ROM $0149: 1F
        RRA  ; ROM $014A: 1F
        RRA  ; ROM $014B: 1F
NATIVE_014C:
        AND $0F  ; ROM $014C: E6 0F
        LD ($201C),A  ; ROM $014E: 32 1C 20
NATIVE_0151:
        POP HL  ; ROM $0151: E1
        LD DE,$0012  ; ROM $0152: 11 12 00
        ADD HL,DE  ; ROM $0155: 19
        LD A,$AB  ; ROM $0156: 3E AB
        CP L  ; ROM $0158: BD
        JP NZ,$00ED  ; ROM $0159: C2 ED 00
        LD HL,$2063  ; ROM $015C: 21 63 20
NATIVE_015F:
        LD A,(HL)  ; ROM $015F: 7E
        AND A  ; ROM $0160: A7
        JP P,$0183  ; ROM $0161: F2 83 01
        LD A,$FF  ; ROM $0164: 3E FF
        LD ($20C4),A  ; ROM $0166: 32 C4 20
        CALL $025E  ; ROM $0169: CD 5E 02
        LD A,(HL)  ; ROM $016C: 7E
        RLA  ; ROM $016D: 17
        OR $7F  ; ROM $016E: F6 7F
        AND (HL)  ; ROM $0170: A6
        LD (HL),A  ; ROM $0171: 77
        JP P,$0183  ; ROM $0172: F2 83 01
        PUSH HL  ; ROM $0175: E5
        LD BC,$0009  ; ROM $0176: 01 09 00
        ADD HL,BC  ; ROM $0179: 09
        CALL $0359  ; ROM $017A: CD 59 03
        LD (HL),E  ; ROM $017D: 73
        INC HL  ; ROM $017E: 23
        LD (HL),D  ; ROM $017F: 72
        INC HL  ; ROM $0180: 23
        LD (HL),C  ; ROM $0181: 71
        POP HL  ; ROM $0182: E1
NATIVE_0183:
        LD BC,$0012  ; ROM $0183: 01 12 00
        ADD HL,BC  ; ROM $0186: 09
        LD A,$AB  ; ROM $0187: 3E AB
        CP L  ; ROM $0189: BD
        JP NZ,$015F  ; ROM $018A: C2 5F 01
        LD HL,($20BE)  ; ROM $018D: 2A BE 20
        LD A,L  ; ROM $0190: 7D
        OR H  ; ROM $0191: B4
        JP NZ,$0198  ; ROM $0192: C2 98 01
        LD HL,$202A  ; ROM $0195: 21 2A 20
NATIVE_0198:
        LD ($20C0),HL  ; ROM $0198: 22 C0 20
        XOR A  ; ROM $019B: AF
        LD ($20BD),A  ; ROM $019C: 32 BD 20
NATIVE_019F:
        LD A,(HL)  ; ROM $019F: 7E
        AND A  ; ROM $01A0: A7
        JP P,$01B1  ; ROM $01A1: F2 B1 01
        CALL $025E  ; ROM $01A4: CD 5E 02
        LD A,($20BD)  ; ROM $01A7: 3A BD 20
        AND A  ; ROM $01AA: A7
        CALL Z,$02C9  ; ROM $01AB: CC C9 02
        LD ($20BE),HL  ; ROM $01AE: 22 BE 20
NATIVE_01B1:
        LD DE,$0013  ; ROM $01B1: 11 13 00
        ADD HL,DE  ; ROM $01B4: 19
        LD A,$63  ; ROM $01B5: 3E 63
        CP L  ; ROM $01B7: BD
        JP NZ,$01BE  ; ROM $01B8: C2 BE 01
        LD HL,$202A  ; ROM $01BB: 21 2A 20
NATIVE_01BE:
        LD A,($20C0)  ; ROM $01BE: 3A C0 20
        CP L  ; ROM $01C1: BD
        JP NZ,$019F  ; ROM $01C2: C2 9F 01
        LD HL,$2014  ; ROM $01C5: 21 14 20
        LD A,(HL)  ; ROM $01C8: 7E
        AND A  ; ROM $01C9: A7
        JP Z,$01D4  ; ROM $01CA: CA D4 01
        DEC (HL)  ; ROM $01CD: 35
        JP NZ,$01D4  ; ROM $01CE: C2 D4 01
        XOR A  ; ROM $01D1: AF
        OUT ($01),A  ; ROM $01D2: D3 01
NATIVE_01D4:
        LD HL,$2009  ; ROM $01D4: 21 09 20
        DEC (HL)  ; ROM $01D7: 35
        JP P,$0208  ; ROM $01D8: F2 08 02
        LD (HL),$22  ; ROM $01DB: 36 22
        LD HL,$2004  ; ROM $01DD: 21 04 20
        LD A,(HL)  ; ROM $01E0: 7E
        AND A  ; ROM $01E1: A7
        JP Z,$01F6  ; ROM $01E2: CA F6 01
        ADD A,$99  ; ROM $01E5: C6 99
        DAA  ; ROM $01E7: 27
        LD (HL),A  ; ROM $01E8: 77
        JP NZ,$01F6  ; ROM $01E9: C2 F6 01
        EX DE,HL  ; ROM $01EC: EB
        LD HL,$20C4  ; ROM $01ED: 21 C4 20
        INC (HL)  ; ROM $01F0: 34
        JP NZ,$039D  ; ROM $01F1: C2 9D 03
        EX DE,HL  ; ROM $01F4: EB
        INC (HL)  ; ROM $01F5: 34
NATIVE_01F6:
        LD HL,$2003  ; ROM $01F6: 21 03 20
        LD A,(HL)  ; ROM $01F9: 7E
        AND A  ; ROM $01FA: A7
        JP Z,$0208  ; ROM $01FB: CA 08 02
        ADD A,$99  ; ROM $01FE: C6 99
        DAA  ; ROM $0200: 27
        LD (HL),A  ; ROM $0201: 77
        JP NZ,$0218  ; ROM $0202: C2 18 02
        JP $0214  ; ROM $0205: C3 14 02
NATIVE_0208:
        LD HL,$2015  ; ROM $0208: 21 15 20
        LD A,(HL)  ; ROM $020B: 7E
        AND A  ; ROM $020C: A7
        JP Z,$0218  ; ROM $020D: CA 18 02
        DEC (HL)  ; ROM $0210: 35
        JP NZ,$0218  ; ROM $0211: C2 18 02
NATIVE_0214:
        LD HL,$20C5  ; ROM $0214: 21 C5 20
        DEC (HL)  ; ROM $0217: 35
NATIVE_0218:
        IN A,($02)  ; ROM $0218: DB 02
        LD B,A  ; ROM $021A: 47
        IN A,($02)  ; ROM $021B: DB 02
        CP B  ; ROM $021D: B8
        LD HL,$2006  ; ROM $021E: 21 06 20
        LD DE,$099E  ; ROM $0221: 11 9E 09
        CALL Z,$040D  ; ROM $0224: CC 0D 04
        POP AF  ; ROM $0227: F1
        POP BC  ; ROM $0228: C1
        POP DE  ; ROM $0229: D1
        POP HL  ; ROM $022A: E1
        EI  ; ROM $022B: FB
        RET  ; ROM $022C: C9
NATIVE_022D:
        LD A,D  ; ROM $022D: 7A
        OR E  ; ROM $022E: B3
        RET Z  ; ROM $022F: C8
        LD A,(DE)  ; ROM $0230: 1A
        INC DE  ; ROM $0231: 13
        LD C,A  ; ROM $0232: 4F
        LD A,(DE)  ; ROM $0233: 1A
        ADD A,B  ; ROM $0234: 80
        LD ($20BC),A  ; ROM $0235: 32 BC 20
        LD A,(DE)  ; ROM $0238: 1A
        INC DE  ; ROM $0239: 13
        LD B,A  ; ROM $023A: 47
NATIVE_023B:
        PUSH BC  ; ROM $023B: C5
        PUSH HL  ; ROM $023C: E5
NATIVE_023D:
        LD A,(DE)  ; ROM $023D: 1A
        INC DE  ; ROM $023E: 13
        OUT ($04),A  ; ROM $023F: D3 04
        IN A,($03)  ; ROM $0241: DB 03
        LD (HL),A  ; ROM $0243: 77
        INC HL  ; ROM $0244: 23
        DEC C  ; ROM $0245: 0D
        JP NZ,$023D  ; ROM $0246: C2 3D 02
        XOR A  ; ROM $0249: AF
        OUT ($04),A  ; ROM $024A: D3 04
        IN A,($03)  ; ROM $024C: DB 03
        LD (HL),A  ; ROM $024E: 77
        POP HL  ; ROM $024F: E1
        LD BC,$0020  ; ROM $0250: 01 20 00
        ADD HL,BC  ; ROM $0253: 09
        POP BC  ; ROM $0254: C1
        DEC B  ; ROM $0255: 05
        JP NZ,$023B  ; ROM $0256: C2 3B 02
        LD A,($20BC)  ; ROM $0259: 3A BC 20
        LD B,A  ; ROM $025C: 47
        RET  ; ROM $025D: C9
NATIVE_025E:
        PUSH HL  ; ROM $025E: E5
        LD A,(HL)  ; ROM $025F: 7E
        INC HL  ; ROM $0260: 23
        CALL $0280  ; ROM $0261: CD 80 02
        LD E,D  ; ROM $0264: 5A
        EX (SP),HL  ; ROM $0265: E3
        XOR (HL)  ; ROM $0266: AE
        LD (HL),A  ; ROM $0267: 77
        RRA  ; ROM $0268: 1F
        RRA  ; ROM $0269: 1F
        EX (SP),HL  ; ROM $026A: E3
        INC HL  ; ROM $026B: 23
        INC HL  ; ROM $026C: 23
        INC HL  ; ROM $026D: 23
        CALL $0280  ; ROM $026E: CD 80 02
        DEC HL  ; ROM $0271: 2B
        LD B,(HL)  ; ROM $0272: 46
        POP HL  ; ROM $0273: E1
        XOR (HL)  ; ROM $0274: AE
        LD (HL),A  ; ROM $0275: 77
        INC HL  ; ROM $0276: 23
        LD A,(HL)  ; ROM $0277: 7E
        OR B  ; ROM $0278: B0
        DEC HL  ; ROM $0279: 2B
        RET NZ  ; ROM $027A: C0
        LD A,$BF  ; ROM $027B: 3E BF
        AND (HL)  ; ROM $027D: A6
        LD (HL),A  ; ROM $027E: 77
        RET  ; ROM $027F: C9
NATIVE_0280:
        AND $03  ; ROM $0280: E6 03
        LD B,A  ; ROM $0282: 47
        LD A,(HL)  ; ROM $0283: 7E
        INC HL  ; ROM $0284: 23
        ADD A,(HL)  ; ROM $0285: 86
        LD C,A  ; ROM $0286: 4F
        INC HL  ; ROM $0287: 23
        SUB (HL)  ; ROM $0288: 96
        INC HL  ; ROM $0289: 23
        JP C,$0297  ; ROM $028A: DA 97 02
        SUB (HL)  ; ROM $028D: 96
        JP NC,$0297  ; ROM $028E: D2 97 02
        DEC HL  ; ROM $0291: 2B
        DEC HL  ; ROM $0292: 2B
        LD (HL),C  ; ROM $0293: 71
NATIVE_0294:
        LD D,(HL)  ; ROM $0294: 56
        XOR A  ; ROM $0295: AF
        RET  ; ROM $0296: C9
NATIVE_0297:
        DEC HL  ; ROM $0297: 2B
        DEC HL  ; ROM $0298: 2B
        DEC B  ; ROM $0299: 05
        JP NZ,$02A7  ; ROM $029A: C2 A7 02
        DEC HL  ; ROM $029D: 2B
        XOR A  ; ROM $029E: AF
        SUB (HL)  ; ROM $029F: 96
        LD (HL),A  ; ROM $02A0: 77
        INC HL  ; ROM $02A1: 23
        LD A,$10  ; ROM $02A2: 3E 10
        JP $02BA  ; ROM $02A4: C3 BA 02
NATIVE_02A7:
        DEC HL  ; ROM $02A7: 2B
        LD (HL),$00  ; ROM $02A8: 36 00
        INC HL  ; ROM $02AA: 23
        DEC B  ; ROM $02AB: 05
        JP NZ,$02B4  ; ROM $02AC: C2 B4 02
        LD A,$60  ; ROM $02AF: 3E 60
        JP $02BA  ; ROM $02B1: C3 BA 02
NATIVE_02B4:
        DEC B  ; ROM $02B4: 05
        JP NZ,$0294  ; ROM $02B5: C2 94 02
        LD A,$40  ; ROM $02B8: 3E 40
NATIVE_02BA:
        LD D,(HL)  ; ROM $02BA: 56
        AND A  ; ROM $02BB: A7
        RET  ; ROM $02BC: C9
NATIVE_02BD:
        XOR A  ; ROM $02BD: AF
        LD E,(HL)  ; ROM $02BE: 5E
        LD (HL),A  ; ROM $02BF: 77
        INC HL  ; ROM $02C0: 23
        LD D,(HL)  ; ROM $02C1: 56
        LD (HL),A  ; ROM $02C2: 77
        INC HL  ; ROM $02C3: 23
        LD B,A  ; ROM $02C4: 47
        LD A,D  ; ROM $02C5: 7A
        OR E  ; ROM $02C6: B3
        EX DE,HL  ; ROM $02C7: EB
        RET  ; ROM $02C8: C9
NATIVE_02C9:
        PUSH HL  ; ROM $02C9: E5
        LD BC,$000F  ; ROM $02CA: 01 0F 00
        ADD HL,BC  ; ROM $02CD: 09
        LD B,H  ; ROM $02CE: 44
        LD C,L  ; ROM $02CF: 4D
        CPL  ; ROM $02D0: 2F
        LD ($20BD),A  ; ROM $02D1: 32 BD 20
        LD A,$60  ; ROM $02D4: 3E 60
        CP D  ; ROM $02D6: BA
        LD HL,$20AB  ; ROM $02D7: 21 AB 20
        JP NC,$02E0  ; ROM $02DA: D2 E0 02
        LD HL,$20B2  ; ROM $02DD: 21 B2 20
NATIVE_02E0:
        LD (HL),C  ; ROM $02E0: 71
        INC HL  ; ROM $02E1: 23
        LD (HL),B  ; ROM $02E2: 70
        INC HL  ; ROM $02E3: 23
        CALL $0359  ; ROM $02E4: CD 59 03
        LD (HL),E  ; ROM $02E7: 73
        INC HL  ; ROM $02E8: 23
        LD (HL),D  ; ROM $02E9: 72
        INC HL  ; ROM $02EA: 23
        LD (HL),C  ; ROM $02EB: 71
        INC HL  ; ROM $02EC: 23
        EX (SP),HL  ; ROM $02ED: E3
        LD A,(HL)  ; ROM $02EE: 7E
        EX DE,HL  ; ROM $02EF: EB
        LD HL,$000B  ; ROM $02F0: 21 0B 00
        ADD HL,DE  ; ROM $02F3: 19
        EX DE,HL  ; ROM $02F4: EB
        EX (SP),HL  ; ROM $02F5: E3
        LD (HL),E  ; ROM $02F6: 73
        INC HL  ; ROM $02F7: 23
        LD (HL),D  ; ROM $02F8: 72
        EX DE,HL  ; ROM $02F9: EB
        RLA  ; ROM $02FA: 17
        RLA  ; ROM $02FB: 17
        JP C,$0314  ; ROM $02FC: DA 14 03
        RLA  ; ROM $02FF: 17
        JP C,$033E  ; ROM $0300: DA 3E 03
        DEC HL  ; ROM $0303: 2B
        LD D,(HL)  ; ROM $0304: 56
        DEC HL  ; ROM $0305: 2B
        LD E,(HL)  ; ROM $0306: 5E
        LD BC,$0004  ; ROM $0307: 01 04 00
        LD A,$80  ; ROM $030A: 3E 80
NATIVE_030C:
        ADD HL,BC  ; ROM $030C: 09
        LD (HL),E  ; ROM $030D: 73
        INC HL  ; ROM $030E: 23
        LD (HL),D  ; ROM $030F: 72
        POP HL  ; ROM $0310: E1
        XOR (HL)  ; ROM $0311: AE
        LD (HL),A  ; ROM $0312: 77
        RET  ; ROM $0313: C9
NATIVE_0314:
        POP HL  ; ROM $0314: E1
        LD A,$50  ; ROM $0315: 3E 50
        CP L  ; ROM $0317: BD
        RET Z  ; ROM $0318: C8
        PUSH HL  ; ROM $0319: E5
        LD A,$2A  ; ROM $031A: 3E 2A
        CP L  ; ROM $031C: BD
        LD HL,$0349  ; ROM $031D: 21 49 03
        JP Z,$0326  ; ROM $0320: CA 26 03
        LD HL,$0351  ; ROM $0323: 21 51 03
NATIVE_0326:
        LD A,($2009)  ; ROM $0326: 3A 09 20
        AND $0C  ; ROM $0329: E6 0C
        RRCA  ; ROM $032B: 0F
        ADD A,L  ; ROM $032C: 85
        LD L,A  ; ROM $032D: 6F
        JP NC,$0332  ; ROM $032E: D2 32 03
        INC H  ; ROM $0331: 24
NATIVE_0332:
        LD E,(HL)  ; ROM $0332: 5E
        INC HL  ; ROM $0333: 23
        LD D,(HL)  ; ROM $0334: 56
        POP HL  ; ROM $0335: E1
        PUSH HL  ; ROM $0336: E5
        LD BC,$000D  ; ROM $0337: 01 0D 00
        XOR A  ; ROM $033A: AF
        JP $030C  ; ROM $033B: C3 0C 03
NATIVE_033E:
        XOR A  ; ROM $033E: AF
        LD (HL),A  ; ROM $033F: 77
        INC HL  ; ROM $0340: 23
        LD (HL),A  ; ROM $0341: 77
        INC HL  ; ROM $0342: 23
        LD (HL),A  ; ROM $0343: 77
        INC HL  ; ROM $0344: 23
        LD (HL),A  ; ROM $0345: 77
        POP HL  ; ROM $0346: E1
        LD (HL),A  ; ROM $0347: 77
        RET  ; ROM $0348: C9
        DB $8B,$0D,$B1,$0D,$D7,$0D,$B1,$0D,$C7,$22,$ED,$22 ; ROM $0349 unclassified
        DB $13,$23,$ED,$22 ; ROM $0355 unclassified
NATIVE_0359:
        LD A,E  ; ROM $0359: 7B
        AND $07  ; ROM $035A: E6 07
        LD C,A  ; ROM $035C: 4F
        LD B,$03  ; ROM $035D: 06 03
NATIVE_035F:
        XOR A  ; ROM $035F: AF
        LD A,D  ; ROM $0360: 7A
        RRA  ; ROM $0361: 1F
        LD D,A  ; ROM $0362: 57
        LD A,E  ; ROM $0363: 7B
        RRA  ; ROM $0364: 1F
        LD E,A  ; ROM $0365: 5F
        DEC B  ; ROM $0366: 05
        JP NZ,$035F  ; ROM $0367: C2 5F 03
        PUSH HL  ; ROM $036A: E5
        LD HL,$2400  ; ROM $036B: 21 00 24
        ADD HL,DE  ; ROM $036E: 19
        EX DE,HL  ; ROM $036F: EB
        POP HL  ; ROM $0370: E1
        RET  ; ROM $0371: C9
NATIVE_0372:
        DI  ; ROM $0372: F3
NATIVE_0373:
        LD A,(HL)  ; ROM $0373: 7E
        INC HL  ; ROM $0374: 23
        LD (DE),A  ; ROM $0375: 12
        INC DE  ; ROM $0376: 13
        DEC C  ; ROM $0377: 0D
        JP NZ,$0373  ; ROM $0378: C2 73 03
        RET  ; ROM $037B: C9
NATIVE_037C:
        PUSH DE  ; ROM $037C: D5
        LD E,A  ; ROM $037D: 5F
        LD D,$00  ; ROM $037E: 16 00
        ADD HL,DE  ; ROM $0380: 19
        LD A,B  ; ROM $0381: 78
        LD B,(HL)  ; ROM $0382: 46
        INC HL  ; ROM $0383: 23
        LD D,(HL)  ; ROM $0384: 56
        POP HL  ; ROM $0385: E1
        ADD A,(HL)  ; ROM $0386: 86
        LD E,A  ; ROM $0387: 5F
        INC HL  ; ROM $0388: 23
        INC HL  ; ROM $0389: 23
        INC HL  ; ROM $038A: 23
        INC HL  ; ROM $038B: 23
        LD A,(HL)  ; ROM $038C: 7E
        ADD A,D  ; ROM $038D: 82
        LD D,A  ; ROM $038E: 57
        RET  ; ROM $038F: C9
NATIVE_0390:
        LD A,$08  ; ROM $0390: 3E 08
        LD HL,$2002  ; ROM $0392: 21 02 20
        LD B,$00  ; ROM $0395: 06 00
NATIVE_0397:
        LD (HL),B  ; ROM $0397: 70
        INC HL  ; ROM $0398: 23
        DEC A  ; ROM $0399: 3D
        JP NZ,$0397  ; ROM $039A: C2 97 03
NATIVE_039D:
        CALL $0655  ; ROM $039D: CD 55 06
        LD HL,$0821  ; ROM $03A0: 21 21 08
        LD ($2000),HL  ; ROM $03A3: 22 00 20
        EI  ; ROM $03A6: FB
NATIVE_03A7:
        LD HL,($2000)  ; ROM $03A7: 2A 00 20
        LD A,($20C6)  ; ROM $03AA: 3A C6 20
        AND A  ; ROM $03AD: A7
        JP Z,$03B4  ; ROM $03AE: CA B4 03
        LD HL,$089B  ; ROM $03B1: 21 9B 08
NATIVE_03B4:
        LD E,(HL)  ; ROM $03B4: 5E
        INC HL  ; ROM $03B5: 23
        LD ($2000),HL  ; ROM $03B6: 22 00 20
        LD D,$00  ; ROM $03B9: 16 00
        LD HL,$09AE  ; ROM $03BB: 21 AE 09
        ADD HL,DE  ; ROM $03BE: 19
        ADD HL,DE  ; ROM $03BF: 19
        LD E,(HL)  ; ROM $03C0: 5E
        INC HL  ; ROM $03C1: 23
        LD D,(HL)  ; ROM $03C2: 56
        EX DE,HL  ; ROM $03C3: EB
        LD DE,$03A6  ; ROM $03C4: 11 A6 03
        PUSH DE  ; ROM $03C7: D5
        JP (HL)  ; ROM $03C8: E9
NATIVE_WORD_14_INPUT_EVENT_DISPATCH:
NATIVE_03C9:
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
        LD HL,$2018  ; ROM $03E1: 21 18 20
        LD DE,$098E  ; ROM $03E4: 11 8E 09
        CALL Z,$040D  ; ROM $03E7: CC 0D 04
        LD HL,$201C  ; ROM $03EA: 21 1C 20
        LD A,(HL)  ; ROM $03ED: 7E
        AND A  ; ROM $03EE: A7
        JP Z,$0404  ; ROM $03EF: CA 04 04
        LD (HL),$00  ; ROM $03F2: 36 00
        RLCA  ; ROM $03F4: 07
        LD E,A  ; ROM $03F5: 5F
        LD D,$00  ; ROM $03F6: 16 00
        LD HL,$09D6  ; ROM $03F8: 21 D6 09
        ADD HL,DE  ; ROM $03FB: 19
        LD E,(HL)  ; ROM $03FC: 5E
        INC HL  ; ROM $03FD: 23
        LD D,(HL)  ; ROM $03FE: 56
        EX DE,HL  ; ROM $03FF: EB

        ORG $0400
; Device 7609g.bin, SHA1 c177e3f72db9af17ab99b2481448ca26318184b9
        LD ($2000),HL  ; ROM $0400: 22 00 20
        RET  ; ROM $0403: C9
NATIVE_0404:
        LD A,($2009)  ; ROM $0404: 3A 09 20
        CP $22  ; ROM $0407: FE 22
        CALL P,$05A7  ; ROM $0409: F4 A7 05
        RET  ; ROM $040C: C9
NATIVE_040D:
        XOR (HL)  ; ROM $040D: AE
        RET Z  ; ROM $040E: C8
        LD C,A  ; ROM $040F: 4F
        LD B,$01  ; ROM $0410: 06 01
NATIVE_0412:
        LD A,C  ; ROM $0412: 79
        RRCA  ; ROM $0413: 0F
        JP C,$0420  ; ROM $0414: DA 20 04
        LD C,A  ; ROM $0417: 4F
        LD A,B  ; ROM $0418: 78
        RLCA  ; ROM $0419: 07
        LD B,A  ; ROM $041A: 47
        INC DE  ; ROM $041B: 13
        INC DE  ; ROM $041C: 13
        JP $0412  ; ROM $041D: C3 12 04
NATIVE_0420:
        LD A,B  ; ROM $0420: 78
        XOR (HL)  ; ROM $0421: AE
        LD (HL),A  ; ROM $0422: 77
        AND B  ; ROM $0423: A0
        EX DE,HL  ; ROM $0424: EB
        LD C,(HL)  ; ROM $0425: 4E
        INC HL  ; ROM $0426: 23
        LD H,(HL)  ; ROM $0427: 66
        LD L,C  ; ROM $0428: 69
        JP (HL)  ; ROM $0429: E9
NATIVE_042A:
        LD A,(DE)  ; ROM $042A: 1A
        AND $70  ; ROM $042B: E6 70
        RRCA  ; ROM $042D: 0F
        RRCA  ; ROM $042E: 0F
        RRCA  ; ROM $042F: 0F
        AND A  ; ROM $0430: A7
        RET Z  ; ROM $0431: C8
        LD ($201A),A  ; ROM $0432: 32 1A 20
        LD HL,$0EE2  ; ROM $0435: 21 E2 0E
        LD DE,$202A  ; ROM $0438: 11 2A 20
        JP $044F  ; ROM $043B: C3 4F 04
NATIVE_043E:
        LD A,(DE)  ; ROM $043E: 1A
        AND $70  ; ROM $043F: E6 70
        RRCA  ; ROM $0441: 0F
        RRCA  ; ROM $0442: 0F
        RRCA  ; ROM $0443: 0F
        AND A  ; ROM $0444: A7
        RET Z  ; ROM $0445: C8
        LD ($201B),A  ; ROM $0446: 32 1B 20
        LD HL,$0EF0  ; ROM $0449: 21 F0 0E
        LD DE,$203D  ; ROM $044C: 11 3D 20
NATIVE_044F:
        LD C,A  ; ROM $044F: 4F
        LD B,$00  ; ROM $0450: 06 00
        ADD HL,BC  ; ROM $0452: 09
        LD C,(HL)  ; ROM $0453: 4E
        INC HL  ; ROM $0454: 23
        LD B,(HL)  ; ROM $0455: 46
        EX DE,HL  ; ROM $0456: EB
        LD (HL),$C0  ; ROM $0457: 36 C0
        LD DE,$000B  ; ROM $0459: 11 0B 00
        ADD HL,DE  ; ROM $045C: 19
        LD (HL),C  ; ROM $045D: 71
        INC HL  ; ROM $045E: 23
        LD (HL),B  ; ROM $045F: 70
        RET  ; ROM $0460: C9
NATIVE_0461:
        LD B,$FE  ; ROM $0461: 06 FE
NATIVE_0463:
        JP NZ,$0468  ; ROM $0463: C2 68 04
        LD B,$00  ; ROM $0466: 06 00
NATIVE_0468:
        LD HL,$202A  ; ROM $0468: 21 2A 20
NATIVE_046B:
        LD (HL),$C0  ; ROM $046B: 36 C0
        LD DE,$0005  ; ROM $046D: 11 05 00
        ADD HL,DE  ; ROM $0470: 19
        LD (HL),B  ; ROM $0471: 70
        RET  ; ROM $0472: C9
NATIVE_0473:
        LD B,$02  ; ROM $0473: 06 02
        JP $0463  ; ROM $0475: C3 63 04
NATIVE_0478:
        LD B,$FF  ; ROM $0478: 06 FF
NATIVE_047A:
        JP NZ,$047F  ; ROM $047A: C2 7F 04
        LD B,$00  ; ROM $047D: 06 00
NATIVE_047F:
        LD HL,$202A  ; ROM $047F: 21 2A 20
NATIVE_0482:
        LD (HL),$C0  ; ROM $0482: 36 C0
        INC HL  ; ROM $0484: 23
        LD (HL),B  ; ROM $0485: 70
        RET  ; ROM $0486: C9
NATIVE_0487:
        LD B,$01  ; ROM $0487: 06 01
        JP $047A  ; ROM $0489: C3 7A 04
NATIVE_048C:
        LD B,$FE  ; ROM $048C: 06 FE
NATIVE_048E:
        JP NZ,$0493  ; ROM $048E: C2 93 04
        LD B,$00  ; ROM $0491: 06 00
NATIVE_0493:
        LD HL,$203D  ; ROM $0493: 21 3D 20
        JP $046B  ; ROM $0496: C3 6B 04
NATIVE_0499:
        LD B,$02  ; ROM $0499: 06 02
        JP $048E  ; ROM $049B: C3 8E 04
NATIVE_049E:
        LD B,$FF  ; ROM $049E: 06 FF
NATIVE_04A0:
        JP NZ,$04A5  ; ROM $04A0: C2 A5 04
        LD B,$00  ; ROM $04A3: 06 00
NATIVE_04A5:
        LD HL,$203D  ; ROM $04A5: 21 3D 20
        JP $0482  ; ROM $04A8: C3 82 04
NATIVE_04AB:
        LD B,$01  ; ROM $04AB: 06 01
        JP $04A0  ; ROM $04AD: C3 A0 04
NATIVE_04B0:
        RET Z  ; ROM $04B0: C8
        LD HL,$2063  ; ROM $04B1: 21 63 20
        LD A,(HL)  ; ROM $04B4: 7E
        AND $80  ; ROM $04B5: E6 80
        JP Z,$04C1  ; ROM $04B7: CA C1 04
        LD HL,$2075  ; ROM $04BA: 21 75 20
        LD A,(HL)  ; ROM $04BD: 7E
        AND $80  ; ROM $04BE: E6 80
        RET NZ  ; ROM $04C0: C0
NATIVE_04C1:
        LD DE,$2012  ; ROM $04C1: 11 12 20
        LD A,(DE)  ; ROM $04C4: 1A
        AND A  ; ROM $04C5: A7
        RET NZ  ; ROM $04C6: C0
        PUSH HL  ; ROM $04C7: E5
        EX DE,HL  ; ROM $04C8: EB
        LD DE,$3EA2  ; ROM $04C9: 11 A2 3E
        LD BC,$2010  ; ROM $04CC: 01 10 20
        CALL $04FA  ; ROM $04CF: CD FA 04
        LD A,$E2  ; ROM $04D2: 3E E2
        OUT ($01),A  ; ROM $04D4: D3 01
        LD DE,$202C  ; ROM $04D6: 11 2C 20
        LD BC,$1A08  ; ROM $04D9: 01 08 1A
        LD A,($201A)  ; ROM $04DC: 3A 1A 20
NATIVE_04DF:
        LD HL,$0EFE  ; ROM $04DF: 21 FE 0E
        CALL $037C  ; ROM $04E2: CD 7C 03
        POP HL  ; ROM $04E5: E1
        DI  ; ROM $04E6: F3
        LD (HL),$C6  ; ROM $04E7: 36 C6
        INC HL  ; ROM $04E9: 23
        LD (HL),C  ; ROM $04EA: 71
        INC HL  ; ROM $04EB: 23
        LD (HL),E  ; ROM $04EC: 73
        INC HL  ; ROM $04ED: 23
        INC HL  ; ROM $04EE: 23
        INC HL  ; ROM $04EF: 23
        LD (HL),B  ; ROM $04F0: 70
        INC HL  ; ROM $04F1: 23
        LD (HL),D  ; ROM $04F2: 72
        EI  ; ROM $04F3: FB
        LD A,$02  ; ROM $04F4: 3E 02
        LD ($2014),A  ; ROM $04F6: 32 14 20
        RET  ; ROM $04F9: C9
NATIVE_04FA:
        LD A,(BC)  ; ROM $04FA: 0A
        INC A  ; ROM $04FB: 3C
        LD (BC),A  ; ROM $04FC: 02
        CP $06  ; ROM $04FD: FE 06
        JP M,$0511  ; ROM $04FF: FA 11 05
        LD (HL),A  ; ROM $0502: 77
        LD B,A  ; ROM $0503: 47
        LD HL,$2003  ; ROM $0504: 21 03 20
        LD A,(HL)  ; ROM $0507: 7E
        LD (HL),$11  ; ROM $0508: 36 11
        AND A  ; ROM $050A: A7
        JP Z,$0510  ; ROM $050B: CA 10 05
        LD (HL),$02  ; ROM $050E: 36 02
NATIVE_0510:
        LD A,B  ; ROM $0510: 78
NATIVE_0511:
        LD HL,$0FA4  ; ROM $0511: 21 A4 0F
        JP $05FB  ; ROM $0514: C3 FB 05
NATIVE_0517:
        RET Z  ; ROM $0517: C8
        LD HL,$2087  ; ROM $0518: 21 87 20
        LD A,(HL)  ; ROM $051B: 7E
        AND $80  ; ROM $051C: E6 80
        JP Z,$0528  ; ROM $051E: CA 28 05
        LD HL,$2099  ; ROM $0521: 21 99 20
        LD A,(HL)  ; ROM $0524: 7E
        AND $80  ; ROM $0525: E6 80
        RET NZ  ; ROM $0527: C0
NATIVE_0528:
        LD DE,$2013  ; ROM $0528: 11 13 20
        LD A,(DE)  ; ROM $052B: 1A
        AND A  ; ROM $052C: A7
        RET NZ  ; ROM $052D: C0
        PUSH HL  ; ROM $052E: E5
        EX DE,HL  ; ROM $052F: EB
        LD DE,$3EB8  ; ROM $0530: 11 B8 3E
        LD BC,$2011  ; ROM $0533: 01 11 20
        CALL $04FA  ; ROM $0536: CD FA 04
        LD A,$D2  ; ROM $0539: 3E D2
        OUT ($01),A  ; ROM $053B: D3 01
        LD DE,$203F  ; ROM $053D: 11 3F 20
        LD BC,$F6F8  ; ROM $0540: 01 F8 F6
        LD A,($201B)  ; ROM $0543: 3A 1B 20
        JP $04DF  ; ROM $0546: C3 DF 04
NATIVE_0549:
        RET Z  ; ROM $0549: C8
        LD A,$04  ; ROM $054A: 3E 04
        LD ($2014),A  ; ROM $054C: 32 14 20
        OUT ($01),A  ; ROM $054F: D3 01
        LD HL,$2007  ; ROM $0551: 21 07 20
        INC (HL)  ; ROM $0554: 34
        LD A,($2006)  ; ROM $0555: 3A 06 20
        LD C,A  ; ROM $0558: 4F
        AND $03  ; ROM $0559: E6 03
        CP (HL)  ; ROM $055B: BE
        RET NC  ; ROM $055C: D0
        LD (HL),$00  ; ROM $055D: 36 00
        LD A,C  ; ROM $055F: 79
        RRA  ; ROM $0560: 1F
        RRA  ; ROM $0561: 1F
        AND $03  ; ROM $0562: E6 03
        INC A  ; ROM $0564: 3C
        LD HL,$2008  ; ROM $0565: 21 08 20
        ADD A,(HL)  ; ROM $0568: 86
        AND $07  ; ROM $0569: E6 07
        LD (HL),A  ; ROM $056B: 77
NATIVE_056C:
        RET Z  ; ROM $056C: C8
        LD A,($2004)  ; ROM $056D: 3A 04 20
        AND A  ; ROM $0570: A7
        RET NZ  ; ROM $0571: C0
        LD A,($2008)  ; ROM $0572: 3A 08 20
        AND A  ; ROM $0575: A7
        RET Z  ; ROM $0576: C8
        DEC A  ; ROM $0577: 3D
        LD ($2008),A  ; ROM $0578: 32 08 20
        LD B,$60  ; ROM $057B: 06 60
        LD A,($2006)  ; ROM $057D: 3A 06 20
        AND $30  ; ROM $0580: E6 30
        JP Z,$0590  ; ROM $0582: CA 90 05
NATIVE_0585:
        LD C,A  ; ROM $0585: 4F
        LD A,B  ; ROM $0586: 78
        ADD A,$10  ; ROM $0587: C6 10
        LD B,A  ; ROM $0589: 47
        LD A,C  ; ROM $058A: 79
        SUB $10  ; ROM $058B: D6 10
        JP NZ,$0585  ; ROM $058D: C2 85 05
NATIVE_0590:
        LD A,B  ; ROM $0590: 78
        LD ($2004),A  ; ROM $0591: 32 04 20
        LD HL,$20C6  ; ROM $0594: 21 C6 20
        DEC (HL)  ; ROM $0597: 35
        LD HL,$2002  ; ROM $0598: 21 02 20
        XOR A  ; ROM $059B: AF
        LD (HL),A  ; ROM $059C: 77
        INC HL  ; ROM $059D: 23
        LD (HL),A  ; ROM $059E: 77
        INC HL  ; ROM $059F: 23
        INC HL  ; ROM $05A0: 23
        LD (HL),A  ; ROM $05A1: 77
        RET  ; ROM $05A2: C9
NATIVE_WORD_13_UPDATE_SCORE_TEXT:
NATIVE_05A3:
        XOR A  ; ROM $05A3: AF
        LD ($2003),A  ; ROM $05A4: 32 03 20
NATIVE_05A7:
        LD C,$04  ; ROM $05A7: 0E 04
        LD HL,$201E  ; ROM $05A9: 21 1E 20
        LD DE,$2002  ; ROM $05AC: 11 02 20
NATIVE_05AF:
        LD A,(DE)  ; ROM $05AF: 1A
        RRA  ; ROM $05B0: 1F
        RRA  ; ROM $05B1: 1F
        RRA  ; ROM $05B2: 1F
        RRA  ; ROM $05B3: 1F
        AND $0F  ; ROM $05B4: E6 0F
        JP NZ,$05BB  ; ROM $05B6: C2 BB 05
        LD A,$10  ; ROM $05B9: 3E 10
NATIVE_05BB:
        ADD A,$30  ; ROM $05BB: C6 30
        LD (HL),A  ; ROM $05BD: 77
        INC HL  ; ROM $05BE: 23
        LD A,(DE)  ; ROM $05BF: 1A
        AND $0F  ; ROM $05C0: E6 0F
        OR $30  ; ROM $05C2: F6 30
        LD (HL),A  ; ROM $05C4: 77
        LD B,$2B  ; ROM $05C5: 06 2B
        LD A,C  ; ROM $05C7: 79
        CP $03  ; ROM $05C8: FE 03
        JP NZ,$05D6  ; ROM $05CA: C2 D6 05
        LD B,$2C  ; ROM $05CD: 06 2C
        LD A,(DE)  ; ROM $05CF: 1A
        AND A  ; ROM $05D0: A7
        JP NZ,$05D6  ; ROM $05D1: C2 D6 05
        LD (HL),$40  ; ROM $05D4: 36 40
NATIVE_05D6:
        INC DE  ; ROM $05D6: 13
        INC HL  ; ROM $05D7: 23
        LD (HL),B  ; ROM $05D8: 70
        INC HL  ; ROM $05D9: 23
        DEC C  ; ROM $05DA: 0D
        JP NZ,$05AF  ; ROM $05DB: C2 AF 05
        LD A,$08  ; ROM $05DE: 3E 08
        LD HL,$201E  ; ROM $05E0: 21 1E 20
        LD DE,$2405  ; ROM $05E3: 11 05 24
        JP $05FB  ; ROM $05E6: C3 FB 05
NATIVE_WORD_01_DRAW_FORMATTED_DATA:
NATIVE_05E9:
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
        LD ($2000),HL  ; ROM $05F7: 22 00 20
        POP HL  ; ROM $05FA: E1
NATIVE_05FB:
        PUSH AF  ; ROM $05FB: F5
NATIVE_05FC:
        LD A,(HL)  ; ROM $05FC: 7E
        INC HL  ; ROM $05FD: 23
        SUB $30  ; ROM $05FE: D6 30
        JP P,$0614  ; ROM $0600: F2 14 06
        LD B,A  ; ROM $0603: 47
NATIVE_0604:
        INC E  ; ROM $0604: 1C
        LD A,E  ; ROM $0605: 7B
        AND $1F  ; ROM $0606: E6 1F
        JP NZ,$060D  ; ROM $0608: C2 0D 06
        INC D  ; ROM $060B: 14
        INC D  ; ROM $060C: 14
NATIVE_060D:
        INC B  ; ROM $060D: 04
        JP NZ,$0604  ; ROM $060E: C2 04 06
        JP $05FC  ; ROM $0611: C3 FC 05
NATIVE_0614:
        PUSH HL  ; ROM $0614: E5
        PUSH DE  ; ROM $0615: D5
        LD HL,$09F8  ; ROM $0616: 21 F8 09
        JP Z,$0624  ; ROM $0619: CA 24 06
        LD BC,$000A  ; ROM $061C: 01 0A 00
NATIVE_061F:
        ADD HL,BC  ; ROM $061F: 09
        DEC A  ; ROM $0620: 3D
        JP NZ,$061F  ; ROM $0621: C2 1F 06
NATIVE_0624:
        EX DE,HL  ; ROM $0624: EB
        LD BC,$0020  ; ROM $0625: 01 20 00
        LD A,$0A  ; ROM $0628: 3E 0A
NATIVE_062A:
        PUSH AF  ; ROM $062A: F5
        LD A,(DE)  ; ROM $062B: 1A
        INC DE  ; ROM $062C: 13
        LD (HL),A  ; ROM $062D: 77
        ADD HL,BC  ; ROM $062E: 09
        POP AF  ; ROM $062F: F1
        DEC A  ; ROM $0630: 3D
        JP NZ,$062A  ; ROM $0631: C2 2A 06
        POP DE  ; ROM $0634: D1
        POP HL  ; ROM $0635: E1
        INC DE  ; ROM $0636: 13
        POP AF  ; ROM $0637: F1
        DEC A  ; ROM $0638: 3D
        JP NZ,$05FB  ; ROM $0639: C2 FB 05
        RET  ; ROM $063C: C9
NATIVE_WORD_02_SET_RAM_2003:
NATIVE_063D:
        LD HL,($2000)  ; ROM $063D: 2A 00 20
        LD A,(HL)  ; ROM $0640: 7E
        INC HL  ; ROM $0641: 23
        LD ($2000),HL  ; ROM $0642: 22 00 20
        LD ($2003),A  ; ROM $0645: 32 03 20
        RET  ; ROM $0648: C9
NATIVE_WORD_03_SET_RAM_2015:
NATIVE_0649:
        LD HL,($2000)  ; ROM $0649: 2A 00 20
        LD A,(HL)  ; ROM $064C: 7E
        INC HL  ; ROM $064D: 23
        LD ($2000),HL  ; ROM $064E: 22 00 20
        LD ($2015),A  ; ROM $0651: 32 15 20
        RET  ; ROM $0654: C9
NATIVE_WORD_04_CLEAR_DISPLAY:
NATIVE_0655:
        DI  ; ROM $0655: F3
        POP HL  ; ROM $0656: E1
        LD BC,$0000  ; ROM $0657: 01 00 00
        LD DE,$0000  ; ROM $065A: 11 00 00
        LD A,$10  ; ROM $065D: 3E 10
        LD SP,$400F  ; ROM $065F: 31 0F 40
NATIVE_0662:
        PUSH BC  ; ROM $0662: C5
        INC DE  ; ROM $0663: 13
        CP D  ; ROM $0664: BA
        JP NZ,$0662  ; ROM $0665: C2 62 06
        XOR A  ; ROM $0668: AF
        OUT ($01),A  ; ROM $0669: D3 01
        LD SP,$2400  ; ROM $066B: 31 00 24
        EI  ; ROM $066E: FB
        JP (HL)  ; ROM $066F: E9
NATIVE_WORD_07_CLEAR_OBJECT_FLAGS:
NATIVE_0670:
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
        RET  ; ROM $0681: C9
NATIVE_WORD_09_BRANCH_SCRIPT:
NATIVE_0682:
        LD HL,($2000)  ; ROM $0682: 2A 00 20
        LD E,(HL)  ; ROM $0685: 5E
        INC HL  ; ROM $0686: 23
        LD D,(HL)  ; ROM $0687: 56
        EX DE,HL  ; ROM $0688: EB
        LD ($2000),HL  ; ROM $0689: 22 00 20
        RET  ; ROM $068C: C9
NATIVE_WORD_05_COPY_INLINE_15:
NATIVE_068D:
        LD HL,($2000)  ; ROM $068D: 2A 00 20
        LD E,(HL)  ; ROM $0690: 5E
        INC HL  ; ROM $0691: 23
        LD D,(HL)  ; ROM $0692: 56
        INC HL  ; ROM $0693: 23
        LD C,$0F  ; ROM $0694: 0E 0F
        CALL $0372  ; ROM $0696: CD 72 03
        LD ($2000),HL  ; ROM $0699: 22 00 20
        RET  ; ROM $069C: C9
NATIVE_WORD_06_COPY_INLINE_9:
NATIVE_069D:
        LD HL,($2000)  ; ROM $069D: 2A 00 20
        LD E,(HL)  ; ROM $06A0: 5E
        INC HL  ; ROM $06A1: 23
        LD D,(HL)  ; ROM $06A2: 56
        INC HL  ; ROM $06A3: 23
        LD C,$09  ; ROM $06A4: 0E 09
        CALL $0372  ; ROM $06A6: CD 72 03
        LD ($2000),HL  ; ROM $06A9: 22 00 20
        RET  ; ROM $06AC: C9
NATIVE_WORD_08_TOGGLE_OBJECT_FLAGS:
NATIVE_06AD:
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
NATIVE_WORD_0A_GAME_DISPLAY:
NATIVE_06BC:
        LD HL,$0F0E  ; ROM $06BC: 21 0E 0F
        XOR A  ; ROM $06BF: AF
        OUT ($02),A  ; ROM $06C0: D3 02
        LD A,($2002)  ; ROM $06C2: 3A 02 20
NATIVE_06C5:
        DEC A  ; ROM $06C5: 3D
        JP M,$06EB  ; ROM $06C6: FA EB 06
        CP $02  ; ROM $06C9: FE 02
        CALL P,$0719  ; ROM $06CB: F4 19 07
        CP $05  ; ROM $06CE: FE 05
        JP M,$06D5  ; ROM $06D0: FA D5 06
        LD A,$04  ; ROM $06D3: 3E 04
NATIVE_06D5:
        LD E,(HL)  ; ROM $06D5: 5E
        INC HL  ; ROM $06D6: 23
        LD D,(HL)  ; ROM $06D7: 56
        INC HL  ; ROM $06D8: 23
        PUSH DE  ; ROM $06D9: D5
        LD E,(HL)  ; ROM $06DA: 5E
        INC HL  ; ROM $06DB: 23
        LD D,(HL)  ; ROM $06DC: 56
        INC HL  ; ROM $06DD: 23
        LD B,$00  ; ROM $06DE: 06 00
        EX (SP),HL  ; ROM $06E0: E3
        PUSH AF  ; ROM $06E1: F5
        CALL $022D  ; ROM $06E2: CD 2D 02
        POP AF  ; ROM $06E5: F1
        POP HL  ; ROM $06E6: E1
        DEC A  ; ROM $06E7: 3D
        JP P,$06D5  ; ROM $06E8: F2 D5 06
NATIVE_06EB:
        LD A,($2016)  ; ROM $06EB: 3A 16 20
        LD B,A  ; ROM $06EE: 47
        AND $80  ; ROM $06EF: E6 80
        JP NZ,$0703  ; ROM $06F1: C2 03 07
        LD A,B  ; ROM $06F4: 78
        OR $80  ; ROM $06F5: F6 80
        LD ($2016),A  ; ROM $06F7: 32 16 20
        LD HL,$0F22  ; ROM $06FA: 21 22 0F
        LD A,($2005)  ; ROM $06FD: 3A 05 20
        JP $06C5  ; ROM $0700: C3 C5 06
NATIVE_0703:
        LD A,($2016)  ; ROM $0703: 3A 16 20
        AND $40  ; ROM $0706: E6 40
        RET NZ  ; ROM $0708: C0
        OR $40  ; ROM $0709: F6 40
        LD ($2016),A  ; ROM $070B: 32 16 20
        LD A,$04  ; ROM $070E: 3E 04
        OUT ($02),A  ; ROM $0710: D3 02
        XOR A  ; ROM $0712: AF
        LD HL,$0F36  ; ROM $0713: 21 36 0F
        JP $06D5  ; ROM $0716: C3 D5 06
NATIVE_0719:
        PUSH HL  ; ROM $0719: E5
        PUSH AF  ; ROM $071A: F5
        LD HL,$2050  ; ROM $071B: 21 50 20
        LD A,(HL)  ; ROM $071E: 7E
        AND $80  ; ROM $071F: E6 80
        JP NZ,$072D  ; ROM $0721: C2 2D 07
        EX DE,HL  ; ROM $0724: EB
        LD C,$0F  ; ROM $0725: 0E 0F
        LD HL,$0F52  ; ROM $0727: 21 52 0F
        CALL $0372  ; ROM $072A: CD 72 03
NATIVE_072D:
        LD A,($2016)  ; ROM $072D: 3A 16 20
        OR $40  ; ROM $0730: F6 40
        LD ($2016),A  ; ROM $0732: 32 16 20
        POP AF  ; ROM $0735: F1
        POP HL  ; ROM $0736: E1
        RET  ; ROM $0737: C9
NATIVE_WORD_0C_BCD_INCREMENT_INIT:
NATIVE_0738:
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
NATIVE_WORD_0B_INIT_OBJECT:
NATIVE_0749:
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
        LD (DE),A  ; ROM $0758: 12
        INC DE  ; ROM $0759: 13
        INC DE  ; ROM $075A: 13
        INC DE  ; ROM $075B: 13
        INC DE  ; ROM $075C: 13
        LD A,(DE)  ; ROM $075D: 1A
        ADD A,$08  ; ROM $075E: C6 08
        LD (DE),A  ; ROM $0760: 12
        LD C,(HL)  ; ROM $0761: 4E
        INC HL  ; ROM $0762: 23
        LD B,(HL)  ; ROM $0763: 46
        INC HL  ; ROM $0764: 23
        LD ($2000),HL  ; ROM $0765: 22 00 20
        INC DE  ; ROM $0768: 13
        INC DE  ; ROM $0769: 13
        INC DE  ; ROM $076A: 13
        EX DE,HL  ; ROM $076B: EB
        LD (HL),C  ; ROM $076C: 71
        INC HL  ; ROM $076D: 23
        LD (HL),B  ; ROM $076E: 70
        INC HL  ; ROM $076F: 23
        XOR A  ; ROM $0770: AF
        LD (HL),A  ; ROM $0771: 77
        INC HL  ; ROM $0772: 23
        LD (HL),A  ; ROM $0773: 77
        RET  ; ROM $0774: C9
NATIVE_WORD_0D_SET_OUTPUT_AND_RAM:
NATIVE_0775:
        LD HL,($2000)  ; ROM $0775: 2A 00 20
        LD A,(HL)  ; ROM $0778: 7E
        OUT ($01),A  ; ROM $0779: D3 01
        INC HL  ; ROM $077B: 23
        LD A,(HL)  ; ROM $077C: 7E
        INC HL  ; ROM $077D: 23
        LD ($2000),HL  ; ROM $077E: 22 00 20
        LD ($2014),A  ; ROM $0781: 32 14 20
NATIVE_0784:
        RET  ; ROM $0784: C9
NATIVE_WORD_0E_FILL_RECTANGLE:
NATIVE_0785:
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
NATIVE_079A:
        PUSH HL  ; ROM $079A: E5
        LD C,E  ; ROM $079B: 4B
NATIVE_079C:
        LD (HL),B  ; ROM $079C: 70
        INC HL  ; ROM $079D: 23
        DEC C  ; ROM $079E: 0D
        JP NZ,$079C  ; ROM $079F: C2 9C 07
        POP HL  ; ROM $07A2: E1
        LD C,$20  ; ROM $07A3: 0E 20
        ADD HL,BC  ; ROM $07A5: 09
        DEC D  ; ROM $07A6: 15
        JP NZ,$079A  ; ROM $07A7: C2 9A 07
        RET  ; ROM $07AA: C9
NATIVE_WORD_0F_EXPAND_GRAPHICS:
NATIVE_07AB:
        LD HL,$2100  ; ROM $07AB: 21 00 21
        LD DE,$0BC4  ; ROM $07AE: 11 C4 0B
NATIVE_07B1:
        LD A,(DE)  ; ROM $07B1: 1A
        AND A  ; ROM $07B2: A7
        RET Z  ; ROM $07B3: C8
        LD (HL),A  ; ROM $07B4: 77
        INC HL  ; ROM $07B5: 23
        INC DE  ; ROM $07B6: 13
        LD C,A  ; ROM $07B7: 4F
        LD A,(DE)  ; ROM $07B8: 1A
        INC DE  ; ROM $07B9: 13
        LD B,A  ; ROM $07BA: 47
        LD (HL),A  ; ROM $07BB: 77
        INC HL  ; ROM $07BC: 23
NATIVE_07BD:
        PUSH BC  ; ROM $07BD: C5
        LD A,B  ; ROM $07BE: 78
        LD B,$00  ; ROM $07BF: 06 00
        ADD HL,BC  ; ROM $07C1: 09
        LD B,A  ; ROM $07C2: 47
NATIVE_07C3:
        DEC HL  ; ROM $07C3: 2B
        LD A,(DE)  ; ROM $07C4: 1A
        INC DE  ; ROM $07C5: 13
        PUSH DE  ; ROM $07C6: D5
        LD D,A  ; ROM $07C7: 57
        LD E,$00  ; ROM $07C8: 1E 00
        LD B,$08  ; ROM $07CA: 06 08
NATIVE_07CC:
        LD A,D  ; ROM $07CC: 7A
        RRA  ; ROM $07CD: 1F
        LD D,A  ; ROM $07CE: 57
        LD A,E  ; ROM $07CF: 7B
        RLA  ; ROM $07D0: 17
        LD E,A  ; ROM $07D1: 5F
        DEC B  ; ROM $07D2: 05
        JP NZ,$07CC  ; ROM $07D3: C2 CC 07
        LD (HL),E  ; ROM $07D6: 73
        POP DE  ; ROM $07D7: D1
        DEC C  ; ROM $07D8: 0D
        JP NZ,$07C3  ; ROM $07D9: C2 C3 07
        POP BC  ; ROM $07DC: C1
        LD A,B  ; ROM $07DD: 78
        LD B,$00  ; ROM $07DE: 06 00
        ADD HL,BC  ; ROM $07E0: 09
        LD B,A  ; ROM $07E1: 47
        DEC B  ; ROM $07E2: 05
        JP NZ,$07BD  ; ROM $07E3: C2 BD 07
        JP $07B1  ; ROM $07E6: C3 B1 07
NATIVE_WORD_11_DRAW_STATUS_A:
NATIVE_07E9:
        LD HL,$203F  ; ROM $07E9: 21 3F 20
        JP $07F2  ; ROM $07EC: C3 F2 07
NATIVE_WORD_12_DRAW_STATUS_B:
NATIVE_07EF:
        LD HL,$202C  ; ROM $07EF: 21 2C 20
NATIVE_07F2:
        LD E,(HL)  ; ROM $07F2: 5E
        LD BC,$0004  ; ROM $07F3: 01 04 00
        ADD HL,BC  ; ROM $07F6: 09
        LD D,(HL)  ; ROM $07F7: 56
        CALL $0359  ; ROM $07F8: CD 59 03
        DEC DE  ; ROM $07FB: 1B
        DEC D  ; ROM $07FC: 15
        DEC D  ; ROM $07FD: 15
        DEC D  ; ROM $07FE: 15
        DB $21 ; ROM $07FF unclassified

        ORG $0800
; Device 7609f.bin, SHA1 215b068663e431582591001cbe028929fa96d49f
        DB $CE,$0F ; ROM $0800 unclassified
        LD A,$07  ; ROM $0802: 3E 07
        JP $05FB  ; ROM $0804: C3 FB 05
NATIVE_WORD_10_BRANCH_IF_STATE:
NATIVE_0807:
        LD A,($2008)  ; ROM $0807: 3A 08 20
        AND A  ; ROM $080A: A7
        RET Z  ; ROM $080B: C8
        LD HL,$0882  ; ROM $080C: 21 82 08
        LD ($2000),HL  ; ROM $080F: 22 00 20
        RET  ; ROM $0812: C9
NATIVE_WORD_00_WAIT_REPEAT:
NATIVE_0813:
        LD HL,$20C5  ; ROM $0813: 21 C5 20
        INC (HL)  ; ROM $0816: 34
        RET Z  ; ROM $0817: C8
        DEC (HL)  ; ROM $0818: 35
        LD HL,($2000)  ; ROM $0819: 2A 00 20
        DEC HL  ; ROM $081C: 2B
        LD ($2000),HL  ; ROM $081D: 22 00 20
        RET  ; ROM $0820: C9
CMD_0821_CLEAR_VIDEO:
        DB $04 ; word CLEAR_VIDEO ($04)
CMD_0822_FORMAT_SCORE:
        DB $13 ; word FORMAT_SCORE ($13)
CMD_0823_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $0C ; format
        DW $0F61 ; source
        DW $240A ; destination
CMD_0829_BRANCH_IF_STATE:
        DB $10 ; word BRANCH_IF_STATE ($10)
CMD_082A_EXPAND_GLYPHS:
        DB $0F ; word EXPAND_GLYPHS ($0F)
CMD_082B_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $5A ; state
CMD_082D_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_082E_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $29 ; format
        DW $0F6D ; source
        DW $2600 ; destination
CMD_0834_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $5A ; state
CMD_0836_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0837_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $0B ; format
        DW $0F99 ; source
        DW $3D14 ; destination
CMD_083D_COPY15_TO_RAM:
        DB $05 ; word COPY15_TO_RAM ($05)
        DW $202A ; destination
        DB $C3,$01,$00,$00,$40,$00,$66,$0B,$AA,$8B,$0D,$4A,$0D,$8B,$0D ; inline RAM data
CMD_084F_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $5A ; state
CMD_0851_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0852_COPY9_TO_RAM:
        DB $06 ; word COPY9_TO_RAM ($06)
        DW $2063 ; destination
        DB $C6,$03,$54,$00,$FE,$02,$78,$00,$C8 ; inline RAM data
CMD_085E_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $4B ; state
CMD_0860_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0861_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $0B ; format
        DW $0FA4 ; source
        DW $3D14 ; destination
CMD_0867_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $3C ; state
CMD_0869_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_086A_COPY15_TO_RAM:
        DB $05 ; word COPY15_TO_RAM ($05)
        DW $203D ; destination
        DB $C2,$FF,$40,$00,$60,$00,$66,$27,$A0,$C7,$22,$00,$21,$C7,$22 ; inline RAM data
CMD_087C_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $40 ; state
CMD_087E_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_087F_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $0821 ; RAM address / target / packed dimension
CMD_0882_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $27 ; format
        DW $0FD5 ; source
        DW $2A01 ; destination
CMD_0888_COPY15_TO_RAM:
        DB $05 ; word COPY15_TO_RAM ($05)
        DW $202A ; destination
        DB $C3,$02,$00,$00,$40,$00,$A0,$0B,$AA,$8B,$0D,$4A,$0D,$8B,$0D ; inline RAM data
CMD_089A_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_089B_CLEAR_VIDEO:
        DB $04 ; word CLEAR_VIDEO ($04)
CMD_089C_FORMAT_SCORE:
        DB $13 ; word FORMAT_SCORE ($13)
CMD_089D_EXPAND_GLYPHS:
        DB $0F ; word EXPAND_GLYPHS ($0F)
CMD_089E_DRAW_GAME_STATUS:
        DB $0A ; word DRAW_GAME_STATUS ($0A)
CMD_089F_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $09 ; format
        DW $0FAF ; source
        DW $2E0C ; destination
CMD_08A5_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $0C ; format
        DW $0FB8 ; source
        DW $3EA2 ; destination
CMD_08AB_COPY15_TO_RAM:
        DB $05 ; word COPY15_TO_RAM ($05)
        DW $202A ; destination
        DB $C0,$01,$00,$00,$48,$00,$66,$13,$9A,$8B,$0D,$87,$0C,$8B,$0D ; inline RAM data
CMD_08BD_COPY15_TO_RAM:
        DB $05 ; word COPY15_TO_RAM ($05)
        DW $203D ; destination
        DB $C0,$FF,$E7,$A0,$48,$00,$66,$13,$9A,$C7,$22,$C3,$21,$C7,$22 ; inline RAM data
CMD_08CF_COPY9_TO_RAM:
        DB $06 ; word COPY9_TO_RAM ($06)
        DW $2063 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08DB_COPY9_TO_RAM:
        DB $06 ; word COPY9_TO_RAM ($06)
        DW $2075 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08E7_COPY9_TO_RAM:
        DB $06 ; word COPY9_TO_RAM ($06)
        DW $2087 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08F3_COPY9_TO_RAM:
        DB $06 ; word COPY9_TO_RAM ($06)
        DW $2099 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08FF_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $1E ; state
CMD_0901_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0902_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $09 ; format
        DW $0FC5 ; source
        DW $2E0C ; destination
CMD_0908_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $0A ; state
CMD_090A_CLEAR_OBJECT_BITS:
        DB $07 ; word CLEAR_OBJECT_BITS ($07)
        DW $202A ; RAM address / target / packed dimension
CMD_090D_CLEAR_OBJECT_BITS:
        DB $07 ; word CLEAR_OBJECT_BITS ($07)
        DW $203D ; RAM address / target / packed dimension
CMD_0910_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0911_DRAW_FORMATTED:
        DB $01 ; word DRAW_FORMATTED ($01)
        DB $05 ; format
        DW $0FA4 ; source
        DW $2E0E ; destination
CMD_0917_READ_INPUT_EVENTS:
        DB $14 ; word READ_INPUT_EVENTS ($14)
CMD_0918_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $089B ; RAM address / target / packed dimension
CMD_091B_BCD_INCREMENT_SETUP:
        DB $0C ; word BCD_INCREMENT_SETUP ($0C)
        DW $2005 ; BCD counter
        DW $202A ; descriptor address
        DB $20 ; flags
        DW $0DFD ; link pointer
CMD_0923_SET_OUTPUT_MODE:
        DB $0D ; word SET_OUTPUT_MODE ($0D)
        DB $C2 ; output
        DB $02 ; state
CMD_0926_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $0F ; state
CMD_0928_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0929_SETUP_OBJECT:
        DB $0B ; word SETUP_OBJECT ($0B)
        DW $202A ; descriptor address
        DB $10 ; flags
        DW $0E5F ; link pointer
CMD_092F_DRAW_STATUS_B:
        DB $12 ; word DRAW_STATUS_B ($12)
CMD_0930_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $2D ; state
CMD_0932_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0933_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $089B ; RAM address / target / packed dimension
CMD_0936_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $1060 ; RAM address / target / packed dimension
CMD_0939_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $095D ; RAM address / target / packed dimension
CMD_093C_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $5060 ; RAM address / target / packed dimension
CMD_093F_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $095D ; RAM address / target / packed dimension
CMD_0942_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $9060 ; RAM address / target / packed dimension
CMD_0945_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $095D ; RAM address / target / packed dimension
CMD_0948_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $1078 ; RAM address / target / packed dimension
CMD_094B_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $095D ; RAM address / target / packed dimension
CMD_094E_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $1090 ; RAM address / target / packed dimension
CMD_0951_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $095D ; RAM address / target / packed dimension
CMD_0954_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $5090 ; RAM address / target / packed dimension
CMD_0957_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $095D ; RAM address / target / packed dimension
CMD_095A_FILL_VIDEO_RECT:
        DB $0E ; word FILL_VIDEO_RECT ($0E)
        DW $9090 ; RAM address / target / packed dimension
CMD_095D_SET_OUTPUT_MODE:
        DB $0D ; word SET_OUTPUT_MODE ($0D)
        DB $B2 ; output
        DB $02 ; state
CMD_0960_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $0917 ; RAM address / target / packed dimension
CMD_0963_BCD_INCREMENT_SETUP:
        DB $0C ; word BCD_INCREMENT_SETUP ($0C)
        DW $2002 ; BCD counter
        DW $203D ; descriptor address
        DB $D0 ; flags
        DW $2339 ; link pointer
CMD_096B_SET_OUTPUT_MODE:
        DB $0D ; word SET_OUTPUT_MODE ($0D)
        DB $B2 ; output
        DB $02 ; state
CMD_096E_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $0A ; state
CMD_0970_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_0971_SETUP_OBJECT:
        DB $0B ; word SETUP_OBJECT ($0B)
        DW $203D ; descriptor address
        DB $D0 ; flags
        DW $239B ; link pointer
CMD_0977_DRAW_STATUS_A:
        DB $11 ; word DRAW_STATUS_A ($11)
CMD_0978_SET_DELAY:
        DB $03 ; word SET_DELAY ($03)
        DB $2D ; state
CMD_097A_WAIT_REPEAT:
        DB $00 ; word WAIT_REPEAT ($00)
CMD_097B_SCRIPT_JUMP:
        DB $09 ; word SCRIPT_JUMP ($09)
        DW $089B ; RAM address / target / packed dimension
ROM_NATIVE_EVENT_ACTION_00:
        DW $0461 ; NATIVE_EVENT_ACTION pointer from ROM $097E
ROM_NATIVE_EVENT_ACTION_01:
        DW $0473 ; NATIVE_EVENT_ACTION pointer from ROM $0980
ROM_NATIVE_EVENT_ACTION_02:
        DW $0478 ; NATIVE_EVENT_ACTION pointer from ROM $0982
ROM_NATIVE_EVENT_ACTION_03:
        DW $0487 ; NATIVE_EVENT_ACTION pointer from ROM $0984
ROM_NATIVE_EVENT_ACTION_04:
        DW $042A ; NATIVE_EVENT_ACTION pointer from ROM $0986
ROM_NATIVE_EVENT_ACTION_05:
        DW $042A ; NATIVE_EVENT_ACTION pointer from ROM $0988
ROM_NATIVE_EVENT_ACTION_06:
        DW $042A ; NATIVE_EVENT_ACTION pointer from ROM $098A
ROM_NATIVE_EVENT_ACTION_07:
        DW $04B0 ; NATIVE_EVENT_ACTION pointer from ROM $098C
ROM_NATIVE_EVENT_ACTION_08:
        DW $048C ; NATIVE_EVENT_ACTION pointer from ROM $098E
ROM_NATIVE_EVENT_ACTION_09:
        DW $0499 ; NATIVE_EVENT_ACTION pointer from ROM $0990
ROM_NATIVE_EVENT_ACTION_0A:
        DW $049E ; NATIVE_EVENT_ACTION pointer from ROM $0992
ROM_NATIVE_EVENT_ACTION_0B:
        DW $04AB ; NATIVE_EVENT_ACTION pointer from ROM $0994
ROM_NATIVE_EVENT_ACTION_0C:
        DW $043E ; NATIVE_EVENT_ACTION pointer from ROM $0996
ROM_NATIVE_EVENT_ACTION_0D:
        DW $043E ; NATIVE_EVENT_ACTION pointer from ROM $0998
ROM_NATIVE_EVENT_ACTION_0E:
        DW $043E ; NATIVE_EVENT_ACTION pointer from ROM $099A
ROM_NATIVE_EVENT_ACTION_0F:
        DW $0517 ; NATIVE_EVENT_ACTION pointer from ROM $099C
ROM_NATIVE_EVENT_ACTION_10:
        DW $0784 ; NATIVE_EVENT_ACTION pointer from ROM $099E
ROM_NATIVE_EVENT_ACTION_11:
        DW $0784 ; NATIVE_EVENT_ACTION pointer from ROM $09A0
ROM_NATIVE_EVENT_ACTION_12:
        DW $0784 ; NATIVE_EVENT_ACTION pointer from ROM $09A2
ROM_NATIVE_EVENT_ACTION_13:
        DW $0784 ; NATIVE_EVENT_ACTION pointer from ROM $09A4
ROM_NATIVE_EVENT_ACTION_14:
        DW $0784 ; NATIVE_EVENT_ACTION pointer from ROM $09A6
ROM_NATIVE_EVENT_ACTION_15:
        DW $0784 ; NATIVE_EVENT_ACTION pointer from ROM $09A8
ROM_NATIVE_EVENT_ACTION_16:
        DW $0549 ; NATIVE_EVENT_ACTION pointer from ROM $09AA
ROM_NATIVE_EVENT_ACTION_17:
        DW $056C ; NATIVE_EVENT_ACTION pointer from ROM $09AC
ROM_GAME_WORD_00:
        DW $0813 ; GAME_WORD pointer from ROM $09AE
ROM_GAME_WORD_01:
        DW $05E9 ; GAME_WORD pointer from ROM $09B0
ROM_GAME_WORD_02:
        DW $063D ; GAME_WORD pointer from ROM $09B2
ROM_GAME_WORD_03:
        DW $0649 ; GAME_WORD pointer from ROM $09B4
ROM_GAME_WORD_04:
        DW $0655 ; GAME_WORD pointer from ROM $09B6
ROM_GAME_WORD_05:
        DW $068D ; GAME_WORD pointer from ROM $09B8
ROM_GAME_WORD_06:
        DW $069D ; GAME_WORD pointer from ROM $09BA
ROM_GAME_WORD_07:
        DW $0670 ; GAME_WORD pointer from ROM $09BC
ROM_GAME_WORD_08:
        DW $06AD ; GAME_WORD pointer from ROM $09BE
ROM_GAME_WORD_09:
        DW $0682 ; GAME_WORD pointer from ROM $09C0
ROM_GAME_WORD_0A:
        DW $06BC ; GAME_WORD pointer from ROM $09C2
ROM_GAME_WORD_0B:
        DW $0749 ; GAME_WORD pointer from ROM $09C4
ROM_GAME_WORD_0C:
        DW $0738 ; GAME_WORD pointer from ROM $09C6
ROM_GAME_WORD_0D:
        DW $0775 ; GAME_WORD pointer from ROM $09C8
ROM_GAME_WORD_0E:
        DW $0785 ; GAME_WORD pointer from ROM $09CA
ROM_GAME_WORD_0F:
        DW $07AB ; GAME_WORD pointer from ROM $09CC
ROM_GAME_WORD_10:
        DW $0807 ; GAME_WORD pointer from ROM $09CE
ROM_GAME_WORD_11:
        DW $07E9 ; GAME_WORD pointer from ROM $09D0
ROM_GAME_WORD_12:
        DW $07EF ; GAME_WORD pointer from ROM $09D2
ROM_GAME_WORD_13:
        DW $05A3 ; GAME_WORD pointer from ROM $09D4
ROM_GAME_WORD_14:
        DW $03C9 ; GAME_WORD pointer from ROM $09D6
ROM_EVENT_SCRIPT_00:
        DW $091B ; EVENT_SCRIPT pointer from ROM $09D8
ROM_EVENT_SCRIPT_01:
        DW $0936 ; EVENT_SCRIPT pointer from ROM $09DA
ROM_EVENT_SCRIPT_02:
        DW $093C ; EVENT_SCRIPT pointer from ROM $09DC
ROM_EVENT_SCRIPT_03:
        DW $0942 ; EVENT_SCRIPT pointer from ROM $09DE
ROM_EVENT_SCRIPT_04:
        DW $0948 ; EVENT_SCRIPT pointer from ROM $09E0
ROM_EVENT_SCRIPT_05:
        DW $094E ; EVENT_SCRIPT pointer from ROM $09E2
ROM_EVENT_SCRIPT_06:
        DW $0954 ; EVENT_SCRIPT pointer from ROM $09E4
ROM_EVENT_SCRIPT_07:
        DW $095A ; EVENT_SCRIPT pointer from ROM $09E6
ROM_EVENT_SCRIPT_08:
        DW $0963 ; EVENT_SCRIPT pointer from ROM $09E8
        DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; ROM $09EA unclassified
        DB $00,$00,$3C,$7E,$66,$66,$66,$66,$66,$66,$7E,$3C ; ROM $09F6 unclassified
        DB $18,$1C,$18,$18,$18,$18,$18,$18,$3C,$3C,$3C,$7E ; ROM $0A02 unclassified
        DB $66,$60,$7C,$3E,$06,$06,$7E,$7E,$3C,$7E,$66,$60 ; ROM $0A0E unclassified
        DB $38,$78,$60,$66,$7E,$3C,$66,$66,$66,$66,$7E,$7E ; ROM $0A1A unclassified
        DB $60,$60,$60,$60,$3E,$3E,$06,$06,$3E,$7E,$60,$66 ; ROM $0A26 unclassified
        DB $7E,$3C,$3C,$3E,$06,$06,$3E,$7E,$66,$66,$7E,$3C ; ROM $0A32 unclassified
        DB $7E,$7E,$60,$70,$30,$38,$18,$1C,$0C,$0C,$3C,$7E ; ROM $0A3E unclassified
        DB $66,$66,$3C,$7E,$66,$66,$7E,$3C,$3C,$7E,$66,$66 ; ROM $0A4A unclassified
        DB $7E,$7C,$60,$60,$7C,$3C,$10,$38,$38,$38,$38,$38 ; ROM $0A56 unclassified
        DB $38,$38,$38,$7C,$C0,$C0,$C0,$C0,$C0,$C0,$00,$00 ; ROM $0A62 unclassified
        DB $C0,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$C0,$C0 ; ROM $0A6E unclassified
        DB $00,$00,$00,$20,$40,$FF,$40,$20,$00,$00,$F0,$C0 ; ROM $0A7A unclassified
        DB $A0,$90,$08,$04,$02,$01,$00,$00,$78,$FC,$CC,$E0 ; ROM $0A86 unclassified
        DB $70,$30,$30,$00,$30,$30,$00,$00,$00,$00,$00,$00 ; ROM $0A92 unclassified
        DB $00,$00,$00,$00,$18,$3C,$7E,$66,$66,$66,$7E,$7E ; ROM $0A9E unclassified
        DB $66,$66,$3E,$7E,$66,$66,$3E,$7E,$66,$66,$7E,$3E ; ROM $0AAA unclassified
        DB $3C,$7E,$66,$06,$06,$06,$06,$66,$7E,$3C,$3E,$7E ; ROM $0AB6 unclassified
        DB $66,$66,$66,$66,$66,$66,$7E,$3E,$7E,$7E,$06,$06 ; ROM $0AC2 unclassified
        DB $3E,$3E,$06,$06,$7E,$7E,$7E,$7E,$06,$06,$3E,$3E ; ROM $0ACE unclassified
        DB $06,$06,$06,$06,$3C,$7E,$66,$06,$06,$76,$76,$66 ; ROM $0ADA unclassified
        DB $7E,$3C,$66,$66,$66,$66,$7E,$7E,$66,$66,$66,$66 ; ROM $0AE6 unclassified
        DB $3C,$3C,$18,$18,$18,$18,$18,$18,$3C,$3C,$06,$06 ; ROM $0AF2 unclassified
        DB $06,$06,$06,$06,$06,$06,$7E,$7E,$C3,$C3,$E7,$E7 ; ROM $0AFE unclassified
        DB $FF,$FF,$DB,$C3,$C3,$C3,$66,$66,$6E,$6E,$7E,$7E ; ROM $0B0A unclassified
        DB $76,$76,$66,$66,$3C,$7E,$66,$66,$66,$66,$66,$66 ; ROM $0B16 unclassified
        DB $7E,$3C,$3E,$7E,$66,$66,$7E,$3E,$06,$06,$06,$06 ; ROM $0B22 unclassified
        DB $3E,$7E,$66,$66,$7E,$3E,$76,$66,$66,$66,$3C,$7E ; ROM $0B2E unclassified
        DB $66,$06,$3E,$7C,$60,$66,$7E,$3C,$7E,$7E,$18,$18 ; ROM $0B3A unclassified
        DB $18,$18,$18,$18,$18,$18,$66,$66,$66,$66,$66,$66 ; ROM $0B46 unclassified
        DB $66,$66,$7E,$3C,$66,$66,$66,$66,$66,$7E,$3C,$3C ; ROM $0B52 unclassified
        DB $18,$18,$C3,$C3,$C3,$DB,$FF,$FF,$E7,$E7,$C3,$C3 ; ROM $0B5E unclassified
        DB $66,$66,$7E,$3C,$18,$18,$18,$18,$18,$18,$01,$16 ; ROM $0B6A unclassified
        DB $10,$18,$18,$18,$18,$58,$78,$1B,$1A,$1E,$1E,$98 ; ROM $0B76 unclassified
        DB $98,$78,$38,$18,$18,$18,$18,$18,$18,$18,$02,$1B ; ROM $0B82 unclassified
        DB $00,$01,$00,$03,$80,$03,$C0,$07,$C0,$07,$60,$1D ; ROM $0B8E unclassified
        DB $00,$31,$80,$07,$E0,$1F,$F0,$3D,$38,$39,$04,$41 ; ROM $0B9A unclassified
        DB $80,$03,$C0,$07,$E0,$0F,$F8,$1F,$3E,$29,$07,$E9 ; ROM $0BA6 unclassified
        DB $00,$01,$00,$09,$00,$05,$00,$05,$08,$1F,$38,$1B ; ROM $0BB2 unclassified
        DB $38,$29,$CC,$37,$FE,$5D,$03,$15,$00,$05,$00,$80 ; ROM $0BBE unclassified
        DB $0D,$00,$80,$0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8 ; ROM $0BCA unclassified
        DB $FF,$00,$C0,$17,$80,$C0,$3F,$50,$C0,$7F,$60,$C0 ; ROM $0BD6 unclassified
        DB $1F,$30,$80,$1F,$38,$00,$07,$1C,$80,$0F,$0E,$F8 ; ROM $0BE2 unclassified
        DB $FF,$07,$FC,$FF,$03,$CE,$FF,$01,$C6,$1F,$00,$C6 ; ROM $0BEE unclassified
        DB $1F,$00,$C6,$1F,$00,$C6 ; ROM $0BFA unclassified

        ORG $0C00
; Device 7609e.bin, SHA1 de3f2e6841122bbe6e2fda5b87d37842c072289a
        DB $1F,$00,$FA,$3F,$00,$03,$15,$00,$05,$00,$80,$0D ; ROM $0C00 unclassified
        DB $00,$80,$0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8,$FF ; ROM $0C0C unclassified
        DB $00,$C0,$17,$00,$C0,$3F,$00,$C0,$7F,$00,$C0,$1F ; ROM $0C18 unclassified
        DB $C0,$80,$1F,$70,$00,$07,$3C,$80,$0F,$0F,$F8,$FF ; ROM $0C24 unclassified
        DB $03,$FC,$FF,$01,$CE,$FF,$00,$C6,$1F,$00,$C6,$1F ; ROM $0C30 unclassified
        DB $00,$C6,$1F,$00,$C6,$1F,$00,$FA,$3F,$00,$03,$15 ; ROM $0C3C unclassified
        DB $00,$05,$00,$80,$0D,$00,$80,$0D,$00,$80,$0F,$00 ; ROM $0C48 unclassified
        DB $C8,$9F,$00,$F8,$FF,$00,$C0,$17,$00,$C0,$3F,$00 ; ROM $0C54 unclassified
        DB $C0,$7F,$00,$C0,$1F,$00,$80,$1F,$C0,$00,$07,$38 ; ROM $0C60 unclassified
        DB $80,$0F,$0C,$F8,$FF,$0F,$FC,$FF,$03,$CE,$7F,$00 ; ROM $0C6C unclassified
        DB $C6,$1F,$00,$C6,$1F,$00,$C6,$1F,$00,$C6,$1F,$00 ; ROM $0C78 unclassified
        DB $FA,$3F,$00,$03,$15,$00,$05,$00,$80,$0D,$00,$80 ; ROM $0C84 unclassified
        DB $0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8,$FF,$00,$C0 ; ROM $0C90 unclassified
        DB $17,$00,$C0,$3F,$00,$C0,$7F,$00,$C0,$1F,$00,$80 ; ROM $0C9C unclassified
        DB $1F,$00,$00,$07,$08,$80,$0F,$F0,$F8,$FF,$1F,$FC ; ROM $0CA8 unclassified
        DB $FF,$0F,$CE,$FF,$00,$C6,$1F,$00,$C6,$1F,$00,$C6 ; ROM $0CB4 unclassified
        DB $1F,$00,$C6,$1F,$00,$FA,$3F,$00,$03,$15,$00,$05 ; ROM $0CC0 unclassified
        DB $00,$80,$0D,$00,$80,$0D,$00,$80,$0F,$00,$C8,$9F ; ROM $0CCC unclassified
        DB $00,$F8,$FF,$00,$C0,$17,$00,$C0,$3F,$00,$C0,$7F ; ROM $0CD8 unclassified
        DB $00,$C0,$1F,$00,$80,$1F,$00,$00,$07,$00,$80,$0F ; ROM $0CE4 unclassified
        DB $00,$F8,$3F,$00,$FC,$FF,$01,$CE,$FF,$0F,$C6,$1F ; ROM $0CF0 unclassified
        DB $7F,$C6,$1F,$00,$C6,$1F,$00,$C6,$1F,$00,$FA,$3F ; ROM $0CFC unclassified
        DB $00,$03,$15,$00,$05,$00,$80,$0D,$00,$80,$0D,$00 ; ROM $0D08 unclassified
        DB $80,$0F,$00,$C8,$9F,$00,$F8,$FF,$00,$C0,$17,$00 ; ROM $0D14 unclassified
        DB $C0,$3F,$00,$C0,$7F,$00,$C0,$1F,$00,$80,$1F,$00 ; ROM $0D20 unclassified
        DB $00,$07,$00,$80,$0F,$00,$F8,$3F,$00,$FC,$FF,$00 ; ROM $0D2C unclassified
        DB $CE,$FF,$01,$C6,$FF,$07,$C6,$1F,$1E,$C6,$1F,$70 ; ROM $0D38 unclassified
        DB $C6,$1F,$00,$FA,$3F,$00,$03,$15,$00,$05,$00,$80 ; ROM $0D44 unclassified
        DB $0D,$00,$80,$0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8 ; ROM $0D50 unclassified
        DB $FF,$00,$C0,$17,$00,$C0,$3F,$00,$C0,$7F,$00,$C0 ; ROM $0D5C unclassified
        DB $1F,$00,$80,$1F,$00,$00,$07,$00,$80,$0F,$00,$F8 ; ROM $0D68 unclassified
        DB $3F,$00,$FC,$7F,$00,$CE,$FF,$01,$C6,$FF,$03,$C6 ; ROM $0D74 unclassified
        DB $1F,$17,$C6,$1F,$0E,$C6,$1F,$14,$FA,$3F,$20,$03 ; ROM $0D80 unclassified
        DB $0C,$F0,$3F,$00,$F0,$3F,$00,$E0,$3D,$00,$C0,$79 ; ROM $0D8C unclassified
        DB $00,$C0,$71,$00,$C0,$E1,$00,$C0,$E1,$00,$E0,$60 ; ROM $0D98 unclassified
        DB $00,$70,$70,$00,$34,$34,$00,$38,$38,$00,$F0,$F0 ; ROM $0DA4 unclassified
        DB $00,$03,$0C,$F0,$3F,$00,$E0,$3F,$00,$C0,$1F,$00 ; ROM $0DB0 unclassified
        DB $C0,$1F,$00,$C0,$1F,$00,$C0,$1F,$00,$00,$1E,$00 ; ROM $0DBC unclassified
        DB $00,$1C,$00,$00,$0C,$00,$00,$0D,$00,$00,$0E,$00 ; ROM $0DC8 unclassified
        DB $00,$3C,$00,$03,$0C,$F0,$3F,$00,$F0,$3F,$00,$E0 ; ROM $0DD4 unclassified
        DB $1F,$00,$C0,$0F,$00,$80,$1F,$00,$00,$3E,$00,$C0 ; ROM $0DE0 unclassified
        DB $7C,$00,$E0,$78,$00,$70,$30,$00,$34,$34,$00,$38 ; ROM $0DEC unclassified
        DB $38,$00,$F0,$F0,$00,$03,$20,$04,$00,$00,$19,$02 ; ROM $0DF8 unclassified
        DB $00,$7A,$01,$00,$FC,$00,$00,$7E,$05,$00,$FE,$03 ; ROM $0E04 unclassified
        DB $80,$FC,$03,$40,$FE,$07,$38,$F9,$03,$3E,$F0,$FF ; ROM $0E10 unclassified
        DB $0F,$A0,$FF,$03,$80,$FF,$00,$80,$FF,$00,$C0,$FF ; ROM $0E1C unclassified
        DB $00,$E0,$FF,$00,$E0,$FF,$01,$70,$FF,$03,$30,$FE ; ROM $0E28 unclassified
        DB $07,$30,$FC,$0F,$30,$FE,$0F,$30,$FE,$0F,$30,$F8 ; ROM $0E34 unclassified
        DB $0F,$20,$F0,$07,$00,$F0,$07,$00,$F0,$07,$00,$C0 ; ROM $0E40 unclassified
        DB $07,$00,$80,$07,$00,$00,$07,$00,$00,$03,$00,$40 ; ROM $0E4C unclassified
        DB $03,$00,$80,$03,$00,$00,$0F,$04,$0B,$A0,$00,$00 ; ROM $0E58 unclassified
        DB $00,$B0,$01,$00,$00,$B0,$01,$3C,$00,$B0,$01,$7E ; ROM $0E64 unclassified
        DB $00,$F9,$13,$FF,$00,$FF,$9F,$FF,$81,$F8,$C7,$FF ; ROM $0E70 unclassified
        DB $9F,$FC,$FF,$FF,$FF,$FE,$FF,$FF,$FF,$00,$00,$FF ; ROM $0E7C unclassified
        DB $40,$00,$00,$00,$20,$00,$03,$1C,$00,$7E,$00,$80 ; ROM $0E88 unclassified
        DB $FF,$01,$E0,$FF,$07,$F0,$FF,$0F,$F0,$FF,$0F,$F8 ; ROM $0E94 unclassified
        DB $FF,$1F,$F8,$FF,$1F,$F8,$FF,$1F,$F8,$E7,$1F,$F0 ; ROM $0EA0 unclassified
        DB $C3,$0F,$F0,$81,$0F,$E0,$81,$07,$C0,$81,$03,$80 ; ROM $0EAC unclassified
        DB $C3,$01,$F0,$FF,$0F,$E0,$FF,$07,$E0,$FF,$07,$F4 ; ROM $0EB8 unclassified
        DB $FF,$2F,$84,$3C,$21,$04,$81,$20,$04,$81,$20,$06 ; ROM $0EC4 unclassified
        DB $81,$60,$F7,$FF,$EF,$06,$81,$60,$04,$00,$20,$04 ; ROM $0ED0 unclassified
        DB $00,$20,$04,$00,$20,$04,$00,$20,$4A,$0D,$46,$0C ; ROM $0EDC unclassified
        DB $87,$0C,$C4,$0B,$09,$0D,$05,$0C,$C8,$0C,$86,$22 ; ROM $0EE8 unclassified
        DB $82,$21,$C3,$21,$00,$21,$45,$22,$41,$21,$04,$22 ; ROM $0EF4 unclassified
        DB $06,$1A,$FF,$08,$00,$0C,$FA,$FE,$03,$16,$FD,$02 ; ROM $0F00 unclassified
        DB $01,$14,$13,$28,$74,$0B,$33,$36,$74,$0B,$12,$30 ; ROM $0F0C unclassified
        DB $74,$0B,$32,$36,$8C,$0B,$12,$28,$8C,$0B,$0C,$38 ; ROM $0F18 unclassified
        DB $74,$0B,$0C,$2A,$74,$0B,$0D,$30,$74,$0B,$0C,$2A ; ROM $0F24 unclassified
        DB $8C,$0B,$0C,$38,$8C,$0B,$0F,$30,$74,$0B,$11,$11 ; ROM $0F30 unclassified
        DB $11,$52,$65,$99,$99,$99,$11,$11,$11,$53,$75,$99 ; ROM $0F3C unclassified
        DB $99,$99,$11,$11,$11,$54,$85,$99,$99,$99,$C4,$00 ; ROM $0F48 unclassified
        DB $74,$70,$20,$FF,$A0,$0A,$B4,$00,$00,$8E,$0E,$00 ; ROM $0F54 unclassified
        DB $00,$47,$41,$4B,$45,$40,$40,$40,$40,$4D,$53,$45 ; ROM $0F60 unclassified
        DB $4F,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40 ; ROM $0F6C unclassified
        DB $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40 ; ROM $0F78 unclassified
        DB $40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00,$25 ; ROM $0F84 unclassified
        DB $47,$52,$4C,$40,$46,$49,$47,$48,$51,$49,$4C,$50 ; ROM $0F90 unclassified
        DB $45,$4F,$51,$40,$43,$4D,$49,$4C,$40,$40,$40,$40 ; ROM $0F9C unclassified
        DB $40,$40,$40,$40,$40,$40,$40,$47,$45,$51,$40,$4F ; ROM $0FA8 unclassified
        DB $45,$41,$44,$55,$3A,$3A,$3A,$3A,$3A,$3A,$20,$3A ; ROM $0FB4 unclassified
        DB $3A,$3A,$3A,$3A,$3A,$40,$40,$44,$4F,$41,$54,$3B ; ROM $0FC0 unclassified
        DB $40,$40,$47,$4D,$51,$40,$4B,$45,$3B,$48,$45,$55 ; ROM $0FCC unclassified
        DB $40,$4E,$41,$4F,$44,$4C,$45,$4F,$3B,$2E,$55,$4D ; ROM $0FD8 unclassified
        DB $52,$40,$48,$41,$53,$45,$40,$43,$4F,$45,$44,$49 ; ROM $0FE4 unclassified
        DB $51,$3C,$00,$00,$1A,$4E,$52,$50,$48,$40,$42,$52 ; ROM $0FF0 unclassified
        DB $51,$51,$4D,$4C ; ROM $0FFC unclassified
