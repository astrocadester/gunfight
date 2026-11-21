# Gun Fight — original native block-label inventory

This is the complete cross-reference inventory of the **92 formerly generic `NATIVE_xxxx` labels** addressed by the v20261108-0009 hard RE pass. Each address retains its original ROM location. The descriptive name identifies an **internal loop/conditional/shared continuation**, not a new public function or a guessed original DNA symbol.

Meaning is inferred from the Intel 8080 instructions at the address and its immediate control-flow neighborhood; not every game's pixel, collision, or sound consequence can be established from the static stream alone. Callable-function contracts, hardware entry points and gameplay flow are recorded in [NATIVE-CONTROL-FLOW.md](NATIVE-CONTROL-FLOW.md).

**Trace convention:** `Branches: N` counts direct `JP`/`CALL` instructions that now reference the block by symbol. `0` ordinarily means fall-through from the previous block; some of these are also indirect or shared paths.

## Interrupt and object/frame processing

- `$0021` **`IRQ_COPY_OBJECT_LIST_ENTRY`** — Shared IRQ loop: extract next nonzero list pointer from a 0x12-byte slot at $206F. (Branches: 1)
- `$0028` **`IRQ_COPY_OBJECT_LIST_ROW`** — Copy a pair of source bytes to a destination row, advance by $20, repeat using B. (Branches: 1)
- `$0038` **`IRQ_ADVANCE_FIRST_LIST_SLOT`** — Restore list slot address and advance $12 until low byte reaches $B7. (Branches: 1)
- `$0046` **`IRQ_COMPOSITE_SECOND_LIST_ENTRY`** — Process the $20A2-list slots, setting bitmap pointer and the port-$02 mode. (Branches: 1)
- `$0057` **`IRQ_COMPOSITE_SECOND_LIST_ROW`** — Merge two source bytes through graphics ports $04/$03 with OR into bitmap row. (Branches: 1)
- `$0076` **`IRQ_ADVANCE_SECOND_LIST_SLOT`** — Restore list slot and step backward by $12 until low byte reaches $5A. (Branches: 1)
- `$0087` **`IRQ_RESUME_COMMON_FRAME_PATH`** — Shared continuation of RST $08/$10: choose pending bitmap operations or input sampling. (Branches: 1)
- `$0091` **`IRQ_CONSUME_BITMAP_JOB`** — Consume pointer fields from pending draw/clear descriptor at HL. (Branches: 1)
- `$00A4` **`IRQ_CLEAR_BITMAP_ROW_GROUP`** — Use B as fill value to clear C bytes per row for D rows. (Branches: 1)
- `$00A6` **`IRQ_CLEAR_BITMAP_ROW_BYTES`** — Inner fill loop: write B to (HL), advance until C expires. (Branches: 1)
- `$00B4` **`IRQ_RENDER_PENDING_SPRITE_JOB`** — Restore pending descriptor, select video mode and draw two object-pattern sources. (Branches: 2)
- `$00EA` **`IRQ_SCAN_PROJECTILE_RECORDS`** — Begin pass over projectile/object records at $2063. (Branches: 1)
- `$00ED` **`IRQ_CHECK_PROJECTILE_SLOT`** — Check active flag and coordinate window for one $12-byte projectile slot. (Branches: 1)
- `$0103` **`IRQ_CHECK_PROJECTILE_UPPER_WINDOW`** — Apply upper limit $90 to signed/alternate projectile coordinate path. (Branches: 1)
- `$0108` **`IRQ_TEST_PROJECTILE_STATE_AND_BOUNDS`** — Check additional record field and lower bound before reporting collision code. (Branches: 1)
- `$014C` **`IRQ_STORE_EVENT_SELECTOR`** — Extract low nibble of ROM table value into RAM $201C (event selector). (Branches: 1)
- `$0151` **`IRQ_NEXT_PROJECTILE_SLOT`** — Advance by $12 through projectile records until low byte is $AB. (Branches: 5)
- `$015F` **`IRQ_UPDATE_VISIBLE_OBJECT_SLOT`** — Update an active object and calculate its bitmap address and bit phase. (Branches: 1)
- `$0183` **`IRQ_NEXT_VISIBLE_OBJECT_SLOT`** — Advance active object record by $12; after final slot, examine $20BE. (Branches: 2)
- `$0198` **`IRQ_BEGIN_OBJECT_CYCLE`** — Save initial walker address to $20C0 and clear cycle activity byte $20BD. (Branches: 1)
- `$019F` **`IRQ_STEP_OBJECT_CYCLE`** — Update active object, optionally prepare drawing job, persist current pointer. (Branches: 1)
- `$01B1` **`IRQ_ADVANCE_OBJECT_CYCLE`** — Advance the object walker by $13, wrapping at $2063 to $202A. (Branches: 1)
- `$01BE` **`IRQ_CHECK_OBJECT_CYCLE_COMPLETE`** — Compare walker against starting slot and update output/timing after a full pass. (Branches: 1)
- `$01D4` **`IRQ_ADVANCE_ROUND_TIMERS`** — Decrease round timer at $2009 and update BCD game-state counters on rollover. (Branches: 2)
- `$01F6` **`IRQ_UPDATE_SECOND_BCD_TIMER`** — Update BCD timer at $2003; on expiry transition to wait counter. (Branches: 2)
- `$0208` **`IRQ_DECREMENT_FRAME_DELAY`** — Decrement $2015 and branch to frame end until the delay expires. (Branches: 2)
- `$0214` **`IRQ_DECREMENT_WAIT_COUNTER`** — Decrement waiting/repeat counter at $20C5. (Branches: 1)
- `$0218` **`IRQ_SAMPLE_PORT2_AND_RESTORE`** — Double-sample input port $02; dispatch stable changes, restore saved registers. (Branches: 6)

