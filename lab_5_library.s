
	.text
	.global illuminate_RGB_LED
	.global output_character
	.global output_string
	.global read_character
	.global wait

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

illuminate_RGB_LED:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ; format
    ; bit 0 = red
    ; bit 1 = blue
    ; bit 2 = green

	; in decimal
	; 0 = off
	; 1 = red
	; 2 = blue
	; 4 = green
	; 3 = purple
	; 5 = yellow
	; 7 = white

    MOV r1, #0x5000
    MOVT r1, #0x4002 ; PORT F Base Address

    AND r0, r0, #0x07 ; remove all but last 3 bits

    LSL r0, r0, #1 ; Shift left to align with PF1-PF3

    STR r0, [r1, #0x3FC] ; Write the value to the LED pins PF1-3

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


wait:
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r4, #3 ; 3 sec??
	MOV r5, #0

wait_loop:
	NOP
	ADD r5, r5, #1
	CMP r4, r5
	BLE wait_loop

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


	.end



