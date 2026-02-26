	.data

	.global prompt
	.global mydata

prompt:	.string "Your prompt with instructions is place here", 0
mydata:	.byte	0x20	
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
	
ptr_to_prompt:		.word prompt
ptr_to_mydata:		.word mydata

lab5:								; This is your main routine which is called from 
; your C wrapper.  
	PUSH {r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_mydata

 	bl uart_init
	bl uart_interrupt_init
	bl gpio_interrupt_init

	; This is where you should implement a loop, waiting for the user to 
	; indicate if they want to end the program.

game_loop:

	; reset flags
	LDR r0, =game_state
	MOV r1, #0
	STR r1, [r0]

	LDR r0, =winner
	MOV r1, #0
	STR r1, [r0]

	LDR r0, =prompt
	BL output_string

wait_for_start:

	; stay until uart handler sets winner
	LDR r0, =winner
	LDR r1, [r0]
	CMP r1, #1
	BEQ wait_for_start

	; clear winner
	MOV r1, #0
	STR r1, [r0]

	; turn off led
	MOV r0, #0
	BL illiuminate_rgb_led

	; set game state to armed (1)
	LDR r0, =game_state
	MOV r1, #1
	STR r1, [r0]

	; delay some how
	; sleep (100)
	MOV r0, #2 
	BL illiuminate_rgb_led	; make led green to indicate armed

	LDR r0, =game_state
	MOV r1, #2
	STR r1, [r0]

wait_for_winner:
	; stay until uart handler sets winner
	LDR r0, =winner
	LDR r1, [r0]
	CMP r1, #0
	BEQ wait_for_winner

	CMP r1, #1
	BEQ player1_wins

	CMP r1, #2
	BEQ player2_wins

player1_wins:

	LDR r2, =player1_score
	LDR r3, [r2]
	ADD r3, r3, #1
	STRB r3, [r2]

	LDR r0, =player1_win_prompt
	BL output_string
	B check_end

player2_wins:

	LDR r2, =player2_score
	LDR r3, [r2]
	ADD r3, r3, #1
	STRB r3, [r2]

	LDR r0, =player2_win_prompt
	BL output_string

check_end:

	; check if user wants to end game
	MOV r0, #0
	BL illiuminate_rgb_led	; turn off led

	; check if someone has 3
	LDR r2, =player1_score
	LDR r1, [r0]
	CMP r1, #3
	BEQ end_game

	LDR r2, =player2_score
	LDR r1, [r0]
	CMP r1, #3
	BEQ end_game
 
	B game_loop

end_game:

	LDR r0, =end_game_prompt
	BL output_string

	POP {lr}		; Restore registers to adhere to the AAPCS
	MOV pc, lr



uart_interrupt_init:
		
	; Your code to initialize the UART0 interrupt goes here
	; dont need to push or pop

	; enabling the iterrupt in UART0
	MOV r0, #0xC038
	MOVT, r0, #0x4000 ; UART0_IM_R
	LDR r1 ,[r0]
	ORR r1, r1, #0x10
	STR r1, [r0]

	; enabling NVIC
	MOV r0, #0xE100
	MOVT, r0, #0xE000	; NVIC_ISER0
	LDR r1, [r0]
	ORR r1, r1, #0x20	; UART0 is interrupt number 5
	STR r1, [r0]

	MOV pc, lr


gpio_interrupt_init:
		
	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.

	; enable GPIO F
	MOV r0, #0xE608
	MOVT, r0, #0x400F	; RCGCGPIO
	LDR r1, [r0]
	ORR r1, r1, #0x20	; enable port F
	STR r1, [r0]

	; set PF4 as input
	MOV r0, #0x5000
	MOVT, r0, #0x4002	; base address for port F

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
	MOVT, r0, #0xE000	; NVIC_EN0

	MOV r1, #1
	LSL r1, r1, #30 
	STR r1, [r0]		; enable interrupt number 30 for GPIO F

	MOV pc, lr


UART0_Handler: 
	
	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping 
	; them to & from the stack at the beginning & end of the handler
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
	LDR r5, =game_state
	LDR r6, [r5]

	; check if player 1 wins (keyboard)
	CMP r6, #2
	BEQ player1_win 

	CMP r6, #1
	BEQ too_early

	B uart_done

player1_win:
	LDR r7, =winner
	MOV r8, #1
	STR r8, [r7]
	B uart_done

too_early:
	;make led red
	B uart_done

	POP {r4-r12}
	BX lr       	; Return


Switch_Handler:
	
	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping 
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r12}

	MOV r0, #0x541C
	MOVT r0, #0x4002	; GPIOF_ICR
	MOV r1, #0x10
	STR r1, [r0]		; clear the interrupt

	; game
	LDR r5, =game_state
	LDR r6, [r5]

	; check if player 2 wins (switch)
	CMP r6, #2
	BEQ player2_win

	CMP r6, #1
	BEQ too_early_switch

	B switch_done

player2_win:
	LDR r7, =winner
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
