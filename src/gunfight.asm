;*******************************************************************************
; GUN FIGHT (1975)
;*******************************************************************************
; Two-player western shoot-out for Midway Intel 8080 arcade hardware.
;
; Developer : Dave Nutting Associates (DNA)
; Publisher : Midway Manufacturing
; CPU       : Intel 8080
; Software  : Native 8080 routines and 21-word game-command interpreter
;
; ROM       : 7609h.bin / 7609g.bin / 7609f.bin / 7609e.bin
; Build     : Project zmac v1.3; four original 1 KB ROM devices
;
; The source reconstructs the original ROM. Descriptive symbols are
; reverse-engineered names, not asserted original DNA source identifiers.
; Script commands, native vectors and packed graphics retain ROM byte order.
; The maintained ASM is assembled directly; no generator rewrites it.
;*******************************************************************************

; -----------------------------------------------------------------------------
; GF-RE-002: projectile and event RAM addresses used by native 8080 code.
; EQU aliases allocate no ROM or RAM bytes. Each projectile slot is $12
; bytes; the four entries are two slots per player.
; -----------------------------------------------------------------------------
PROJECTILE_P1_SLOT_0      EQU $2063
PROJECTILE_P1_SLOT_1      EQU $2075
PROJECTILE_P2_SLOT_0      EQU $2087
PROJECTILE_P2_SLOT_1      EQU $2099
PROJECTILE_P1_FIRE_GUARD  EQU $2012
PROJECTILE_P2_FIRE_GUARD  EQU $2013
PLAYER_ONE_SHOT_COUNT     EQU $2010
PLAYER_TWO_SHOT_COUNT     EQU $2011
PROJECTILE_EVENT_SELECTOR EQU $201C
PROJECTILE_EVENT_CONTEXT  EQU $201D
PROJECTILE_OUTPUT_TIMER   EQU $2014

        ORG $0000

; Device 7609h.bin, SHA1 99d01313e251818d336281700e206d9003c71dae
; -----------------------------------------------------------------------------
; RESET_ENTRY
; Reset vector; establishes the video RAM stack and enters game
; initialization.
; Entry: CPU reset. Exit: jump to INITIALIZE_GAME.
; -----------------------------------------------------------------------------
RESET_ENTRY:
        NOP
        NOP
        LD SP,$2400
        JP INITIALIZE_GAME

; -----------------------------------------------------------------------------
; INTERRUPT_VECTOR_08
; Entry: interrupt at $0008. Save HL/DE/BC/AF before entering common
; pending-video-job service at IRQ_RESUME_COMMON_FRAME_PATH.
; The common exit at IRQ_SAMPLE_PORT2_AND_RESTORE pops all four registers,
; enables interrupts and returns to interrupted execution.
; -----------------------------------------------------------------------------
INTERRUPT_VECTOR_08:
        PUSH HL
        PUSH DE
        PUSH BC
        PUSH AF
        JP IRQ_RESUME_COMMON_FRAME_PATH
        DB $00

; -----------------------------------------------------------------------------
; INTERRUPT_VECTOR_10
; Entry: interrupt at $0010; save HL/DE/BC/AF.
; Complement $20B9 to alternate service phases. One phase traverses two
; pending bitmap queues ($206F.. and $20A2..); the other scans projectile
; slots at $2063, updates moving objects and round/frame counters.
; Both phases converge at IRQ_SAMPLE_PORT2_AND_RESTORE.
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
        JP M,IRQ_SCAN_PROJECTILE_RECORDS
        LD HL,$206F

; Shared IRQ loop: extract next nonzero list pointer from a 0x12-byte slot
; at $206F.
IRQ_COPY_OBJECT_LIST_ENTRY:
        PUSH HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,IRQ_ADVANCE_FIRST_LIST_SLOT

; Copy a pair of source bytes to a destination row, advance by $20, repeat
; using B.
IRQ_COPY_OBJECT_LIST_ROW:
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
        JP Z,IRQ_COPY_OBJECT_LIST_ROW

; Restore list slot address and advance $12 until low byte reaches $B7.
IRQ_ADVANCE_FIRST_LIST_SLOT:
        POP HL
        LD DE,$0012
        ADD HL,DE
        LD A,L
        CP $B7
        JP NZ,IRQ_COPY_OBJECT_LIST_ENTRY
        LD HL,$20A2

; Process the $20A2-list slots, setting bitmap pointer and the port-$02
; mode.
IRQ_COMPOSITE_SECOND_LIST_ENTRY:
        PUSH HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,IRQ_ADVANCE_SECOND_LIST_SLOT
        LD A,(DE)
        INC DE
        EX DE,HL
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        EX DE,HL
        OUT ($02),A

; Merge two source bytes through graphics ports $04/$03 with OR into bitmap
; row.
IRQ_COMPOSITE_SECOND_LIST_ROW:
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
        JP Z,IRQ_COMPOSITE_SECOND_LIST_ROW

; Restore list slot and step backward by $12 until low byte reaches $5A.
IRQ_ADVANCE_SECOND_LIST_SLOT:
        POP HL
        LD DE,$FFEE
        ADD HL,DE
        LD A,L
        CP $5A
        JP NZ,IRQ_COMPOSITE_SECOND_LIST_ENTRY
        LD HL,$20B2
        JP IRQ_CONSUME_BITMAP_JOB

; Shared continuation of RST $08/$10: choose pending bitmap operations or
; input sampling.
IRQ_RESUME_COMMON_FRAME_PATH:
        LD A,($20B9)
        AND A
        JP M,IRQ_SAMPLE_PORT2_AND_RESTORE
        LD HL,$20AB

; Consume pointer fields from pending draw/clear descriptor at HL.
IRQ_CONSUME_BITMAP_JOB:
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        PUSH DE
        JP Z,IRQ_RENDER_PENDING_SPRITE_JOB
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        EX DE,HL
        PUSH DE
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        POP DE
        JP Z,IRQ_RENDER_PENDING_SPRITE_JOB

; Internal block: Use B as fill value to clear C bytes per row for D rows.
IRQ_CLEAR_BITMAP_ROW_GROUP:
        PUSH HL
        LD C,E

; Internal block: Inner fill loop: write B to (HL), advance until C expires.
IRQ_CLEAR_BITMAP_ROW_BYTES:
        LD (HL),B
        INC HL
        DEC C
        JP NZ,IRQ_CLEAR_BITMAP_ROW_BYTES
        POP HL
        LD C,$20
        ADD HL,BC
        DEC D
        JP NZ,IRQ_CLEAR_BITMAP_ROW_GROUP

; Restore pending descriptor, select video mode and draw two object-pattern
; sources.
IRQ_RENDER_PENDING_SPRITE_JOB:
        POP HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,IRQ_SAMPLE_PORT2_AND_RESTORE
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
        JP IRQ_SAMPLE_PORT2_AND_RESTORE

; Internal block: Begin pass over projectile/object records at $2063.
IRQ_SCAN_PROJECTILE_RECORDS:
        LD HL,PROJECTILE_P1_SLOT_0

; GF-RE-002: examine four $12-byte projectile slots at $2063/$2075/
; $2087/$2099. This checks status and coordinate windows, not a proven
; pixel-overlap collision test.
IRQ_CHECK_PROJECTILE_SLOT:
        LD A,(HL)
        AND A
        PUSH HL
        JP P,IRQ_NEXT_PROJECTILE_SLOT
        INC HL
        LD A,(HL)
        AND A
        INC HL
        LD A,(HL)
        JP M,IRQ_CHECK_PROJECTILE_UPPER_WINDOW
        CP $70
        JP NC,IRQ_TEST_PROJECTILE_STATE_AND_BOUNDS
        JP IRQ_NEXT_PROJECTILE_SLOT

; Apply upper limit $90 to signed/alternate projectile coordinate path.
IRQ_CHECK_PROJECTILE_UPPER_WINDOW:
        CP $90
        JP NC,IRQ_NEXT_PROJECTILE_SLOT

; Qualify a projectile-generated event using another nonzero record
; field and bounded coordinate. Not yet proven to test pixel overlap.
IRQ_TEST_PROJECTILE_STATE_AND_BOUNDS:
        LD DE,$000C
        ADD HL,DE
        LD A,(HL)
        AND A
        JP Z,IRQ_NEXT_PROJECTILE_SLOT
        LD DE,$FFF8
        ADD HL,DE
        LD A,(HL)
        SUB $10
        CP $C0
        JP NC,IRQ_NEXT_PROJECTILE_SLOT
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
        LD (PROJECTILE_EVENT_CONTEXT),A
        SUB $10
        RRA
        RRA
        AND $30
        OR C
        RRA
        LD E,A
        LD D,$00
        LD HL,PROJECTILE_EVENT_LOOKUP_RECORDS
        ADD HL,DE
        LD A,C
        RRA
        LD A,(HL)
        JP NC,IRQ_STORE_EVENT_SELECTOR
        RRA
        RRA
        RRA
        RRA

; GF-RE-002: write the low nibble selected from ROM table $0F3A into
; $201C. The VM later consumes nonzero selectors through $09D6-based
; script pointers; selector-to-visible-hit meaning needs an IRQ trace.
IRQ_STORE_EVENT_SELECTOR:
        AND $0F
        LD (PROJECTILE_EVENT_SELECTOR),A

; Advance by $12 through projectile records until low byte is $AB.
IRQ_NEXT_PROJECTILE_SLOT:
        POP HL
        LD DE,$0012
        ADD HL,DE
        LD A,$AB
        CP L
        JP NZ,IRQ_CHECK_PROJECTILE_SLOT
        LD HL,PROJECTILE_P1_SLOT_0

; Update an active object and calculate its bitmap address and bit phase.
IRQ_UPDATE_VISIBLE_OBJECT_SLOT:
        LD A,(HL)
        AND A
        JP P,IRQ_NEXT_VISIBLE_OBJECT_SLOT
        LD A,$FF
        LD ($20C4),A
        CALL UPDATE_ACTIVE_OBJECT_COORDINATES
        LD A,(HL)
        RLA
        OR $7F
        AND (HL)
        LD (HL),A
        JP P,IRQ_NEXT_VISIBLE_OBJECT_SLOT
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

; Advance active object record by $12; after final slot, examine $20BE.
IRQ_NEXT_VISIBLE_OBJECT_SLOT:
        LD BC,$0012
        ADD HL,BC
        LD A,$AB
        CP L
        JP NZ,IRQ_UPDATE_VISIBLE_OBJECT_SLOT
        LD HL,($20BE)
        LD A,L
        OR H
        JP NZ,IRQ_BEGIN_OBJECT_CYCLE
        LD HL,$202A

; Save initial walker address to $20C0 and clear cycle activity byte $20BD.
IRQ_BEGIN_OBJECT_CYCLE:
        LD ($20C0),HL
        XOR A
        LD ($20BD),A

; Update active object, optionally prepare drawing job, persist current
; pointer.
IRQ_STEP_OBJECT_CYCLE:
        LD A,(HL)
        AND A
        JP P,IRQ_ADVANCE_OBJECT_CYCLE
        CALL UPDATE_ACTIVE_OBJECT_COORDINATES
        LD A,($20BD)
        AND A
        CALL Z,QUEUE_OBJECT_BITMAP_UPDATE
        LD ($20BE),HL

; Advance the object walker by $13, wrapping at $2063 to $202A.
IRQ_ADVANCE_OBJECT_CYCLE:
        LD DE,$0013
        ADD HL,DE
        LD A,$63
        CP L
        JP NZ,IRQ_CHECK_OBJECT_CYCLE_COMPLETE
        LD HL,$202A

; GF-RE-002: after a full $13-byte object cycle, service output latch
; $2014, frame/round countdown $2009, BCD state and script delay.
; Output port $01 values are established; electrical meanings are not.
IRQ_CHECK_OBJECT_CYCLE_COMPLETE:
        LD A,($20C0)
        CP L
        JP NZ,IRQ_STEP_OBJECT_CYCLE
        LD HL,$2014
        LD A,(HL)
        AND A
        JP Z,IRQ_ADVANCE_ROUND_TIMERS
        DEC (HL)
        JP NZ,IRQ_ADVANCE_ROUND_TIMERS
        XOR A
        OUT ($01),A

; Decrease round timer at $2009 and update BCD game-state counters on
; rollover.
IRQ_ADVANCE_ROUND_TIMERS:
        LD HL,$2009
        DEC (HL)
        JP P,IRQ_DECREMENT_FRAME_DELAY
        LD (HL),$22
        LD HL,$2004
        LD A,(HL)
        AND A
        JP Z,IRQ_UPDATE_SECOND_BCD_TIMER
        ADD A,$99
        DAA
        LD (HL),A
        JP NZ,IRQ_UPDATE_SECOND_BCD_TIMER
        EX DE,HL
        LD HL,$20C4
        INC (HL)
        JP NZ,INSTALL_INITIAL_VM_SCRIPT
        EX DE,HL
        INC (HL)

