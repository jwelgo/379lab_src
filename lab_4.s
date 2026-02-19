	.text
	.global new_line
	.global uart_init
	.global gpio_btn_and_LED_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED  
	.global read_tiva_push_button  
	.global str2int
	.global int2str
	.global unsigned_division
	.global signed_division
	.global mod
	.global lab4

	prompt_l1:		.string "Lab 4 library test module", 0
	prompt_l2: 		.string "Please select a subroutine to test:", 0
	prompt_l3:  	.string "Test read_tiva_push_button - 1", 0
	prompt_l4:		.string "Test read_from_push_btns - 2", 0
	prompt_l5:		.string "Test illuminate_LEDs - 3", 0
	prompt_l6:		.string "Test illuminate_RGB_LED - 4", 0
	prompt_l7:		.string "Input a number 1 - 4 to run a test: ", 0

	prompt_l8:		.string "Test complete, continue testing? (y/n):", 0
	prompt_l9:		.string "Please enter y or n for a yes or no prompt", 0

	prompt_l0:      .string "Invalid test selection, please retry", 0

	ptr_to_prompt_l1:	.word prompt_l1
	ptr_to_prompt_l2:	.word prompt_l2
	ptr_to_prompt_l3:	.word prompt_l3
	ptr_to_prompt_l4:	.word prompt_l4
	ptr_to_prompt_l5:	.word prompt_l5
	ptr_to_prompt_l6:	.word prompt_l6
	ptr_to_prompt_l7:	.word prompt_l7

	ptr_to_prompt_l8:   .word prompt_l8
	ptr_to_prompt_l9:	.word prompt_l9

	ptr_to_prompt_l0:	.word prompt_l0

lab4:
	PUSH {r4-r12,lr}	; Spill registers to stack
    
	BL uart_init ; init uart
	
restart:
	LDR r4, ptr_to_prompt_l1 ; load first prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	LDR r4, ptr_to_prompt_l2 ; load second prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	LDR r4, ptr_to_prompt_l3 ; load third prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	LDR r4, ptr_to_prompt_l4 ; load fourth prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	LDR r4, ptr_to_prompt_l5 ; load fifth prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	LDR r4, ptr_to_prompt_l6 ; load sixth prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	LDR r4, ptr_to_prompt_l7 ; load seventh prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	MOV r0, #0x0000
	MOVT r0, #0x2000 ; Load base address
	BL read_string ; at some point load the characters we just stored into a register

	MOV r0, #0x0000        ; reload address
	MOVT r0, #0x2000
	BL string2int ; convert to integer in r0
	MOV r9, r0 ; save result in r9

	MOV r5, #4 ; bounds of proper user input
	MOV r6, #1

	CMP r5, r9 
	BGT invalid ; invalid input
	CMP r6, r9
	BLT invalid ; invalid input

	MOV r5, #1 ; check if test 1
	CMP r5, r9 
	BL read_tiva_push_button

	MOV r5, #2 ; check if test 2
	CMP r5, r9 
	BL read_from_push_btns

	MOV r5, #3 ; check if test 3
	CMP r5, r9 
	BL illuminate_LEDs

	MOV r5, #4 ; check if test 4
	CMP r5, r9 
	BL illuminate_RGB_LED

invalid_input:
	LDR r4, ptr_to_prompt_l8 ; load eighth prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	MOV r0, #0x0100
	MOVT r0, #0x2000 ; Load base address
	BL read_string ; at some point load the characters we just stored into a register

	MOV r0, #0x0100        ; reload address
	MOVT r0, #0x2000
	MOV r8, r0 ; save result in r8

	MOV r7, #110
	CMP r7, r8
	BEQ done
	MOV r7, #78
	CMP r7, r8
	BEQ done   ; term if user says no more testing 

	MOV r7, #121
	CMP r7, r8
	BEQ done
	MOV r7, #89
	CMP r7, r8
	BEQ restart   ; continue if user says more testing 

	LDR r4, ptr_to_prompt_l9 ; load ninth prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	B invalid_input

invalid:
	LDR r4, ptr_to_prompt_l0 ; load default prompt
	MOV r0, r4 ; send prompt
	BL output_string ; print prompt
	BL new_line ; new line

	B restart ; restart program

done:
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

	.end
