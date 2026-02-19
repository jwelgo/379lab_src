	.text
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



lab4:
	PUSH {r4-r12,lr}	; Spill registers to stack

	;MOV r0, #1 ; red?
	;BL illuminate_RGB_LED
main_loop:
	BL read_tiva_push_button
	CMP r0, #1
	BNE not_pressed

	MOV r0, #1 ; red
	BL illuminate_RGB_LED
	BL main_loop

not_pressed:
	MOV r0, #0 ;turn off led
	BL illuminate_RGB_LED
	BL main_loop

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

	.end