; Update BCD timer at $2003; on expiry transition to wait counter.
IRQ_UPDATE_SECOND_BCD_TIMER:
        LD HL,$2003
        LD A,(HL)
        AND A
        JP Z,IRQ_DECREMENT_FRAME_DELAY
        ADD A,$99
        DAA
        LD (HL),A
        JP NZ,IRQ_SAMPLE_PORT2_AND_RESTORE
        JP IRQ_DECREMENT_WAIT_COUNTER

; Decrement $2015 and branch to frame end until the delay expires.
IRQ_DECREMENT_FRAME_DELAY:
        LD HL,$2015
        LD A,(HL)
        AND A
        JP Z,IRQ_SAMPLE_PORT2_AND_RESTORE
        DEC (HL)
        JP NZ,IRQ_SAMPLE_PORT2_AND_RESTORE

; Internal block: Decrement waiting/repeat counter at $20C5.
IRQ_DECREMENT_WAIT_COUNTER:
        LD HL,$20C5
        DEC (HL)

; Double-sample input port $02; dispatch stable changes, restore saved
; registers.
IRQ_SAMPLE_PORT2_AND_RESTORE:
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
; Called by IRQ_RENDER_PENDING_SPRITE_JOB and RUN_GAME_DISPLAY_SEQUENCE.
; Entry DE=pattern record (width8, height8, row data), HL=bitmap output,
; B=height bias. If DE=0, return without drawing.
; For each of height rows, transfer width bytes via OUT $04 / IN $03,
; append the zero-latch result, and advance output by $20 bytes per row.
; Exit B=original height+entry bias (saved via $20BC); DE/HL advanced;
; A,C,flags changed. I/O: graphics ports $04/$03; RAM $20BC.
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

; Save source dimensions and destination, start another 32-byte-spaced
; bitmap row.
DRAW_OBJECT_NEXT_ROW:
        PUSH BC
        PUSH HL

; Feed a pattern byte to port $04, read pixel result at port $03, and store.
DRAW_OBJECT_ROW_BYTES:
        LD A,(DE)
        INC DE
        OUT ($04),A
        IN A,($03)
        LD (HL),A
        INC HL
        DEC C
        JP NZ,DRAW_OBJECT_ROW_BYTES
        XOR A
        OUT ($04),A
        IN A,($03)
        LD (HL),A
        POP HL
        LD BC,$0020
        ADD HL,BC
        POP BC
        DEC B
        JP NZ,DRAW_OBJECT_NEXT_ROW
        LD A,($20BC)
        LD B,A
        RET

; -----------------------------------------------------------------------------
; UPDATE_ACTIVE_OBJECT_COORDINATES
; Called in the interrupt-driven visible-object and general-object walks.
; Entry HL=object record base, A=object control flags.
; Calls STEP_OBJECT_AXIS for two axes, writes revised control/motion state,
; and clears bit 6 when both velocity fields reach zero.
; Exit HL restored to original object base; A,B,C,D,E and flags modified.
; RAM: object record fields; no direct I/O.
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
; Called twice by UPDATE_ACTIVE_OBJECT_COORDINATES for the two axes.
; Entry A=object control bits, HL=current axis descriptor fields.
; Accumulate axis position and test against both limits; on crossing a
; limit, clear/reverse the component and select a status code.
; Return D=selected axis-position byte; A=status code ($00/$10/$40/$60)
; with flags from AND A in the status exits. HL/B/C may be altered.
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
        JP C,AXIS_HANDLE_LIMIT_VIOLATION
        SUB (HL)
        JP NC,AXIS_HANDLE_LIMIT_VIOLATION
        DEC HL
        DEC HL
        LD (HL),C

; Return current axis byte in D, clear A after the in-bounds check.
AXIS_RETURN_UNCHANGED:
        LD D,(HL)
        XOR A
        RET

; Adjust compact axis record on range violation; branch by B direction mode.
AXIS_HANDLE_LIMIT_VIOLATION:
        DEC HL
        DEC HL
        DEC B
        JP NZ,AXIS_CLEAR_OR_REVERSE_COMPONENT
        DEC HL
        XOR A
        SUB (HL)
        LD (HL),A
        INC HL
        LD A,$10
        JP AXIS_RETURN_STATUS

; Zero a field and select status $60 or alternate path from direction mode.
AXIS_CLEAR_OR_REVERSE_COMPONENT:
        DEC HL
        LD (HL),$00
        INC HL
        DEC B
        JP NZ,AXIS_SELECT_LIMIT_STATUS
        LD A,$60
        JP AXIS_RETURN_STATUS

; Internal block: Choose return status $40 when no earlier mode matches.
AXIS_SELECT_LIMIT_STATUS:
        DEC B
        JP NZ,AXIS_RETURN_UNCHANGED
        LD A,$40

; Return axis value in D and status in A, with flags from AND A.
AXIS_RETURN_STATUS:
        LD D,(HL)
        AND A
        RET

; -----------------------------------------------------------------------------
; TAKE_AND_CLEAR_OBJECT_POINTER
; Remove a little-endian pointer from the field at entry HL, zeroing both
; bytes.
; Exit HL=old pointer, DE=address immediately after the cleared field; B=0;
; Z set if pointer was zero.
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

; -----------------------------------------------------------------------------
; QUEUE_OBJECT_BITMAP_UPDATE — callable helper reached from object walk
; Entry HL=current object record, D=coordinate selected by axis update.
; Save object link and converted bitmap address in one pending-job slot,
; $20AB or $20B2 depending on D relative to $60. Store status in $20BD;
; select a frame pointer from the $0349/$0351 tables when required.
; Some branches clear a pending job instead of drawing it. Return to
; caller at IRQ_STEP_OBJECT_CYCLE; modifies A/B/C/D/E/HL and RAM state.
; -----------------------------------------------------------------------------
; Construct pending object bitmap descriptor in $20AB or $20B2 and update
; slot flags.
QUEUE_OBJECT_BITMAP_UPDATE:
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
        JP NC,STORE_PENDING_BITMAP_DESCRIPTOR
        LD HL,$20B2

; Store source slot pointer, converted video address/phase, and object
; linkage.
STORE_PENDING_BITMAP_DESCRIPTOR:
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
        JP C,SELECT_CURRENT_PLAYER_FRAME
        RLA
        JP C,CLEAR_PENDING_BITMAP_DESCRIPTOR
        DEC HL
        LD D,(HL)
        DEC HL
        LD E,(HL)
        LD BC,$0004
        LD A,$80

; Write pending object link pointer and XOR status into source object
; control byte.
WRITE_OBJECT_LINK_AND_XOR_STATE:
        ADD HL,BC
        LD (HL),E
        INC HL
        LD (HL),D
        POP HL
        XOR (HL)
        LD (HL),A
        RET

; Choose player-specific four-entry frame table based on object slot and
; $2009.
SELECT_CURRENT_PLAYER_FRAME:
        POP HL
        LD A,$50
        CP L
        RET Z
        PUSH HL
        LD A,$2A
        CP L
        LD HL,PLAYER_ONE_FRAME_POINTERS
        JP Z,LOOKUP_PLAYER_FRAME_POINTER
        LD HL,PLAYER_TWO_FRAME_POINTERS

; Scale the $2009 frame selector and index the four-entry player frame
; table.
LOOKUP_PLAYER_FRAME_POINTER:
        LD A,($2009)
        AND $0C
        RRCA
        ADD A,L
        LD L,A
        JP NC,LOAD_FRAME_POINTER_AND_RESET_FLAGS
        INC H

; Read frame pointer into DE; clear/change related status through shared
; exit.
LOAD_FRAME_POINTER_AND_RESET_FLAGS:
        LD E,(HL)
        INC HL
        LD D,(HL)
        POP HL
        PUSH HL
        LD BC,$000D
        XOR A
        JP WRITE_OBJECT_LINK_AND_XOR_STATE

; Zero four pending-record bytes and clear source object's active control
; byte.
CLEAR_PENDING_BITMAP_DESCRIPTOR:
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
        DW PLAYER_FRAME_PATTERN_A_24X12,PLAYER_FRAME_PATTERN_B_24X12,PLAYER_FRAME_PATTERN_C_24X12,PLAYER_FRAME_PATTERN_B_24X12

PLAYER_TWO_FRAME_POINTERS:
        DW $22C7,$22ED,$2313,$22ED

; -----------------------------------------------------------------------------
; VIDEO_ADDRESS_FROM_PACKED_COORDINATES
; Convert packed pixel coordinates in DE to a bitmap byte address relative
; to $2400.
; Exit DE=$2400+(entry DE>>3), C=entry E&7; preserves HL, destroys A/B and
; flags.
; -----------------------------------------------------------------------------
VIDEO_ADDRESS_FROM_PACKED_COORDINATES:
        LD A,E
        AND $07
        LD C,A
        LD B,$03

; One step of the three-bit right shift of DE, preserving carry between D/E.
PIXEL_ADDRESS_SHIFT_RIGHT:
        XOR A
        LD A,D
        RRA
        LD D,A
        LD A,E
        RRA
        LD E,A
        DEC B
        JP NZ,PIXEL_ADDRESS_SHIFT_RIGHT
        PUSH HL
        LD HL,$2400
        ADD HL,DE
        EX DE,HL
        POP HL
        RET

; -----------------------------------------------------------------------------
; COPY_SCRIPT_LITERAL_BLOCK
; Used by VM words $05/$06 and the special-object initializer.
; Entry HL=source byte stream; DE=destination RAM; C=byte count.
; Copies exactly C bytes; exit HL/DE at following addresses, C=0.
; I/O: none. DI is executed here; caller controls interrupt restoration.
; The VM callers separately store the advanced HL back in $2000.
; -----------------------------------------------------------------------------
COPY_SCRIPT_LITERAL_BLOCK:
        DI

; Inline copy loop for VM words $05/$06: copy C bytes HL to DE.
COPY_SCRIPT_LITERAL_BYTE:
        LD A,(HL)
        INC HL
        LD (DE),A
        INC DE
        DEC C
        JP NZ,COPY_SCRIPT_LITERAL_BYTE
        RET

; -----------------------------------------------------------------------------
; CALCULATE_PROJECTILE_ORIGIN
; Fetch a two-byte relative shot adjustment at SHOT_PARAMETER_BASE + A.
; A is the previously saved nonzero even controller direction offset.
; B receives the first byte; D the second. Combine the offset with
; object bytes +0 and +4 and return adjusted DE for projectile placement.
; This is NOT a pointer lookup; unlike INSTALL_AIM_DESCRIPTOR.
; -----------------------------------------------------------------------------
CALCULATE_PROJECTILE_ORIGIN:
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
; Clear initial RAM state, clear video, and install the primary script at
; $0821.
; Entry: reset path; exits through VM dispatch.
; -----------------------------------------------------------------------------
INITIALIZE_GAME:
        LD A,$08
        LD HL,$2002
        LD B,$00

; Internal block: Initialize eight consecutive RAM state bytes at $2002.
CLEAR_INITIAL_GAME_STATE_BYTE:
        LD (HL),B
        INC HL
        DEC A
        JP NZ,CLEAR_INITIAL_GAME_STATE_BYTE

; Clear display, install initial script $0821, enable interrupts and fall
; into VM.
INSTALL_INITIAL_VM_SCRIPT:
        CALL CLEAR_BITMAP_DISPLAY
        LD HL,$0821
        LD ($2000),HL
        EI

; -----------------------------------------------------------------------------
; VM_DISPATCH_NEXT
; Entry from initialization or native-word RET through continuation $03A6.
; Script PC is RAM $2000; nonzero $20C6 selects alternate root $089B.
; Fetch token into E, increment/save $2000, double it to index the 21
; little-endian native pointers at ROM $09AE, push continuation $03A6,
; then JP (HL) to handler. No bounds check is performed by the dispatcher.
; -----------------------------------------------------------------------------
VM_DISPATCH_NEXT:
        LD HL,($2000)
        LD A,($20C6)
        AND A
        JP Z,VM_FETCH_AND_RESOLVE_NATIVE_WORD
        LD HL,$089B

; Fetch indexed command, advance $2000, look up 16-bit handler at $09AE and
; jump.
VM_FETCH_AND_RESOLVE_NATIVE_WORD:
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

VM_WORD_14_INPUT_AND_EVENT_DISPATCH:
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
        LD HL,PROJECTILE_EVENT_SELECTOR
        LD A,(HL)
        AND A
        JP Z,VM_REFRESH_SCORE_IF_NEEDED
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

