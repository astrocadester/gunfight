; Original gunfight Intel 8080 ROM, source reconstructed from original bytes.
; Maintained source: build scripts never regenerate this file.
; Descriptive labels are reverse-engineered, not original DNA symbols.
; Native instruction mnemonics are executable; uncertain regions retain DB.
; Original byte offsets are preserved; zmac v1.3 must rebuild exactly.

        ORG $0000
; Device 7609h.bin, SHA1 99d01313e251818d336281700e206d9003c71dae
; -----------------------------------------------------------------------------
; RESET_ENTRY
; Reset vector; establishes the video RAM stack and enters game initialization.
; Entry: CPU reset. Exit: jump to INITIALIZE_GAME.
; -----------------------------------------------------------------------------
RESET_ENTRY:
        NOP
        NOP
        LD SP,$2400
        JP INITIALIZE_GAME
; -----------------------------------------------------------------------------
; INTERRUPT_VECTOR_08
; Interrupt entry; preserves HL, DE, BC and AF before the shared path.
; Entry: RST $08. Exit: common path at $0087.
; -----------------------------------------------------------------------------
INTERRUPT_VECTOR_08:
        PUSH HL
        PUSH DE
        PUSH BC
        PUSH AF
        JP $0087
        DB $00
; -----------------------------------------------------------------------------
; INTERRUPT_VECTOR_10
; Interrupt entry; preserves registers and updates alternating video-state paths.
; Entry: RST $10. Uses flag at $20B9 and video object state.
; -----------------------------------------------------------------------------
INTERRUPT_VECTOR_10:
        PUSH HL
        PUSH DE
        PUSH BC
        PUSH AF
        LD HL,$20B9
        LD A,(HL)
        CPL
        LD (HL),A
        AND A
        JP M,$00EA
        LD HL,$206F
NATIVE_0021:
        PUSH HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,$0038
NATIVE_0028:
        LD A,(DE)
        INC DE
        LD (HL),A
        INC HL
        LD A,(DE)
        INC DE
        LD (HL),A
        LD A,B
        LD C,$1F
        ADD HL,BC
        DEC B
        AND A
        JP Z,$0028
NATIVE_0038:
        POP HL
        LD DE,$0012
        ADD HL,DE
        LD A,L
        CP $B7
        JP NZ,$0021
        LD HL,$20A2
NATIVE_0046:
        PUSH HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,$0076
        LD A,(DE)
        INC DE
        EX DE,HL
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        EX DE,HL
        OUT ($02),A
NATIVE_0057:
        LD A,(HL)
        LD (DE),A
        INC DE
        LD A,$03
        OUT ($04),A
        IN A,($03)
        OR (HL)
        LD (HL),A
        INC HL
        LD A,(HL)
        LD (DE),A
        INC DE
        XOR A
        OUT ($04),A
        IN A,($03)
        OR (HL)
        LD (HL),A
        LD A,B
        LD C,$1F
        ADD HL,BC
        DEC B
        AND A
        JP Z,$0057
NATIVE_0076:
        POP HL
        LD DE,$FFEE
        ADD HL,DE
        LD A,L
        CP $5A
        JP NZ,$0046
        LD HL,$20B2
        JP $0091
NATIVE_0087:
        LD A,($20B9)
        AND A
        JP M,$0218
        LD HL,$20AB
NATIVE_0091:
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        PUSH DE
        JP Z,$00B4
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        EX DE,HL
        PUSH DE
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        POP DE
        JP Z,$00B4
NATIVE_00A4:
        PUSH HL
        LD C,E
NATIVE_00A6:
        LD (HL),B
        INC HL
        DEC C
        JP NZ,$00A6
        POP HL
        LD C,$20
        ADD HL,BC
        DEC D
        JP NZ,$00A4
NATIVE_00B4:
        POP HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,$0218
        LD A,(DE)
        INC DE
        OUT ($02),A
        PUSH DE
        EX (SP),HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        EX (SP),HL
        LD ($20BA),HL
        LD B,$00
        CALL DRAW_NATIVE_OBJECT_DATA
        EX (SP),HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        EX (SP),HL
        CALL DRAW_NATIVE_OBJECT_DATA
        LD HL,($20BA)
        EX (SP),HL
        INC C
        LD (HL),C
        INC HL
        LD (HL),B
        INC HL
        POP DE
        LD (HL),E
        INC HL
        LD (HL),D
        JP $0218
NATIVE_00EA:
        LD HL,$2063
NATIVE_00ED:
        LD A,(HL)
        AND A
        PUSH HL
        JP P,$0151
        INC HL
        LD A,(HL)
        AND A
        INC HL
        LD A,(HL)
        JP M,$0103
        CP $70
        JP NC,$0108
        JP $0151
NATIVE_0103:
        CP $90
        JP NC,$0151
NATIVE_0108:
        LD DE,$000C
        ADD HL,DE
        LD A,(HL)
        AND A
        JP Z,$0151
        LD DE,$FFF8
        ADD HL,DE
        LD A,(HL)
        SUB $10
        CP $C0
        JP NC,$0151
        POP HL
        PUSH HL
        LD (HL),$A0
        INC HL
        INC HL
        LD A,(HL)
        RRA
        RRA
        RRA
        RRA
        AND $0F
        LD C,A
        INC HL
        INC HL
        INC HL
        INC HL
        LD A,(HL)
        LD ($201D),A
        SUB $10
        RRA
        RRA
        AND $30
        OR C
        RRA
        LD E,A
        LD D,$00
        LD HL,$0F3A
        ADD HL,DE
        LD A,C
        RRA
        LD A,(HL)
        JP NC,$014C
        RRA
        RRA
        RRA
        RRA
NATIVE_014C:
        AND $0F
        LD ($201C),A
NATIVE_0151:
        POP HL
        LD DE,$0012
        ADD HL,DE
        LD A,$AB
        CP L
        JP NZ,$00ED
        LD HL,$2063
NATIVE_015F:
        LD A,(HL)
        AND A
        JP P,$0183
        LD A,$FF
        LD ($20C4),A
        CALL UPDATE_ACTIVE_OBJECT_COORDINATES
        LD A,(HL)
        RLA
        OR $7F
        AND (HL)
        LD (HL),A
        JP P,$0183
        PUSH HL
        LD BC,$0009
        ADD HL,BC
        CALL VIDEO_ADDRESS_FROM_PACKED_COORDINATES
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        LD (HL),C
        POP HL
NATIVE_0183:
        LD BC,$0012
        ADD HL,BC
        LD A,$AB
        CP L
        JP NZ,$015F
        LD HL,($20BE)
        LD A,L
        OR H
        JP NZ,$0198
        LD HL,$202A
NATIVE_0198:
        LD ($20C0),HL
        XOR A
        LD ($20BD),A
NATIVE_019F:
        LD A,(HL)
        AND A
        JP P,$01B1
        CALL UPDATE_ACTIVE_OBJECT_COORDINATES
        LD A,($20BD)
        AND A
        CALL Z,$02C9
        LD ($20BE),HL
NATIVE_01B1:
        LD DE,$0013
        ADD HL,DE
        LD A,$63
        CP L
        JP NZ,$01BE
        LD HL,$202A
NATIVE_01BE:
        LD A,($20C0)
        CP L
        JP NZ,$019F
        LD HL,$2014
        LD A,(HL)
        AND A
        JP Z,$01D4
        DEC (HL)
        JP NZ,$01D4
        XOR A
        OUT ($01),A
NATIVE_01D4:
        LD HL,$2009
        DEC (HL)
        JP P,$0208
        LD (HL),$22
        LD HL,$2004
        LD A,(HL)
        AND A
        JP Z,$01F6
        ADD A,$99
        DAA
        LD (HL),A
        JP NZ,$01F6
        EX DE,HL
        LD HL,$20C4
        INC (HL)
        JP NZ,$039D
        EX DE,HL
        INC (HL)
NATIVE_01F6:
        LD HL,$2003
        LD A,(HL)
        AND A
        JP Z,$0208
        ADD A,$99
        DAA
        LD (HL),A
        JP NZ,$0218
        JP $0214
