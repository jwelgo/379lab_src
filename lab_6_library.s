
	.text
	.global output_character
	.global output_string
	.global read_character
	.global uart_init


uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ; Enable UART0 Clock
    MOV r4, #0xE618
    MOVT r4, #0x400F
    MOV r5, #1
    STR r5, [r4]

wait_uart:
    MOV r4, #0xEA18
    MOVT r4, #0x400F
    LDR r6, [r4]
    AND r6, r6, #1
    CMP r6, #0
    BEQ wait_uart

    ; Enable GPIOA Clock
    MOV r4, #0xE608
    MOVT r4, #0x400F
    MOV r5, #1
    STR r5, [r4]

wait_gpioa:
    MOV r4, #0xEA08
    MOVT r4, #0x400F
    LDR r6, [r4]
    AND r6, r6, #1
    CMP r6, #0
    BEQ wait_gpioa

    ; Disable UART0 before configuration
    MOV r4, #0xC030
    MOVT r4, #0x4000
    MOV r5, #0
    STR r5, [r4]

    ; Configure GPIOA for UART FIRST

    ; Digital enable PA0, PA1
    MOV r4, #0x451C
    MOVT r4, #0x4000
    LDR r6, [r4]
    ORR r6, r6, #0x03
    STR r6, [r4]

    ; Alternate function PA0, PA1
    MOV r4, #0x4420
    MOVT r4, #0x4000
    LDR r6, [r4]
    ORR r6, r6, #0x03
    STR r6, [r4]

    ; Configure PA0, PA1 for UART
    MOV r4, #0x452C
    MOVT r4, #0x4000
    LDR r6, [r4]
    ORR r6, r6, #0x11
    STR r6, [r4]

    ; Configure UART0

    ; IBRD = 8
    MOV r4, #0xC024
    MOVT r4, #0x4000
    MOV r5, #8
    STR r5, [r4]

    ; FBRD = 44
    MOV r4, #0xC028
    MOVT r4, #0x4000
    MOV r5, #44
    STR r5, [r4]

    ; Use system clock
    MOV r4, #0xCFC8
    MOVT r4, #0x4000
    MOV r5, #0
    STR r5, [r4]

    ; 8-bit, 1 stop, no parity
    MOV r4, #0xC02C
    MOVT r4, #0x4000
    MOV r5, #0x60
    STR r5, [r4]

    ; Enable UART0 (RXE | TXE | UARTEN)
    MOV r4, #0xC030
    MOVT r4, #0x4000
    MOV r5, #0x301
    STR r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr



output_character:
	PUSH {r4-r12,lr} 	; Store registers r4 through r12 and lr to the

	; copied output_character from part 1

	MOV r4, #0xC000
	MOVT r4, #0x4000

check_txff:
	LDR r1, [r4, #0x18] ;read flag register

	AND r1, r1, #0x20
	CMP r1, #0x20

	BEQ check_txff ;if full loop

	STRB r0, [r4] ;store for transmit

	POP {r4-r12,lr}	; Restore registers r4 through r12 and lr from the
	mov pc, lr

read_character:
	PUSH {r4-r12,lr} 	; Store registers r4 through r12 and lr to the

	; copied read_character from part 1

	MOV r1, #0xC000
	MOVT r1, #0x4000 ; Load base address of UART0

wait_rxfe:
	LDR r2, [r1, #0x18] ; Read UART0 Flag Register

	; Check if Receive FIFO is empty
	AND r3, r2, #0x10
	CMP r3, #0x10
	BEQ wait_rxfe 	; If bit 4 is set (FIFO Empty), continue waiting

	LDRB r0, [r1]

	POP {r4-r12,lr}	; Restore registers r4 through r12 and lr from the
	mov pc, lr

output_string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

		; Your code for your output_string routine is placed here

	MOV r4, r0              ; r4 = base address of string
	MOV r5, #0              ; r5 = index

output_loop:
	LDRB r0, [r4, r5]       ; Load character
	CMP r0, #0              ; Check for NULL terminator
	BEQ output_done

	BL output_character     ; Output the character
	ADD r5, r5, #1
	B output_loop

output_done:

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr

	.end
