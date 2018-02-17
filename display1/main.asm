; CE  <-> PA3
; RST <-> PF2
; D/C <-> PF3
; D   <-> PA5
; CLK <-> PA2
; LED <-> PF4
; 
	.global  main		; makes main accessible from outside this file.
	
    .thumb			; use thumb
    .data			; set memory location to ram
    				; put your variables here	
    .text				; set memory location to flash

	.include "tm4c123gxl.asm"
	.include "pcd8544.asm"
	.include "judy.asm"

slpcycles: .word 100000

main:
    bl init_ports
    bl init_gpio
	bl init_ssi0
	
	ldr	R6, PORT_F
	mov R0, #4 ; RST
 	strb R0, [R6, #LCD_ALL]
 	
	ldr R2, slpcycles
	bl sleep
 	
	mov R0, #0 ;
 	strb R0, [R6, #LCD_RST]
 	
	ldr R2, slpcycles
	bl sleep

	mov R0, #4 ;
 	strb R0, [R6, #LCD_RST]
	
	ldr R2, slpcycles
	bl sleep
	
	bl init_lcd
	
	mov R0, #0x10
 	strb R0, [R6, #LCD_LED]
	
	ldr R2, slpcycles
	bl sleep
	
	bl lcd_clear
	
	mov R1, #0	
	mov R0, #0x22 ; vertical stream
	bl lcd_send

	;mov R0, #0x80
 	;bl lcd_send
	
	;mov R0, #0x40
	;bl lcd_send
	
	;ldr R0, ptrJudy
	;mov R1, #JUDY_SIZE
	;bl lcd_send_buffer

derp:
	mov R1, #0xAAAA
	bl fill_fb
	bl lcd_draw_fbuffer
	ldr R2, slpcycles
	bl sleep
	mov R1, #0x5555
	bl fill_fb
	bl lcd_draw_fbuffer
	ldr R2, slpcycles
	bl sleep
	b derp

	bl fill_fb

	ldr R0, ptrJudy
	ldr R1, ptrJudy_m
	mov R2, #JUDY_SIZE
	bl fb_draw_sprite_m
	bl lcd_draw_fbuffer



loop:
	b loop

sleep:
	subs R2, #1
	bne sleep
	
	bx LR

fill_fb:
	mov R0, #84
	; mov R1, #0xAAAA
	orr R1, R1, R1, LSL #16
	ldr R2, ptrFBuffer
fill_fb_loop:
	mvn R1, R1
	str R1, [R2], #4
	strh R1, [R2], #2
	subs R0, #1
	bne fill_fb_loop


	bx LR

.end
