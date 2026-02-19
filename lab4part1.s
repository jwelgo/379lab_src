	.text
	.global lab4

lab4:
	PUSH {r4-r12,lr}	; Spill registers to stack

      ; initialize GPIO

init_gpio:

    MOV r0, #0xE608
    MOVT r0, #0x400F ; RCGCGPIO Register Address

    LDR r1, [r0] ; Read the current value of RCGCGPIO
    ORR r1, r1, #0x20 ; set the bit to enable the clock for port f
    STR r1, [r0] ; Write back the updated value to RCGCGPIO

wait_gpio:
    MOV r0, #0xEA08
    MOVT r0, #0x400F ; RCGCGPIO Register Address

    LDR r1, [r0] ; Read the current value of RCGCGPIO
    AND r1, r1, #0x20 ; Check if the clock for port f is enabled
    CMP r1, #0 ; If not enabled, wait
    BEQ wait_gpio

    ; else keep going
    MOV r0, #0x5000
    MOVT r0, #0x4002 ; PORT F Base Address

    MOV r1, #0x0E ; Set the direction of the pins PF1-4 as output
    STR r1, [r0, #0x400] ; Write to the GPIODIR register

    ; digital
    MOV r1, #0x1E ; enable PF1-4
    STR r1, [r0, #0x51C]

    MOV r1, #0x10 ; enable pull-up resistor for PF4
    STR r1, [r0, #0x510]

    ; init done

; logic is to just constantly read the button if not pressed r0 is 0 and the led is off
; if it is pressed r0 is 1 and the led is on, change the color using the comments

main_loop:
    BL read_tiva_push_button ; Read the state of the push button
    CMP r0, #1 ; Check if the button is pressed
    BNE not_pressed

    ; If pressed, illuminate the RGB LED
	; TODO

	MOV r0, #1 ; set red to 1
	BL illuminate_RGB_LED
	NOP
	NOP
	MOV r0, #2
	BL illuminate_RGB_LED
	NOP
	NOP
	MOV r0, #4
	BL illuminate_RGB_LED
	NOP
	NOP
	MOV r0, #3
	BL illuminate_RGB_LED
	NOP
	NOP
	MOV r0, #5
	BL illuminate_RGB_LED
	NOP
	NOP
	MOV r0, #7
    BL illuminate_RGB_LED
    BL main_loop

not_pressed:
    MOV r0, #0x00 ; Set the value to turn off the RGB LED
    BL illuminate_RGB_LED
    BL main_loop

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


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

read_tiva_push_button:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ; r0 = 1 if pressed, 0 if not pressed

    MOV r1, #0x5000
    MOVT r1, #0x4002 ; PORT F Base Address

    LDRB  r2, [r1, #0x3FC] ; Read the value of the push buttons
    AND r2, r2, #0x10 ; Mask the bits except for SW1

    CMP r2, #0 ; check if pressed LOW
    BEQ sw1_pressed

    MOV r0, #0 ; SW1 not pressed
    B sw1_end

sw1_pressed:
    MOV r0, #1 ; SW1 pressed

sw1_end:
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

	.end