NATIVE_0208:
        LD HL,$2015
        LD A,(HL)
        AND A
        JP Z,$0218
        DEC (HL)
        JP NZ,$0218
NATIVE_0214:
        LD HL,$20C5
        DEC (HL)
NATIVE_0218:
        IN A,($02)
        LD B,A
        IN A,($02)
        CP B
        LD HL,$2006
        LD DE,$099E
        CALL Z,DISPATCH_INPUT_TRANSITION
        POP AF
        POP BC
        POP DE
        POP HL
        EI
        RET
; -----------------------------------------------------------------------------
; DRAW_NATIVE_OBJECT_DATA
; Render packed object pattern rows through the board shift/readback ports.
; Entry DE=pattern bytes, HL=bitmap destination, B=vertical bias; uses $04 output / $03 input.
; -----------------------------------------------------------------------------
DRAW_NATIVE_OBJECT_DATA:
        LD A,D
        OR E
        RET Z
        LD A,(DE)
        INC DE
        LD C,A
        LD A,(DE)
        ADD A,B
        LD ($20BC),A
        LD A,(DE)
        INC DE
        LD B,A
NATIVE_023B:
        PUSH BC
        PUSH HL
NATIVE_023D:
        LD A,(DE)
        INC DE
        OUT ($04),A
        IN A,($03)
        LD (HL),A
        INC HL
        DEC C
        JP NZ,$023D
        XOR A
        OUT ($04),A
        IN A,($03)
        LD (HL),A
        POP HL
        LD BC,$0020
        ADD HL,BC
        POP BC
        DEC B
        JP NZ,$023B
        LD A,($20BC)
        LD B,A
        RET
; -----------------------------------------------------------------------------
; UPDATE_ACTIVE_OBJECT_COORDINATES
; Update object-state fields and clear active flag when both trajectory components become zero.
; Called by the frame/interrupt update path; helper at $0280 applies per-axis bounds.
; -----------------------------------------------------------------------------
UPDATE_ACTIVE_OBJECT_COORDINATES:
        PUSH HL
        LD A,(HL)
        INC HL
        CALL STEP_OBJECT_AXIS
        LD E,D
        EX (SP),HL
        XOR (HL)
        LD (HL),A
        RRA
        RRA
        EX (SP),HL
        INC HL
        INC HL
        INC HL
        CALL STEP_OBJECT_AXIS
        DEC HL
        LD B,(HL)
        POP HL
        XOR (HL)
        LD (HL),A
        INC HL
        LD A,(HL)
        OR B
        DEC HL
        RET NZ
        LD A,$BF
        AND (HL)
        LD (HL),A
        RET
; -----------------------------------------------------------------------------
; STEP_OBJECT_AXIS
; Advance a compact object-axis record using its speed, direction and limit fields.
; Used by UPDATE_ACTIVE_OBJECT_COORDINATES; handles boundary response.
; -----------------------------------------------------------------------------
STEP_OBJECT_AXIS:
        AND $03
        LD B,A
        LD A,(HL)
        INC HL
        ADD A,(HL)
        LD C,A
        INC HL
        SUB (HL)
        INC HL
        JP C,$0297
        SUB (HL)
        JP NC,$0297
        DEC HL
        DEC HL
        LD (HL),C
NATIVE_0294:
        LD D,(HL)
        XOR A
        RET
NATIVE_0297:
        DEC HL
        DEC HL
        DEC B
        JP NZ,$02A7
        DEC HL
        XOR A
        SUB (HL)
        LD (HL),A
        INC HL
        LD A,$10
        JP $02BA
NATIVE_02A7:
        DEC HL
        LD (HL),$00
        INC HL
        DEC B
        JP NZ,$02B4
        LD A,$60
        JP $02BA
NATIVE_02B4:
        DEC B
        JP NZ,$0294
        LD A,$40
NATIVE_02BA:
        LD D,(HL)
        AND A
        RET
; -----------------------------------------------------------------------------
; TAKE_AND_CLEAR_OBJECT_POINTER
; Remove a little-endian pointer from the field at entry HL, zeroing both bytes.
; Exit HL=old pointer, DE=address immediately after the cleared field; B=0; Z set if pointer was zero.
; -----------------------------------------------------------------------------
TAKE_AND_CLEAR_OBJECT_POINTER:
        XOR A
        LD E,(HL)
        LD (HL),A
        INC HL
        LD D,(HL)
        LD (HL),A
        INC HL
        LD B,A
        LD A,D
        OR E
        EX DE,HL
        RET
NATIVE_02C9:
        PUSH HL
        LD BC,$000F
        ADD HL,BC
        LD B,H
        LD C,L
        CPL
        LD ($20BD),A
        LD A,$60
        CP D
        LD HL,$20AB
        JP NC,$02E0
        LD HL,$20B2
NATIVE_02E0:
        LD (HL),C
        INC HL
        LD (HL),B
        INC HL
        CALL VIDEO_ADDRESS_FROM_PACKED_COORDINATES
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        LD (HL),C
        INC HL
        EX (SP),HL
        LD A,(HL)
        EX DE,HL
        LD HL,$000B
        ADD HL,DE
        EX DE,HL
        EX (SP),HL
        LD (HL),E
        INC HL
        LD (HL),D
        EX DE,HL
        RLA
        RLA
        JP C,$0314
        RLA
        JP C,$033E
        DEC HL
        LD D,(HL)
        DEC HL
        LD E,(HL)
        LD BC,$0004
        LD A,$80
NATIVE_030C:
        ADD HL,BC
        LD (HL),E
        INC HL
        LD (HL),D
        POP HL
        XOR (HL)
        LD (HL),A
        RET
NATIVE_0314:
        POP HL
        LD A,$50
        CP L
        RET Z
        PUSH HL
        LD A,$2A
        CP L
        LD HL,PLAYER_ONE_FRAME_POINTERS
        JP Z,$0326
        LD HL,PLAYER_TWO_FRAME_POINTERS
NATIVE_0326:
        LD A,($2009)
        AND $0C
        RRCA
        ADD A,L
        LD L,A
        JP NC,$0332
        INC H
NATIVE_0332:
        LD E,(HL)
        INC HL
        LD D,(HL)
        POP HL
        PUSH HL
        LD BC,$000D
        XOR A
        JP $030C
NATIVE_033E:
        XOR A
        LD (HL),A
        INC HL
        LD (HL),A
        INC HL
        LD (HL),A
        INC HL
        LD (HL),A
        POP HL
        LD (HL),A
        RET
; Four 16-bit drawing/animation source pointers for each player.
; The state bits at $2009 select one of four entries (index 0,2,4,6).
PLAYER_ONE_FRAME_POINTERS:
        DW $0D8B,$0DB1,$0DD7,$0DB1
PLAYER_TWO_FRAME_POINTERS:
        DW $22C7,$22ED,$2313,$22ED
; -----------------------------------------------------------------------------
; VIDEO_ADDRESS_FROM_PACKED_COORDINATES
; Convert packed pixel coordinates in DE to a bitmap byte address relative to $2400.
; Exit DE=$2400+(entry DE>>3), C=entry E&7; preserves HL, destroys A/B and flags.
; -----------------------------------------------------------------------------
VIDEO_ADDRESS_FROM_PACKED_COORDINATES:
        LD A,E
        AND $07
        LD C,A
        LD B,$03
NATIVE_035F:
        XOR A
        LD A,D
        RRA
        LD D,A
        LD A,E
        RRA
        LD E,A
        DEC B
        JP NZ,$035F
        PUSH HL
        LD HL,$2400
        ADD HL,DE
        EX DE,HL
        POP HL
        RET
; -----------------------------------------------------------------------------
; COPY_SCRIPT_LITERAL_BLOCK
; Common copy helper for indexed words $05 and $06.
; Entry HL=inline source; DE=RAM destination; C=byte count; exit HL past literals, DE past destination.
; -----------------------------------------------------------------------------
COPY_SCRIPT_LITERAL_BLOCK:
        DI
NATIVE_0373:
        LD A,(HL)
        INC HL
        LD (DE),A
        INC DE
        DEC C
        JP NZ,$0373
        RET