; At VM input/event word exit, refresh score when round state $2009 is below
; $22.
VM_REFRESH_SCORE_IF_NEEDED:
        LD A,($2009)
        CP $22
        CALL P,SCORE_FORMAT_FOUR_FIELDS
        RET

; -----------------------------------------------------------------------------
; DISPATCH_INPUT_TRANSITION
; Entry A=new stable input sample, HL=stored input-state byte,
; DE=16-bit action-vector table for that input port.
; Compute changed bits A XOR (HL); return immediately if none changed.
; Scan low-to-high for the first changed bit using masks in B/C, update
; that stored bit, leave A=(changed bit AND new state), exchange HL/DE,
; and JP (HL) through the selected vector. The native action RET returns
; to the original caller of this helper; DE then points to input state.
; Effects: one bit of stored input state and action-dependent RAM/I/O.
; -----------------------------------------------------------------------------
DISPATCH_INPUT_TRANSITION:
        XOR (HL)
        RET Z
        LD C,A
        LD B,$01

; Rotate change mask C and shift bit mask B until first changed input bit.
INPUT_SCAN_FOR_CHANGED_BIT:
        LD A,C
        RRCA
        JP C,INPUT_UPDATE_BIT_AND_TAIL_CALL
        LD C,A
        LD A,B
        RLCA
        LD B,A
        INC DE
        INC DE
        JP INPUT_SCAN_FOR_CHANGED_BIT

; Update stored input state at HL; load native action address from DE and JP
; (HL).
INPUT_UPDATE_BIT_AND_TAIL_CALL:
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
; Extract player-one input direction from DE and use table $0EE2 to update
; the object record at $202A.
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
        LD HL,PLAYER_ONE_AIM_POINTERS
        LD DE,$202A
        JP INSTALL_AIM_DESCRIPTOR

; -----------------------------------------------------------------------------
; PLAYER_TWO_AIM_ACTION
; Extract player-two input direction from DE and use table $0EF0 to update
; the object record at $203D.
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
        LD HL,PLAYER_TWO_AIM_POINTERS
        LD DE,$203D

; -----------------------------------------------------------------------------
; INSTALL_AIM_DESCRIPTOR
; Input A is a NONZERO EVEN BYTE OFFSET ($02,$04,...,$0E) into a DW table.
; It comes from (controller & $70) rotated right three times.
; Read the little-endian pointer and install it at object record +$0B.
; Entry HL=table base, DE=player object base; zero index is never dispatched.
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

; PLAYER_ONE_AXIS5_NEGATIVE
; Player-one input action: write $FE (or zero when input inactive) to object
; field at $202A+5.
PLAYER_ONE_AXIS5_NEGATIVE:
        LD B,$FE

; If transition flags indicate release, zero B before storing axis5
; velocity.
P1_AXIS5_APPLY_PRESS_FLAG:
        JP NZ,P1_AXIS5_SELECT_OBJECT
        LD B,$00

; Select player-one object base $202A; shared store begins at next label.
P1_AXIS5_SELECT_OBJECT:
        LD HL,$202A

; Shared player-axis helper: mark object $C0 and write signed velocity at
; offset +5.
STORE_AXIS5_COMPONENT:
        LD (HL),$C0
        LD DE,$0005
        ADD HL,DE
        LD (HL),B
        RET

; PLAYER_ONE_AXIS5_POSITIVE
; Player-one input action: write $02 (or zero when input inactive) to object
; field at $202A+5.
PLAYER_ONE_AXIS5_POSITIVE:
        LD B,$02
        JP P1_AXIS5_APPLY_PRESS_FLAG

; PLAYER_ONE_AXIS1_NEGATIVE
; Player-one input action: write $FF (or zero when input inactive) to object
; field at $202A+1.
PLAYER_ONE_AXIS1_NEGATIVE:
        LD B,$FF

; If transition flags indicate release, zero B before storing axis1
; velocity.
P1_AXIS1_APPLY_PRESS_FLAG:
        JP NZ,P1_AXIS1_SELECT_OBJECT
        LD B,$00

; Internal block: Select player-one object base $202A for axis1 update.
P1_AXIS1_SELECT_OBJECT:
        LD HL,$202A

; Shared axis helper: mark object $C0 and write signed velocity to byte +1.
STORE_AXIS1_COMPONENT:
        LD (HL),$C0
        INC HL
        LD (HL),B
        RET

; PLAYER_ONE_AXIS1_POSITIVE
; Player-one input action: write $01 (or zero when input inactive) to object
; field at $202A+1.
PLAYER_ONE_AXIS1_POSITIVE:
        LD B,$01
        JP P1_AXIS1_APPLY_PRESS_FLAG

; PLAYER_TWO_AXIS5_NEGATIVE
; Player-two input action: write $FE (or zero when input inactive) to object
; field at $203D+5.
PLAYER_TWO_AXIS5_NEGATIVE:
        LD B,$FE

; Player-two axis5 press/release gating before shared velocity store.
P2_AXIS5_APPLY_PRESS_FLAG:
        JP NZ,P2_AXIS5_SELECT_OBJECT
        LD B,$00

; Select player-two object base $203D and jump to shared +5 velocity store.
P2_AXIS5_SELECT_OBJECT:
        LD HL,$203D
        JP STORE_AXIS5_COMPONENT

; PLAYER_TWO_AXIS5_POSITIVE
; Player-two input action: write $02 (or zero when input inactive) to object
; field at $203D+5.
PLAYER_TWO_AXIS5_POSITIVE:
        LD B,$02
        JP P2_AXIS5_APPLY_PRESS_FLAG

; PLAYER_TWO_AXIS1_NEGATIVE
; Player-two input action: write $FF (or zero when input inactive) to object
; field at $203D+1.
PLAYER_TWO_AXIS1_NEGATIVE:
        LD B,$FF

; Player-two axis1 press/release gating before shared velocity store.
P2_AXIS1_APPLY_PRESS_FLAG:
        JP NZ,P2_AXIS1_SELECT_OBJECT
        LD B,$00

; Select player-two object base $203D and jump to shared +1 velocity store.
P2_AXIS1_SELECT_OBJECT:
        LD HL,$203D
        JP STORE_AXIS1_COMPONENT

; PLAYER_TWO_AXIS1_POSITIVE
; Player-two input action: write $01 (or zero when input inactive) to object
; field at $203D+1.
PLAYER_TWO_AXIS1_POSITIVE:
        LD B,$01
        JP P2_AXIS1_APPLY_PRESS_FLAG

; -----------------------------------------------------------------------------
; PLAYER_ONE_FIRE_ACTION
; Player-one firing path; checks projectile/object state and updates shot
; hardware.
; Uses records near $202C and $2063; calls common shot update at $04FA.
; -----------------------------------------------------------------------------
PLAYER_ONE_FIRE_ACTION:
        RET Z
        LD HL,PROJECTILE_P1_SLOT_0
        LD A,(HL)
        AND $80
        JP Z,FIRE_P1_CHECK_GUARD_AND_LAUNCH
        LD HL,PROJECTILE_P1_SLOT_1
        LD A,(HL)
        AND $80
        RET NZ

; Reject fire when $2012 nonzero; otherwise update count and configure
; projectile.
FIRE_P1_CHECK_GUARD_AND_LAUNCH:
        LD DE,PROJECTILE_P1_FIRE_GUARD
        LD A,(DE)
        AND A
        RET NZ
        PUSH HL
        EX DE,HL
        LD DE,$3EA2
        LD BC,PLAYER_ONE_SHOT_COUNT
        CALL UPDATE_SHOT_STATE
        LD A,$E2
        OUT ($01),A
        LD DE,$202C
        LD BC,$1A08
        LD A,($201A)

; GF-RE-002: combine selected player origin with two-byte direction
; offset from $0F00-$0F0D. Under DI/EI, initialize the chosen projectile
; slot with status $C6 and derived coordinate fields.
FIRE_INSTALL_PROJECTILE_FROM_DIRECTION:
        LD HL,SHOT_PARAMETER_BASE
        CALL CALCULATE_PROJECTILE_ORIGIN
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
        LD (PROJECTILE_OUTPUT_TIMER),A
        RET

; -----------------------------------------------------------------------------
; UPDATE_SHOT_STATE
; Called by both player firing handlers.
; Entry BC=player shot-counter address, HL=fire guard address,
; DE=bitmap destination for the ammunition counter glyph. Increment (BC), compare with six;
; when reaching threshold, update guard and round-state byte $2003.
; Then tail-call DRAW_FORMATTED_TEXT with A=shot-count character and
; HL=$0FA4. Caller is responsible for output-port fire command and
; projectile initialization. B,A,HL/flags modified.
; -----------------------------------------------------------------------------
UPDATE_SHOT_STATE:
        LD A,(BC)
        INC A
        LD (BC),A
        CP $06
        JP M,SHOT_DRAW_AMMO_INDICATOR
        LD (HL),A
        LD B,A
        LD HL,$2003
        LD A,(HL)
        LD (HL),$11
        AND A
        JP Z,SHOT_RESTORE_DISPLAY_DIGIT
        LD (HL),$02

; Restore A from B after updating round state, before drawing ammunition
; indicator.
SHOT_RESTORE_DISPLAY_DIGIT:
        LD A,B

; Internal block: Tail-call formatted text with character stream $0FA4.
SHOT_DRAW_AMMO_INDICATOR:
        LD HL,$0FA4
        JP DRAW_FORMATTED_TEXT

; -----------------------------------------------------------------------------
; PLAYER_TWO_FIRE_ACTION
; Player-two firing path; checks projectile/object state and updates shot
; hardware.
; Uses records near $203F and $2087; shares shot-update service.
; -----------------------------------------------------------------------------
PLAYER_TWO_FIRE_ACTION:
        RET Z
        LD HL,PROJECTILE_P2_SLOT_0
        LD A,(HL)
        AND $80
        JP Z,FIRE_P2_CHECK_GUARD_AND_LAUNCH
        LD HL,PROJECTILE_P2_SLOT_1
        LD A,(HL)
        AND $80
        RET NZ

; Reject fire when $2013 nonzero; otherwise update count and configure
; projectile.
FIRE_P2_CHECK_GUARD_AND_LAUNCH:
        LD DE,PROJECTILE_P2_FIRE_GUARD
        LD A,(DE)
        AND A
        RET NZ
        PUSH HL
        EX DE,HL
        LD DE,$3EB8
        LD BC,PLAYER_TWO_SHOT_COUNT
        CALL UPDATE_SHOT_STATE
        LD A,$D2
        OUT ($01),A
        LD DE,$203F
        LD BC,$F6F8
        LD A,($201B)
        JP FIRE_INSTALL_PROJECTILE_FROM_DIRECTION

; -----------------------------------------------------------------------------
; ADVANCE_ROUND_EVENT_COUNTER
; Handle a native event trigger: set output $01 to $04, advance $2007 and
; update $2008.
; Uses $2006/$2007 as state/count inputs; alternate exit at $056C.
; -----------------------------------------------------------------------------
ADVANCE_ROUND_EVENT_COUNTER:
        RET Z
        LD A,$04
        LD (PROJECTILE_OUTPUT_TIMER),A
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
        JP Z,ROUND_RESET_SCORE_AND_MODE

; Internal block: Adjust B in $10 increments using $2006 upper mode bits.
ROUND_SELECT_SPEED_FROM_SETTINGS:
        LD C,A
        LD A,B
        ADD A,$10
        LD B,A
        LD A,C
        SUB $10
        JP NZ,ROUND_SELECT_SPEED_FROM_SETTINGS

; Store resulting round mode, decrement $20C6 and clear selected score
; bytes.
ROUND_RESET_SCORE_AND_MODE:
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

VM_WORD_13_UPDATE_SCORE_TEXT:
; -----------------------------------------------------------------------------
; UPDATE_SCORE_DISPLAY
; Convert score state to display characters and refresh score text.
; Reads score-state RAM; uses formatted display service.
; -----------------------------------------------------------------------------
UPDATE_SCORE_DISPLAY:
        XOR A
        LD ($2003),A

; Internal block: Begin four-field BCD score-to-text formatting at RAM $201E.
SCORE_FORMAT_FOUR_FIELDS:
        LD C,$04
        LD HL,$201E
        LD DE,$2002

; Extract high nibble from RAM source, choosing placeholder $10 for leading
; zero.
SCORE_DECODE_HIGH_BCD_DIGIT:
        LD A,(DE)
        RRA
        RRA
        RRA
        RRA
        AND $0F
        JP NZ,SCORE_WRITE_BCD_DIGITS
        LD A,$10

; Convert both packed-decimal nibbles into display font glyph codes.
SCORE_WRITE_BCD_DIGITS:
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
        JP NZ,SCORE_NEXT_FIELD_AND_RENDER
        LD B,$2C
        LD A,(DE)
        AND A
        JP NZ,SCORE_NEXT_FIELD_AND_RENDER
        LD (HL),$40