## Bitmap drawing, movement and object queues

- `$023B` **`DRAW_OBJECT_NEXT_ROW`** — Save source dimensions and destination, start another 32-byte-spaced bitmap row. (Branches: 1)
- `$023D` **`DRAW_OBJECT_ROW_BYTES`** — Feed a pattern byte to port $04, read pixel result at port $03, and store. (Branches: 1)
- `$0294` **`AXIS_RETURN_UNCHANGED`** — Return current axis byte in D, clear A after the in-bounds check. (Branches: 1)
- `$0297` **`AXIS_HANDLE_LIMIT_VIOLATION`** — Adjust compact axis record on range violation; branch by B direction mode. (Branches: 2)
- `$02A7` **`AXIS_CLEAR_OR_REVERSE_COMPONENT`** — Zero a field and select status $60 or alternate path from direction mode. (Branches: 1)
- `$02B4` **`AXIS_SELECT_LIMIT_STATUS`** — Choose return status $40 when no earlier mode matches. (Branches: 1)
- `$02BA` **`AXIS_RETURN_STATUS`** — Return axis value in D and status in A, with flags from AND A. (Branches: 2)
- `$02C9` **`QUEUE_OBJECT_BITMAP_UPDATE`** — Construct pending object bitmap descriptor in $20AB or $20B2 and update slot flags. (Branches: 1)
- `$02E0` **`STORE_PENDING_BITMAP_DESCRIPTOR`** — Store source slot pointer, converted video address/phase, and object linkage. (Branches: 1)
- `$030C` **`WRITE_OBJECT_LINK_AND_XOR_STATE`** — Write pending object link pointer and XOR status into source object control byte. (Branches: 1)
- `$0314` **`SELECT_CURRENT_PLAYER_FRAME`** — Choose player-specific four-entry frame table based on object slot and $2009. (Branches: 1)
- `$0326` **`LOOKUP_PLAYER_FRAME_POINTER`** — Scale the $2009 frame selector and index the four-entry player frame table. (Branches: 1)
- `$0332` **`LOAD_FRAME_POINTER_AND_RESET_FLAGS`** — Read frame pointer into DE; clear/change related status through shared exit. (Branches: 1)
- `$033E` **`CLEAR_PENDING_BITMAP_DESCRIPTOR`** — Zero four pending-record bytes and clear source object's active control byte. (Branches: 1)
- `$035F` **`PIXEL_ADDRESS_SHIFT_RIGHT`** — One step of the three-bit right shift of DE, preserving carry between D/E. (Branches: 1)
- `$0373` **`COPY_SCRIPT_LITERAL_BYTE`** — Inline copy loop for VM words $05/$06: copy C bytes HL to DE. (Branches: 1)

## Startup, interpreter and native input dispatch