; -----------------------------------------------------------------------------
; SELECT_AIM_DESCRIPTOR
; Resolve the selected aim/shot descriptor from a table and active object fields; DE and HL are modified.
; -----------------------------------------------------------------------------
SELECT_AIM_DESCRIPTOR:
        PUSH DE
        LD E,A
        LD D,$00
        ADD HL,DE
        LD A,B
        LD B,(HL)
        INC HL
        LD D,(HL)
        POP HL
        ADD A,(HL)
        LD E,A
        INC HL
        INC HL
        INC HL
        INC HL
        LD A,(HL)
        ADD A,D
        LD D,A
        RET
; -----------------------------------------------------------------------------
; INITIALIZE_GAME
; Clear initial RAM state, clear video, and install the primary script at $0821.
; Entry: reset path; exits through VM dispatch.
; -----------------------------------------------------------------------------
INITIALIZE_GAME:
        LD A,$08
        LD HL,$2002
        LD B,$00
NATIVE_0397:
        LD (HL),B
        INC HL
        DEC A
        JP NZ,$0397
NATIVE_039D:
        CALL CLEAR_BITMAP_DISPLAY
        LD HL,$0821
        LD ($2000),HL
        EI
; -----------------------------------------------------------------------------
; VM_DISPATCH_NEXT
; Fetch indexed command, advance script pointer, and select native vector.
; RAM $2000: script cursor; $20C6: alternative-script selector; table $09AE.
; -----------------------------------------------------------------------------
VM_DISPATCH_NEXT:
        LD HL,($2000)
        LD A,($20C6)
        AND A
        JP Z,$03B4
        LD HL,$089B
NATIVE_03B4:
        LD E,(HL)
        INC HL
        LD ($2000),HL
        LD D,$00
        LD HL,$09AE
        ADD HL,DE
        ADD HL,DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        EX DE,HL
        LD DE,$03A6
        PUSH DE
        JP (HL)
NATIVE_WORD_14_INPUT_EVENT_DISPATCH:
; -----------------------------------------------------------------------------
; VM_INPUT_EVENT_DISPATCH
; Sample controller inputs and dispatch input transitions via action tables.
; I/O: ports $00 and $01; action table $097E; updates game/event state.
; -----------------------------------------------------------------------------
VM_INPUT_EVENT_DISPATCH:
        CALL WAIT_OR_REPEAT_COMMAND
        IN A,($00)
        LD B,A
        IN A,($00)
        CP B
        LD HL,$2017
        LD DE,$097E
        CALL Z,DISPATCH_INPUT_TRANSITION
        IN A,($01)
        LD B,A
        IN A,($01)
        CP B
        LD HL,$2018
        LD DE,$098E
        CALL Z,DISPATCH_INPUT_TRANSITION
        LD HL,$201C
        LD A,(HL)
        AND A
        JP Z,$0404
        LD (HL),$00
        RLCA
        LD E,A
        LD D,$00
        LD HL,$09D6
        ADD HL,DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        EX DE,HL

        ORG $0400
; Device 7609g.bin, SHA1 c177e3f72db9af17ab99b2481448ca26318184b9
        LD ($2000),HL
        RET
NATIVE_0404:
        LD A,($2009)
        CP $22
        CALL P,$05A7
        RET
; -----------------------------------------------------------------------------
; DISPATCH_INPUT_TRANSITION
; Dispatch a selected native input action using the player input tables.
; Called from VM_INPUT_EVENT_DISPATCH; verify exact register contract in next pass.
; -----------------------------------------------------------------------------
DISPATCH_INPUT_TRANSITION:
        XOR (HL)
        RET Z
        LD C,A
        LD B,$01
NATIVE_0412:
        LD A,C
        RRCA
        JP C,$0420
        LD C,A
        LD A,B
        RLCA
        LD B,A
        INC DE
        INC DE
        JP $0412
NATIVE_0420:
        LD A,B
        XOR (HL)
        LD (HL),A
        AND B
        EX DE,HL
        LD C,(HL)
        INC HL
        LD H,(HL)
        LD L,C
        JP (HL)
; -----------------------------------------------------------------------------
; PLAYER_ONE_AIM_ACTION
; Extract player-one input direction from DE and use table $0EE2 to update the object record at $202A.
; A masked input field selects a ROM movement/aim descriptor.
; -----------------------------------------------------------------------------
PLAYER_ONE_AIM_ACTION:
        LD A,(DE)
        AND $70
        RRCA
        RRCA
        RRCA
        AND A
        RET Z
        LD ($201A),A
        LD HL,$0EE2
        LD DE,$202A
        JP INSTALL_AIM_DESCRIPTOR
; -----------------------------------------------------------------------------
; PLAYER_TWO_AIM_ACTION
; Extract player-two input direction from DE and use table $0EF0 to update the object record at $203D.
; Both players share the descriptor selection path at $044F.
; -----------------------------------------------------------------------------
PLAYER_TWO_AIM_ACTION:
        LD A,(DE)
        AND $70
        RRCA
        RRCA
        RRCA
        AND A
        RET Z
        LD ($201B),A
        LD HL,$0EF0
        LD DE,$203D
; -----------------------------------------------------------------------------
; INSTALL_AIM_DESCRIPTOR
; Index the selected player's aim table and copy its 16-bit pointer into object record offset $0B.
; -----------------------------------------------------------------------------
INSTALL_AIM_DESCRIPTOR:
        LD C,A
        LD B,$00
        ADD HL,BC
        LD C,(HL)
        INC HL
        LD B,(HL)
        EX DE,HL
        LD (HL),$C0
        LD DE,$000B
        ADD HL,DE
        LD (HL),C
        INC HL
        LD (HL),B
        RET
NATIVE_0461:
        LD B,$FE
NATIVE_0463:
        JP NZ,$0468
        LD B,$00
NATIVE_0468:
        LD HL,$202A
NATIVE_046B:
        LD (HL),$C0
        LD DE,$0005
        ADD HL,DE
        LD (HL),B
        RET
NATIVE_0473:
        LD B,$02
        JP $0463
NATIVE_0478:
        LD B,$FF
NATIVE_047A:
        JP NZ,$047F
        LD B,$00
NATIVE_047F:
        LD HL,$202A
NATIVE_0482:
        LD (HL),$C0
        INC HL
        LD (HL),B
        RET
NATIVE_0487:
        LD B,$01
        JP $047A
NATIVE_048C:
        LD B,$FE
NATIVE_048E:
        JP NZ,$0493
        LD B,$00
NATIVE_0493:
        LD HL,$203D
        JP $046B
NATIVE_0499:
        LD B,$02
        JP $048E
NATIVE_049E:
        LD B,$FF
NATIVE_04A0:
        JP NZ,$04A5
        LD B,$00
NATIVE_04A5:
        LD HL,$203D
        JP $0482
NATIVE_04AB:
        LD B,$01
        JP $04A0
; -----------------------------------------------------------------------------
; PLAYER_ONE_FIRE_ACTION
; Player-one firing path; checks projectile/object state and updates shot hardware.
; Uses records near $202C and $2063; calls common shot update at $04FA.
; -----------------------------------------------------------------------------
PLAYER_ONE_FIRE_ACTION:
        RET Z
        LD HL,$2063
        LD A,(HL)
        AND $80
        JP Z,$04C1
        LD HL,$2075
        LD A,(HL)
        AND $80
        RET NZ
NATIVE_04C1:
        LD DE,$2012
        LD A,(DE)
        AND A
        RET NZ
        PUSH HL
        EX DE,HL
        LD DE,$3EA2
        LD BC,$2010
        CALL UPDATE_SHOT_STATE
        LD A,$E2
        OUT ($01),A
        LD DE,$202C
        LD BC,$1A08
        LD A,($201A)
NATIVE_04DF:
        LD HL,$0EFE
        CALL SELECT_AIM_DESCRIPTOR
        POP HL
        DI
        LD (HL),$C6
        INC HL
        LD (HL),C
        INC HL
        LD (HL),E
        INC HL
        INC HL
        INC HL
        LD (HL),B
        INC HL
        LD (HL),D
        EI
        LD A,$02
        LD ($2014),A
        RET