; Internal block: Advance source/output pointers; render after four fields.
SCORE_NEXT_FIELD_AND_RENDER:
        INC DE
        INC HL
        LD (HL),B
        INC HL
        DEC C
        JP NZ,SCORE_DECODE_HIGH_BCD_DIGIT
        LD A,$08
        LD HL,$201E
        LD DE,$2405
        JP DRAW_FORMATTED_TEXT

VM_WORD_01_DRAW_FORMATTED_DATA:
; -----------------------------------------------------------------------------
; DRAW_FORMATTED_DATA
; VM word $01: read glyph count, source pointer and display destination.
; Script operands: glyph_count8, source16, destination16.
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
; Entry A=number of glyphs to draw, HL=encoded source stream,
; DE=bitmap destination. Source bytes < $30 advance display position;
; bytes >= $30 select glyph (character-$30) from 10-byte font at $09F8.
; Copy 10 rows per glyph with $20-byte video line stride, then advance
; destination one character byte. A/B/C/DE/flags changed; I/O: bitmap RAM.
; Called by VM word $01, score formatter and player-status display words.
; -----------------------------------------------------------------------------
DRAW_FORMATTED_TEXT:
        PUSH AF

; Fetch source char; values under $30 act as horizontal destination
; advances.
TEXT_FETCH_CHARACTER_OR_ADVANCE:
        LD A,(HL)
        INC HL
        SUB $30
        JP P,TEXT_LOOKUP_FONT_GLYPH
        LD B,A

; Advance bitmap byte address and handle 32-byte scanline boundary.
TEXT_ADVANCE_DISPLAY_COLUMN:
        INC E
        LD A,E
        AND $1F
        JP NZ,TEXT_CONTINUE_COLUMN_ADVANCE
        INC D
        INC D

; Internal block: Loop B column increments, then fetch next source byte.
TEXT_CONTINUE_COLUMN_ADVANCE:
        INC B
        JP NZ,TEXT_ADVANCE_DISPLAY_COLUMN
        JP TEXT_FETCH_CHARACTER_OR_ADVANCE

; Use character minus $30 as index into 10-byte digit glyph records.
TEXT_LOOKUP_FONT_GLYPH:
        PUSH HL
        PUSH DE
        LD HL,FONT_SCORE_DIGITS
        JP Z,TEXT_SETUP_TEN_SCANLINES
        LD BC,$000A

; Advance font pointer by 10 bytes until glyph index exhausted.
TEXT_SKIP_TO_NEXT_DIGIT_GLYPH:
        ADD HL,BC
        DEC A
        JP NZ,TEXT_SKIP_TO_NEXT_DIGIT_GLYPH

; Exchange source/destination and initialize ten glyph rows with $20 stride.
TEXT_SETUP_TEN_SCANLINES:
        EX DE,HL
        LD BC,$0020
        LD A,$0A

; Write one glyph byte to bitmap, step one scanline and repeat ten times.
TEXT_COPY_NEXT_GLYPH_ROW:
        PUSH AF
        LD A,(DE)
        INC DE
        LD (HL),A
        ADD HL,BC
        POP AF
        DEC A
        JP NZ,TEXT_COPY_NEXT_GLYPH_ROW
        POP DE
        POP HL
        INC DE
        POP AF
        DEC A
        JP NZ,DRAW_FORMATTED_TEXT
        RET

VM_WORD_02_SET_2003:
; -----------------------------------------------------------------------------
; SET_SCORE_STATE_BYTE
; VM word $02: read one byte from the script and store it at RAM $2003;
; advance the script cursor.
; -----------------------------------------------------------------------------
SET_SCORE_STATE_BYTE:
        LD HL,($2000)
        LD A,(HL)
        INC HL
        LD ($2000),HL
        LD ($2003),A
        RET

VM_WORD_03_SET_2015:
; -----------------------------------------------------------------------------
; SET_DELAY_STATE_BYTE
; VM word $03: read one byte from the script and store it at RAM $2015;
; advance the script cursor.
; -----------------------------------------------------------------------------
SET_DELAY_STATE_BYTE:
        LD HL,($2000)
        LD A,(HL)
        INC HL
        LD ($2000),HL
        LD ($2015),A
        RET

VM_WORD_04_CLEAR_DISPLAY_MEMORY:
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

; Zero-fill video using PUSH BC from temporary stack pointer $400F.
CLEAR_DISPLAY_PUSH_WORD_LOOP:
        PUSH BC
        INC DE
        CP D
        JP NZ,CLEAR_DISPLAY_PUSH_WORD_LOOP
        XOR A
        OUT ($01),A
        LD SP,$2400
        EI
        JP (HL)

VM_WORD_07_CLEAR_OBJECT_FLAGS:
; -----------------------------------------------------------------------------
; CLEAR_OBJECT_CONTROL_BITS
; VM word $07: read a RAM address from the script, clear bit 6 at that byte,
; and zero its following byte.
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

VM_WORD_09_GOTO_SCRIPT:
; -----------------------------------------------------------------------------
; JUMP_TO_SCRIPT
; VM word $09: read a 16-bit target from the script and replace the
; interpreter cursor at $2000.
; -----------------------------------------------------------------------------
JUMP_TO_SCRIPT:
        LD HL,($2000)
        LD E,(HL)
        INC HL
        LD D,(HL)
        EX DE,HL
        LD ($2000),HL
        RET

VM_WORD_05_COPY_INLINE_15:
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

VM_WORD_06_COPY_INLINE_9:
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

VM_WORD_08_TOGGLE_OBJECT_BITS:
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

VM_WORD_0A_GAME_DISPLAY_SEQUENCE:
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

; Reduce display state and determine whether the next pattern needs frame
; setup.
GAME_SELECT_NEXT_PATTERN:
        DEC A
        JP M,GAME_SELECT_SECOND_PATTERN_SET
        CP $02
        CALL P,GAME_PREPARE_SPECIAL_OBJECT
        CP $05
        JP M,GAME_DRAW_PATTERN_FROM_TABLE
        LD A,$04

; Read graphic pointer and destination from table; draw current pattern.
GAME_DRAW_PATTERN_FROM_TABLE:
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
        JP P,GAME_DRAW_PATTERN_FROM_TABLE

; Internal block: Select secondary graphics set once bit7 of $2016 permits.
GAME_SELECT_SECOND_PATTERN_SET:
        LD A,($2016)
        LD B,A
        AND $80
        JP NZ,GAME_DRAW_FINAL_PATTERN_GROUP
        LD A,B
        OR $80
        LD ($2016),A
        LD HL,$0F22
        LD A,($2005)
        JP GAME_SELECT_NEXT_PATTERN

; If bit6 of $2016 not set, set it, select port-$02 mode and draw last
; group.
GAME_DRAW_FINAL_PATTERN_GROUP:
        LD A,($2016)
        AND $40
        RET NZ
        OR $40
        LD ($2016),A
        LD A,$04
        OUT ($02),A
        XOR A
        LD HL,$0F36
        JP GAME_DRAW_PATTERN_FROM_TABLE

; Check object at $2050 and copy a 15-byte initialization record when
; inactive.
GAME_PREPARE_SPECIAL_OBJECT:
        PUSH HL
        PUSH AF
        LD HL,$2050
        LD A,(HL)
        AND $80
        JP NZ,GAME_SET_PATTERN_READY_FLAG
        EX DE,HL
        LD C,$0F
        LD HL,$0F52
        CALL COPY_SCRIPT_LITERAL_BLOCK

; Set bit6 in $2016; restore caller AF/HL saved by special-object helper.
GAME_SET_PATTERN_READY_FLAG:
        LD A,($2016)
        OR $40
        LD ($2016),A
        POP AF
        POP HL
        RET

VM_WORD_0C_INCREMENT_BCD_AND_RESET:
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

VM_WORD_0B_INITIALIZE_OBJECT:
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

VM_WORD_0D_OUTPUT_AND_SET_2014:
; -----------------------------------------------------------------------------
; WRITE_OUTPUT_AND_MODE
; VM word $0D: read output and state bytes, OUT the first to port $01, store
; second at $2014.
; -----------------------------------------------------------------------------
WRITE_OUTPUT_AND_MODE:
        LD HL,($2000)
        LD A,(HL)
        OUT ($01),A
        INC HL
        LD A,(HL)
        INC HL
        LD ($2000),HL
        LD (PROJECTILE_OUTPUT_TIMER),A

; NO_OP_INPUT_ACTION
; One-byte RET used by six native input action-table positions; also the
; fall-through exit of VM word $0D.
NO_OP_INPUT_ACTION:
        RET

VM_WORD_0E_FILL_RECTANGLE:
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

; Save row destination and fill another horizontal span using 32-byte
; stride.
RECTANGLE_NEXT_SCANLINE:
        PUSH HL
        LD C,E

; Internal block: Fill C consecutive video bytes with B.
RECTANGLE_FILL_ROW_BYTES:
        LD (HL),B
        INC HL
        DEC C
        JP NZ,RECTANGLE_FILL_ROW_BYTES
        POP HL
        LD C,$20
        ADD HL,BC
        DEC D
        JP NZ,RECTANGLE_NEXT_SCANLINE
        RET

VM_WORD_0F_EXPAND_GRAPHICS_TABLE:
; -----------------------------------------------------------------------------
; EXPAND_PACKED_GRAPHICS
; VM word $0F: unpack original RAM-resident graphic patterns.
; Entry: no inline VM operands. Begin at ROM $0BC4, output RAM $2100.
; Records contain dimension/stride bytes followed by packed bitstreams.
; Nested column and byte loops rotate each source byte through D/E eight
; times and write expanded graphic bytes to RAM; terminate at zero marker.
; Clobbers A/B/C/D/E/HL, flags. No replacement graphics are generated.
; -----------------------------------------------------------------------------
EXPAND_PACKED_GRAPHICS:
        LD HL,$2100
        LD DE,$0BC4

; Read next packed graphics record from ROM $0BC4; zero byte ends stream.
EXPAND_GRAPHICS_NEXT_BLOCK:
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

; Compute destination offset from record width for the next packed column.
EXPAND_GRAPHICS_NEXT_COLUMN:
        PUSH BC
        LD A,B
        LD B,$00
        ADD HL,BC
        LD B,A

; Read next source byte and prepare eight-bit rotation into display
; orientation.
EXPAND_GRAPHICS_READ_PACKED_COLUMN:
        DEC HL
        LD A,(DE)
        INC DE
        PUSH DE
        LD D,A
        LD E,$00
        LD B,$08

; Rotate source bits into the expanded byte through D/E shift registers.
EXPAND_GRAPHICS_ROTATE_EIGHT_BITS:
        LD A,D
        RRA
        LD D,A
        LD A,E
        RLA
        LD E,A
        DEC B
        JP NZ,EXPAND_GRAPHICS_ROTATE_EIGHT_BITS
        LD (HL),E
        POP DE
        DEC C
        JP NZ,EXPAND_GRAPHICS_READ_PACKED_COLUMN
        POP BC
        LD A,B
        LD B,$00
        ADD HL,BC
        LD B,A
        DEC B
        JP NZ,EXPAND_GRAPHICS_NEXT_COLUMN
        JP EXPAND_GRAPHICS_NEXT_BLOCK

VM_WORD_11_DRAW_STATUS_203F:
; -----------------------------------------------------------------------------
; DRAW_SECOND_PLAYER_STATUS
; VM word $11: select status record at $203F and branch to the shared text
; drawing path.
; -----------------------------------------------------------------------------
DRAW_SECOND_PLAYER_STATUS:
        LD HL,$203F
        JP DRAW_STATUS_GET_BITMAP_DESTINATION

VM_WORD_12_DRAW_STATUS_202C:
; -----------------------------------------------------------------------------
; DRAW_FIRST_PLAYER_STATUS
; VM word $12: select status record at $202C and use the shared status
; drawing path.
; -----------------------------------------------------------------------------
DRAW_FIRST_PLAYER_STATUS:
        LD HL,$202C

; Read packed object coordinates and derive display destination for 7 chars.
DRAW_STATUS_GET_BITMAP_DESTINATION:
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

VM_WORD_10_CONDITIONAL_GOTO_0882:
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

VM_WORD_00_WAIT_OR_REPEAT:
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

; -----------------------------------------------------------------------------
; Interpreted game scripts ($0821-$097D).
; Each CMD_ label identifies a bytecode packet, not an 8080 instruction.
; Operands follow the VM opcode in original ROM order.
; -----------------------------------------------------------------------------

; $0821: Clear bitmap display for a new scene.
CMD_0821_CLEAR_DISPLAY_MEMORY:
        DB $04

