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
; Internal block: Shared IRQ loop: extract next nonzero list pointer from a 0x12-byte slot at $206F.
IRQ_COPY_OBJECT_LIST_ENTRY:
        PUSH HL
        CALL TAKE_AND_CLEAR_OBJECT_POINTER
        JP Z,IRQ_ADVANCE_FIRST_LIST_SLOT
; Internal block: Copy a pair of source bytes to a destination row, advance by $20, repeat using B.
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
; Internal block: Restore list slot address and advance $12 until low byte reaches $B7.
IRQ_ADVANCE_FIRST_LIST_SLOT:
        POP HL
        LD DE,$0012
        ADD HL,DE
        LD A,L
        CP $B7
        JP NZ,IRQ_COPY_OBJECT_LIST_ENTRY
        LD HL,$20A2
; Internal block: Process the $20A2-list slots, setting bitmap pointer and the port-$02 mode.
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
; Internal block: Merge two source bytes through graphics ports $04/$03 with OR into bitmap row.
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
; Internal block: Restore list slot and step backward by $12 until low byte reaches $5A.
IRQ_ADVANCE_SECOND_LIST_SLOT:
        POP HL
        LD DE,$FFEE
        ADD HL,DE
        LD A,L
        CP $5A
        JP NZ,IRQ_COMPOSITE_SECOND_LIST_ENTRY
        LD HL,$20B2
        JP IRQ_CONSUME_BITMAP_JOB
; Internal block: Shared continuation of RST $08/$10: choose pending bitmap operations or input sampling.
IRQ_RESUME_COMMON_FRAME_PATH:
        LD A,($20B9)
        AND A
        JP M,IRQ_SAMPLE_PORT2_AND_RESTORE
        LD HL,$20AB
; Internal block: Consume pointer fields from pending draw/clear descriptor at HL.
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
; Internal block: Restore pending descriptor, select video mode and draw two object-pattern sources.
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
        LD HL,$2063
; Internal block: Check active flag and coordinate window for one $12-byte projectile slot.
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
; Internal block: Apply upper limit $90 to signed/alternate projectile coordinate path.
IRQ_CHECK_PROJECTILE_UPPER_WINDOW:
        CP $90
        JP NC,IRQ_NEXT_PROJECTILE_SLOT
; Internal block: Check additional record field and lower bound before reporting collision code.
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
        JP NC,IRQ_STORE_EVENT_SELECTOR
        RRA
        RRA
        RRA
        RRA
; Internal block: Extract low nibble of ROM table value into RAM $201C (event selector).
IRQ_STORE_EVENT_SELECTOR:
        AND $0F
        LD ($201C),A
; Internal block: Advance by $12 through projectile records until low byte is $AB.
IRQ_NEXT_PROJECTILE_SLOT:
        POP HL
        LD DE,$0012
        ADD HL,DE
        LD A,$AB
        CP L
        JP NZ,IRQ_CHECK_PROJECTILE_SLOT
        LD HL,$2063
; Internal block: Update an active object and calculate its bitmap address and bit phase.
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
; Internal block: Advance active object record by $12; after final slot, examine $20BE.
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
; Internal block: Save initial walker address to $20C0 and clear cycle activity byte $20BD.
IRQ_BEGIN_OBJECT_CYCLE:
        LD ($20C0),HL
        XOR A
        LD ($20BD),A
; Internal block: Update active object, optionally prepare drawing job, persist current pointer.
IRQ_STEP_OBJECT_CYCLE:
        LD A,(HL)
        AND A
        JP P,IRQ_ADVANCE_OBJECT_CYCLE
        CALL UPDATE_ACTIVE_OBJECT_COORDINATES
        LD A,($20BD)
        AND A
        CALL Z,QUEUE_OBJECT_BITMAP_UPDATE
        LD ($20BE),HL
; Internal block: Advance the object walker by $13, wrapping at $2063 to $202A.
IRQ_ADVANCE_OBJECT_CYCLE:
        LD DE,$0013
        ADD HL,DE
        LD A,$63
        CP L
        JP NZ,IRQ_CHECK_OBJECT_CYCLE_COMPLETE
        LD HL,$202A
; Internal block: Compare walker against starting slot and update output/timing after a full pass.
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
; Internal block: Decrease round timer at $2009 and update BCD game-state counters on rollover.
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
; Internal block: Update BCD timer at $2003; on expiry transition to wait counter.
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
; Internal block: Decrement $2015 and branch to frame end until the delay expires.
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
; Internal block: Double-sample input port $02; dispatch stable changes, restore saved registers.
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
; Internal block: Save source dimensions and destination, start another 32-byte-spaced bitmap row.
DRAW_OBJECT_NEXT_ROW:
        PUSH BC
        PUSH HL
; Internal block: Feed a pattern byte to port $04, read pixel result at port $03, and store.
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
; Internal block: Return current axis byte in D, clear A after the in-bounds check.
AXIS_RETURN_UNCHANGED:
        LD D,(HL)
        XOR A
        RET