- `$0397` **`CLEAR_INITIAL_GAME_STATE_BYTE`** — Initialize eight consecutive RAM state bytes at $2002. (Branches: 1)
- `$039D` **`INSTALL_INITIAL_VM_SCRIPT`** — Clear display, install initial script $0821, enable interrupts and fall into VM. (Branches: 1)
- `$03B4` **`VM_FETCH_AND_RESOLVE_NATIVE_WORD`** — Fetch indexed command, advance $2000, look up 16-bit handler at $09AE and jump. (Branches: 1)
- `$0404` **`VM_REFRESH_SCORE_IF_NEEDED`** — At VM input/event word exit, refresh score when round state $2009 is below $22. (Branches: 1)
- `$0412` **`INPUT_SCAN_FOR_CHANGED_BIT`** — Rotate change mask C and shift bit mask B until first changed input bit. (Branches: 1)
- `$0420` **`INPUT_UPDATE_BIT_AND_TAIL_CALL`** — Update stored input state at HL; load native action address from DE and JP (HL). (Branches: 1)

## Player axes, firing and round control

- `$0463` **`P1_AXIS5_APPLY_PRESS_FLAG`** — If transition flags indicate release, zero B before storing axis5 velocity. (Branches: 1)
- `$0468` **`P1_AXIS5_SELECT_OBJECT`** — Select player-one object base $202A; shared store begins at next label. (Branches: 1)
- `$046B` **`STORE_AXIS5_COMPONENT`** — Shared player-axis helper: mark object $C0 and write signed velocity at offset +5. (Branches: 1)
- `$047A` **`P1_AXIS1_APPLY_PRESS_FLAG`** — If transition flags indicate release, zero B before storing axis1 velocity. (Branches: 1)
- `$047F` **`P1_AXIS1_SELECT_OBJECT`** — Select player-one object base $202A for axis1 update. (Branches: 1)
- `$0482` **`STORE_AXIS1_COMPONENT`** — Shared axis helper: mark object $C0 and write signed velocity to byte +1. (Branches: 1)
- `$048E` **`P2_AXIS5_APPLY_PRESS_FLAG`** — Player-two axis5 press/release gating before shared velocity store. (Branches: 1)
- `$0493` **`P2_AXIS5_SELECT_OBJECT`** — Select player-two object base $203D and jump to shared +5 velocity store. (Branches: 1)
- `$04A0` **`P2_AXIS1_APPLY_PRESS_FLAG`** — Player-two axis1 press/release gating before shared velocity store. (Branches: 1)
- `$04A5` **`P2_AXIS1_SELECT_OBJECT`** — Select player-two object base $203D and jump to shared +1 velocity store. (Branches: 1)
- `$04C1` **`FIRE_P1_CHECK_GUARD_AND_LAUNCH`** — Reject fire when $2012 nonzero; otherwise update count and configure projectile. (Branches: 1)
- `$04DF` **`FIRE_INSTALL_PROJECTILE_FROM_DIRECTION`** — Shared firing tail: apply direction-based shot position; atomically write projectile fields. (Branches: 1)
- `$0510` **`SHOT_RESTORE_DISPLAY_DIGIT`** — Restore A from B after updating round state, before drawing ammunition indicator. (Branches: 1)
- `$0511` **`SHOT_DRAW_AMMO_INDICATOR`** — Tail-call formatted text with character stream $0FA4. (Branches: 1)
- `$0528` **`FIRE_P2_CHECK_GUARD_AND_LAUNCH`** — Reject fire when $2013 nonzero; otherwise update count and configure projectile. (Branches: 1)
- `$0585` **`ROUND_SELECT_SPEED_FROM_SETTINGS`** — Adjust B in $10 increments using $2006 upper mode bits. (Branches: 1)
- `$0590` **`ROUND_RESET_SCORE_AND_MODE`** — Store resulting round mode, decrement $20C6 and clear selected score bytes. (Branches: 1)

## Score, character rendering and screen clear