; $0822: Render the current score and status text.
CMD_0822_UPDATE_SCORE_TEXT:
        DB $13

; $0823: Draw a formatted text or graphic record into display memory.
CMD_0823_DRAW_FORMATTED_DATA:
        DB $01
        DB $0C ; Glyph count
        DW TEXT_GAME_OVER ; Encoded display source
        DW $240A ; Display RAM destination

; $0829: Branch to the alternate $0882 script if game state permits.
CMD_0829_CONDITIONAL_GOTO_0882:
        DB $10

; $082A: Expand packed ROM graphics into working RAM.
CMD_082A_EXPAND_GRAPHICS_TABLE:
        DB $0F

; $082B: Store the next countdown or mode value at RAM $2015.
CMD_082B_SET_2015:
        DB $03
        DB $5A ; Countdown / state value

; $082D: Repeat this command while the frame counter is pending.
CMD_082D_WAIT_OR_REPEAT:
        DB $00

; $082E: Draw a formatted text or graphic record into display memory.
CMD_082E_DRAW_FORMATTED_DATA:
        DB $01
        DB $29 ; Glyph count
        DW TEXT_TITLE_BLANKS ; Encoded display source
        DW $2600 ; Display RAM destination

; $0834: Store the next countdown or mode value at RAM $2015.
CMD_0834_SET_2015:
        DB $03
        DB $5A ; Countdown / state value

; $0836: Repeat this command while the frame counter is pending.
CMD_0836_WAIT_OR_REPEAT:
        DB $00

; $0837: Draw a formatted text or graphic record into display memory.
CMD_0837_DRAW_FORMATTED_DATA:
        DB $01
        DB $0B ; Glyph count
        DW TEXT_INSERT_COIN ; Encoded display source
        DW $3D14 ; Display RAM destination

; $083D: Copy 15 literal bytes from the script into a RAM object record.
CMD_083D_COPY_INLINE_15:
        DB $05
        DW $202A ; Destination object in working RAM
        DB $C3,$01,$00,$00,$40,$00,$66,$0B,$AA,$8B,$0D,$4A,$0D,$8B,$0D ; inline RAM data

; $084F: Store the next countdown or mode value at RAM $2015.
CMD_084F_SET_2015:
        DB $03
        DB $5A ; Countdown / state value

; $0851: Repeat this command while the frame counter is pending.
CMD_0851_WAIT_OR_REPEAT:
        DB $00

; $0852: Copy nine literal bytes from the script into a RAM object record.
CMD_0852_COPY_INLINE_9:
        DB $06
        DW $2063 ; Destination object in working RAM
        DB $C6,$03,$54,$00,$FE,$02,$78,$00,$C8 ; inline RAM data

; $085E: Store the next countdown or mode value at RAM $2015.
CMD_085E_SET_2015:
        DB $03
        DB $4B ; Countdown / state value

; $0860: Repeat this command while the frame counter is pending.
CMD_0860_WAIT_OR_REPEAT:
        DB $00

; $0861: Draw a formatted text or graphic record into display memory.
CMD_0861_DRAW_FORMATTED_DATA:
        DB $01
        DB $0B ; Glyph count
        DW TEXT_CLEAR_MESSAGE_FIELD ; Encoded display source
        DW $3D14 ; Display RAM destination

; $0867: Store the next countdown or mode value at RAM $2015.
CMD_0867_SET_2015:
        DB $03
        DB $3C ; Countdown / state value

; $0869: Repeat this command while the frame counter is pending.
CMD_0869_WAIT_OR_REPEAT:
        DB $00

; $086A: Copy 15 literal bytes from the script into a RAM object record.
CMD_086A_COPY_INLINE_15:
        DB $05
        DW $203D ; Destination object in working RAM
        DB $C2,$FF,$40,$00,$60,$00,$66,$27,$A0,$C7,$22,$00,$21,$C7,$22 ; inline RAM data

; $087C: Store the next countdown or mode value at RAM $2015.
CMD_087C_SET_2015:
        DB $03
        DB $40 ; Countdown / state value

; $087E: Repeat this command while the frame counter is pending.
CMD_087E_WAIT_OR_REPEAT:
        DB $00

; $087F: Replace the VM continuation pointer with an explicit script target.
CMD_087F_GOTO_SCRIPT:
        DB $09
        DW CMD_0821_CLEAR_DISPLAY_MEMORY ; Next script address

; $0882: Draw a formatted text or graphic record into display memory.
CMD_0882_DRAW_FORMATTED_DATA:
        DB $01
        DB $27 ; Format selector
        DW $0FD5 ; ROM data source
        DW $2A01 ; Display RAM destination

; $0888: Copy 15 literal bytes from the script into a RAM object record.
CMD_0888_COPY_INLINE_15:
        DB $05
        DW $202A ; Destination object in working RAM
        DB $C3,$02,$00,$00,$40,$00,$A0,$0B,$AA,$8B,$0D,$4A,$0D,$8B,$0D ; inline RAM data

; $089A: Repeat this command while the frame counter is pending.
CMD_089A_WAIT_OR_REPEAT:
        DB $00

; $089B: Clear bitmap display for a new scene.
CMD_089B_CLEAR_DISPLAY_MEMORY:
        DB $04

; $089C: Render the current score and status text.
CMD_089C_UPDATE_SCORE_TEXT:
        DB $13

; $089D: Expand packed ROM graphics into working RAM.
CMD_089D_EXPAND_GRAPHICS_TABLE:
        DB $0F

; $089E: Run the game display setup sequence.
CMD_089E_GAME_DISPLAY_SEQUENCE:
        DB $0A

; $089F: Draw a formatted text or graphic record into display memory.
CMD_089F_DRAW_FORMATTED_DATA:
        DB $01
        DB $09 ; Glyph count
        DW TEXT_READY_AND_DIALOGUE ; Encoded display source
        DW $2E0C ; Display RAM destination

; $08A5: Draw a formatted text or graphic record into display memory.
CMD_08A5_DRAW_FORMATTED_DATA:
        DB $01
        DB $0C ; Glyph count
        DW TEXT_READY_SEPARATOR ; Encoded display source
        DW $3EA2 ; Display RAM destination

; $08AB: Copy 15 literal bytes from the script into a RAM object record.
CMD_08AB_COPY_INLINE_15:
        DB $05
        DW $202A ; Destination object in working RAM
        DB $C0,$01,$00,$00,$48,$00,$66,$13,$9A,$8B,$0D,$87,$0C,$8B,$0D ; inline RAM data

; $08BD: Copy 15 literal bytes from the script into a RAM object record.
CMD_08BD_COPY_INLINE_15:
        DB $05
        DW $203D ; Destination object in working RAM
        DB $C0,$FF,$E7,$A0,$48,$00,$66,$13,$9A,$C7,$22,$C3,$21,$C7,$22 ; inline RAM data

; $08CF: Copy nine literal bytes from the script into a RAM object record.
CMD_08CF_COPY_INLINE_9:
        DB $06
        DW $2063 ; Destination object in working RAM
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data

; $08DB: Copy nine literal bytes from the script into a RAM object record.
CMD_08DB_COPY_INLINE_9:
        DB $06
        DW $2075 ; Destination object in working RAM
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data

; $08E7: Copy nine literal bytes from the script into a RAM object record.
CMD_08E7_COPY_INLINE_9:
        DB $06
        DW $2087 ; Destination object in working RAM
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data

; $08F3: Copy nine literal bytes from the script into a RAM object record.
CMD_08F3_COPY_INLINE_9:
        DB $06
        DW $2099 ; Destination object in working RAM
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data

; $08FF: Store the next countdown or mode value at RAM $2015.
CMD_08FF_SET_2015:
        DB $03
        DB $1E ; Countdown / state value

; $0901: Repeat this command while the frame counter is pending.
CMD_0901_WAIT_OR_REPEAT:
        DB $00

; $0902: Draw a formatted text or graphic record into display memory.
CMD_0902_DRAW_FORMATTED_DATA:
        DB $01
        DB $09 ; Glyph count
        DW TEXT_DRAW_AND_DIALOGUE ; Encoded display source
        DW $2E0C ; Display RAM destination

; $0908: Store the next countdown or mode value at RAM $2015.
CMD_0908_SET_2015:
        DB $03
        DB $0A ; Countdown / state value

; $090A: Clear selected control bits in an object record.
CMD_090A_CLEAR_OBJECT_FLAGS:
        DB $07
        DW $202A ; RAM address / target / packed dimension

; $090D: Clear selected control bits in an object record.
CMD_090D_CLEAR_OBJECT_FLAGS:
        DB $07
        DW $203D ; RAM address / target / packed dimension

; $0910: Repeat this command while the frame counter is pending.
CMD_0910_WAIT_OR_REPEAT:
        DB $00

; $0911: Draw a formatted text or graphic record into display memory.
CMD_0911_DRAW_FORMATTED_DATA:
        DB $01
        DB $05 ; Glyph count
        DW TEXT_CLEAR_MESSAGE_FIELD ; Encoded display source
        DW $2E0E ; Display RAM destination

; $0917: Read player inputs and choose the next event action.
CMD_0917_INPUT_AND_EVENT_DISPATCH:
        DB $14

; $0918: Replace the VM continuation pointer with an explicit script target.
CMD_0918_GOTO_SCRIPT:
        DB $09
        DW CMD_089B_CLEAR_DISPLAY_MEMORY ; Next script address

; $091B: Advance BCD score state and reset related counters.
CMD_091B_INCREMENT_BCD_AND_RESET:
        DB $0C
        DW $2005 ; BCD counter
        DW $202A ; descriptor address
        DB $20 ; flags
        DW EVENT_OBJECT_PATTERN_24X32 ; initial object graphic

; $0923: Set the output mode and update RAM $2014.
CMD_0923_OUTPUT_AND_SET_2014:
        DB $0D
        DB $C2 ; output
        DB $02 ; Countdown / state value

; $0926: Store the next countdown or mode value at RAM $2015.
CMD_0926_SET_2015:
        DB $03
        DB $0F ; Countdown / state value

; $0928: Repeat this command while the frame counter is pending.
CMD_0928_WAIT_OR_REPEAT:
        DB $00

; $0929: Initialize an object descriptor using inline operands.
CMD_0929_INITIALIZE_OBJECT:
        DB $0B
        DW $202A ; descriptor address
        DB $10 ; flags
        DW EVENT_OBJECT_PATTERN_32X11 ; initial object graphic

; $092F: Render the first player's status fields.
CMD_092F_DRAW_STATUS_202C:
        DB $12

; $0930: Store the next countdown or mode value at RAM $2015.
CMD_0930_SET_2015:
        DB $03
        DB $2D ; Countdown / state value

; $0932: Repeat this command while the frame counter is pending.
CMD_0932_WAIT_OR_REPEAT:
        DB $00

; $0933: Replace the VM continuation pointer with an explicit script target.
CMD_0933_GOTO_SCRIPT:
        DB $09
        DW CMD_089B_CLEAR_DISPLAY_MEMORY ; Next script address

; $0936: Fill a rectangular portion of display memory.
CMD_0936_FILL_RECTANGLE:
        DB $0E
        DW $1060 ; RAM address / target / packed dimension

; $0939: Replace the VM continuation pointer with an explicit script target.
CMD_0939_GOTO_SCRIPT:
        DB $09
        DW CMD_095D_OUTPUT_AND_SET_2014 ; Next script address

; $093C: Fill a rectangular portion of display memory.
CMD_093C_FILL_RECTANGLE:
        DB $0E
        DW $5060 ; RAM address / target / packed dimension

; $093F: Replace the VM continuation pointer with an explicit script target.
CMD_093F_GOTO_SCRIPT:
        DB $09
        DW CMD_095D_OUTPUT_AND_SET_2014 ; Next script address

; $0942: Fill a rectangular portion of display memory.
CMD_0942_FILL_RECTANGLE:
        DB $0E
        DW $9060 ; RAM address / target / packed dimension

; $0945: Replace the VM continuation pointer with an explicit script target.
CMD_0945_GOTO_SCRIPT:
        DB $09
        DW CMD_095D_OUTPUT_AND_SET_2014 ; Next script address

; $0948: Fill a rectangular portion of display memory.
CMD_0948_FILL_RECTANGLE:
        DB $0E
        DW $1078 ; RAM address / target / packed dimension

; $094B: Replace the VM continuation pointer with an explicit script target.
CMD_094B_GOTO_SCRIPT:
        DB $09
        DW CMD_095D_OUTPUT_AND_SET_2014 ; Next script address

; $094E: Fill a rectangular portion of display memory.
CMD_094E_FILL_RECTANGLE:
        DB $0E
        DW $1090 ; RAM address / target / packed dimension

