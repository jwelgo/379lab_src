	.data

	.global prompt
	.global player1_score
	.global player2_score
	.global game_state
	.global winner
	.global player1_win_prompt
	.global player2_win_prompt
	.global end_game_prompt



prompt:	.string "Reaction game, press space to start, click enter or sw1 when the LED turns green | First to 3 wins\r\n", 0
player1_win_prompt: .string "Player 1 wins\r\n", 0
player2_win_prompt: .string "Player 2 wins\r\n", 0
end_game_prompt: .string "Game Over\r\n", 0

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

ptr_to_prompt:					.word prompt
ptr_to_player1_win_prompt:		.word player1_win_prompt
ptr_to_player2_win_prompt:		.word player2_win_prompt
ptr_to_end_game_prompt:			.word end_game_prompt

ptr_to_player1_score:			.word player1_score
ptr_to_player2_score:			.word player2_score
ptr_to_game_state:				.word game_state
ptr_to_winner:					.word winner

lab5:								; This is your main routine which is called from
; your C wrapper.
	PUSH {r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	ldr r4, ptr_to_prompt

 	bl uart_init
	bl uart_interrupt_init
	bl gpio_interrupt_init

	; This is where you should implement a loop, waiting for the user to
	; indicate if they want to end the program.

	;TODO
	; make winners be declared here instead of in handlers | move the CMP out of the handlers to increase speed
	; move declaring too early out of handlers too to lab5 main | ie. switching led to red here instead of in handlers


game_loop:

	; reset flags
	LDR r0, ptr_to_game_state
	MOV r1, #0
	STR r1, [r0]

	LDR r0, ptr_to_winner
	MOV r1, #0
	STR r1, [r0]

	LDR r0, ptr_to_prompt
	BL output_string

wait_for_start:

	; stay until uart handler sets winner
	LDR r0, ptr_to_winner
	LDR r1, [r0]
	CMP r1, #1
	BEQ wait_for_start

	; clear winner
	MOV r1, #0
	STR r1, [r0]

	; turn off led
	MOV r0, #0
	BL illuminate_RGB_LED

	; set game state to armed (1)
	LDR r0, ptr_to_game_state
	MOV r1, #1
	STR r1, [r0]

	; delay some how
	BL wait ; wait 3 seconds
	MOV r0, #2
	BL illuminate_RGB_LED	; make led green to indicate armed

	LDR r0, ptr_to_game_state
	MOV r1, #2
	STR r1, [r0]

wait_for_winner:
	; stay until uart handler sets winner
	LDR r0, ptr_to_winner
	LDR r1, [r0]
	CMP r1, #0
	BEQ wait_for_winner

	CMP r1, #1
	BEQ player1_wins

	CMP r1, #2
	BEQ player2_wins

player1_wins:

	LDR r2, ptr_to_player1_score
	LDR r3, [r2]
	ADD r3, r3, #1
	STRB r3, [r2]

	LDR r0, ptr_to_player1_win_prompt
	BL output_string
	B check_end

player2_wins:

	LDR r2, ptr_to_player2_score
	LDR r3, [r2]
	ADD r3, r3, #1
	STRB r3, [r2]

	LDR r0, ptr_to_player2_win_prompt
	BL output_string

check_end:

	; check if user wants to end game
	MOV r0, #0
	BL illuminate_RGB_LED	; turn off led

	; check if someone has 3
	LDR r2, ptr_to_player1_score
	LDR r1, [r0]
	CMP r1, #3
	BEQ end_game

	LDR r2, ptr_to_player2_score
	LDR r1, [r0]
	CMP r1, #3
	BEQ end_game

	B game_loop

end_game:

	LDR r0, ptr_to_end_game_prompt
	BL output_string

	POP {lr}		; Restore registers to adhere to the AAPCS
	MOV pc, lr



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

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.

	; init RGB LED too

	; enable GPIO F
	MOV r0, #0xE608
	MOVT r0, #0x400F	; RCGCGPIO
	LDR r1, [r0]
	ORR r1, r1, #0x20	; enable port F
	STR r1, [r0]

	; set PF4 as input
	MOV r0, #0x5000
	MOVT r0, #0x4002	; base address for port F

	MOV r1, #0x00
	STR r1, [r0, #0x400]	; GPIODIR

	MOV r1, #0x10
	STR r1, [r0, #0x51C]	; GPIODEN

	MOV r1, #0x10
	STR r1, [r0, #0x510]	; GPIOPUR

	MOV r1, #0x00
	STR r1, [r0, #0x404]

	MOV r1, #0x00
	STR r1, [r0, #0x408]

	MOV r1, #0x10
	STR r1, [r0, #0x40C]

	MOV r1, #0x10
	STR r1, [r0, #0x41C]

	MOV r1, #0x10
	STR r1, [r0, #0x410]

	MOV r0, #0xE100
	MOVT r0, #0xE000	; NVIC_EN0

	MOV r1, #1
	LSL r1, r1, #30
	STR r1, [r0]		; enable interrupt number 30 for GPIO F

	MOV pc, lr


UART0_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

	; TODO
	; make handler just set winner and handle declaring the winner in lab5 instead of handler to make it more consistent

	PUSH {r4-r12}

	MOV r0, #0xC044
	MOVT r0, #0x4000	; UART0_ICR_R
	MOV r1, #0x10
	STR r1, [r0]		; clear the interrupt

	MOV r0, #0xC000
	MOVT r0, #0x4000	; UART0_DR_R
	LDR r4, [r0]		; read the data

	; check if spacebar is pressed if not end
	CMP r4, #32
	BNE uart_done

	; load game
	LDR r5, ptr_to_game_state
	LDR r6, [r5]

	; check if player 1 wins (keyboard)
	CMP r6, #2
	BEQ player1_win

	CMP r6, #1
	BEQ too_early

	B uart_done

player1_win:
	LDR r7, ptr_to_winner
	MOV r8, #1
	STR r8, [r7]
	B uart_done

too_early:
	;make led red


uart_done:
	POP {r4-r12}
	BX lr       	; Return


Switch_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

	; TODO
	; make handler just set winner and handle declaring the winner in lab5 instead of handler to make it more consistent

	PUSH {r4-r12}

	MOV r0, #0x541C
	MOVT r0, #0x4002	; GPIOF_ICR
	MOV r1, #0x10
	STR r1, [r0]		; clear the interrupt

	; game
	LDR r5, ptr_to_game_state
	LDR r6, [r5]

	; check if player 2 wins (switch)
	CMP r6, #2
	BEQ player2_win

	CMP r6, #1
	BEQ too_early_switch

	B switch_done

player2_win:
	LDR r7, ptr_to_winner
	MOV r8, #2
	STR r8, [r7]
	B switch_done

too_early_switch:
	;make led red
	B switch_done

switch_done:
	POP {r4-r12}
	BX lr       	; Return


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
