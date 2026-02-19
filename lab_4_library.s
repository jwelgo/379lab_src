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


uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

gpio_btn_and_LED_init: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_character: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr






read_character: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_string: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_string: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_from_push_btns: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_LEDs: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_RGB_LED: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_tiva_pushbutton: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


str2int: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

int2str: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

unsigned_division: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

signed_division: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

mod: 
	PUSH {r4-r12,lr}	; Spill registers to stack
    
          ; Your code is placed here
 
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


	.end