; Internal block: Adjust compact axis record on range violation; branch by B direction mode.
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
; Internal block: Zero a field and select status $60 or alternate path from direction mode.
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
; Internal block: Return axis value in D and status in A, with flags from AND A.
AXIS_RETURN_STATUS:
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
; -----------------------------------------------------------------------------
; QUEUE_OBJECT_BITMAP_UPDATE — callable helper reached from object walk
; Entry HL=current object record, D=coordinate selected by axis update.
; Save object link and converted bitmap address in one pending-job slot,
; $20AB or $20B2 depending on D relative to $60. Store status in $20BD;
; select a frame pointer from the $0349/$0351 tables when required.
; Some branches clear a pending job instead of drawing it. Return to
; caller at IRQ_STEP_OBJECT_CYCLE; modifies A/B/C/D/E/HL and RAM state.
; -----------------------------------------------------------------------------
; Internal block: Construct pending object bitmap descriptor in $20AB or $20B2 and update slot flags.
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
; Internal block: Store source slot pointer, converted video address/phase, and object linkage.
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
; Internal block: Write pending object link pointer and XOR status into source object control byte.
WRITE_OBJECT_LINK_AND_XOR_STATE:
        ADD HL,BC
        LD (HL),E
        INC HL
        LD (HL),D
        POP HL
        XOR (HL)
        LD (HL),A
        RET
; Internal block: Choose player-specific four-entry frame table based on object slot and $2009.
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
; Internal block: Scale the $2009 frame selector and index the four-entry player frame table.
LOOKUP_PLAYER_FRAME_POINTER:
        LD A,($2009)
        AND $0C
        RRCA
        ADD A,L
        LD L,A
        JP NC,LOAD_FRAME_POINTER_AND_RESET_FLAGS
        INC H
; Internal block: Read frame pointer into DE; clear/change related status through shared exit.
LOAD_FRAME_POINTER_AND_RESET_FLAGS:
        LD E,(HL)
        INC HL
        LD D,(HL)
        POP HL
        PUSH HL
        LD BC,$000D
        XOR A
        JP WRITE_OBJECT_LINK_AND_XOR_STATE
; Internal block: Zero four pending-record bytes and clear source object's active control byte.
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
        DW ROM_FRAME_PATTERN_A,ROM_FRAME_PATTERN_B,ROM_FRAME_PATTERN_C,ROM_FRAME_PATTERN_B
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
; Internal block: One step of the three-bit right shift of DE, preserving carry between D/E.
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
; Internal block: Inline copy loop for VM words $05/$06: copy C bytes HL to DE.
COPY_SCRIPT_LITERAL_BYTE:
        LD A,(HL)
        INC HL
        LD (DE),A
        INC DE
        DEC C
        JP NZ,COPY_SCRIPT_LITERAL_BYTE
        RET
; -----------------------------------------------------------------------------
; SELECT_AIM_DESCRIPTOR
; Fetch a two-byte relative shot adjustment at SHOT_PARAMETER_BASE + A.
; A is the previously saved nonzero even controller direction offset.
; B receives the first byte; D the second. Combine the offset with
; object bytes +0 and +4 and return adjusted DE for projectile placement.
; This is NOT a pointer lookup; unlike INSTALL_AIM_DESCRIPTOR.
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
; Internal block: Initialize eight consecutive RAM state bytes at $2002.
CLEAR_INITIAL_GAME_STATE_BYTE:
        LD (HL),B
        INC HL
        DEC A
        JP NZ,CLEAR_INITIAL_GAME_STATE_BYTE
; Internal block: Clear display, install initial script $0821, enable interrupts and fall into VM.
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
; Internal block: Fetch indexed command, advance $2000, look up 16-bit handler at $09AE and jump.
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
NATIVE_WORD_14_INPUT_AND_EVENT_DISPATCH:
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
; Internal block: At VM input/event word exit, refresh score when round state $2009 is below $22.
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
; Internal block: Rotate change mask C and shift bit mask B until first changed input bit.
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
; Internal block: Update stored input state at HL; load native action address from DE and JP (HL).
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
        LD HL,PLAYER_ONE_AIM_POINTERS
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
; Player-one input action: write $FE (or zero when input inactive) to object field at $202A+5.
PLAYER_ONE_AXIS5_NEGATIVE:
        LD B,$FE
; Internal block: If transition flags indicate release, zero B before storing axis5 velocity.
P1_AXIS5_APPLY_PRESS_FLAG:
        JP NZ,P1_AXIS5_SELECT_OBJECT
        LD B,$00
; Internal block: Select player-one object base $202A; shared store begins at next label.
P1_AXIS5_SELECT_OBJECT:
        LD HL,$202A
; Internal block: Shared player-axis helper: mark object $C0 and write signed velocity at offset +5.
STORE_AXIS5_COMPONENT:
        LD (HL),$C0
        LD DE,$0005
        ADD HL,DE
        LD (HL),B
        RET
