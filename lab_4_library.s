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
	.global new_line


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

gpio_btn_and_LED_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

init_gpio:

    MOV r0, #0xE608
    MOVT r0, #0x400F ; RCGCGPIO Register Address

    LDR r1, [r0] ; Read the current value of RCGCGPIO
    ORR r1, r1, #0x32
    STR r1, [r0] ; Write back the updated value to RCGCGPIO

wait_gpio:
    MOV r0, #0xEA08
    MOVT r0, #0x400F ; RCGCGPIO Register Address

gpio_wait_loop:
    LDR r1, [r0] ; Read the current value of RCGCGPIO
    AND r1, r1, #0x32 ; Check if the clock for port is enabled
    CMP r1, #0x32 ; If not enabled, wait
    BNE gpio_wait_loop

    ; else keep going
    ; port F init
    MOV r0, #0x5000
    MOVT r0, #0x4002 ; PORT F Base Address

    MOV r1, #0x1E ; Set the direction of the pins (PF1-3 as output and 4 as input)
    STR r1, [r0, #0x400] ; Write to the GPIODIR register

    ; digital
    MOV r1, #0x1E ; enable PF1-4
    STR r1, [r0, #0x51C]

    MOV r1, #0x10 ; enable pull-up resistor for PF4
    STR r1, [r0, #0x510]

    ; port B init
    MOV r0, #0x5000
    MOVT r0, #0x4000 ; PORT B Base Address

    MOV r1, #0x0F ; Set the direction of the pins (PB0-3 as output)
    STR r1, [r0, #0x400] ; Write to the GPIODIR register

    ; digital
    MOV r1, #0x0F ; enable PB0-3
    STR r1, [r0, #0x51C]

    ; port D init
    ; switch 2 is pin 3
    ; switch 5 is pin 0
    MOV r0, #0x7000
    MOVT r0, #0x4000 ; PORT D Base Address

    MOV r1, #0x0F ; Set the direction of the pin
    STR r1, [r0, #0x510] ; Write to the GPIODIR register

    ; digital
    MOV r1, #0x0F ; enable
    STR r1, [r0, #0x510]

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
	BEQ detect_comma           ; Skip comma, don't store

	; Echo the character
	BL output_character

	; Store character in string
	STRB r0, [r4, r5]
	ADD r5, r5, #1

	B read_loop

detect_comma:
	BL output_character
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

read_from_push_btns:
    PUSH {r4-r12, lr} 	; Spill registers to stack

    ; Load Port D base address
    MOV  r1, #0x7000
    MOVT r1, #0x4000

    ; Read Port D data register
    LDR  r0, [r1, #0x3FC]

    ; Mask PD0–PD3 (Switches 2–5)
    AND  r0, r0, #0x0F
	;EOR  r0, r0, #0x0F     ; if switches need to be inverted

    POP {r4-r12, lr}	; Restore registers from stack
    MOV  pc, lr

illuminate_LEDs:
    PUSH {r4-r12, lr} 	; Spill registers to stack

	; format
	;   bit 0 = LED0 (PB0)
	;   bit 1 = LED1 (PB1)
	;   bit 2 = LED2 (PB2)
	;   bit 3 = LED3 (PB3)
	
	; in decimal
	;   0  = all OFF
	;   1  = LED0
	;   2  = LED1
	;   4  = LED2
	;   8  = LED3
	;   3  = LED0 + LED1
	;   5  = LED0 + LED2
	;   7  = LED0 + LED1 + LED2
	;   15 = all LEDs ON

    ; Load Port B base address
    MOV  r1, #0x5000
    MOVT r1, #0x4000

    ; Keep only lower 4 bits (LED0–LED3)
    AND  r0, r0, #0x0F

    ; Write to Port B DATA register
    STR  r0, [r1, #0x3FC]

    POP {r4-r12, lr}	; Restore registers from stack
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


str2int:
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

unsigned_division:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ;place holder for unsigned div
	UDIV r0, r1, r0

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

signed_division:
	PUSH {r4-r12,lr}	; Spill registers to stack

	;place holder for signed div
	SDIV r0, r1, r0

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

mod:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ;place holder for mod
	MOV r4, r0 ;temp divisior
	MOV r5, r1 ;temp dividend
	SDIV r0, r1, r0
	MUL r0, r0, r4
	
	SUB r0, r5, r0

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

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
