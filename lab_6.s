	.data

	.global prompt
	.global mydata

prompt:	.string "GAME GAME GAME use wasd to move, score points by hitting numbers", 0xA, 0xD
		.string "If you hit the walls you lose!", 0xA, 0xD
		.string "Every 5 seconds the game speeds up with a 20 second time limit", 0xA, 0xD

clear:  .string 0x1B, 0x5B, 0x32, 0x4A, 0x1B, 0x5B, 0x48

last_key: .string "", 0

direction:  .word 0
paused:     .word 0
timer_flag: .word 0
player_x:	.word 10 ; which character
player_y:	.word 10 ; which line
score:      .word 0
game_time:  .word 20

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
        .string "|   4     *          |", 0xA, 0xD
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
ptr_to_score_line:	.word score_line
ptr_to_direction:   .word direction
ptr_to_paused:      .word paused
ptr_to_timer_flag:  .word timer_flag
ptr_to_player_x:    .word player_x
ptr_to_player_y:    .word player_y
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

    ; pause
    CMP r1, #2
    ; poll / change direction
    BNE check_w

    LDR r2, ptr_to_paused
    LDR r3, [r2]

    EOR r3, r3, #1
    STR r3, [r2]

    B clear_key

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
    ; to detect game over if at least one coordinate is 0 or 20 game over
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

    LDR r0, ptr_to_direction
    LDR r6, [r0]

    ; check right
    CMP r6, #0
    BNE check_up
    ADD r4, r4, #1
    B check_wall

check_up:
    CMP r6, #1
    BNE check_left
    SUB r5, r5, #1
    B check_wall

check_left:
    CMP r6, #2
    BNE check_down
    SUB r4, r4, #1
    B check_wall

check_down:
    ADD r5, r5, #1

check_wall:
    CMP r4, #0
    BEQ game_over
    CMP r4, #20
    BEQ game_over

    CMP r5, #0
    BEQ game_over
    CMP r5, #0
    BEQ game_over

    LDR r0, ptr_to_player_x
    STR r4, [r0]

    LDR r0, ptr_to_player_y
    STR r5, [r0]

;clear_board:
	LDR r0, ptr_to_clear
    BL output_string

;update board
update_board:
	LDR r0, ptr_to_score_line
	BL output_string    ; reprint score

    LDR r7, ptr_to_board

    ; compute offset
    MOV r8, r5
    MOV r9, #22 ; 22 chars
    MUL r8, r8, r9

    ; offset += x
    ADD r8, r8, r4

    ; address of new pos
    ADD r10, r7, r8

    ; read character at pos
    LDRB r11, [r10]

    ; check if number in between 1 and 9
    CMP r11, #49 ; 1
    BLT not_number
    CMP r11, #57 ; 9
    BGT not_number

    ; convert to number
    SUB r11, r11, #48

    ; add to score
    LDR r0, ptr_to_score
    LDR r1, [r0]
    ADD r1, r1, r11
    STR r1, [r0]

    MOV r11, #32
    STRB r11, [r10]

not_number:
    MOV r11, #42
    STRB r11, [r10]

    ; reprint
    LDR r0, ptr_to_board
    BL output_string


done_move:

    POP {r4-r12,lr}
    BX lr

game_over:

    ; game over
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
    LDR  r5, ptr_to_last_key
    MOV  r6, #2
    STR  r6, [r5]

    POP  {r4-r12, lr}
    BX   lr

Timer_init:

    ; enable timer clock
    ; 16MHZ clock
    ; counts down from 16 mil

    MOV r0, #0xE604
    MOVT r0, #0x400F
    LDR r1, [r0]
    ORR r1, r1, #1
    STR r1, [r0]

    MOV r0, #0x000C
    MOVT r0, #0x4003
    MOV r1, #0
    STR r1, [r0]

    MOV r0, #0x0
    MOVT r0, #0x4003
    MOV r1, #0
    STR r1, [r0]

    MOV r0, #0x0004
    MOVT r0, #0x4003
    MOV r1, #2
    STR r1, [r0]

    MOV r0, #0x0028
    MOVT r0, #0x4003

    MOV r1, #0x2400
    MOVT r1, #0x00F4

    STR r1, [r0]

    MOV r0, #0x0018
    MOVT r0, #0x4003
    MOV r1, #1
    STR r1, [r0]

    MOV r0, #0x00C
    MOVT r0, #0x4003
    MOV r1, #1
    STR r1, [r0]

Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed for
	; Lab #5, but will be used in Lab #6.  It is referenced here because
	; the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.
	PUSH {r4-r12, lr}
    MOV r0, #0x0024
    MOVT r0, #0x4003
    MOV r1, #1
    STR r1, [r0]

    LDR r0, ptr_to_timer_flag
    MOV r1, #1
    STR r1, [r0]

	POP {r4-r12, lr}
	BX lr       	; Return


simple_read_character:

	MOV pc, lr	; Return

	.end