; PLAYER_ONE_AXIS5_POSITIVE
; Player-one input action: write $02 (or zero when input inactive) to object field at $202A+5.
PLAYER_ONE_AXIS5_POSITIVE:
        LD B,$02
        JP P1_AXIS5_APPLY_PRESS_FLAG
; PLAYER_ONE_AXIS1_NEGATIVE
; Player-one input action: write $FF (or zero when input inactive) to object field at $202A+1.
PLAYER_ONE_AXIS1_NEGATIVE:
        LD B,$FF
; Internal block: If transition flags indicate release, zero B before storing axis1 velocity.
P1_AXIS1_APPLY_PRESS_FLAG:
        JP NZ,P1_AXIS1_SELECT_OBJECT
        LD B,$00
; Internal block: Select player-one object base $202A for axis1 update.
P1_AXIS1_SELECT_OBJECT:
        LD HL,$202A
; Internal block: Shared axis helper: mark object $C0 and write signed velocity to byte +1.
STORE_AXIS1_COMPONENT:
        LD (HL),$C0
        INC HL
        LD (HL),B
        RET
; PLAYER_ONE_AXIS1_POSITIVE
; Player-one input action: write $01 (or zero when input inactive) to object field at $202A+1.
PLAYER_ONE_AXIS1_POSITIVE:
        LD B,$01
        JP P1_AXIS1_APPLY_PRESS_FLAG
; PLAYER_TWO_AXIS5_NEGATIVE
; Player-two input action: write $FE (or zero when input inactive) to object field at $203D+5.
PLAYER_TWO_AXIS5_NEGATIVE:
        LD B,$FE
; Internal block: Player-two axis5 press/release gating before shared velocity store.
P2_AXIS5_APPLY_PRESS_FLAG:
        JP NZ,P2_AXIS5_SELECT_OBJECT
        LD B,$00
; Internal block: Select player-two object base $203D and jump to shared +5 velocity store.
P2_AXIS5_SELECT_OBJECT:
        LD HL,$203D
        JP STORE_AXIS5_COMPONENT
; PLAYER_TWO_AXIS5_POSITIVE
; Player-two input action: write $02 (or zero when input inactive) to object field at $203D+5.
PLAYER_TWO_AXIS5_POSITIVE:
        LD B,$02
        JP P2_AXIS5_APPLY_PRESS_FLAG
; PLAYER_TWO_AXIS1_NEGATIVE
; Player-two input action: write $FF (or zero when input inactive) to object field at $203D+1.
PLAYER_TWO_AXIS1_NEGATIVE:
        LD B,$FF
; Internal block: Player-two axis1 press/release gating before shared velocity store.
P2_AXIS1_APPLY_PRESS_FLAG:
        JP NZ,P2_AXIS1_SELECT_OBJECT
        LD B,$00
; Internal block: Select player-two object base $203D and jump to shared +1 velocity store.
P2_AXIS1_SELECT_OBJECT:
        LD HL,$203D
        JP STORE_AXIS1_COMPONENT
; PLAYER_TWO_AXIS1_POSITIVE
; Player-two input action: write $01 (or zero when input inactive) to object field at $203D+1.
PLAYER_TWO_AXIS1_POSITIVE:
        LD B,$01
        JP P2_AXIS1_APPLY_PRESS_FLAG
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
        JP Z,FIRE_P1_CHECK_GUARD_AND_LAUNCH
        LD HL,$2075
        LD A,(HL)
        AND $80
        RET NZ
; Internal block: Reject fire when $2012 nonzero; otherwise update count and configure projectile.
FIRE_P1_CHECK_GUARD_AND_LAUNCH:
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
; Internal block: Shared firing tail: apply direction-based shot position; atomically write projectile fields.
FIRE_INSTALL_PROJECTILE_FROM_DIRECTION:
        LD HL,SHOT_PARAMETER_BASE
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
; Called by both player firing handlers.
; Entry BC=player shot-counter address, HL=guard/delay state address,
; DE=scoreboard output destination. Increment (BC), compare with six;
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
; Internal block: Restore A from B after updating round state, before drawing ammunition indicator.
SHOT_RESTORE_DISPLAY_DIGIT:
        LD A,B
; Internal block: Tail-call formatted text with character stream $0FA4.
SHOT_DRAW_AMMO_INDICATOR:
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
        JP Z,FIRE_P2_CHECK_GUARD_AND_LAUNCH
        LD HL,$2099
        LD A,(HL)
        AND $80
        RET NZ