; $0951: Replace the VM continuation pointer with an explicit script target.
CMD_0951_GOTO_SCRIPT:
        DB $09
        DW CMD_095D_OUTPUT_AND_SET_2014 ; Next script address

; $0954: Fill a rectangular portion of display memory.
CMD_0954_FILL_RECTANGLE:
        DB $0E
        DW $5090 ; RAM address / target / packed dimension

; $0957: Replace the VM continuation pointer with an explicit script target.
CMD_0957_GOTO_SCRIPT:
        DB $09
        DW CMD_095D_OUTPUT_AND_SET_2014 ; Next script address

; $095A: Fill a rectangular portion of display memory.
CMD_095A_FILL_RECTANGLE:
        DB $0E
        DW $9090 ; RAM address / target / packed dimension

; $095D: Set the output mode and update RAM $2014.
CMD_095D_OUTPUT_AND_SET_2014:
        DB $0D
        DB $B2 ; output
        DB $02 ; Countdown / state value

; $0960: Replace the VM continuation pointer with an explicit script target.
CMD_0960_GOTO_SCRIPT:
        DB $09
        DW CMD_0917_INPUT_AND_EVENT_DISPATCH ; Next script address

; $0963: Advance BCD score state and reset related counters.
CMD_0963_INCREMENT_BCD_AND_RESET:
        DB $0C
        DW $2002 ; BCD counter
        DW $203D ; descriptor address
        DB $D0 ; flags
        DW $2339 ; link pointer

; $096B: Set the output mode and update RAM $2014.
CMD_096B_OUTPUT_AND_SET_2014:
        DB $0D
        DB $B2 ; output
        DB $02 ; Countdown / state value

; $096E: Store the next countdown or mode value at RAM $2015.
CMD_096E_SET_2015:
        DB $03
        DB $0A ; Countdown / state value

; $0970: Repeat this command while the frame counter is pending.
CMD_0970_WAIT_OR_REPEAT:
        DB $00

; $0971: Initialize an object descriptor using inline operands.
CMD_0971_INITIALIZE_OBJECT:
        DB $0B
        DW $203D ; descriptor address
        DB $D0 ; flags
        DW $239B ; link pointer

; $0977: Render the second player's status fields.
CMD_0977_DRAW_STATUS_203F:
        DB $11

; $0978: Store the next countdown or mode value at RAM $2015.
CMD_0978_SET_2015:
        DB $03
        DB $2D ; Countdown / state value

; $097A: Repeat this command while the frame counter is pending.
CMD_097A_WAIT_OR_REPEAT:
        DB $00

; $097B: Replace the VM continuation pointer with an explicit script target.
CMD_097B_GOTO_SCRIPT:
        DB $09
        DW CMD_089B_CLEAR_DISPLAY_MEMORY ; Next script address

; -----------------------------------------------------------------------------
; Native input-action vector table ($097E-$09AD), 24 16-bit entries.
; Selected by the input transition dispatcher, separate from the 21 VM words.
; -----------------------------------------------------------------------------

; Player 1: decrease axis 5.
INPUT_ACTION_VECTOR_00:
        DW PLAYER_ONE_AXIS5_NEGATIVE ; Native input handler (table $097E)

; Player 1: increase axis 5.
INPUT_ACTION_VECTOR_01:
        DW PLAYER_ONE_AXIS5_POSITIVE ; Native input handler (table $0980)

; Player 1: decrease axis 1.
INPUT_ACTION_VECTOR_02:
        DW PLAYER_ONE_AXIS1_NEGATIVE ; Native input handler (table $0982)

; Player 1: increase axis 1.
INPUT_ACTION_VECTOR_03:
        DW PLAYER_ONE_AXIS1_POSITIVE ; Native input handler (table $0984)

; Player 1: aim-direction handler (shared).
INPUT_ACTION_VECTOR_04:
        DW $042A ; Native input handler (table $0986)

; Player 1: aim-direction handler (shared).
INPUT_ACTION_VECTOR_05:
        DW $042A ; Native input handler (table $0988)

; Player 1: aim-direction handler (shared).
INPUT_ACTION_VECTOR_06:
        DW $042A ; Native input handler (table $098A)

; Player 1: fire.
INPUT_ACTION_VECTOR_07:
        DW PLAYER_ONE_FIRE_ACTION ; Native input handler (table $098C)

; Player 2: decrease axis 5.
INPUT_ACTION_VECTOR_08:
        DW PLAYER_TWO_AXIS5_NEGATIVE ; Native input handler (table $098E)

; Player 2: increase axis 5.
INPUT_ACTION_VECTOR_09:
        DW PLAYER_TWO_AXIS5_POSITIVE ; Native input handler (table $0990)

; Player 2: decrease axis 1.
INPUT_ACTION_VECTOR_0A:
        DW PLAYER_TWO_AXIS1_NEGATIVE ; Native input handler (table $0992)

; Player 2: increase axis 1.
INPUT_ACTION_VECTOR_0B:
        DW PLAYER_TWO_AXIS1_POSITIVE ; Native input handler (table $0994)

; Player 2: aim-direction handler (shared).
INPUT_ACTION_VECTOR_0C:
        DW $043E ; Native input handler (table $0996)

; Player 2: aim-direction handler (shared).
INPUT_ACTION_VECTOR_0D:
        DW $043E ; Native input handler (table $0998)

; Player 2: aim-direction handler (shared).
INPUT_ACTION_VECTOR_0E:
        DW $043E ; Native input handler (table $099A)

; Player 2: fire.
INPUT_ACTION_VECTOR_0F:
        DW PLAYER_TWO_FIRE_ACTION ; Native input handler (table $099C)

; Reserved input action: no operation.
INPUT_ACTION_VECTOR_10:
        DW NO_OP_INPUT_ACTION ; Native input handler (table $099E)

; Reserved input action: no operation.
INPUT_ACTION_VECTOR_11:
        DW NO_OP_INPUT_ACTION ; Native input handler (table $09A0)

; Reserved input action: no operation.
INPUT_ACTION_VECTOR_12:
        DW NO_OP_INPUT_ACTION ; Native input handler (table $09A2)

; Reserved input action: no operation.
INPUT_ACTION_VECTOR_13:
        DW NO_OP_INPUT_ACTION ; Native input handler (table $09A4)

; Reserved input action: no operation.
INPUT_ACTION_VECTOR_14:
        DW NO_OP_INPUT_ACTION ; Native input handler (table $09A6)

; Reserved input action: no operation.
INPUT_ACTION_VECTOR_15:
        DW NO_OP_INPUT_ACTION ; Native input handler (table $09A8)

; Special native input action at $0549; behavior traced in source.
INPUT_ACTION_VECTOR_16:
        DW $0549 ; Native input handler (table $09AA)

; Special native input action at $056C; behavior traced in source.
INPUT_ACTION_VECTOR_17:
        DW $056C ; Native input handler (table $09AC)

; -----------------------------------------------------------------------------
; Game-command vector table ($09AE-$09D7), 21 16-bit entries.
; The interpreter indexes these addresses using VM opcodes $00-$14.
; -----------------------------------------------------------------------------

; VM word $00: wait or repeat command.
VM_WORD_VECTOR_00:
        DW WAIT_OR_REPEAT_COMMAND ; Interpreter handler (table $09AE)

; VM word $01: draw formatted data.
VM_WORD_VECTOR_01:
        DW DRAW_FORMATTED_DATA ; Interpreter handler (table $09B0)

; VM word $02: set score state byte.
VM_WORD_VECTOR_02:
        DW SET_SCORE_STATE_BYTE ; Interpreter handler (table $09B2)

; VM word $03: set delay state byte.
VM_WORD_VECTOR_03:
        DW SET_DELAY_STATE_BYTE ; Interpreter handler (table $09B4)

; VM word $04: clear bitmap display.
VM_WORD_VECTOR_04:
        DW CLEAR_BITMAP_DISPLAY ; Interpreter handler (table $09B6)

; VM word $05: copy inline 15 to ram.
VM_WORD_VECTOR_05:
        DW COPY_INLINE_15_TO_RAM ; Interpreter handler (table $09B8)

; VM word $06: copy inline 9 to ram.
VM_WORD_VECTOR_06:
        DW COPY_INLINE_9_TO_RAM ; Interpreter handler (table $09BA)

; VM word $07: clear object control bits.
VM_WORD_VECTOR_07:
        DW CLEAR_OBJECT_CONTROL_BITS ; Interpreter handler (table $09BC)

; VM word $08: toggle object control bits.
VM_WORD_VECTOR_08:
        DW TOGGLE_OBJECT_CONTROL_BITS ; Interpreter handler (table $09BE)

; VM word $09: jump to script.
VM_WORD_VECTOR_09:
        DW JUMP_TO_SCRIPT ; Interpreter handler (table $09C0)

; VM word $0A: $06bc.
VM_WORD_VECTOR_0A:
        DW $06BC ; Interpreter handler (table $09C2)

; VM word $0B: initialize object record.
VM_WORD_VECTOR_0B:
        DW INITIALIZE_OBJECT_RECORD ; Interpreter handler (table $09C4)

; VM word $0C: increment bcd and init.
VM_WORD_VECTOR_0C:
        DW INCREMENT_BCD_AND_INIT ; Interpreter handler (table $09C6)

; VM word $0D: write output and mode.
VM_WORD_VECTOR_0D:
        DW WRITE_OUTPUT_AND_MODE ; Interpreter handler (table $09C8)

; VM word $0E: $0785.
VM_WORD_VECTOR_0E:
        DW $0785 ; Interpreter handler (table $09CA)

; VM word $0F: expand packed graphics.
VM_WORD_VECTOR_0F:
        DW EXPAND_PACKED_GRAPHICS ; Interpreter handler (table $09CC)

; VM word $10: branch to alternate scene.
VM_WORD_VECTOR_10:
        DW BRANCH_TO_ALTERNATE_SCENE ; Interpreter handler (table $09CE)

; VM word $11: draw second player status.
VM_WORD_VECTOR_11:
        DW DRAW_SECOND_PLAYER_STATUS ; Interpreter handler (table $09D0)

; VM word $12: draw first player status.
VM_WORD_VECTOR_12:
        DW DRAW_FIRST_PLAYER_STATUS ; Interpreter handler (table $09D2)

; VM word $13: update score display.
VM_WORD_VECTOR_13:
        DW UPDATE_SCORE_DISPLAY ; Interpreter handler (table $09D4)

; VM word $14: vm input event dispatch.
VM_WORD_VECTOR_14:
        DW VM_INPUT_EVENT_DISPATCH ; Interpreter handler (table $09D6)

; -----------------------------------------------------------------------------
; Event-script destination table ($09D8-$09E9), nine 16-bit entries.
; These are interpreted script locations, not native handler addresses.
; -----------------------------------------------------------------------------

; Event $00: interpreted script entry.
EVENT_SCRIPT_VECTOR_00:
        DW $091B ; VM script (table $09D8)

; Event $01: interpreted script entry.
EVENT_SCRIPT_VECTOR_01:
        DW $0936 ; VM script (table $09DA)

; Event $02: interpreted script entry.
EVENT_SCRIPT_VECTOR_02:
        DW $093C ; VM script (table $09DC)

; Event $03: interpreted script entry.
EVENT_SCRIPT_VECTOR_03:
        DW $0942 ; VM script (table $09DE)

; Event $04: interpreted script entry.
EVENT_SCRIPT_VECTOR_04:
        DW $0948 ; VM script (table $09E0)

; Event $05: interpreted script entry.
EVENT_SCRIPT_VECTOR_05:
        DW $094E ; VM script (table $09E2)

; Event $06: interpreted script entry.
EVENT_SCRIPT_VECTOR_06:
        DW $0954 ; VM script (table $09E4)

; Event $07: interpreted script entry.
EVENT_SCRIPT_VECTOR_07:
        DW $095A ; VM script (table $09E6)

; Event $08: interpreted script entry.
EVENT_SCRIPT_VECTOR_08:
        DW $0963 ; VM script (table $09E8)
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

; -----------------------------------------------------------------------------
; Display font continuation, 28 ten-scanline glyph slots ($3A-$55).
; Each slot is ten literal bytes, addressed by the game's font renderer.
; Slots are named by their encoded character value, not inferred artwork.
; -----------------------------------------------------------------------------

; Glyph code $3A at ROM $0A5C.
FONT_GLYPH_3A:
        DB $10 ; ...#....
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $38 ; ..###...
        DB $7C ; .#####..

; Glyph code $3B at ROM $0A66.
FONT_GLYPH_3B:
        DB $C0 ; ##......
        DB $C0 ; ##......
        DB $C0 ; ##......
        DB $C0 ; ##......
        DB $C0 ; ##......
        DB $C0 ; ##......
        DB $00 ; ........
        DB $00 ; ........
        DB $C0 ; ##......
        DB $C0 ; ##......

