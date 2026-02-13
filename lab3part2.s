	.data

	.global prompt
	.global dividend
	.global divisor
	.global quotient
	.global remainder

prompt:		.string "Integer Division", 0
dividend: 	.string "Enter dividend (-32,768 through 32,767)", 0
divisor:  	.string "Enter divisor (-32,768 through 32,767)", 0
quotient:	.string "Your quotient is:", 0
remainder:	.string "Your remainder is:", 0

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

	MOV r0, r4 ; send first prompt
	BL output_string
	BL new_line ; new line

	; dividend

	MOV r0, r5 ; send second prompt (dividend)
	BL output_string
	BL new_line

	MOV r0, r5 ; read dividend into r0
	BL read_string

	; check for q to quit
	;LDRB r0, [r5] ; check first character of dividend string
	;CMP r0, #0x71 ; ASCII 'q'
	;BEQ lab3_end ; if 'q', end program

	MOV r0, r5 ; buf
	BL string2int ; convert dividend to integer in r0
	MOV r9, r0 ; save dividend in r9

	; divisor

	MOV r0, r6 ; send third prompt (divisor)
	BL output_string
	BL new_line

	MOV r0, r6 ; read divisor into r0
	BL read_string

	; check for q to quit
	LDRB r0, [r6] ; check first character of dividend string
	CMP r0, #0x71 ; ASCII 'q'
	BEQ lab3_end ; if 'q', end program

	MOV r0, r6 ; buf
	BL string2int ; convert divisor to integer in r0
	MOV r10, r0 ; save divisor in r10

	; perform division
	SDIV r11, r9, r10 ; quotient in r11
	; signed div in reference card kinda cheated, couuld just use what we made already

	; get remainder
	MUL r12, r11, r10 ; r12 = quotient * divisor
	SUB r12, r9, r12 ; r12 = dividend - (quotient * divisor) = remainder

	; display quotient
	MOV r0, r7 ; send fourth prompt (quotient)
	BL output_string
	BL new_line

	MOV r0, r7 ; buf
	MOV r0, r11 ; convert quotient to string in r0
	BL int2string

	MOV r0, r7 ; buf
	BL output_string ; display quotient
	BL new_line

	; display remainder
	MOV r0, r8 ; send fifth prompt (remainder)
	BL output_string
	BL new_line

	MOV r0, r8 ; buf
	MOV r0, r12 ; convert remainder to string in r0
	BL int2string

	BL output_string ; display remainder
	BL new_line

	B lab3_end ;end

	; Your code is placed here.  This is your main routine for
	; Lab #3.  This should call your other routines such as
	; uart_init, read_string, output_string, int2string, &
	; string2int

lab3_end:

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr





uart_init:
;	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
;						; that are used in your routine.  Include lr if this
;						; routine calls another routine.
;
;	; tried to copy over the C code
;	; this will most likely not work!
;
;	; Provide clock to UART0
;	MOV r4, #0xE618
;	MOVT r4, #0x400F
;	MOV r5, #1
;	STR r5, [r4]
;
;wait_uart:
;	MOV r4, #0xEA18
;	MOVT r4, #0x400F
;	LDR r6, [r4]
;	AND r6, r6, #1
;	CMP r6, #0
;	BEQ wait_uart
;
;	; enable clock to PortA
;	MOV r4, #0xE608
;	MOVT r4, #0x400F
;	MOV r5, #1
;	STR r5, [r4]
;
	; Disable UART0
;	MOV r4, #0xC030
;	MOVT r4, #0x4000
;	MOV r5, #0
;	STR r5, [r4]
;
;	; Set IBRD = 8
;	MOV r4, #0xC024
;	MOVT r4, #0x4000
;	MOV r5, #8
;	STR r5, [r4]
;
;	; Set FBRD = 44
;	MOV r4, #0xC028
;	MOVT r4, #0x4000
;	MOV r5, #44
;	STR r5, [r4]
;
;	; Use system clock
;	MOV r4, #0xCFC8
;	MOVT r4, #0x4000
;	MOV r5, #0
;	STR r5, [r4]
;
;	; 8-bit, 1 stop, no pairity
;	MOV r4, #0xC02C
;	MOVT r4, #0x4000
;	MOV r5, #0x60
;	STR r5, [r4]
;
;	; Enable UART0
;	MOV r4, #0xC030
;	MOVT r4, #0x4000
;	MOV r5, #0x301
;	STR r5, [r4]
;
;	; digital enable PA0
;	MOV r4, #0x451C
;	MOVT r4, #0x4000
;	LDR r6, [r4]
;	ORR r6, r6, #0x03
;	STR r6, [r4]
;
;	; alternate function
;	MOV r4, #0x4420
;	MOVT r4, #0x4000
;	LDR r6, [r4]
;	ORR r6, r6, #0x03
;	STR r6, [r4]
;
;	; configure PA0
;	MOV r4, #0x452C
;	MOVT r4, #0x4000
;	LDR r6, [r4]
;	ORR r6, r6, #0x11
;	STR r6, [r4]
;
;	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
;						; PUSH at the top of this routine from the stack.
;	mov pc, lr


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
	BL output_character

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

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr



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
	CMP r0, #45             ; ASCII code for '-'
	BNE s2i_loop
	MOV r7, #1              ; Set negative flag
	ADD r6, r6, #1          ; Skip '-' character

s2i_loop:
	LDRB r0, [r4, r6]       ; Load character
	CMP r0, #0              ; Check for NULL
	BEQ s2i_done

	; Check if valid digit
	CMP r0, #48             ; ASCII '0'
	BLT s2i_done
	CMP r0, #57             ; ASCII '9'
	BGT s2i_done

	; Convert ASCII to digit
	SUB r0, r0, #48         ; Subtract '0'

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
	RSB r5, r5, #0          ; Negate (r5 = 0 - r5)

s2i_return:
	MOV r0, r5          ; Return result in r0
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


; Additional subroutines may be included here
new_line:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.

	MOV r0, #13
	BL output_character
	MOV r0, #10
	BL output_character

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


	.end