; Internal block: Reject fire when $2013 nonzero; otherwise update count and configure projectile.
FIRE_P2_CHECK_GUARD_AND_LAUNCH:
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
        JP FIRE_INSTALL_PROJECTILE_FROM_DIRECTION
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
; Internal block: Store resulting round mode, decrement $20C6 and clear selected score bytes.
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
NATIVE_WORD_13_UPDATE_SCORE_TEXT:
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
; Internal block: Extract high nibble from RAM source, choosing placeholder $10 for leading zero.
SCORE_DECODE_HIGH_BCD_DIGIT:
        LD A,(DE)
        RRA
        RRA
        RRA
        RRA
        AND $0F
        JP NZ,SCORE_WRITE_BCD_DIGITS
        LD A,$10
; Internal block: Emit ASCII high/low score digits into formatted text buffer.
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
; Entry A=source character count, HL=formatted source stream,
; DE=bitmap destination. Source bytes < $30 advance display position;
; bytes >= $30 select glyph (character-$30) from 10-byte font at $09F8.
; Copy 10 rows per glyph with $20-byte video line stride, then advance
; destination one character byte. A/B/C/DE/flags changed; I/O: bitmap RAM.
; Called by VM word $01, score formatter and player-status display words.
; -----------------------------------------------------------------------------
DRAW_FORMATTED_TEXT:
        PUSH AF
; Internal block: Fetch source char; values under $30 act as horizontal destination advances.
TEXT_FETCH_CHARACTER_OR_ADVANCE:
        LD A,(HL)
        INC HL
        SUB $30
        JP P,TEXT_LOOKUP_FONT_GLYPH
        LD B,A
; Internal block: Advance bitmap byte address and handle 32-byte scanline boundary.
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
; Internal block: Use character minus $30 as index into 10-byte digit glyph records.
TEXT_LOOKUP_FONT_GLYPH:
        PUSH HL
        PUSH DE
        LD HL,FONT_SCORE_DIGITS
        JP Z,TEXT_SETUP_TEN_SCANLINES
        LD BC,$000A
; Internal block: Advance font pointer by 10 bytes until glyph index exhausted.
TEXT_SKIP_TO_NEXT_DIGIT_GLYPH:
        ADD HL,BC
        DEC A
        JP NZ,TEXT_SKIP_TO_NEXT_DIGIT_GLYPH
; Internal block: Exchange source/destination and initialize ten glyph rows with $20 stride.
TEXT_SETUP_TEN_SCANLINES:
        EX DE,HL
        LD BC,$0020
        LD A,$0A
; Internal block: Write one glyph byte to bitmap, step one scanline and repeat ten times.
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
NATIVE_WORD_02_SET_2003:
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
NATIVE_WORD_03_SET_2015:
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
NATIVE_WORD_04_CLEAR_DISPLAY_MEMORY:
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
; Internal block: Zero-fill video using PUSH BC from temporary stack pointer $400F.
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
NATIVE_WORD_09_GOTO_SCRIPT:
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
NATIVE_WORD_08_TOGGLE_OBJECT_BITS:
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
NATIVE_WORD_0A_GAME_DISPLAY_SEQUENCE:
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
; Internal block: Reduce display state and determine whether the next pattern needs frame setup.
GAME_SELECT_NEXT_PATTERN:
        DEC A
        JP M,GAME_SELECT_SECOND_PATTERN_SET
        CP $02
        CALL P,GAME_PREPARE_SPECIAL_OBJECT
        CP $05
        JP M,GAME_DRAW_PATTERN_FROM_TABLE
        LD A,$04
; Internal block: Read graphic pointer and destination from table; draw current pattern.
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
; Internal block: If bit6 of $2016 not set, set it, select port-$02 mode and draw last group.
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
; Internal block: Check object at $2050 and copy a 15-byte initialization record when inactive.
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
; Internal block: Set bit6 in $2016; restore caller AF/HL saved by special-object helper.
GAME_SET_PATTERN_READY_FLAG:
        LD A,($2016)
        OR $40
        LD ($2016),A
        POP AF
        POP HL
        RET
NATIVE_WORD_0C_INCREMENT_BCD_AND_RESET:
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
NATIVE_WORD_0B_INITIALIZE_OBJECT:
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
NATIVE_WORD_0D_OUTPUT_AND_SET_2014:
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
; NO_OP_INPUT_ACTION
; One-byte RET used by six native input action-table positions; also the fall-through exit of VM word $0D.
NO_OP_INPUT_ACTION:
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
; Internal block: Save row destination and fill another horizontal span using 32-byte stride.
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
NATIVE_WORD_0F_EXPAND_GRAPHICS_TABLE:
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
; Internal block: Read next packed graphics record from ROM $0BC4; zero byte ends stream.
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
; Internal block: Compute destination offset from record width for the next packed column.
EXPAND_GRAPHICS_NEXT_COLUMN:
        PUSH BC
        LD A,B
        LD B,$00
        ADD HL,BC
        LD B,A
; Internal block: Read next source byte and prepare eight-bit rotation into display orientation.
EXPAND_GRAPHICS_READ_PACKED_COLUMN:
        DEC HL
        LD A,(DE)
        INC DE
        PUSH DE
        LD D,A
        LD E,$00
        LD B,$08
