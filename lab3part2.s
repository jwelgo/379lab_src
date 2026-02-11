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

	  POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	  mov pc, lr





uart_init:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
					; that are used in your routine.  Include lr if this 
					; routine calls another routine.
	
		; Your code for your uart_init routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_character:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your read_character routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_string:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your read_string routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


output_character:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your output_character routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


output_string:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your output_string routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


int2string:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your int2string routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


string2int:  
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this 
						; routine calls another routine.
	
		; Your code for your string2int routine is placed here

	POP {r4-r12,lr}   ; Restore registers all registers preserved in the 
						; PUSH at the top of this routine from the stack.
	mov pc, lr


; Additional subroutines may be included here


	.end 