- `$05A7` **`SCORE_FORMAT_FOUR_FIELDS`** — Begin four-field BCD score-to-text formatting at RAM $201E. (Branches: 1)
- `$05AF` **`SCORE_DECODE_HIGH_BCD_DIGIT`** — Extract high nibble from RAM source, choosing placeholder $10 for leading zero. (Branches: 1)
- `$05BB` **`SCORE_WRITE_BCD_DIGITS`** — Emit ASCII high/low score digits into formatted text buffer. (Branches: 1)
- `$05D6` **`SCORE_NEXT_FIELD_AND_RENDER`** — Advance source/output pointers; render after four fields. (Branches: 2)
- `$05FC` **`TEXT_FETCH_CHARACTER_OR_ADVANCE`** — Fetch source char; values under $30 act as horizontal destination advances. (Branches: 1)
- `$0604` **`TEXT_ADVANCE_DISPLAY_COLUMN`** — Advance bitmap byte address and handle 32-byte scanline boundary. (Branches: 1)
- `$060D` **`TEXT_CONTINUE_COLUMN_ADVANCE`** — Loop B column increments, then fetch next source byte. (Branches: 1)
- `$0614` **`TEXT_LOOKUP_FONT_GLYPH`** — Use character minus $30 as index into 10-byte digit glyph records. (Branches: 1)
- `$061F` **`TEXT_SKIP_TO_NEXT_DIGIT_GLYPH`** — Advance font pointer by 10 bytes until glyph index exhausted. (Branches: 1)
- `$0624` **`TEXT_SETUP_TEN_SCANLINES`** — Exchange source/destination and initialize ten glyph rows with $20 stride. (Branches: 1)
- `$062A` **`TEXT_COPY_NEXT_GLYPH_ROW`** — Write one glyph byte to bitmap, step one scanline and repeat ten times. (Branches: 1)
- `$0662` **`CLEAR_DISPLAY_PUSH_WORD_LOOP`** — Zero-fill video using PUSH BC from temporary stack pointer $400F. (Branches: 1)

## Scene/graphics selection

- `$06C5` **`GAME_SELECT_NEXT_PATTERN`** — Reduce display state and determine whether the next pattern needs frame setup. (Branches: 1)
- `$06D5` **`GAME_DRAW_PATTERN_FROM_TABLE`** — Read graphic pointer and destination from table; draw current pattern. (Branches: 3)
- `$06EB` **`GAME_SELECT_SECOND_PATTERN_SET`** — Select secondary graphics set once bit7 of $2016 permits. (Branches: 1)
- `$0703` **`GAME_DRAW_FINAL_PATTERN_GROUP`** — If bit6 of $2016 not set, set it, select port-$02 mode and draw last group. (Branches: 1)
- `$0719` **`GAME_PREPARE_SPECIAL_OBJECT`** — Check object at $2050 and copy a 15-byte initialization record when inactive. (Branches: 1)
- `$072D` **`GAME_SET_PATTERN_READY_FLAG`** — Set bit6 in $2016; restore caller AF/HL saved by special-object helper. (Branches: 1)

## Rectangle and packed graphics decode

- `$079A` **`RECTANGLE_NEXT_SCANLINE`** — Save row destination and fill another horizontal span using 32-byte stride. (Branches: 1)
- `$079C` **`RECTANGLE_FILL_ROW_BYTES`** — Fill C consecutive video bytes with B. (Branches: 1)
- `$07B1` **`EXPAND_GRAPHICS_NEXT_BLOCK`** — Read next packed graphics record from ROM $0BC4; zero byte ends stream. (Branches: 1)
- `$07BD` **`EXPAND_GRAPHICS_NEXT_COLUMN`** — Compute destination offset from record width for the next packed column. (Branches: 1)
- `$07C3` **`EXPAND_GRAPHICS_READ_PACKED_COLUMN`** — Read next source byte and prepare eight-bit rotation into display orientation. (Branches: 1)
- `$07CC` **`EXPAND_GRAPHICS_ROTATE_EIGHT_BITS`** — Rotate source bits into the expanded byte through D/E shift registers. (Branches: 1)
- `$07F2` **`DRAW_STATUS_GET_BITMAP_DESTINATION`** — Read packed object coordinates and derive display destination for 7 chars. (Branches: 1)

Total: **92** internal labels across seven address groups. Other descriptive labels in the ASM are the actual callable routines, VM handlers, ROM tables and named script locations.

## Remaining verification

The structural pass must be followed by an independent native zmac build and exact device SHA-1 comparison. Dynamic confirmation of collision outcomes, audio and video compositing, and complete game-frame behavior remains separate technical debt.