; Internal block: Rotate source bits into the expanded byte through D/E shift registers.
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
NATIVE_WORD_11_DRAW_STATUS_203F:
; -----------------------------------------------------------------------------
; DRAW_SECOND_PLAYER_STATUS
; VM word $11: select status record at $203F and branch to the shared text drawing path.
; -----------------------------------------------------------------------------
DRAW_SECOND_PLAYER_STATUS:
        LD HL,$203F
        JP DRAW_STATUS_GET_BITMAP_DESTINATION
NATIVE_WORD_12_DRAW_STATUS_202C:
; -----------------------------------------------------------------------------
; DRAW_FIRST_PLAYER_STATUS
; VM word $12: select status record at $202C and use the shared status drawing path.
; -----------------------------------------------------------------------------
DRAW_FIRST_PLAYER_STATUS:
        LD HL,$202C
; Internal block: Read packed object coordinates and derive display destination for 7 chars.
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
NATIVE_WORD_10_CONDITIONAL_GOTO_0882:
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
NATIVE_WORD_00_WAIT_OR_REPEAT:
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
CMD_0821_CLEAR_DISPLAY_MEMORY:
        DB $04 ; word CLEAR_DISPLAY_MEMORY ($04)
CMD_0822_UPDATE_SCORE_TEXT:
        DB $13 ; word UPDATE_SCORE_TEXT ($13)
CMD_0823_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $0C ; format
        DW $0F61 ; source
        DW $240A ; destination
CMD_0829_CONDITIONAL_GOTO_0882:
        DB $10 ; word CONDITIONAL_GOTO_0882 ($10)
CMD_082A_EXPAND_GRAPHICS_TABLE:
        DB $0F ; word EXPAND_GRAPHICS_TABLE ($0F)
CMD_082B_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $5A ; state
CMD_082D_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_082E_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $29 ; format
        DW $0F6D ; source
        DW $2600 ; destination
CMD_0834_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $5A ; state
CMD_0836_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0837_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $0B ; format
        DW $0F99 ; source
        DW $3D14 ; destination
CMD_083D_COPY_INLINE_15:
        DB $05 ; word COPY_INLINE_15 ($05)
        DW $202A ; destination
        DB $C3,$01,$00,$00,$40,$00,$66,$0B,$AA,$8B,$0D,$4A,$0D,$8B,$0D ; inline RAM data
CMD_084F_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $5A ; state
CMD_0851_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0852_COPY_INLINE_9:
        DB $06 ; word COPY_INLINE_9 ($06)
        DW $2063 ; destination
        DB $C6,$03,$54,$00,$FE,$02,$78,$00,$C8 ; inline RAM data
CMD_085E_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $4B ; state
CMD_0860_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0861_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $0B ; format
        DW $0FA4 ; source
        DW $3D14 ; destination
CMD_0867_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $3C ; state
CMD_0869_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_086A_COPY_INLINE_15:
        DB $05 ; word COPY_INLINE_15 ($05)
        DW $203D ; destination
        DB $C2,$FF,$40,$00,$60,$00,$66,$27,$A0,$C7,$22,$00,$21,$C7,$22 ; inline RAM data
CMD_087C_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $40 ; state
CMD_087E_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_087F_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_0821_CLEAR_DISPLAY_MEMORY ; script destination
CMD_0882_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $27 ; format
        DW $0FD5 ; source
        DW $2A01 ; destination
CMD_0888_COPY_INLINE_15:
        DB $05 ; word COPY_INLINE_15 ($05)
        DW $202A ; destination
        DB $C3,$02,$00,$00,$40,$00,$A0,$0B,$AA,$8B,$0D,$4A,$0D,$8B,$0D ; inline RAM data
CMD_089A_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_089B_CLEAR_DISPLAY_MEMORY:
        DB $04 ; word CLEAR_DISPLAY_MEMORY ($04)
CMD_089C_UPDATE_SCORE_TEXT:
        DB $13 ; word UPDATE_SCORE_TEXT ($13)
CMD_089D_EXPAND_GRAPHICS_TABLE:
        DB $0F ; word EXPAND_GRAPHICS_TABLE ($0F)
CMD_089E_GAME_DISPLAY_SEQUENCE:
        DB $0A ; word GAME_DISPLAY_SEQUENCE ($0A)
CMD_089F_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $09 ; format
        DW $0FAF ; source
        DW $2E0C ; destination
CMD_08A5_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $0C ; format
        DW $0FB8 ; source
        DW $3EA2 ; destination
CMD_08AB_COPY_INLINE_15:
        DB $05 ; word COPY_INLINE_15 ($05)
        DW $202A ; destination
        DB $C0,$01,$00,$00,$48,$00,$66,$13,$9A,$8B,$0D,$87,$0C,$8B,$0D ; inline RAM data
