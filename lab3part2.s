	.data

	.global prompt
	.global dividend
	.global divisor
	.global quotient
	.global remainder

prompt:		.string "Your prompts are placed here", 0 
dividend: 	.string "Place holder string for your dividend", 0
divisor:  	.string "Place holder string for your divisor", 0
quotient:	.string "Your remainder is stored here", 0
remainder:	.string "Your remainder is stored here", 0

	.text
	.global lab3

U0FR: 	.equ 0x18	; UART0 Flag Register

ptr_to_prompt:		.word prompt
ptr_to_dividend:	.word dividend 
ptr_to_divisor:		.word divisor
ptr_to_quotient:	.word quotient
ptr_to_remainder:	.word remainder

lab3:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_dividend
	ldr r6, ptr_to_divisor
	ldr r7, ptr_to_quotient
	ldr r8, ptr_to_remainder

	; Your code is placed here.  This is your main routine for
	; Lab #3.  This should call your other routines such as
	; uart_init, read_string, output_string, int2string, &
	; string2int

lab3_end:

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr





uart_init:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your uart_init routine is placed here

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_character:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your read_character routine is placed here

	MOV r1, #0xC000
	MOVT r1, #0x4000  	; Load base address of UART0 using MOV/MOVT

wait_rxfe:
	LDR r2, [r1, #0x18] ; Read UART0 Flag Register (offset 0x18)

	AND r3, r2, #0x10   ; Check if Receive FIFO is Empty (bit 4)
	CMP r3, #0x10
	BEQ wait_rxfe
	
	LDR r0, [r1, #0x00] ; Receive FIFO has data, read character from Data Register

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_string:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your read_string routine is placed here

	MOV r4, r0         	; r4 = base address for string storage
	MOV r5, #0         	; r5 = index/counter

read_loop:
	BL read_character       ; Read character into r0
	
	; Check for carriage return (Enter key - ASCII 13 or 10)
	CMP r0, #13
	BEQ read_done
	CMP r0, #10
	BEQ read_done
	
	; Check for comma - ignore it
	CMP r0, #44
	BEQ read_loop           ; Skip comma, don't store or echo
	
	; Echo the character
	MOV r6, r0              ; Save character
	BL output_character
	MOV r0, r6              ; Restore character
	
	; Store character in string
	STRB r0, [r4, r5]
	ADD r5, r5, #1
	
	B read_loop

read_done:
	MOV r0, #0
	STRB r0, [r4, r5] ; Add NULL terminator
	
	; Echo newline for formatting
	MOV r0, #13
	BL output_character
	MOV r0, #10
	BL output_character
	
	POP {r4-r6,lr}
	MOV pc, lr

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


output_character:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your output_character routine is placed here

	MOV r4, r0     ; Save the character to transmit
	
	MOV r1, #0xC000
	MOVT r1, #0x4000    ; Load base address of UART0 using MOV/MOVT

wait_txff:
	LDR r2, [r1, #0x18]   ; Read UART0 Flag Register (offset 0x18)
	
	AND r3, r2, #0x20    ; Check if Transmit FIFO is Full (bit 5)
	CMP r3, #0x20
	BEQ wait_txff
	
	STR r4, [r1, #0x00]  ; Transmit FIFO is not full, write character
	
	POP {r1-r4,lr}
	MOV pc, lr

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
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
	POP {r4-r5,lr}
	MOV pc, lr


	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


int2string:  
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
	MOV r0, #'-'
	STRB r0, [r4, r6]
	ADD r6, r6, #1
	NEG r5, r5              ; Make positive

i2s_positive:
	; Handle special case of 0
	CMP r5, #0
	BNE i2s_convert
	MOV r0, #'0'
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
	ADD r3, r3, #'0'
	STRB r3, [r7, r8]
	ADD r8, r8, #1
	
	MOV r5, r2              ; Continue with quotient
	B i2s_digit_loop
	
i2s_reverse:
	; Reverse the digits
	MOV r9, #0              ; Left index
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


string2int:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
	; Your code for your string2int routine is placed here
	
	MOV r4, r0              ; r4 = string address
	MOV r5, #0              ; r5 = result
	MOV r6, #0              ; r6 = index
	MOV r7, #0              ; r7 = negative flag
	
	; Check for negative sign
	LDRB r0, [r4, r6]
	CMP r0, #'-'
	BNE s2i_loop
	MOV r7, #1              ; Set negative flag
	ADD r6, r6, #1          ; Skip '-' character
	
s2i_loop:
	LDRB r0, [r4, r6]       ; Load character
	CMP r0, #0              ; Check for NULL
	BEQ s2i_done
	
	; Check if valid digit
	CMP r0, #'0'
	BLT s2i_done
	CMP r0, #'9'
	BGT s2i_done
	
	; Convert ASCII to digit
	SUB r0, r0, #'0'
	
	; result = result * 10 + digit
	MOV r1, #10
	MUL r5, r5, r1
	ADD r5, r5, r0
	
	ADD r6, r6, #1
	B s2i_loop
	
s2i_done:
	; Apply negative if needed
	CMP r7, #1
	BNE s2i_return
	NEG r5, r5
	
s2i_return:
	MOV r0, r5         	; Return result in r0
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


; Additional subroutines may be included here


	.end 