; -----------------------------------------------------------------------------
; UPDATE_SHOT_STATE
; Increment the active player's shot count, select the scoreboard number and draw it.
; Entry BC=shot counter address, HL=fire guard address, DE=scoreboard destination; uses $0FA4 character stream.
; -----------------------------------------------------------------------------
UPDATE_SHOT_STATE:
        LD A,(BC)
        INC A
        LD (BC),A
        CP $06
        JP M,$0511
        LD (HL),A
        LD B,A
        LD HL,$2003
        LD A,(HL)
        LD (HL),$11
        AND A
        JP Z,$0510
        LD (HL),$02
NATIVE_0510:
        LD A,B
NATIVE_0511:
        LD HL,$0FA4
        JP DRAW_FORMATTED_TEXT
; -----------------------------------------------------------------------------
; PLAYER_TWO_FIRE_ACTION
; Player-two firing path; checks projectile/object state and updates shot hardware.
; Uses records near $203F and $2087; shares shot-update service.
; -----------------------------------------------------------------------------
PLAYER_TWO_FIRE_ACTION:
        RET Z
        LD HL,$2087
        LD A,(HL)
        AND $80
        JP Z,$0528
        LD HL,$2099
        LD A,(HL)
        AND $80
        RET NZ
NATIVE_0528:
        LD DE,$2013
        LD A,(DE)
        AND A
        RET NZ
        PUSH HL
        EX DE,HL
        LD DE,$3EB8
        LD BC,$2011
        CALL UPDATE_SHOT_STATE
        LD A,$D2
        OUT ($01),A
        LD DE,$203F
        LD BC,$F6F8
        LD A,($201B)
        JP $04DF
; -----------------------------------------------------------------------------
; ADVANCE_ROUND_EVENT_COUNTER
; Handle a native event trigger: set output $01 to $04, advance $2007 and update $2008.
; Uses $2006/$2007 as state/count inputs; alternate exit at $056C.
; -----------------------------------------------------------------------------
ADVANCE_ROUND_EVENT_COUNTER:
        RET Z
        LD A,$04
        LD ($2014),A
        OUT ($01),A
        LD HL,$2007
        INC (HL)
        LD A,($2006)
        LD C,A
        AND $03
        CP (HL)
        RET NC
        LD (HL),$00
        LD A,C
        RRA
        RRA
        AND $03
        INC A
        LD HL,$2008
        ADD A,(HL)
        AND $07
        LD (HL),A
; -----------------------------------------------------------------------------
; UPDATE_ROUND_STATE
; Native input-event action: adjust $2008 when $2004 is clear.
; This address is also reached from the preceding event action.
; -----------------------------------------------------------------------------
UPDATE_ROUND_STATE:
        RET Z
        LD A,($2004)
        AND A
        RET NZ
        LD A,($2008)
        AND A
        RET Z
        DEC A
        LD ($2008),A
        LD B,$60
        LD A,($2006)
        AND $30
        JP Z,$0590
NATIVE_0585:
        LD C,A
        LD A,B
        ADD A,$10
        LD B,A
        LD A,C
        SUB $10
        JP NZ,$0585
NATIVE_0590:
        LD A,B
        LD ($2004),A
        LD HL,$20C6
        DEC (HL)
        LD HL,$2002
        XOR A
        LD (HL),A
        INC HL
        LD (HL),A
        INC HL
        INC HL
        LD (HL),A
        RET
NATIVE_WORD_13_UPDATE_SCORE_TEXT:
; -----------------------------------------------------------------------------
; UPDATE_SCORE_DISPLAY
; Convert score state to display characters and refresh score text.
; Reads score-state RAM; uses formatted display service.
; -----------------------------------------------------------------------------
UPDATE_SCORE_DISPLAY:
        XOR A
        LD ($2003),A
NATIVE_05A7:
        LD C,$04
        LD HL,$201E
        LD DE,$2002
NATIVE_05AF:
        LD A,(DE)
        RRA
        RRA
        RRA
        RRA
        AND $0F
        JP NZ,$05BB
        LD A,$10
NATIVE_05BB:
        ADD A,$30
        LD (HL),A
        INC HL
        LD A,(DE)
        AND $0F
        OR $30
        LD (HL),A
        LD B,$2B
        LD A,C
        CP $03
        JP NZ,$05D6
        LD B,$2C
        LD A,(DE)
        AND A
        JP NZ,$05D6
        LD (HL),$40
NATIVE_05D6:
        INC DE
        INC HL
        LD (HL),B
        INC HL
        DEC C
        JP NZ,$05AF
        LD A,$08
        LD HL,$201E
        LD DE,$2405
        JP DRAW_FORMATTED_TEXT
NATIVE_WORD_01_DRAW_FORMATTED_DATA:
; -----------------------------------------------------------------------------
; DRAW_FORMATTED_DATA
; VM word $01: consume inline format and two little-endian addresses.
; Script operand: format8, source16, destination16.
; -----------------------------------------------------------------------------
DRAW_FORMATTED_DATA:
        LD HL,($2000)
        LD A,(HL)
        INC HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        PUSH DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD ($2000),HL
        POP HL
; -----------------------------------------------------------------------------
; DRAW_FORMATTED_TEXT
; Render A characters from source HL to display address DE; characters below $30 move the destination.
; Character patterns are read at ROM $09F8, ten scanline bytes per glyph; bitmap row stride is $20.
; -----------------------------------------------------------------------------
DRAW_FORMATTED_TEXT:
        PUSH AF
NATIVE_05FC:
        LD A,(HL)
        INC HL
        SUB $30
        JP P,$0614
        LD B,A
NATIVE_0604:
        INC E
        LD A,E
        AND $1F
        JP NZ,$060D
        INC D
        INC D
NATIVE_060D:
        INC B
        JP NZ,$0604
        JP $05FC
NATIVE_0614:
        PUSH HL
        PUSH DE
        LD HL,FONT_SCORE_DIGITS
        JP Z,$0624
        LD BC,$000A
NATIVE_061F:
        ADD HL,BC
        DEC A
        JP NZ,$061F
NATIVE_0624:
        EX DE,HL
        LD BC,$0020
        LD A,$0A
NATIVE_062A:
        PUSH AF
        LD A,(DE)
        INC DE
        LD (HL),A
        ADD HL,BC
        POP AF
        DEC A
        JP NZ,$062A
        POP DE
        POP HL
        INC DE
        POP AF
        DEC A
        JP NZ,DRAW_FORMATTED_TEXT
        RET
NATIVE_WORD_02_SET_RAM_2003:
; -----------------------------------------------------------------------------
; SET_SCORE_STATE_BYTE
; VM word $02: read one byte from the script and store it at RAM $2003; advance the script cursor.
; -----------------------------------------------------------------------------
SET_SCORE_STATE_BYTE:
        LD HL,($2000)
        LD A,(HL)
        INC HL
        LD ($2000),HL
        LD ($2003),A
        RET
NATIVE_WORD_03_SET_RAM_2015:
; -----------------------------------------------------------------------------
; SET_DELAY_STATE_BYTE
; VM word $03: read one byte from the script and store it at RAM $2015; advance the script cursor.
; -----------------------------------------------------------------------------
SET_DELAY_STATE_BYTE:
        LD HL,($2000)
        LD A,(HL)
        INC HL
        LD ($2000),HL
        LD ($2015),A
        RET
NATIVE_WORD_04_CLEAR_DISPLAY:
; -----------------------------------------------------------------------------
; CLEAR_BITMAP_DISPLAY
; VM word $04: clear bitmap display using the 8080 stack-driven display clear.
; Disables interrupts temporarily, switches SP, restores execution.
; -----------------------------------------------------------------------------
CLEAR_BITMAP_DISPLAY:
        DI
        POP HL
        LD BC,$0000
        LD DE,$0000
        LD A,$10
        LD SP,$400F
NATIVE_0662:
        PUSH BC
        INC DE
        CP D
        JP NZ,$0662
        XOR A
        OUT ($01),A
        LD SP,$2400
        EI
        JP (HL)