CMD_08BD_COPY_INLINE_15:
        DB $05 ; word COPY_INLINE_15 ($05)
        DW $203D ; destination
        DB $C0,$FF,$E7,$A0,$48,$00,$66,$13,$9A,$C7,$22,$C3,$21,$C7,$22 ; inline RAM data
CMD_08CF_COPY_INLINE_9:
        DB $06 ; word COPY_INLINE_9 ($06)
        DW $2063 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08DB_COPY_INLINE_9:
        DB $06 ; word COPY_INLINE_9 ($06)
        DW $2075 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08E7_COPY_INLINE_9:
        DB $06 ; word COPY_INLINE_9 ($06)
        DW $2087 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08F3_COPY_INLINE_9:
        DB $06 ; word COPY_INLINE_9 ($06)
        DW $2099 ; destination
        DB $06,$00,$00,$04,$F8,$00,$00,$0A,$C8 ; inline RAM data
CMD_08FF_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $1E ; state
CMD_0901_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0902_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $09 ; format
        DW $0FC5 ; source
        DW $2E0C ; destination
CMD_0908_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $0A ; state
CMD_090A_CLEAR_OBJECT_FLAGS:
        DB $07 ; word CLEAR_OBJECT_FLAGS ($07)
        DW $202A ; RAM address / target / packed dimension
CMD_090D_CLEAR_OBJECT_FLAGS:
        DB $07 ; word CLEAR_OBJECT_FLAGS ($07)
        DW $203D ; RAM address / target / packed dimension
CMD_0910_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0911_DRAW_FORMATTED_DATA:
        DB $01 ; word DRAW_FORMATTED_DATA ($01)
        DB $05 ; format
        DW $0FA4 ; source
        DW $2E0E ; destination
CMD_0917_INPUT_AND_EVENT_DISPATCH:
        DB $14 ; word INPUT_AND_EVENT_DISPATCH ($14)
CMD_0918_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_089B_CLEAR_DISPLAY_MEMORY ; script destination
CMD_091B_INCREMENT_BCD_AND_RESET:
        DB $0C ; word INCREMENT_BCD_AND_RESET ($0C)
        DW $2005 ; BCD counter
        DW $202A ; descriptor address
        DB $20 ; flags
        DW $0DFD ; link pointer
CMD_0923_OUTPUT_AND_SET_2014:
        DB $0D ; word OUTPUT_AND_SET_2014 ($0D)
        DB $C2 ; output
        DB $02 ; state
CMD_0926_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $0F ; state
CMD_0928_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0929_INITIALIZE_OBJECT:
        DB $0B ; word INITIALIZE_OBJECT ($0B)
        DW $202A ; descriptor address
        DB $10 ; flags
        DW $0E5F ; link pointer
CMD_092F_DRAW_STATUS_202C:
        DB $12 ; word DRAW_STATUS_202C ($12)
CMD_0930_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $2D ; state
CMD_0932_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0933_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_089B_CLEAR_DISPLAY_MEMORY ; script destination
CMD_0936_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $1060 ; RAM address / target / packed dimension
CMD_0939_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_095D_OUTPUT_AND_SET_2014 ; script destination
CMD_093C_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $5060 ; RAM address / target / packed dimension
CMD_093F_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_095D_OUTPUT_AND_SET_2014 ; script destination
CMD_0942_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $9060 ; RAM address / target / packed dimension
CMD_0945_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_095D_OUTPUT_AND_SET_2014 ; script destination
CMD_0948_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $1078 ; RAM address / target / packed dimension
CMD_094B_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_095D_OUTPUT_AND_SET_2014 ; script destination
CMD_094E_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $1090 ; RAM address / target / packed dimension
CMD_0951_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_095D_OUTPUT_AND_SET_2014 ; script destination
CMD_0954_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $5090 ; RAM address / target / packed dimension
CMD_0957_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_095D_OUTPUT_AND_SET_2014 ; script destination
CMD_095A_FILL_RECTANGLE:
        DB $0E ; word FILL_RECTANGLE ($0E)
        DW $9090 ; RAM address / target / packed dimension
CMD_095D_OUTPUT_AND_SET_2014:
        DB $0D ; word OUTPUT_AND_SET_2014 ($0D)
        DB $B2 ; output
        DB $02 ; state
CMD_0960_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_0917_INPUT_AND_EVENT_DISPATCH ; script destination
CMD_0963_INCREMENT_BCD_AND_RESET:
        DB $0C ; word INCREMENT_BCD_AND_RESET ($0C)
        DW $2002 ; BCD counter
        DW $203D ; descriptor address
        DB $D0 ; flags
        DW $2339 ; link pointer
CMD_096B_OUTPUT_AND_SET_2014:
        DB $0D ; word OUTPUT_AND_SET_2014 ($0D)
        DB $B2 ; output
        DB $02 ; state
CMD_096E_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $0A ; state
CMD_0970_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_0971_INITIALIZE_OBJECT:
        DB $0B ; word INITIALIZE_OBJECT ($0B)
        DW $203D ; descriptor address
        DB $D0 ; flags
        DW $239B ; link pointer