; Glyph code $3C at ROM $0A70.
FONT_GLYPH_3C:
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $C0 ; ##......
        DB $C0 ; ##......

; Glyph code $3D at ROM $0A7A.
FONT_GLYPH_3D:
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $20 ; ..#.....
        DB $40 ; .#......
        DB $FF ; ########
        DB $40 ; .#......
        DB $20 ; ..#.....
        DB $00 ; ........
        DB $00 ; ........

; Glyph code $3E at ROM $0A84.
FONT_GLYPH_3E:
        DB $F0 ; ####....
        DB $C0 ; ##......
        DB $A0 ; #.#.....
        DB $90 ; #..#....
        DB $08 ; ....#...
        DB $04 ; .....#..
        DB $02 ; ......#.
        DB $01 ; .......#
        DB $00 ; ........
        DB $00 ; ........

; Glyph code $3F at ROM $0A8E.
FONT_GLYPH_3F:
        DB $78 ; .####...
        DB $FC ; ######..
        DB $CC ; ##..##..
        DB $E0 ; ###.....
        DB $70 ; .###....
        DB $30 ; ..##....
        DB $30 ; ..##....
        DB $00 ; ........
        DB $30 ; ..##....
        DB $30 ; ..##....

; Glyph code $40 at ROM $0A98.
FONT_GLYPH_40:
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........
        DB $00 ; ........

; Glyph code $41 at ROM $0AA2.
FONT_GLYPH_41:
        DB $18 ; ...##...
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.

; Glyph code $42 at ROM $0AAC.
FONT_GLYPH_42:
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3E ; ..#####.

; Glyph code $43 at ROM $0AB6.
FONT_GLYPH_43:
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..

; Glyph code $44 at ROM $0AC0.
FONT_GLYPH_44:
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3E ; ..#####.

; Glyph code $45 at ROM $0ACA.
FONT_GLYPH_45:
        DB $7E ; .######.
        DB $7E ; .######.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $3E ; ..#####.
        DB $3E ; ..#####.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $7E ; .######.
        DB $7E ; .######.

; Glyph code $46 at ROM $0AD4.
FONT_GLYPH_46:
        DB $7E ; .######.
        DB $7E ; .######.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $3E ; ..#####.
        DB $3E ; ..#####.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.

; Glyph code $47 at ROM $0ADE.
FONT_GLYPH_47:
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $76 ; .###.##.
        DB $76 ; .###.##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..

; Glyph code $48 at ROM $0AE8.
FONT_GLYPH_48:
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.

; Glyph code $49 at ROM $0AF2.
FONT_GLYPH_49:
        DB $3C ; ..####..
        DB $3C ; ..####..
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $3C ; ..####..
        DB $3C ; ..####..

; Glyph code $4A at ROM $0AFC.
FONT_GLYPH_4A:
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $7E ; .######.
        DB $7E ; .######.

; Glyph code $4B at ROM $0B06.
FONT_GLYPH_4B:
        DB $C3 ; ##....##
        DB $C3 ; ##....##
        DB $E7 ; ###..###
        DB $E7 ; ###..###
        DB $FF ; ########
        DB $FF ; ########
        DB $DB ; ##.##.##
        DB $C3 ; ##....##
        DB $C3 ; ##....##
        DB $C3 ; ##....##

; Glyph code $4C at ROM $0B10.
FONT_GLYPH_4C:
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $6E ; .##.###.
        DB $6E ; .##.###.
        DB $7E ; .######.
        DB $7E ; .######.
        DB $76 ; .###.##.
        DB $76 ; .###.##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.

; Glyph code $4D at ROM $0B1A.
FONT_GLYPH_4D:
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

; Glyph code $4E at ROM $0B24.
FONT_GLYPH_4E:
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3E ; ..#####.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.
        DB $06 ; .....##.

; Glyph code $4F at ROM $0B2E.
FONT_GLYPH_4F:
        DB $3E ; ..#####.
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3E ; ..#####.
        DB $76 ; .###.##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.

; Glyph code $50 at ROM $0B38.
FONT_GLYPH_50:
        DB $3C ; ..####..
        DB $7E ; .######.
        DB $66 ; .##..##.
        DB $06 ; .....##.
        DB $3E ; ..#####.
        DB $7C ; .#####..
        DB $60 ; .##.....
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..

; Glyph code $51 at ROM $0B42.
FONT_GLYPH_51:
        DB $7E ; .######.
        DB $7E ; .######.
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...

; Glyph code $52 at ROM $0B4C.
FONT_GLYPH_52:
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..

; Glyph code $53 at ROM $0B56.
FONT_GLYPH_53:
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
        DB $3C ; ..####..
        DB $18 ; ...##...
        DB $18 ; ...##...

; Glyph code $54 at ROM $0B60.
FONT_GLYPH_54:
        DB $C3 ; ##....##
        DB $C3 ; ##....##
        DB $C3 ; ##....##
        DB $DB ; ##.##.##
        DB $FF ; ########
        DB $FF ; ########
        DB $E7 ; ###..###
        DB $E7 ; ###..###
        DB $C3 ; ##....##
        DB $C3 ; ##....##

; Glyph code $55 at ROM $0B6A.
FONT_GLYPH_55:
        DB $66 ; .##..##.
        DB $66 ; .##..##.
        DB $7E ; .######.
        DB $3C ; ..####..
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...

; -----------------------------------------------------------------------------
; Eight-bit-wide, 22-row scene element; rendered by scene draw sets.
; Original width/height header: 1 bytes per row by 22 rows.
; -----------------------------------------------------------------------------
SCENE_VERTICAL_STRIP_8X22:
        DB $01,$16 ; width in bytes, height in rows
        DB $10 ; ...#....
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $58 ; .#.##...
        DB $78 ; .####...
        DB $1B ; ...##.##
        DB $1A ; ...##.#.
        DB $1E ; ...####.
        DB $1E ; ...####.
        DB $98 ; #..##...
        DB $98 ; #..##...
        DB $78 ; .####...
        DB $38 ; ..###...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...
        DB $18 ; ...##...

; -----------------------------------------------------------------------------
; Sixteen-bit-wide, 27-row scene element; rendered by scene draw sets.
; Original width/height header: 2 bytes per row by 27 rows.
; -----------------------------------------------------------------------------
SCENE_WIDE_SHAPE_16X27:
        DB $02,$1B ; width in bytes, height in rows
        DB $00,$01 ; ........ .......#
        DB $00,$03 ; ........ ......##
        DB $80,$03 ; #....... ......##
        DB $C0,$07 ; ##...... .....###
        DB $C0,$07 ; ##...... .....###
        DB $60,$1D ; .##..... ...###.#
        DB $00,$31 ; ........ ..##...#
        DB $80,$07 ; #....... .....###
        DB $E0,$1F ; ###..... ...#####
        DB $F0,$3D ; ####.... ..####.#
        DB $38,$39 ; ..###... ..###..#
        DB $04,$41 ; .....#.. .#.....#
        DB $80,$03 ; #....... ......##
        DB $C0,$07 ; ##...... .....###
        DB $E0,$0F ; ###..... ....####
        DB $F8,$1F ; #####... ...#####
        DB $3E,$29 ; ..#####. ..#.#..#
        DB $07,$E9 ; .....### ###.#..#
        DB $00,$01 ; ........ .......#
        DB $00,$09 ; ........ ....#..#
        DB $00,$05 ; ........ .....#.#
        DB $00,$05 ; ........ .....#.#
        DB $08,$1F ; ....#... ...#####
        DB $38,$1B ; ..###... ...##.##
        DB $38,$29 ; ..###... ..#.#..#
        DB $CC,$37 ; ##..##.. ..##.###
        DB $FE,$5D ; #######. .#.###.#

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_0: 24 stored bits x 21 rows.
; Original ROM $0BC4; copied to RAM $2100 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_0:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$80 ; ##...... ...#.### #.......
        DB $C0,$3F,$50 ; ##...... ..###### .#.#....
        DB $C0,$7F,$60 ; ##...... .####### .##.....
        DB $C0,$1F,$30 ; ##...... ...##### ..##....
        DB $80,$1F,$38 ; #....... ...##### ..###...
        DB $00,$07,$1C ; ........ .....### ...###..
        DB $80,$0F,$0E ; #....... ....#### ....###.
        DB $F8,$FF,$07 ; #####... ######## .....###
        DB $FC,$FF,$03 ; ######.. ######## ......##
        DB $CE,$FF,$01 ; ##..###. ######## .......#
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $FA,$3F,$00 ; #####.#. ..###### ........

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_1: 24 stored bits x 21 rows.
; Original ROM $0C05; copied to RAM $2141 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_1:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$00 ; ##...... ...#.### ........
        DB $C0,$3F,$00 ; ##...... ..###### ........
        DB $C0,$7F,$00 ; ##...... .####### ........
        DB $C0,$1F,$C0 ; ##...... ...##### ##......
        DB $80,$1F,$70 ; #....... ...##### .###....
        DB $00,$07,$3C ; ........ .....### ..####..
        DB $80,$0F,$0F ; #....... ....#### ....####
        DB $F8,$FF,$03 ; #####... ######## ......##
        DB $FC,$FF,$01 ; ######.. ######## .......#
        DB $CE,$FF,$00 ; ##..###. ######## ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $FA,$3F,$00 ; #####.#. ..###### ........

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_2: 24 stored bits x 21 rows.
; Original ROM $0C46; copied to RAM $2182 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_2:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$00 ; ##...... ...#.### ........
        DB $C0,$3F,$00 ; ##...... ..###### ........
        DB $C0,$7F,$00 ; ##...... .####### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $80,$1F,$C0 ; #....... ...##### ##......
        DB $00,$07,$38 ; ........ .....### ..###...
        DB $80,$0F,$0C ; #....... ....#### ....##..
        DB $F8,$FF,$0F ; #####... ######## ....####
        DB $FC,$FF,$03 ; ######.. ######## ......##
        DB $CE,$7F,$00 ; ##..###. .####### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $FA,$3F,$00 ; #####.#. ..###### ........

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_3: 24 stored bits x 21 rows.
; Original ROM $0C87; copied to RAM $21C3 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_3:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$00 ; ##...... ...#.### ........
        DB $C0,$3F,$00 ; ##...... ..###### ........
        DB $C0,$7F,$00 ; ##...... .####### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $80,$1F,$00 ; #....... ...##### ........
        DB $00,$07,$08 ; ........ .....### ....#...
        DB $80,$0F,$F0 ; #....... ....#### ####....
        DB $F8,$FF,$1F ; #####... ######## ...#####
        DB $FC,$FF,$0F ; ######.. ######## ....####
        DB $CE,$FF,$00 ; ##..###. ######## ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $FA,$3F,$00 ; #####.#. ..###### ........

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_4: 24 stored bits x 21 rows.
; Original ROM $0CC8; copied to RAM $2204 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_4:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$00 ; ##...... ...#.### ........
        DB $C0,$3F,$00 ; ##...... ..###### ........
        DB $C0,$7F,$00 ; ##...... .####### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $80,$1F,$00 ; #....... ...##### ........
        DB $00,$07,$00 ; ........ .....### ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $F8,$3F,$00 ; #####... ..###### ........
        DB $FC,$FF,$01 ; ######.. ######## .......#
        DB $CE,$FF,$0F ; ##..###. ######## ....####
        DB $C6,$1F,$7F ; ##...##. ...##### .#######
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $FA,$3F,$00 ; #####.#. ..###### ........

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_5: 24 stored bits x 21 rows.
; Original ROM $0D09; copied to RAM $2245 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_5:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$00 ; ##...... ...#.### ........
        DB $C0,$3F,$00 ; ##...... ..###### ........
        DB $C0,$7F,$00 ; ##...... .####### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $80,$1F,$00 ; #....... ...##### ........
        DB $00,$07,$00 ; ........ .....### ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $F8,$3F,$00 ; #####... ..###### ........
        DB $FC,$FF,$00 ; ######.. ######## ........
        DB $CE,$FF,$01 ; ##..###. ######## .......#
        DB $C6,$FF,$07 ; ##...##. ######## .....###
        DB $C6,$1F,$1E ; ##...##. ...##### ...####.
        DB $C6,$1F,$70 ; ##...##. ...##### .###....
        DB $C6,$1F,$00 ; ##...##. ...##### ........
        DB $FA,$3F,$00 ; #####.#. ..###### ........