NATIVE_WORD_07_CLEAR_OBJECT_FLAGS:
; -----------------------------------------------------------------------------
; CLEAR_OBJECT_CONTROL_BITS
; VM word $07: read a RAM address from the script, clear bit 6 at that byte, and zero its following byte.
; -----------------------------------------------------------------------------
CLEAR_OBJECT_CONTROL_BITS:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD ($2000),HL
        LD A,(DE)
        AND $BF
        LD (DE),A
        INC DE
        XOR A
        LD (DE),A
        RET
NATIVE_WORD_09_BRANCH_SCRIPT:
; -----------------------------------------------------------------------------
; JUMP_TO_SCRIPT
; VM word $09: read a 16-bit target from the script and replace the interpreter cursor at $2000.
; -----------------------------------------------------------------------------
JUMP_TO_SCRIPT:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        EX DE,HL
        LD ($2000),HL
        RET
NATIVE_WORD_05_COPY_INLINE_15:
; -----------------------------------------------------------------------------
; COPY_INLINE_15_TO_RAM
; VM word $05: copy fifteen inline bytes to RAM destination.
; Script operands: destination16, 15 literal bytes; helper $0372.
; -----------------------------------------------------------------------------
COPY_INLINE_15_TO_RAM:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD C,$0F
        CALL COPY_SCRIPT_LITERAL_BLOCK
        LD ($2000),HL
        RET
NATIVE_WORD_06_COPY_INLINE_9:
; -----------------------------------------------------------------------------
; COPY_INLINE_9_TO_RAM
; VM word $06: copy nine inline bytes to RAM destination.
; Script operands: destination16, 9 literal bytes; helper $0372.
; -----------------------------------------------------------------------------
COPY_INLINE_9_TO_RAM:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD C,$09
        CALL COPY_SCRIPT_LITERAL_BLOCK
        LD ($2000),HL
        RET
NATIVE_WORD_08_TOGGLE_OBJECT_FLAGS:
; -----------------------------------------------------------------------------
; TOGGLE_OBJECT_CONTROL_BITS
; VM word $08: read a RAM address and XOR bit mask $60 into its first byte.
; -----------------------------------------------------------------------------
TOGGLE_OBJECT_CONTROL_BITS:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD ($2000),HL
        LD A,(DE)
        XOR $60
        LD (DE),A
        RET
NATIVE_WORD_0A_GAME_DISPLAY:
; -----------------------------------------------------------------------------
; RUN_GAME_DISPLAY_SEQUENCE
; VM word $0A: use status state to select native graphic object drawing.
; Calls DRAW_NATIVE_OBJECT_DATA; uses $2016 state and output port $02.
; -----------------------------------------------------------------------------
RUN_GAME_DISPLAY_SEQUENCE:
        LD HL,$0F0E
        XOR A
        OUT ($02),A
        LD A,($2002)
NATIVE_06C5:
        DEC A
        JP M,$06EB
        CP $02
        CALL P,$0719
        CP $05
        JP M,$06D5
        LD A,$04
NATIVE_06D5:
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        PUSH DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD B,$00
        EX (SP),HL
        PUSH AF
        CALL DRAW_NATIVE_OBJECT_DATA
        POP AF
        POP HL
        DEC A
        JP P,$06D5
NATIVE_06EB:
        LD A,($2016)
        LD B,A
        AND $80
        JP NZ,$0703
        LD A,B
        OR $80
        LD ($2016),A
        LD HL,$0F22
        LD A,($2005)
        JP $06C5
NATIVE_0703:
        LD A,($2016)
        AND $40
        RET NZ
        OR $40
        LD ($2016),A
        LD A,$04
        OUT ($02),A
        XOR A
        LD HL,$0F36
        JP $06D5
NATIVE_0719:
        PUSH HL
        PUSH AF
        LD HL,$2050
        LD A,(HL)
        AND $80
        JP NZ,$072D
        EX DE,HL
        LD C,$0F
        LD HL,$0F52
        CALL COPY_SCRIPT_LITERAL_BLOCK
NATIVE_072D:
        LD A,($2016)
        OR $40
        LD ($2016),A
        POP AF
        POP HL
        RET
NATIVE_WORD_0C_BCD_INCREMENT_INIT:
; -----------------------------------------------------------------------------
; INCREMENT_BCD_AND_INIT
; VM word $0C: packed-decimal increment, then object initialization.
; Uses DAA; falls through to VM word $0B.
; -----------------------------------------------------------------------------
INCREMENT_BCD_AND_INIT:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD ($2000),HL
        LD A,(DE)
        INC A
        DAA
        LD (DE),A
        CALL UPDATE_SCORE_DISPLAY
NATIVE_WORD_0B_INIT_OBJECT:
; -----------------------------------------------------------------------------
; INITIALIZE_OBJECT_RECORD
; VM word $0B: initialize a game-object descriptor from inline operands.
; Updates RAM object records and their metadata.
; -----------------------------------------------------------------------------
INITIALIZE_OBJECT_RECORD:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        DI
        LD A,$80
        LD (DE),A
        INC DE
        INC DE
        LD A,(HL)
        INC HL
        LD (DE),A
        INC DE
        INC DE
        INC DE
        INC DE
        LD A,(DE)
        ADD A,$08
        LD (DE),A
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD ($2000),HL
        INC DE
        INC DE
        INC DE
        EX DE,HL
        LD (HL),C
        INC HL
        LD (HL),B
        INC HL
        XOR A
        LD (HL),A
        INC HL
        LD (HL),A
        RET
NATIVE_WORD_0D_SET_OUTPUT_AND_RAM:
; -----------------------------------------------------------------------------
; WRITE_OUTPUT_AND_MODE
; VM word $0D: read output and state bytes, OUT the first to port $01, store second at $2014.
; -----------------------------------------------------------------------------
WRITE_OUTPUT_AND_MODE:
        LD HL,($2000)
        LD A,(HL)
        OUT ($01),A
        INC HL
        LD A,(HL)
        INC HL
        LD ($2000),HL
        LD ($2014),A
NATIVE_0784:
        RET
NATIVE_WORD_0E_FILL_RECTANGLE:
; -----------------------------------------------------------------------------
; FILL_DISPLAY_RECTANGLE
; VM word $0E: consume a packed dimension word and fill a display rectangle.
; Uses $201D, packed coordinate conversion, and 32-byte display stride.
; -----------------------------------------------------------------------------
FILL_DISPLAY_RECTANGLE:
        LD HL,($2000)
        LD A,($201D)
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD ($2000),HL
        SUB D
        LD L,$02
        LD H,A
        CALL VIDEO_ADDRESS_FROM_PACKED_COORDINATES
        EX DE,HL
NATIVE_079A:
        PUSH HL
        LD C,E
NATIVE_079C:
        LD (HL),B
        INC HL
        DEC C
        JP NZ,$079C
        POP HL
        LD C,$20
        ADD HL,BC
        DEC D
        JP NZ,$079A
        RET
NATIVE_WORD_0F_EXPAND_GRAPHICS:
; -----------------------------------------------------------------------------
; EXPAND_PACKED_GRAPHICS
; VM word $0F: transform packed ROM graphics into RAM starting at $2100.
; Source table begins at $0BC4.
; -----------------------------------------------------------------------------
EXPAND_PACKED_GRAPHICS:
        LD HL,$2100
        LD DE,$0BC4
NATIVE_07B1:
        LD A,(DE)
        AND A
        RET Z
        LD (HL),A
        INC HL
        INC DE
        LD C,A
        LD A,(DE)
        INC DE
        LD B,A
        LD (HL),A
        INC HL
NATIVE_07BD:
        PUSH BC
        LD A,B
        LD B,$00
        ADD HL,BC
        LD B,A
NATIVE_07C3:
        DEC HL
        LD A,(DE)
        INC DE
        PUSH DE
        LD D,A
        LD E,$00
        LD B,$08
NATIVE_07CC:
        LD A,D
        RRA
        LD D,A
        LD A,E
        RLA
        LD E,A
        DEC B
        JP NZ,$07CC
        LD (HL),E
        POP DE
        DEC C
        JP NZ,$07C3
        POP BC
        LD A,B
        LD B,$00
        ADD HL,BC
        LD B,A
        DEC B
        JP NZ,$07BD
        JP $07B1