CMD_0977_DRAW_STATUS_203F:
        DB $11 ; word DRAW_STATUS_203F ($11)
CMD_0978_SET_2015:
        DB $03 ; word SET_2015 ($03)
        DB $2D ; state
CMD_097A_WAIT_OR_REPEAT:
        DB $00 ; word WAIT_OR_REPEAT ($00)
CMD_097B_GOTO_SCRIPT:
        DB $09 ; word GOTO_SCRIPT ($09)
        DW CMD_089B_CLEAR_DISPLAY_MEMORY ; script destination
ROM_NATIVE_EVENT_ACTION_00:
        DW PLAYER_ONE_AXIS5_NEGATIVE ; NATIVE_EVENT_ACTION pointer from ROM $097E
ROM_NATIVE_EVENT_ACTION_01:
        DW PLAYER_ONE_AXIS5_POSITIVE ; NATIVE_EVENT_ACTION pointer from ROM $0980
ROM_NATIVE_EVENT_ACTION_02:
        DW PLAYER_ONE_AXIS1_NEGATIVE ; NATIVE_EVENT_ACTION pointer from ROM $0982
ROM_NATIVE_EVENT_ACTION_03:
        DW PLAYER_ONE_AXIS1_POSITIVE ; NATIVE_EVENT_ACTION pointer from ROM $0984
ROM_NATIVE_EVENT_ACTION_04:
        DW $042A ; NATIVE_EVENT_ACTION pointer from ROM $0986
ROM_NATIVE_EVENT_ACTION_05:
        DW $042A ; NATIVE_EVENT_ACTION pointer from ROM $0988
ROM_NATIVE_EVENT_ACTION_06:
        DW $042A ; NATIVE_EVENT_ACTION pointer from ROM $098A
ROM_NATIVE_EVENT_ACTION_07:
        DW PLAYER_ONE_FIRE_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $098C
ROM_NATIVE_EVENT_ACTION_08:
        DW PLAYER_TWO_AXIS5_NEGATIVE ; NATIVE_EVENT_ACTION pointer from ROM $098E
ROM_NATIVE_EVENT_ACTION_09:
        DW PLAYER_TWO_AXIS5_POSITIVE ; NATIVE_EVENT_ACTION pointer from ROM $0990
ROM_NATIVE_EVENT_ACTION_0A:
        DW PLAYER_TWO_AXIS1_NEGATIVE ; NATIVE_EVENT_ACTION pointer from ROM $0992
ROM_NATIVE_EVENT_ACTION_0B:
        DW PLAYER_TWO_AXIS1_POSITIVE ; NATIVE_EVENT_ACTION pointer from ROM $0994
ROM_NATIVE_EVENT_ACTION_0C:
        DW $043E ; NATIVE_EVENT_ACTION pointer from ROM $0996
ROM_NATIVE_EVENT_ACTION_0D:
        DW $043E ; NATIVE_EVENT_ACTION pointer from ROM $0998
ROM_NATIVE_EVENT_ACTION_0E:
        DW $043E ; NATIVE_EVENT_ACTION pointer from ROM $099A
ROM_NATIVE_EVENT_ACTION_0F:
        DW PLAYER_TWO_FIRE_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $099C
ROM_NATIVE_EVENT_ACTION_10:
        DW NO_OP_INPUT_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $099E
ROM_NATIVE_EVENT_ACTION_11:
        DW NO_OP_INPUT_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $09A0
ROM_NATIVE_EVENT_ACTION_12:
        DW NO_OP_INPUT_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $09A2
ROM_NATIVE_EVENT_ACTION_13:
        DW NO_OP_INPUT_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $09A4
ROM_NATIVE_EVENT_ACTION_14:
        DW NO_OP_INPUT_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $09A6
ROM_NATIVE_EVENT_ACTION_15:
        DW NO_OP_INPUT_ACTION ; NATIVE_EVENT_ACTION pointer from ROM $09A8
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
; Packed graphics and game tables.
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
; ROM_FRAME_PATTERN_A: 3 bytes per row (24 stored bits) x 12 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
ROM_FRAME_PATTERN_A:
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
; ROM_FRAME_PATTERN_B: 3 bytes per row (24 stored bits) x 12 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
ROM_FRAME_PATTERN_B:
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
; ROM_FRAME_PATTERN_C: 3 bytes per row (24 stored bits) x 12 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
ROM_FRAME_PATTERN_C:
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
; ROM_OBJECT_PATTERN_32_ROWS: 3 bytes per row (24 stored bits) x 32 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
ROM_OBJECT_PATTERN_32_ROWS:
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
; ROM_OBJECT_PATTERN_4BYTE_11ROWS: 4 bytes per row (32 stored bits) x 11 rows.
; Inline bits are shown MSB-first, not necessarily final display orientation.
; -----------------------------------------------------------------------------
ROM_OBJECT_PATTERN_4BYTE_11ROWS:
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
        DB $00,$03,$1C,$00,$7E,$00,$80,$FF,$01,$E0,$FF,$07
        DB $F0,$FF,$0F,$F0,$FF,$0F,$F8,$FF,$1F,$F8,$FF,$1F
        DB $F8,$FF,$1F,$F8,$E7,$1F,$F0,$C3,$0F,$F0,$81,$0F
        DB $E0,$81,$07,$C0,$81,$03,$80,$C3,$01,$F0,$FF,$0F
        DB $E0,$FF,$07,$E0,$FF,$07,$F4,$FF,$2F,$84,$3C,$21
        DB $04,$81,$20,$04,$81,$20,$06,$81,$60,$F7,$FF,$EF
        DB $06,$81,$60,$04,$00,$20,$04,$00,$20,$04,$00,$20
        DB $04 ; preceding graphic/table byte at $0EE1

