
	.global  main		; makes main accessible from outside this file.
	
    .thumb			; use thumb
    .data			; set memory location to ram
    				; put your variables here
    				
    .text				; set memory location to flash

RCGCGPIO:	.word 0x400FE608 ; GPIO clock gating control
GPIOHBCTL:	.word 0x400FE06C ; high-performance bus control
PORT_F:		.word 0x4005D000 ; port F registers on high-performance bus

; port register offsets
GPIODIR		.equ 0x400	; input/output register
GPIOAFSEL	.equ 0x420	; alternate function selector
GPIODEN		.equ 0x51C	; digital enable
GPIOPCTL	.equ 0x52C	; GPIO port control (controls the port function MUX)

; pin address masks
; a bit mask must be provided in the pin data adress
; that only writes on the masked pins
; and shifted by 2 bits
PF0 .equ 0x4
PF1 .equ 0x8
PF2 .equ 0x10
PF3 .equ 0x20
PF4 .equ 0x40

; tiva C RGB LED addressing
LED_RED		.equ PF1
LED_BLUE	.equ PF2
LED_GREEN	.equ PF3

LED_PINK	.equ LED_RED|LED_BLUE
LED_YELLOW	.equ LED_RED|LED_GREEN
LED_CYAN	.equ LED_BLUE|LED_GREEN

LED_WHITE	.equ LED_RED|LED_BLUE|LED_GREEN

; blink color
LED_COLOR	.equ LED_RED

slpcycles: .word 4000000	; 4x10^6xsleep instruction cycles seem
							; to be around 0.5s at default freq

main:
	; enable port F
	mov R0, #0x20	; port F bit
	ldr R6, RCGCGPIO
	str R0, [R6]
	
	; enable high performance bus (optional) for port F
	ldr R6, GPIOHBCTL
	str R0, [R6]
	
	mov R0, #0x0E 	; enable the 3 RGB pins
	ldr R6, PORT_F
	strb R0, [R6, #GPIODIR] ; set pin 1 for output
	strb R0, [R6, #GPIODEN] ; enable pin 1 function

	; R0 can be our led state
	strb R0, [R6, #LED_COLOR]
	
	ldr R1, slpcycles
sleep:
	subs R1, #1
	bne sleep
	
	mvn R0, R0	; toggle pin state
	strb R0, [R6, #LED_COLOR]
	
	ldr R1, slpcycles
	b sleep

end_main:	b end_main

	.end