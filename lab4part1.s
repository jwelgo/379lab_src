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

	MOV r1, #1 ; set red to 1
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

    MOV r0, #0x5000
    MOVT r0, #0x4002 ; PORT F Base Address

    MOV r4, #0x3FC

	; r1 = red
	; r2 = blue
	; r3 = green

    STRB r1, [r0, r4], #32 ; pin 1
    STRB r2, [r0, r4], #32 ; pin 2?
    STRB r3, [r0, r4]	; pin 3?

    ; TODO
    ; confirm that that is right

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