; Player aim lookup: input bits 4..6 become byte offsets $02,$04,...,$0E.
; Zero is rejected by both callers; every valid offset addresses a DW.
PLAYER_ONE_AIM_POINTERS:
        DW $2000 ; unused zero-index entry (the dispatcher rejects zero)
        DW $0D4A ; direction offset $02
        DW $0C46 ; direction offset $04
        DW $0C87 ; direction offset $06
        DW $0BC4 ; direction offset $08
        DW $0D09 ; direction offset $0A
        DW $0C05 ; direction offset $0C
; The shared boundary is player one's last entry and player two's
; unreachable zero-index entry. It is stored ONCE in the original ROM.
PLAYER_TWO_AIM_POINTERS:
        DW $0CC8 ; P1 offset $0E / P2 offset $00 (unused)
        DW $2286 ; P2 direction offset $02
        DW $2182 ; P2 direction offset $04
        DW $21C3 ; P2 direction offset $06
        DW $2100 ; P2 direction offset $08
        DW $2245 ; P2 direction offset $0A
        DW $2141 ; P2 direction offset $0C
; This entry is also the base used for packed shot parameter byte lookups
; at +$02,+$04,...,+$0E. Those bytes are NOT a third DW pointer table.
SHOT_PARAMETER_BASE:
        DW $2204 ; P2 direction offset $0E / shot-parameter base $0EFE
; This seven-entry table is indexed from SHOT_PARAMETER_BASE by the
; same nonzero even $02..$0E direction offsets. Unlike the aim tables,
; its entries are relative coordinate byte pairs, NOT pointers.
SHOT_DIRECTION_DELTAS:
        DB $06,$1A ; offset $02: low and high coordinate adjustments
        DB $FF,$08 ; offset $04
        DB $00,$0C ; offset $06
        DB $FA,$FE ; offset $08
        DB $03,$16 ; offset $0A
        DB $FD,$02 ; offset $0C
        DB $01,$14 ; offset $0E
        DB $13,$28,$74 ; following unrelated game data
        DB $0B,$33,$36,$74,$0B,$12,$30,$74,$0B,$32,$36,$8C
        DB $0B,$12,$28,$8C,$0B,$0C,$38,$74,$0B,$0C,$2A,$74
        DB $0B,$0D,$30,$74,$0B,$0C,$2A,$8C,$0B,$0C,$38,$8C
        DB $0B,$0F,$30,$74,$0B,$11,$11,$11,$52,$65,$99,$99
        DB $99,$11,$11,$11,$53,$75,$99,$99,$99,$11,$11,$11
        DB $54,$85,$99,$99,$99,$C4,$00,$74,$70,$20,$FF,$A0
        DB $0A,$B4,$00,$00,$8E,$0E,$00,$00,$47,$41,$4B,$45
        DB $40,$40,$40,$40,$4D,$53,$45,$4F,$40,$40,$40,$40
        DB $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
        DB $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
        DB $40,$40,$40,$40,$00,$00,$25,$47,$52,$4C,$40,$46
        DB $49,$47,$48,$51,$49,$4C,$50,$45,$4F,$51,$40,$43
        DB $4D,$49,$4C,$40,$40,$40,$40,$40,$40,$40,$40,$40
        DB $40,$40,$47,$45,$51,$40,$4F,$45,$41,$44,$55,$3A
        DB $3A,$3A,$3A,$3A,$3A,$20,$3A,$3A,$3A,$3A,$3A,$3A
        DB $40,$40,$44,$4F,$41,$54,$3B,$40,$40,$47,$4D,$51
        DB $40,$4B,$45,$3B,$48,$45,$55,$40,$4E,$41,$4F,$44
        DB $4C,$45,$4F,$3B,$2E,$55,$4D,$52,$40,$48,$41,$53
        DB $45,$40,$43,$4F,$45,$44,$49,$51,$3C,$00,$00,$1A
        DB $4E,$52,$50,$48,$40,$42,$52,$51,$51,$4D,$4C
