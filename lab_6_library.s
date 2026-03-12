
	.text
	.global output_character
	.global output_string
	.global read_character
	.global uart_init
	.global int2str_i
	.global str2int_i


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

int2str:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

		; Your code for your int2string routine is placed here

	MOV r4, r0              ; r4 = destination address
	MOV r5, r1              ; r5 = integer value
	MOV r6, #0              ; r6 = character count

	; Check if negative
	CMP r5, #0
	BGE i2s_positive

	; Handle negative number
	MOV r0, #45             ; ASCII code for '-'
	STRB r0, [r4, r6]
	ADD r6, r6, #1
	RSB r5, r5, #0          ; Make positive (r5 = 0 - r5)

i2s_positive:
	; Handle special case of 0
	CMP r5, #0
	BNE i2s_convert
	MOV r0, #48             ; ASCII '0'
	STRB r0, [r4, r6]
	ADD r6, r6, #1
	B i2s_null

i2s_convert:
	; Convert digits (in reverse order to temp area)
	MOV r7, r4              ; Save base address
	ADD r7, r7, r6          ; Start position for digits
	MOV r8, #0              ; Digit count

i2s_digit_loop:
	CMP r5, #0
	BEQ i2s_reverse

	; Divide by 10
	MOV r0, r5
	MOV r1, #10
	UDIV r2, r0, r1         ; r2 = quotient
	MLS r3, r2, r1, r0      ; r3 = remainder (digit)

	; Convert digit to ASCII
	ADD r3, r3, #48         ; Add '0'
	STRB r3, [r7, r8]
	ADD r8, r8, #1

	MOV r5, r2              ; Continue with quotient
	B i2s_digit_loop

i2s_reverse:
	; Reverse the digits
	MOV r9, #1              ; Left index, offset by 1
i2s_rev_loop:
	CMP r9, r8
	BGE i2s_reversed

	SUB r0, r8, #1
	SUB r0, r0, r9          ; Right index

	LDRB r1, [r7, r9]       ; Left char
	LDRB r2, [r7, r0]       ; Right char
	STRB r2, [r7, r9]       ; Swap
	STRB r1, [r7, r0]

	ADD r9, r9, #1
	B i2s_rev_loop

i2s_reversed:
	ADD r6, r6, r8          ; Update total count

i2s_null:
	; Add NULL terminator
	MOV r0, #0
	STRB r0, [r4, r6]

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr

int2str_i:
    PUSH {r4-r12, lr}

    ; r0 = input integer (single digit, 0-9)

    ; Clamp to 0-9
    CMP r0, #0
    BLT i2si_lt
    CMP r0, #9
    BGT i2si_gt

i2si_lt:
	MOV r0, #0
	B i2si_continue

i2si_gt:
	MOV r0, #9
	B i2si_continue

i2si_continue:
	ADD r0, r0, #48         ; Convert digit to ASCII ('0' = 48)

    POP {r4-r12, lr}
    MOV pc, lr


str2int_i:
    PUSH {r4-r12, lr}

    ; r0 = single ASCII character ('0'-'9')

    ; Clamp to valid ASCII digit range
    CMP r0, #48             ; Below '0'?
    BLT s2ii_lt
    CMP r0, #57             ; Above '9'?
    BGT s2ii_gt

s2ii_lt:
	MOV r0, #48
	B s2ii_continue

s2ii_gt:
	MOV r0, #57
	B s2ii_continue

s2ii_continue:

    SUB r0, r0, #48         ; Convert ASCII to integer

    POP {r4-r12, lr}
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
