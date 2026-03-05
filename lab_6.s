	.data

	.global prompt
	.global mydata

prompt:	.string "Your prompt with instructions is place here", 0
last_key: .string "", 0
direction:  .word 0
paused:     .word 0
timer_flag: .word 0
board:  .string "      Score: 0      ", 0xA, 0xD  
        .string " -------------------- ", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string "|                    |", 0xA, 0xD
        .string " -------------------- ", 0x0


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
ptr_to_last_key:	.word last_key
ptr_to_board:       .word board
ptr_to_direction:   .word direction
ptr_to_paused:      .word paused
ptr_to_timer_flag:  .word timer_flag

lab6:								; This is your main routine which is called from 
; your C wrapper.  
	PUSH {r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_mydata

 	bl uart_init
    bl gpio_interrupt_init
	bl uart_interrupt_init
    bl Timer_init

    LDR r0, ptr_to_prompt
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
    BNE check_w

    LDR r2, ptr_to_paused
    LDR r3, [r2]

    EORR r3, r3, #1
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
	
 

clear_key:

    MOV r1, #0
    STR r1, [r0]

check_timer:

    LDR r0, ptr_to_timer_flag
    LDR r1, [r0]

    CMP r1, #0
    BEQ main_loop

    ; clear
    MOV r1, #0
    STR r1, [r0]

    ; movement code

    B main_loop

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

	BX lr       	; Return


simple_read_character: 
	
	MOV pc, lr	; Return

	.end