NATIVE_WORD_11_DRAW_STATUS_A:
; -----------------------------------------------------------------------------
; DRAW_SECOND_PLAYER_STATUS
; VM word $11: select status record at $203F and branch to the shared text drawing path.
; -----------------------------------------------------------------------------
DRAW_SECOND_PLAYER_STATUS:
        LD HL,$203F
        JP $07F2
NATIVE_WORD_12_DRAW_STATUS_B:
; -----------------------------------------------------------------------------
; DRAW_FIRST_PLAYER_STATUS
; VM word $12: select status record at $202C and use the shared status drawing path.
; -----------------------------------------------------------------------------
DRAW_FIRST_PLAYER_STATUS:
        LD HL,$202C
NATIVE_07F2:
        LD E,(HL)
        LD BC,$0004
        ADD HL,BC
        LD D,(HL)
        CALL VIDEO_ADDRESS_FROM_PACKED_COORDINATES
        DEC DE
        DEC D
        DEC D
        DEC D
        DB $21

        ORG $0800
; Device 7609f.bin, SHA1 215b068663e431582591001cbe028929fa96d49f
        DB $CE,$0F
        LD A,$07
        JP DRAW_FORMATTED_TEXT
NATIVE_WORD_10_BRANCH_IF_STATE:
; -----------------------------------------------------------------------------
; BRANCH_TO_ALTERNATE_SCENE
; VM word $10: redirect script to $0882 when $2008 is active.
; Conditional script pointer replacement.
; -----------------------------------------------------------------------------
BRANCH_TO_ALTERNATE_SCENE:
        LD A,($2008)
        AND A
        RET Z
        LD HL,$0882
        LD ($2000),HL
        RET
NATIVE_WORD_00_WAIT_REPEAT:
; -----------------------------------------------------------------------------
; WAIT_OR_REPEAT_COMMAND
; VM word $00: repeat current command until its timer condition completes.
; Counter $20C5; may decrement script pointer $2000.
; -----------------------------------------------------------------------------
WAIT_OR_REPEAT_COMMAND:
        LD HL,$20C5
        INC (HL)
        RET Z
        DEC (HL)
        LD HL,($2000)
        DEC HL
        LD ($2000),HL
        RET
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
        DW PLAYER_ONE_FIRE_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $098C
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
        DW PLAYER_TWO_FIRE_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $099C
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
        DW WAIT_OR_REPEAT_COMMAND ; GAME_WORD pointer from ROM $09AE
ROM_GAME_WORD_01:
        DW DRAW_FORMATTED_DATA ; GAME_WORD pointer from ROM $09B0
ROM_GAME_WORD_02:
        DW SET_SCORE_STATE_BYTE ; GAME_WORD pointer from ROM $09B2
ROM_GAME_WORD_03:
        DW SET_DELAY_STATE_BYTE ; GAME_WORD pointer from ROM $09B4
ROM_GAME_WORD_04:
        DW CLEAR_BITMAP_DISPLAY ; GAME_WORD pointer from ROM $09B6
ROM_GAME_WORD_05:
        DW COPY_INLINE_15_TO_RAM ; GAME_WORD pointer from ROM $09B8
ROM_GAME_WORD_06:
        DW COPY_INLINE_9_TO_RAM ; GAME_WORD pointer from ROM $09BA
ROM_GAME_WORD_07:
        DW CLEAR_OBJECT_CONTROL_BITS ; GAME_WORD pointer from ROM $09BC
ROM_GAME_WORD_08:
        DW TOGGLE_OBJECT_CONTROL_BITS ; GAME_WORD pointer from ROM $09BE
ROM_GAME_WORD_09:
        DW JUMP_TO_SCRIPT ; GAME_WORD pointer from ROM $09C0
ROM_GAME_WORD_0A:
        DW $06BC ; GAME_WORD pointer from ROM $09C2
ROM_GAME_WORD_0B:
        DW INITIALIZE_OBJECT_RECORD ; GAME_WORD pointer from ROM $09C4
ROM_GAME_WORD_0C:
        DW INCREMENT_BCD_AND_INIT ; GAME_WORD pointer from ROM $09C6
ROM_GAME_WORD_0D:
        DW WRITE_OUTPUT_AND_MODE ; GAME_WORD pointer from ROM $09C8
ROM_GAME_WORD_0E:
        DW $0785 ; GAME_WORD pointer from ROM $09CA
ROM_GAME_WORD_0F:
        DW EXPAND_PACKED_GRAPHICS ; GAME_WORD pointer from ROM $09CC
ROM_GAME_WORD_10:
        DW BRANCH_TO_ALTERNATE_SCENE ; GAME_WORD pointer from ROM $09CE
ROM_GAME_WORD_11:
        DW DRAW_SECOND_PLAYER_STATUS ; GAME_WORD pointer from ROM $09D0
ROM_GAME_WORD_12:
        DW DRAW_FIRST_PLAYER_STATUS ; GAME_WORD pointer from ROM $09D2
ROM_GAME_WORD_13:
        DW UPDATE_SCORE_DISPLAY ; GAME_WORD pointer from ROM $09D4
ROM_GAME_WORD_14:
        DW VM_INPUT_EVENT_DISPATCH ; GAME_WORD pointer from ROM $09D6
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
; -----------------------------------------------------------------------------
; Score font at $09F8: ten 10-row digit glyphs ($30 to $39).
; DRAW_FORMATTED_TEXT indexes these patterns by character value minus $30.
; Each source byte is one horizontal eight-pixel row, rendered vertically
; with 32-byte destination stride. '#' is a set bit, '.' is a clear bit.
; -----------------------------------------------------------------------------
        DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; preceding padding
