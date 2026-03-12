	.data

	.global prompt
	.global mydata

prompt:	.string "GAME GAME GAME use wasd to move, score points by hitting numbers", 0xA, 0xD
		.string "If you hit the walls you lose!", 0xA, 0xD
		.string "20 second time limit", 0xA, 0xD
		.string "Press SW1 to start!", 0xA, 0xD

clear:  .string 0x1B, 0x5B, 0x32, 0x4A, 0x1B, 0x5B, 0x48

last_key: .string "", 0

direction:  .word 0
paused:     .word 1
timer_flag: .word 0
player_x:	.word 10 ; which character
player_y:	.word 10 ; which line
old_player_x: .word 10
old_player_y: .word 10
score:      .word 0
game_time:  .word 40 ; doubled because we are on half clock cycke

score_line:	.string "      Score: 0      ", 0xA, 0xD, 0x0

board:  .string " -------------------- ", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|               1    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|    9               |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|               5    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|   4                |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|              3     |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|  2              7  |", 0xA, 0xD
        .string "|        8           |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                6   |", 0xA, 0xD
        .string " -------------------- ", 0xA, 0xD, 0x0

game_over_text:
    .string 0xA,0xD
    .string "=+=+=+=+=+=+=+=+=+=+=",0xA,0xD
    .string "      GAME OVER     ",0xA,0xD
    .string "=+=+=+=+=+=+=+=+=+=+=",0xA,0xD
    .string 0x0


	.text

	.global uart_interrupt_init
    .global gpio_interrupt_init
	.global UART0_Handler
	.global Timer_Handler			; This is needed for Lab #6
    .global Switch_Handler
	.global simple_read_character	; read_character modified for interrupts
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init					; This is from your Lab #4 Library
	.global lab6

ptr_to_prompt:		.word prompt
ptr_to_clear: 		.word clear
ptr_to_last_key:	.word last_key
ptr_to_board:       .word board
ptr_to_game_over_text: .word game_over_text
ptr_to_score_line:	.word score_line
ptr_to_direction:   .word direction
ptr_to_paused:      .word paused
ptr_to_timer_flag:  .word timer_flag
ptr_to_player_x:    .word player_x
ptr_to_player_y:    .word player_y
ptr_to_old_player_x: .word old_player_x
ptr_to_old_player_y: .word old_player_y
ptr_to_score:       .word score
ptr_to_game_time:   .word game_time