; -----------------------------------------------------------------------------
; AIM_DIRECTION_PATTERN_6: 24 stored bits x 21 rows.
; Original ROM $0D4A; copied to RAM $2286 by VM word $0F.
; Selected by a controller direction through an indexed graphics pointer.
; -----------------------------------------------------------------------------
AIM_DIRECTION_PATTERN_6:
        DB $03,$15 ; width in bytes, height in rows
        DB $00,$05,$00 ; ........ .....#.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0D,$00 ; #....... ....##.# ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $C8,$9F,$00 ; ##..#... #..##### ........
        DB $F8,$FF,$00 ; #####... ######## ........
        DB $C0,$17,$00 ; ##...... ...#.### ........
        DB $C0,$3F,$00 ; ##...... ..###### ........
        DB $C0,$7F,$00 ; ##...... .####### ........
        DB $C0,$1F,$00 ; ##...... ...##### ........
        DB $80,$1F,$00 ; #....... ...##### ........
        DB $00,$07,$00 ; ........ .....### ........
        DB $80,$0F,$00 ; #....... ....#### ........
        DB $F8,$3F,$00 ; #####... ..###### ........
        DB $FC,$7F,$00 ; ######.. .####### ........
        DB $CE,$FF,$01 ; ##..###. ######## .......#
        DB $C6,$FF,$03 ; ##...##. ######## ......##
        DB $C6,$1F,$17 ; ##...##. ...##### ...#.###
        DB $C6,$1F,$0E ; ##...##. ...##### ....###.
        DB $C6,$1F,$14 ; ##...##. ...##### ...#.#..
        DB $FA,$3F,$20 ; #####.#. ..###### ..#.....

; -----------------------------------------------------------------------------
; PLAYER_FRAME_PATTERN_A_24X12: 3 bytes per row (24 stored bits) x 12 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
PLAYER_FRAME_PATTERN_A_24X12:
        DB $03,$0C ; width (bytes), height (rows)
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
; PLAYER_FRAME_PATTERN_B_24X12: 3 bytes per row (24 stored bits) x 12 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
PLAYER_FRAME_PATTERN_B_24X12:
        DB $03,$0C ; width (bytes), height (rows)
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
; PLAYER_FRAME_PATTERN_C_24X12: 3 bytes per row (24 stored bits) x 12 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
PLAYER_FRAME_PATTERN_C_24X12:
        DB $03,$0C ; width (bytes), height (rows)
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
; EVENT_OBJECT_PATTERN_24X32: 3 bytes per row (24 stored bits) x 32 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
EVENT_OBJECT_PATTERN_24X32:
        DB $03,$20 ; width (bytes), height (rows)
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

; -----------------------------------------------------------------------------
; EVENT_OBJECT_PATTERN_32X11: 4 bytes per row (32 stored bits) x 11 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
EVENT_OBJECT_PATTERN_32X11:
        DB $04,$0B ; width (bytes), height (rows)
        DB $A0,$00,$00,$00 ; #.#..... ........ ........ ........
        DB $B0,$01,$00,$00 ; #.##.... .......# ........ ........
        DB $B0,$01,$3C,$00 ; #.##.... .......# ..####.. ........
        DB $B0,$01,$7E,$00 ; #.##.... .......# .######. ........
        DB $F9,$13,$FF,$00 ; #####..# ...#..## ######## ........
        DB $FF,$9F,$FF,$81 ; ######## #..##### ######## #......#
        DB $F8,$C7,$FF,$9F ; #####... ##...### ######## #..#####
        DB $FC,$FF,$FF,$FF ; ######.. ######## ######## ########
        DB $FE,$FF,$FF,$FF ; #######. ######## ######## ########
        DB $00,$00,$FF,$40 ; ........ ........ ######## .#......
        DB $00,$00,$00,$20 ; ........ ........ ........ ..#.....

; -----------------------------------------------------------------------------
; Expanded-graphics terminator at $0E8D. The VM unpacker returns here.
; -----------------------------------------------------------------------------
EXPANDED_GRAPHICS_TERMINATOR:
        DB $00

; -----------------------------------------------------------------------------
; Special-object 24x28 pattern at ROM $0E8E, referenced from $0F5D.
; 3 source bytes per row, 28 rows. Its last row shares the $0EE2-$0EE3
; bytes used as the unused first entry in PLAYER_ONE_AIM_POINTERS.
; The overlap is intentional source-byte ownership: DO NOT duplicate.
; -----------------------------------------------------------------------------
SPECIAL_OBJECT_PATTERN_24X28:
        DB $03,$1C ; width in bytes, height in rows
        DB $00,$7E,$00 ; ........ .######. ........
        DB $80,$FF,$01 ; #....... ######## .......#
        DB $E0,$FF,$07 ; ###..... ######## .....###
        DB $F0,$FF,$0F ; ####.... ######## ....####
        DB $F0,$FF,$0F ; ####.... ######## ....####
        DB $F8,$FF,$1F ; #####... ######## ...#####
        DB $F8,$FF,$1F ; #####... ######## ...#####
        DB $F8,$FF,$1F ; #####... ######## ...#####
        DB $F8,$E7,$1F ; #####... ###..### ...#####
        DB $F0,$C3,$0F ; ####.... ##....## ....####
        DB $F0,$81,$0F ; ####.... #......# ....####
        DB $E0,$81,$07 ; ###..... #......# .....###
        DB $C0,$81,$03 ; ##...... #......# ......##
        DB $80,$C3,$01 ; #....... ##....## .......#
        DB $F0,$FF,$0F ; ####.... ######## ....####
        DB $E0,$FF,$07 ; ###..... ######## .....###
        DB $E0,$FF,$07 ; ###..... ######## .....###
        DB $F4,$FF,$2F ; ####.#.. ######## ..#.####
        DB $84,$3C,$21 ; #....#.. ..####.. ..#....#
        DB $04,$81,$20 ; .....#.. #......# ..#.....
        DB $04,$81,$20 ; .....#.. #......# ..#.....
        DB $06,$81,$60 ; .....##. #......# .##.....
        DB $F7,$FF,$EF ; ####.### ######## ###.####
        DB $06,$81,$60 ; .....##. #......# .##.....
        DB $04,$00,$20 ; .....#.. ........ ..#.....
        DB $04,$00,$20 ; .....#.. ........ ..#.....
        DB $04,$00,$20 ; .....#.. ........ ..#.....
; Last row: $0EE1 plus shared $0EE2-$0EE3 (the DW immediately below).
        DB $04

; -----------------------------------------------------------------------------
; Player 1 aiming graphics pointer table ($0EE2).
; INPUT bits 4-6 select even byte offsets $02,$04,...,$0E.
; $00 is rejected by the controller handler; it shares the final two
; bytes of SPECIAL_OBJECT_PATTERN_24X28 and is never dereferenced.
; The table selects a 24x21 pattern in original ROM.
; -----------------------------------------------------------------------------
PLAYER_ONE_AIM_POINTERS:
        DW $2000
        DW AIM_DIRECTION_PATTERN_6
        DW AIM_DIRECTION_PATTERN_2
        DW AIM_DIRECTION_PATTERN_3
        DW AIM_DIRECTION_PATTERN_0
        DW AIM_DIRECTION_PATTERN_5
        DW AIM_DIRECTION_PATTERN_1

; -----------------------------------------------------------------------------
; Player 2 aiming graphics table ($0EF0), same direction offsets.
; Each active entry points to the corresponding graphic expanded to RAM
; at $2100 by VM word $0F. The first entry ($0CC8) is shared with
; Player 1's last direction and cannot be selected by Player 2's zero
; offset (rejected before reading the table).
; -----------------------------------------------------------------------------
PLAYER_TWO_AIM_POINTERS:
        DW AIM_DIRECTION_PATTERN_4
        DW $2286
        DW $2182
        DW $21C3
        DW $2100
        DW $2245
        DW $2141

; -----------------------------------------------------------------------------
; Player 2 final direction pattern at $0EFE; also shot lookup base.
; The shared bytes form pointer $2204 for direction $0E.
; Projectile selection starts at +$02, so no shot lookup reads them.
; -----------------------------------------------------------------------------
SHOT_PARAMETER_BASE:
        DW $2204

; -----------------------------------------------------------------------------
; Shot origin adjustment pairs at $0F00, indexed by the SAME nonzero
; even direction offsets $02..$0E used by aiming. Each record is
; (X adjustment, Y adjustment) in 8-bit modular arithmetic, added
; to the player's origin by CALCULATE_PROJECTILE_ORIGIN; these are NOT DWs.
; Rows below are in ascending direction-index order.
; -----------------------------------------------------------------------------
SHOT_DIRECTION_DELTAS:
        DB $06,$1A
        DB $FF,$08
        DB $00,$0C
        DB $FA,$FE
        DB $03,$16
        DB $FD,$02
        DB $01,$14

; -----------------------------------------------------------------------------
; Game display scene set selected from state at $2002 ($0F0E).
; Each entry contains a bitmap destination (HL), then the address
; of its original width/height-prefixed source pattern (DE).
; -----------------------------------------------------------------------------
SCENE_DRAW_TABLE_PRIMARY:
        DW $2813,SCENE_VERTICAL_STRIP_8X22
        DW $3633,SCENE_VERTICAL_STRIP_8X22
        DW $3012,SCENE_VERTICAL_STRIP_8X22
        DW $3632,SCENE_WIDE_SHAPE_16X27
        DW $2812,SCENE_WIDE_SHAPE_16X27

; -----------------------------------------------------------------------------
; Secondary game display set selected from state at $2005 ($0F22).
; Each entry contains a bitmap destination (HL), then the address
; of its original width/height-prefixed source pattern (DE).
; -----------------------------------------------------------------------------
SCENE_DRAW_TABLE_SECONDARY:
        DW $380C,SCENE_VERTICAL_STRIP_8X22
        DW $2A0C,SCENE_VERTICAL_STRIP_8X22
        DW $300D,SCENE_VERTICAL_STRIP_8X22
        DW $2A0C,SCENE_WIDE_SHAPE_16X27
        DW $380C,SCENE_WIDE_SHAPE_16X27

; -----------------------------------------------------------------------------
; Final scene pattern drawn in output mode $04 ($0F36).
; Each entry contains a bitmap destination (HL), then the address
; of its original width/height-prefixed source pattern (DE).
; -----------------------------------------------------------------------------
SCENE_DRAW_TABLE_FINAL:
        DW $300F,SCENE_VERTICAL_STRIP_8X22

; Event lookup records at $0F3A-$0F51. IRQ projectile qualification
; indexes these 24 original bytes and extracts a nibble into RAM $201C.
; Individual event outcomes have not yet been traced in MAME.
PROJECTILE_EVENT_LOOKUP_RECORDS:
        DB $11,$11,$11,$52,$65,$99,$99,$99
        DB $11,$11,$11,$53,$75,$99,$99,$99
        DB $11,$11,$11,$54,$85,$99,$99,$99

; Fifteen original object-initialization bytes at $0F52, copied to
; $2050 by GAME_PREPARE_SPECIAL_OBJECT. These include $0E8E, the
; pointer to SPECIAL_OBJECT_PATTERN_24X28.
SPECIAL_OBJECT_INITIALIZATION_BYTES:
        DB $C4,$00,$74,$70,$20,$FF,$A0,$0A,$B4,$00,$00,$8E,$0E,$00,$00

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; Original game-message glyph codes ($0F61-$0FFF).
; Quoted DB strings represent the actual encoded ROM bytes, NOT ASCII
; transcriptions of what appears on the screen. For example, the first
; displayed "GAME" is stored as "GAKE" because glyph code $4B is M.
; $40 is the blank glyph; $30+ codes use the ROM font at $09F8.
; Values below $30 are display-cursor controls and remain numeric.
; The decoded screen wording is described above each source entry.
; -----------------------------------------------------------------------------

; Displayed: GAME    OVER
TEXT_GAME_OVER:
        DB "GAKE@@@@MSEO"

; Displayed: Blank title area, then GUN FIGHT
TEXT_TITLE_BLANKS:
        DB "@@@@@@@@@@@@@@@@@@@@@@@@@","@@@@@@@",$00,$00,$25
        DB "GRL@FIGHQ"

; Displayed: INSERT COIN
TEXT_INSERT_COIN:
        DB "ILPEOQ@CMIL"

; Displayed: Blank message field
TEXT_CLEAR_MESSAGE_FIELD:
        DB "@@@@@@@@@@@"

; Displayed: GET READY
TEXT_READY_AND_DIALOGUE:
        DB "GEQ@OEADU"

; Displayed: Separators and cursor advancement
TEXT_READY_SEPARATOR:
        DB "::::::",$20,"::::::"

; Displayed: DRAW, GOT ME, HEY PARDNER, YOU HAVE CREDIT, PUSH BUTTON
TEXT_DRAW_AND_DIALOGUE:
        DB "@@DOAT;@@GMQ@KE;HEU@NAODL","EO;",$2E,"UMR@HASE@COEDIQ<"
        DB $00,$00,$1A,"NRPH@BRQQML"