FONT_SCORE_DIGITS:
        ; digit 0
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
        ; digit 1
        DB $18 ; ...##...
        DB $1C ; ...###..
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $3C ; ..####..
        DB $3C ; ..####..
        ; digit 2
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $60 ; .##.....
        DB $7C ; .#####..
        DB $3E ; ..#####.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $7E ; .######.
        DB $7E ; .######.
        ; digit 3
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $60 ; .##.....
        DB $38 ; ..###...
        DB $78 ; .####...
        DB $60 ; .##.....
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
        ; digit 4
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $7E ; .######.
        DB $60 ; .##.....
        DB $60 ; .##.....
        DB $60 ; .##.....
        DB $60 ; .##.....
        ; digit 5
        DB $3E ; ..#####.
        DB $3E ; ..#####.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $60 ; .##.....
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
        ; digit 6
        DB $3C ; ..####..
        DB $3E ; ..#####.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
        ; digit 7
        DB $7E ; .######.
        DB $7E ; .######.
        DB $60 ; .##.....
        DB $70 ; .###....
        DB $30 ; ..##....
        DB $38 ; ..###...
        DB $18 ; ...##...
        DB $1C ; ...###..
        DB $0C ; ....##..
        DB $0C ; ....##..
        ; digit 8
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
        ; digit 9
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $7C ; .#####..
        DB $60 ; .##.....
        DB $60 ; .##.....
        DB $7C ; .#####..
        DB $3C ; ..####..
        DB $10,$38,$38,$38,$38,$38 ; next graphic data
        DB $38,$38,$38,$7C,$C0,$C0,$C0,$C0,$C0,$C0,$00,$00
        DB $C0,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$C0,$C0
        DB $00,$00,$00,$20,$40,$FF,$40,$20,$00,$00,$F0,$C0
        DB $A0,$90,$08,$04,$02,$01,$00,$00,$78,$FC,$CC,$E0
        DB $70,$30,$30,$00,$30,$30,$00,$00,$00,$00,$00,$00
        DB $00,$00,$00,$00,$18,$3C,$7E,$66,$66,$66,$7E,$7E
        DB $66,$66,$3E,$7E,$66,$66,$3E,$7E,$66,$66,$7E,$3E
        DB $3C,$7E,$66,$06,$06,$06,$06,$66,$7E,$3C,$3E,$7E
        DB $66,$66,$66,$66,$66,$66,$7E,$3E,$7E,$7E,$06,$06
        DB $3E,$3E,$06,$06,$7E,$7E,$7E,$7E,$06,$06,$3E,$3E
        DB $06,$06,$06,$06,$3C,$7E,$66,$06,$06,$76,$76,$66
        DB $7E,$3C,$66,$66,$66,$66,$7E,$7E,$66,$66,$66,$66
        DB $3C,$3C,$18,$18,$18,$18,$18,$18,$3C,$3C,$06,$06
        DB $06,$06,$06,$06,$06,$06,$7E,$7E,$C3,$C3,$E7,$E7
        DB $FF,$FF,$DB,$C3,$C3,$C3,$66,$66,$6E,$6E,$7E,$7E
        DB $76,$76,$66,$66,$3C,$7E,$66,$66,$66,$66,$66,$66
        DB $7E,$3C,$3E,$7E,$66,$66,$7E,$3E,$06,$06,$06,$06
        DB $3E,$7E,$66,$66,$7E,$3E,$76,$66,$66,$66,$3C,$7E
        DB $66,$06,$3E,$7C,$60,$66,$7E,$3C,$7E,$7E,$18,$18
        DB $18,$18,$18,$18,$18,$18,$66,$66,$66,$66,$66,$66
        DB $66,$66,$7E,$3C,$66,$66,$66,$66,$66,$7E,$3C,$3C
        DB $18,$18,$C3,$C3,$C3,$DB,$FF,$FF,$E7,$E7,$C3,$C3
        DB $66,$66,$7E,$3C,$18,$18,$18,$18,$18,$18,$01,$16
        DB $10,$18,$18,$18,$18,$58,$78,$1B,$1A,$1E,$1E,$98
        DB $98,$78,$38,$18,$18,$18,$18,$18,$18,$18,$02,$1B
        DB $00,$01,$00,$03,$80,$03,$C0,$07,$C0,$07,$60,$1D
        DB $00,$31,$80,$07,$E0,$1F,$F0,$3D,$38,$39,$04,$41
        DB $80,$03,$C0,$07,$E0,$0F,$F8,$1F,$3E,$29,$07,$E9
        DB $00,$01,$00,$09,$00,$05,$00,$05,$08,$1F,$38,$1B
        DB $38,$29,$CC,$37,$FE,$5D,$03,$15,$00,$05,$00,$80
        DB $0D,$00,$80,$0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8
        ; Packed bits, successive 3-byte groups (raw MSB-to-LSB preview):
        ; ....##.# ........ #.......
        ; ....##.# ........ #.......
        ; ....#### ........ ##..#...
        ; #..##### ........ #####...
        DB $FF,$00,$C0,$17,$80,$C0,$3F,$50,$C0,$7F,$60,$C0
        DB $1F,$30,$80,$1F,$38,$00,$07,$1C,$80,$0F,$0E,$F8
        DB $FF,$07,$FC,$FF,$03,$CE,$FF,$01,$C6,$1F,$00,$C6
        DB $1F,$00,$C6,$1F,$00,$C6

        ORG $0C00
; Device 7609e.bin, SHA1 de3f2e6841122bbe6e2fda5b87d37842c072289a
; Packed graphics and table data; original pixel bytes are shown in ROM order.
        DB $1F,$00,$FA,$3F,$00,$03,$15,$00,$05,$00,$80,$0D
        DB $00,$80,$0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8,$FF
        DB $00,$C0,$17,$00,$C0,$3F,$00,$C0,$7F,$00,$C0,$1F
        DB $C0,$80,$1F,$70,$00,$07,$3C,$80,$0F,$0F,$F8,$FF
        DB $03,$FC,$FF,$01,$CE,$FF,$00,$C6,$1F,$00,$C6,$1F
        DB $00,$C6,$1F,$00,$C6,$1F,$00,$FA,$3F,$00,$03,$15
        DB $00,$05,$00,$80,$0D,$00,$80,$0D,$00,$80,$0F,$00
        DB $C8,$9F,$00,$F8,$FF,$00,$C0,$17,$00,$C0,$3F,$00
        DB $C0,$7F,$00,$C0,$1F,$00,$80,$1F,$C0,$00,$07,$38
        DB $80,$0F,$0C,$F8,$FF,$0F,$FC,$FF,$03,$CE,$7F,$00
        DB $C6,$1F,$00,$C6,$1F,$00,$C6,$1F,$00,$C6,$1F,$00
        DB $FA,$3F,$00,$03,$15,$00,$05,$00,$80,$0D,$00,$80
        DB $0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8,$FF,$00,$C0
        DB $17,$00,$C0,$3F,$00,$C0,$7F,$00,$C0,$1F,$00,$80
        DB $1F,$00,$00,$07,$08,$80,$0F,$F0,$F8,$FF,$1F,$FC
        DB $FF,$0F,$CE,$FF,$00,$C6,$1F,$00,$C6,$1F,$00,$C6
        DB $1F,$00,$C6,$1F,$00,$FA,$3F,$00,$03,$15,$00,$05
        DB $00,$80,$0D,$00,$80,$0D,$00,$80,$0F,$00,$C8,$9F
        DB $00,$F8,$FF,$00,$C0,$17,$00,$C0,$3F,$00,$C0,$7F
        DB $00,$C0,$1F,$00,$80,$1F,$00,$00,$07,$00,$80,$0F
        DB $00,$F8,$3F,$00,$FC,$FF,$01,$CE,$FF,$0F,$C6,$1F
        DB $7F,$C6,$1F,$00,$C6,$1F,$00,$C6,$1F,$00,$FA,$3F
        DB $00,$03,$15,$00,$05,$00,$80,$0D,$00,$80,$0D,$00
PACKED_GRAPHICS_BITSTREAM:
        DB $80,$0F,$00,$C8,$9F,$00,$F8,$FF,$00,$C0,$17,$00
        DB $C0,$3F,$00,$C0,$7F,$00,$C0,$1F,$00,$80,$1F,$00
        DB $00,$07,$00,$80,$0F,$00,$F8,$3F,$00,$FC,$FF,$00
        DB $CE,$FF,$01,$C6,$FF,$07,$C6,$1F,$1E,$C6,$1F,$70
        DB $C6,$1F,$00,$FA,$3F,$00,$03,$15,$00,$05,$00,$80
        DB $0D,$00,$80,$0D,$00,$80,$0F,$00,$C8,$9F,$00,$F8
        DB $FF,$00,$C0,$17,$00,$C0,$3F,$00,$C0,$7F,$00,$C0
        DB $1F,$00,$80,$1F,$00,$00,$07,$00,$80,$0F,$00,$F8
        DB $3F,$00,$FC,$7F,$00,$CE,$FF,$01,$C6,$FF,$03,$C6
        DB $1F,$17,$C6,$1F,$0E,$C6,$1F,$14,$FA,$3F,$20

; -----------------------------------------------------------------------------
; ROM_FRAME_PATTERN_A: 24 stored bits per row, 12 rows.
; Header bytes: width=3 bytes, height=12 rows, as used by DRAW_NATIVE_OBJECT_DATA.
; Bit previews follow ROM MSB-first order; screen orientation is hardware-dependent.
; -----------------------------------------------------------------------------
ROM_FRAME_PATTERN_A:
        DB $03,$0C ; width in bytes, height in rows
        DB $F0,$3F,$00 ; ####.... ..###### ........
        DB $F0,$3F,$00 ; ####.... ..###### ........
        DB $E0,$3D,$00 ; ###..... ..####.# ........
        DB $C0,$79,$00 ; ##...... .####..# ........
        DB $C0,$71,$00 ; ##...... .###...# ........
        DB $C0,$E1,$00 ; ##...... ###....# ........
        DB $C0,$E1,$00 ; ##...... ###....# ........
        DB $E0,$60,$00 ; ###..... .##..... ........
        DB $70,$70,$00 ; .###.... .###.... ........
        DB $34,$34,$00 ; ..##.#.. ..##.#.. ........
        DB $38,$38,$00 ; ..###... ..###... ........
        DB $F0,$F0,$00 ; ####.... ####.... ........

