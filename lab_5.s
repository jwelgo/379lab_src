	.data

	.global prompt
	.global player1_score
	.global player2_score
	.global game_state
	.global winner
	.global player1_win_prompt
	.global player2_win_prompt
	.global end_game_prompt



prompt:	.string "Reaction game, press space to start, click enter or sw1 when the LED turns green | First to 3 wins", 0
too_early_prompt:	.string "Too Early!", 0
player1_win_prompt: .string "Player 1 wins", 0
player2_win_prompt: .string "Player 2 wins", 0
end_game_prompt: .string "Game Over", 0
game_started_prompt: .string "Game Started!", 0
last_key: .string "", 0

player1_score: .byte 0
player2_score: .byte 0
game_state: .byte 0 ; 0 waiting, 1 armed, 2 go
winner: .byte 0 ; 0 none 1 player 1 wins, 2 player 2 wins



			; This is where you can store data.
			; The .byte assembler directive stores a byte
			; (initialized to 0x20 in this case) at the label
			; mydata.  Halfwords & Words can be stored using the
			; directives .half & .word

	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler			; This is needed for Lab #6
	.global simple_read_character	; read_character modified for interrupts
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init					; This is from your Lab #4 Library
	.global lab5
	.global illuminate_RGB_LED
	.global output_character
	.global output_string
	.global read_character
	.global wait
	.global new_line

ptr_to_prompt:					.word prompt
ptr_to_too_early_prompt:			.word too_early_prompt
ptr_to_player1_win_prompt:		.word player1_win_prompt
ptr_to_player2_win_prompt:		.word player2_win_prompt
ptr_to_end_game_prompt:			.word end_game_prompt
ptr_to_game_started_prompt:     .word game_started_prompt
ptr_to_last_key:				.word last_key

ptr_to_player1_score:			.word player1_score
ptr_to_player2_score:			.word player2_score
ptr_to_game_state:				.word game_state
ptr_to_winner:					.word winner

lab5:
    PUSH {r4-r12, lr}

    ; Initialize peripherals
    BL uart_init
    BL uart_interrupt_init
    BL gpio_interrupt_init

game_loop:

    ; Reset game state and winner
    LDR r0, ptr_to_game_state
    MOV r1, #0              ; 0 = waiting to start
    STR r1, [r0]

    LDR r0, ptr_to_winner
    MOV r1, #0
    STR r1, [r0]

    ; Turn off LED
    MOV r0, #0
    BL illuminate_RGB_LED

    ; Print start prompt
    LDR r0, ptr_to_prompt
    BL output_string
    BL new_line


; WAIT FOR SPACE TO START (winner == 1)
wait_for_start:
    LDR r0, ptr_to_last_key
wait_for_space:
    LDR r1, [r0]
    CMP r1, #32          ; ASCII space
    BNE wait_for_space

    ; Clear last_key immediately
    MOV r1, #0
    STR r1, [r0]

    ; Set state = 1 (arming period)
    LDR r0, ptr_to_game_state
    MOV r1, #1
    STR r1, [r0]

    ; Print "Game started"
    LDR r0, ptr_to_game_started_prompt
    BL output_string
    BL new_line

    ; 3-second delay
    BL wait

    ; Clear last_key again to ignore accidental key presses during delay
    MOV r1, #0
    LDR r0, ptr_to_last_key
    STR r1, [r0]

    ; ARM GAME
    MOV r0, #2
    BL illuminate_RGB_LED

    LDR r0, ptr_to_game_state
    MOV r1, #2
    STR r1, [r0]

    B wait_for_winner


; WAIT FOR SOMEONE TO PRESS
wait_for_winner:

    LDR r0, ptr_to_last_key
    LDR r1, [r0]
    CMP r1, #0
    BEQ wait_for_winner

    ; If enter pressed player 1
    CMP r1, #13
    BEQ player1_wins

    ; Check if pressed too early
    LDR r2, ptr_to_game_state
    LDR r3, [r2]
    CMP r3, #2
    BNE too_early

    ; VALID WIN
    CMP r1, #1
    BEQ player1_wins

    CMP r1, #2
    BEQ player2_wins


; TOO EARLY PRESS
too_early:
    MOV r0, #1              ; Red LED
    BL illuminate_RGB_LED

    LDR r0, ptr_to_too_early_prompt
    BL output_string
    BL new_line

    B check_end

; PLAYER 1 WINS
player1_wins:

    MOV r0, #2              ; Green LED
    BL illuminate_RGB_LED

    LDR r2, ptr_to_player1_score
    LDR r3, [r2]
    ADD r3, r3, #1
    STR r3, [r2]

    LDR r0, ptr_to_player1_win_prompt
    BL output_string
    BL new_line

    B check_end

; PLAYER 2 WINS
player2_wins:

    MOV r0, #2              ; Green LED
    BL illuminate_RGB_LED

    LDR r2, ptr_to_player2_score
    LDR r3, [r2]
    ADD r3, r3, #1
    STR r3, [r2]

    LDR r0, ptr_to_player2_win_prompt
    BL output_string
    BL new_line

; CHECK IF GAME OVER
check_end:

    ; Reset winner flag
    LDR r0, ptr_to_winner
    MOV r1, #0
    STR r1, [r0]

    ; Check P1 score
    LDR r2, ptr_to_player1_score
    LDR r3, [r2]
    CMP r3, #3
    BEQ end_game

    ; Check P2 score
    LDR r2, ptr_to_player2_score
    LDR r3, [r2]
    CMP r3, #3
    BEQ end_game

    B game_loop


; END GAME
end_game:

    LDR r0, ptr_to_end_game_prompt
    BL output_string
    BL new_line

    MOV r0, #0
    BL illuminate_RGB_LED

    POP {r4-r12, lr}
    BX lr



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

    ; Set winner = 2
    LDR  r5, ptr_to_winner
    MOV  r6, #2
    STR  r6, [r5]

    POP  {r4-r12, lr}
    BX   lr

Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed for
	; Lab #5, but will be used in Lab #6.  It is referenced here because
	; the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.

	BX lr       	; Return


simple_read_character:

	MOV pc, lr	; Return

	.end