lab6:								; This is your main routine which is called from
; your C wrapper.
	PUSH {r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	ldr r4, ptr_to_prompt

 	bl uart_init
    bl gpio_interrupt_init
	bl uart_interrupt_init
    bl Timer_init

    LDR r0, ptr_to_prompt
    BL output_string

	LDR r0, ptr_to_score_line
	BL output_string

    LDR r0, ptr_to_board
    BL output_string

main_loop:

    LDR r0, ptr_to_last_key
    LDR r1, [r0]

    CMP r1, #0
    BEQ check_timer

; check each key and change direction
; w up 1
; a left 2
; s down 3
; d right 0

check_w:

    CMP r1, #119
    BNE check_a

    LDR r2, ptr_to_direction
    MOV r3, #1
    STR r3, [r2]
    B clear_key

check_a:

	CMP r1, #97
	BNE check_s

	LDR r2, ptr_to_direction
	MOV r3, #2
	STR r3, [r2]
	B clear_key

check_s:

	CMP r1, #115
	BNE check_d

	LDR r2, ptr_to_direction
	MOV r3, #3
	STR r3, [r2]
	B clear_key

check_d:

	CMP r1, #100
	BNE check_timer

	LDR r2, ptr_to_direction
	MOV r3, #0
	STR r3, [r2]

clear_key:

	MOV r1, #0


check_timer:

    LDR r0, ptr_to_timer_flag
    LDR r1, [r0]

    CMP r1, #0
    BEQ main_loop

    ; clear
    MOV r1, #0
    STR r1, [r0]

    ; movement code
    ; idea for now
    ; move by looking at the character one ahead in direction
    ; if it is a number add it to score
    ; if it is a | or - end game
    ; somehow use the y cordinate to determine which line of board to look at
    ; use the x cordinate to determine which character in the line to look at
    BL move_player

    B main_loop

	POP {lr}		; Restore registers to adhere to the AAPCS
	MOV pc, lr


move_player:
    PUSH {r4-r12,lr}

    LDR r0, ptr_to_paused
    LDR r1, [r0]
    CMP r1, #1
    BEQ done_move

    LDR r0, ptr_to_player_x
    LDR r4, [r0]

    LDR r0, ptr_to_player_y
    LDR r5, [r0]

    LDR r0, ptr_to_old_player_x
	STR r4, [r0]

	LDR r0, ptr_to_old_player_y
	STR r5, [r0]

    LDR r0, ptr_to_direction
    LDR r6, [r0]

    ; check right
    CMP r6, #0
    BNE check_up
    ADD r4, r4, #1
    B move_done

check_up:
    CMP r6, #1
    BNE check_left
    SUB r5, r5, #1
    B move_done

check_left:
    CMP r6, #2
    BNE check_down
    SUB r4, r4, #1
    B move_done

check_down:
    ADD r5, r5, #1

move_done:
    LDR r0, ptr_to_player_x
    STR r4, [r0]

    LDR r0, ptr_to_player_y
    STR r5, [r0]


;update board
update_board:

	;clear_board:
	LDR r0, ptr_to_clear
    BL output_string

    ; reprint score
    LDR r0, ptr_to_score_line
    BL output_string

    LDR r7, ptr_to_board

	; erase OLD player position
    LDR r0, ptr_to_old_player_y
    LDR r1, [r0]

    MOV r2, #24
    MUL r1, r1, r2

    LDR r0, ptr_to_old_player_x
    LDR r3, [r0]

    ADD r1, r1, r3
    ADD r1, r1, #1

    ADD r1, r7, r1

    MOV r2, #32      ; space
    STRB r2, [r1]

	; compute NEW position
    MOV r8, r5
    MOV r9, #24
    MUL r8, r8, r9

    ADD r8, r8, r4
    ADD r8, r8, #1

    ADD r10, r7, r8

	; check if number
    LDRB r11, [r10]

	; check if wall
	CMP r11, #45
	BEQ game_over

	CMP r11, #124
	BEQ game_over

    CMP r11, #49
    BLT not_number

    CMP r11, #57
    BGT not_number

    ; convert ASCII -> number
    SUB r11, r11, #48

    ; add to score
    LDR r0, ptr_to_score
    LDR r1, [r0]
    ADD r1, r1, r11
    STR r1, [r0]

    ; remove number from board
    MOV r11, #32
    STRB r11, [r10]

not_number:

	; draw player
    MOV r11, #42
    STRB r11, [r10]


	; print board

	; load score
	LDR r0, ptr_to_score
	LDR r1, [r0]

	; convert to ASCII
	ADD r1, r1, #48

	; load score_line
	LDR r2, ptr_to_score_line

	; offset to digit in string
	ADD r2, r2, #13

	; store ASCII digit
	STRB r1, [r2]

    LDR r0, ptr_to_board
    BL output_string

done_move:

    POP {r4-r12,lr}
    BX lr

game_over:

    ; set paused = 1
    LDR r0, ptr_to_paused
    MOV r1, #1
    STR r1, [r0]

    ; clear screen
    LDR r0, ptr_to_clear
    BL output_string

    ; print game over text
    LDR r0, ptr_to_game_over_text
    BL output_string

    B done_move

uart_interrupt_init:

	; Your code to initialize the UART0 interrupt goes here
	; dont need to push or pop

	; enabling the iterrupt in UART0
	MOV r0, #0xC038
	MOVT r0, #0x4000 ; UART0_IM_R
	LDR r1 ,[r0]
	ORR r1, r1, #0x10
	STR r1, [r0]

	; enabling NVIC
	MOV r0, #0xE100
	MOVT r0, #0xE000	; NVIC_ISER0
	LDR r1, [r0]
	ORR r1, r1, #0x20	; UART0 is interrupt number 5
	STR r1, [r0]

	MOV pc, lr


UART0_Handler:
    PUSH {r4-r12, lr}

	; storing last key now instead to move comparison away from the handler

    ; Clear UART RX interrupt
    MOV  r0, #0xC044
    MOVT r0, #0x4000
    MOV  r1, #0x10
    STR  r1, [r0]

    ; Read received character
    MOV  r0, #0xC000
    MOVT r0, #0x4000
    LDR  r4, [r0]

    ; Store character globally
    LDR  r5, ptr_to_last_key
    STR  r4, [r5]

    POP  {r4-r12, lr}
    BX   lr

gpio_interrupt_init:

    ; Enable GPIO Port F clock
    MOV  r0, #0xE608
    MOVT r0, #0x400F        ; RCGCGPIO
    LDR  r1, [r0]
    ORR  r1, r1, #0x20
    STR  r1, [r0]

    ; Base address Port F
    MOV  r0, #0x5000
    MOVT r0, #0x4002

    ; Unlock PF4
    MOV  r1, #0x434B
    MOVT r1, #0x4C4F
    STR  r1, [r0, #0x520]   ; GPIOLOCK
    MOV  r1, #0x10
    STR  r1, [r0, #0x524]   ; GPIOCR

    MOV  r1, #0x0E          ; 0000 1110
    STR  r1, [r0, #0x400]   ; GPIODIR

    ; Digital enable PF1-4
    MOV  r1, #0x1E          ; 0001 1110
    STR  r1, [r0, #0x51C]   ; GPIODEN

    ; Pull-up on PF4
    MOV  r1, #0x10
    STR  r1, [r0, #0x510]   ; GPIOPUR

    ; Interrupt configuration PF4
    MOV  r1, #0x00
    STR  r1, [r0, #0x404]   ; GPIOIS

    ; Single edge
    MOV  r1, #0x00
    STR  r1, [r0, #0x408]   ; GPIOIBE

    ; Falling edge trigger
    MOV  r1, #0x10
    STR  r1, [r0, #0x40C]   ; GPIOIEV

    ; Clear any prior interrupt
    MOV  r1, #0x10
    STR  r1, [r0, #0x41C]   ; GPIOICR

    ; Unmask PF4 interrupt
    MOV  r1, #0x10
    STR  r1, [r0, #0x410]   ; GPIOIM

    ; Enable NVIC interrupt
    MOV  r0, #0xE100
    MOVT r0, #0xE000        ; NVIC_EN0

    MOV  r1, #1
    LSL  r1, r1, #30
    STR  r1, [r0]

    MOV  pc, lr

Switch_Handler:

    ; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

    PUSH {r4-r12, lr}

    ; Clear PF4 interrupt
    MOV  r0, #0x541C
    MOVT r0, #0x4002        ; GPIOF_ICR
    MOV  r1, #0x10
    STR  r1, [r0]

    ; Set pause
    LDR r0, ptr_to_paused
    LDR r1, [r0]

    EOR r1, r1, #1
    STR r1, [r0]

    POP  {r4-r12, lr}
    BX   lr

Timer_init:

    ; enable Timer0 clock
    MOV r0, #0xE604
    MOVT r0, #0x400F
    LDR r1, [r0]
    ORR r1, r1, #1
    STR r1, [r0]

wait_timer:
    MOV r0, #0xEA04
    MOVT r0, #0x400F
    LDR r1, [r0]
    AND r1, r1, #1
    CMP r1, #1
    BNE wait_timer

    ; disable timer
    MOV r0, #0x000C
    MOVT r0, #0x4003
    MOV r1, #0
    STR r1, [r0]

    ; 32 bit timer
    MOV r0, #0x0000
    MOVT r0, #0x4003
    MOV r1, #0
    STR r1, [r0]

    ; periodic mode
    MOV r0, #0x0004
    MOVT r0, #0x4003
    MOV r1, #2
    STR r1, [r0]

    ; load value 8 mil
	MOV r0, #0x0028
	MOVT r0, #0x4003
	MOV r1, #0x1200
	MOVT r1, #0x007A
	STR r1, [r0]

    ; enable timeout interrupt
    MOV r0, #0x0018
    MOVT r0, #0x4003
    MOV r1, #1
    STR r1, [r0]

    ; enable interrupt
    MOV r0, #0xE100
    MOVT r0, #0xE000
    MOV r1, #1
    LSL r1, r1, #19
    STR r1, [r0]

    ; enable timer
    MOV r0, #0x000C
    MOVT r0, #0x4003
    MOV r1, #1
    STR r1, [r0]

    MOV pc, lr


Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed for
	; Lab #5, but will be used in Lab #6.  It is referenced here because
	; the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.
    PUSH {r4-r12, lr}

    ; clear timer interrupt
    MOV r0, #0x0024
    MOVT r0, #0x4003
    MOV r1, #1
    STR r1, [r0]

    ; set timer flag for main loop
    LDR r0, ptr_to_timer_flag
    MOV r1, #1
    STR r1, [r0]

    ; decrement game_time
    LDR r0, ptr_to_game_time
    LDR r1, [r0]
    SUB r1, r1, #1
    STR r1, [r0]

    ; check if time is up
    CMP r1, #0
    BNE done_timer

    ; trigger game over
    BL game_over

done_timer:
    POP {r4-r12, lr}
    BX lr

simple_read_character:

	MOV pc, lr	; Return

	.end