; -----------------------------------------------------------------------------
; ROM_FRAME_PATTERN_B: 24 stored bits per row, 12 rows.
; Header bytes: width=3 bytes, height=12 rows, as used by DRAW_NATIVE_OBJECT_DATA.
; Bit previews follow ROM MSB-first order; screen orientation is hardware-dependent.
; -----------------------------------------------------------------------------
ROM_FRAME_PATTERN_B:
        DB $03,$0C ; width in bytes, height in rows
        DB $F0,$3F,$00 ; ####.... ..###### ........
        DB $E0,$3F,$00 ; ###..... ..###### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $00,$1E,$00 ; ........ ...####. ........
        DB $00,$1C,$00 ; ........ ...###.. ........
        DB $00,$0C,$00 ; ........ ....##.. ........
        DB $00,$0D,$00 ; ........ ....##.# ........
        DB $00,$0E,$00 ; ........ ....###. ........
        DB $00,$3C,$00 ; ........ ..####.. ........

; -----------------------------------------------------------------------------
; ROM_FRAME_PATTERN_C: 24 stored bits per row, 12 rows.
; Header bytes: width=3 bytes, height=12 rows, as used by DRAW_NATIVE_OBJECT_DATA.
; Bit previews follow ROM MSB-first order; screen orientation is hardware-dependent.
; -----------------------------------------------------------------------------
ROM_FRAME_PATTERN_C:
        DB $03,$0C ; width in bytes, height in rows
        DB $F0,$3F,$00 ; ####.... ..###### ........
        DB $F0,$3F,$00 ; ####.... ..###### ........
        DB $E0,$1F,$00 ; ###..... ...##### ........
        DB $C0,$0F,$00 ; ##...... ....#### ........
        DB $80,$1F,$00 ; #....... ...##### ........
        DB $00,$3E,$00 ; ........ ..#####. ........
        DB $C0,$7C,$00 ; ##...... .#####.. ........
        DB $E0,$78,$00 ; ###..... .####... ........
        DB $70,$30,$00 ; .###.... ..##.... ........
        DB $34,$34,$00 ; ..##.#.. ..##.#.. ........
        DB $38,$38,$00 ; ..###... ..###... ........
        DB $F0,$F0,$00 ; ####.... ####.... ........

; -----------------------------------------------------------------------------
; ROM_OBJECT_PATTERN_32_ROWS: 24 stored bits per row, 32 rows.
; Header bytes: width=3 bytes, height=32 rows, as used by DRAW_NATIVE_OBJECT_DATA.
; Bit previews follow ROM MSB-first order; screen orientation is hardware-dependent.
; -----------------------------------------------------------------------------
ROM_OBJECT_PATTERN_32_ROWS:
        DB $03,$20 ; width in bytes, height in rows
        DB $04,$00,$00 ; .....#.. ........ ........
        DB $19,$02,$00 ; ...##..# ......#. ........
        DB $7A,$01,$00 ; .####.#. .......# ........
        DB $FC,$00,$00 ; ######.. ........ ........
        DB $7E,$05,$00 ; .######. .....#.# ........
        DB $FE,$03,$80 ; #######. ......## #.......
        DB $FC,$03,$40 ; ######.. ......## .#......
        DB $FE,$07,$38 ; #######. .....### ..###...
        DB $F9,$03,$3E ; #####..# ......## ..#####.
        DB $F0,$FF,$0F ; ####.... ######## ....####
        DB $A0,$FF,$03 ; #.#..... ######## ......##
        DB $80,$FF,$00 ; #....... ######## ........
        DB $80,$FF,$00 ; #....... ######## ........
        DB $C0,$FF,$00 ; ##...... ######## ........
        DB $E0,$FF,$00 ; ###..... ######## ........
        DB $E0,$FF,$01 ; ###..... ######## .......#
        DB $70,$FF,$03 ; .###.... ######## ......##
        DB $30,$FE,$07 ; ..##.... #######. .....###
        DB $30,$FC,$0F ; ..##.... ######.. ....####
        DB $30,$FE,$0F ; ..##.... #######. ....####
        DB $30,$FE,$0F ; ..##.... #######. ....####
        DB $30,$F8,$0F ; ..##.... #####... ....####
        DB $20,$F0,$07 ; ..#..... ####.... .....###
        DB $00,$F0,$07 ; ........ ####.... .....###
        DB $00,$F0,$07 ; ........ ####.... .....###
        DB $00,$C0,$07 ; ........ ##...... .....###
        DB $00,$80,$07 ; ........ #....... .....###
        DB $00,$00,$07 ; ........ ........ .....###
        DB $00,$00,$03 ; ........ ........ ......##
        DB $00,$40,$03 ; ........ .#...... ......##
        DB $00,$80,$03 ; ........ #....... ......##
        DB $00,$00,$0F ; ........ ........ ....####
        DB $04,$0B,$A0,$00,$00,$00,$B0,$01,$00,$00,$B0,$01
        DB $3C,$00,$B0,$01,$7E,$00,$F9,$13,$FF,$00,$FF,$9F
        DB $FF,$81,$F8,$C7,$FF,$9F,$FC,$FF,$FF,$FF,$FE,$FF
        DB $FF,$FF,$00,$00,$FF,$40,$00,$00,$00,$20,$00,$03
        DB $1C,$00,$7E,$00,$80,$FF,$01,$E0,$FF,$07,$F0,$FF
        DB $0F,$F0,$FF,$0F,$F8,$FF,$1F,$F8,$FF,$1F,$F8,$FF
        DB $1F,$F8,$E7,$1F,$F0,$C3,$0F,$F0,$81,$0F,$E0,$81
        DB $07,$C0,$81,$03,$80,$C3,$01,$F0,$FF,$0F,$E0,$FF
        DB $07,$E0,$FF,$07,$F4,$FF,$2F,$84,$3C,$21,$04,$81
        DB $20,$04,$81,$20,$06,$81,$60,$F7,$FF,$EF,$06,$81
        DB $60,$04,$00,$20,$04,$00,$20,$04,$00,$20,$04,$00
        DB $20,$4A,$0D,$46,$0C,$87,$0C,$C4,$0B,$09,$0D,$05
        DB $0C,$C8,$0C,$86,$22,$82,$21,$C3,$21,$00,$21,$45
        DB $22,$41,$21,$04,$22,$06,$1A,$FF,$08,$00,$0C,$FA
        DB $FE,$03,$16,$FD,$02,$01,$14,$13,$28,$74,$0B,$33
        DB $36,$74,$0B,$12,$30,$74,$0B,$32,$36,$8C,$0B,$12
        DB $28,$8C,$0B,$0C,$38,$74,$0B,$0C,$2A,$74,$0B,$0D
        DB $30,$74,$0B,$0C,$2A,$8C,$0B,$0C,$38,$8C,$0B,$0F
        DB $30,$74,$0B,$11,$11,$11,$52,$65,$99,$99,$99,$11
        DB $11,$11,$53,$75,$99,$99,$99,$11,$11,$11,$54,$85
        DB $99,$99,$99,$C4,$00,$74,$70,$20,$FF,$A0,$0A,$B4
        DB $00,$00,$8E,$0E,$00,$00,$47,$41,$4B,$45,$40,$40
        DB $40,$40,$4D,$53,$45,$4F,$40,$40,$40,$40,$40,$40
        DB $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
        DB $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
        DB $40,$40,$00,$00,$25,$47,$52,$4C,$40,$46,$49,$47
        DB $48,$51,$49,$4C,$50,$45,$4F,$51,$40,$43,$4D,$49
        DB $4C,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
        DB $47,$45,$51,$40,$4F,$45,$41,$44,$55,$3A,$3A,$3A
        DB $3A,$3A,$3A,$20,$3A,$3A,$3A,$3A,$3A,$3A,$40,$40
        DB $44,$4F,$41,$54,$3B,$40,$40,$47,$4D,$51,$40,$4B
        DB $45,$3B,$48,$45,$55,$40,$4E,$41,$4F,$44,$4C,$45
        DB $4F,$3B,$2E,$55,$4D,$52,$40,$48,$41,$53,$45,$40
        DB $43,$4F,$45,$44,$49,$51,$3C,$00,$00,$1A,$4E,$52
        DB $50,$48,$40,$42,$52,$51,$51,$4D,$4C
