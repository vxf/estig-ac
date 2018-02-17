LCD_SIZE .equ 84*6

; LCD_CEN .equ PIN1
LCD_RST .equ PIN2
LCD_CMD .equ PIN3
LCD_LED .equ PIN4

LCD_ALL .equ LCD_CMD|LCD_RST

	.data
fBuffer:	.space LCD_SIZE
	.text
ptrFBuffer:	.field fBuffer, 32

;--------------------------
	and R3, R2, #0xFF ; y
	and R4, R2, #0xFF00 ; x

;	ldr R5, ptrFBuffer
;	add R5, R5, R4, LSL #8 ; x
	add R5, R5, R3, LSL #3 ; R5 = *fb + x + y // 3

	and R4, R2, #3 ; y shift

	lsl R2, #19 ; w | h // 3
	and R3, R2, #0x1F ; h // 3
	lsl R2, #5 ; w
;---------------------------------
; R0 *sprite
; R1 *sprite mask
; R2 size w|h|x|y
fb_draw_sprite_m:

;	ldr R5, ptrFBuffers


fb_draw_sprite_m_loop:
	cmp R2, #0
	beq fb_draw_sprite_m_loop_end

	ldrb R3, [R5]
	ldrb R4, [R1], #1
	and R3, R3, R4
	ldrb R4, [R0], #1
	orr R3, R3, R4
	strb R3, [R5], #1
 	sub R2, #1

 	b fb_draw_sprite_m_loop
fb_draw_sprite_m_loop_end:

	bx LR

lcd_draw_fbuffer:
	push {LR}

	mov R0, #0x80
 	bl lcd_send

	mov R0, #0x40
	bl lcd_send

	ldr R0, ptrFBuffer
	mov R1, #LCD_SIZE
	bl lcd_send_buffer

	pop {LR}
	bx LR

; send to LCD
; R0 data
; R1 type (1 Data/0 CMD)
lcd_send:
	ldr R5, SSI_0
lcd_send_bsy_wait:
 	ldr R2, [R5, #SSI_SR]
 	tst R2, #0x10 ; test BSY bit
 	bne lcd_send_bsy_wait

 	ldr R6, PORT_F
 	mov R2, #0x4
 	orr	R2, R2, R1, LSL #3
 	strb R2, [R6, #LCD_ALL]

 	strb R0, [R5, #SSI_DATA]

lcd_send_bsy_wait2:
 	ldr R2, [R5, #SSI_SR]
 	tst R2, #0x10 ; test BSY bit
 	bne lcd_send_bsy_wait2

	bx LR

; send to LCD
; R0 data
lcd_send_data:
	ldr R5, SSI_0
lcd_send_data_bsy_wait:
 	ldr R1, [R5, #SSI_SR]
 	tst R1, #0x02 ; test FIFO Full bit
 	beq lcd_send_data_bsy_wait

 	ldr R6, PORT_F
	mov R1, #0xC
 	strb R1, [R6, #LCD_ALL]

 	strb R0, [R5, #SSI_DATA]

	bx LR

; send buffer to LCD as data
; R0 *data
; R1 size
lcd_send_buffer:
	ldr R5, SSI_0
 	ldr R6, PORT_F

lcd_send_buffer_bsy_wait:
 	ldr R2, [R5, #SSI_SR]
 	tst R2, #0x02 ; FIFO Full bit
 	beq lcd_send_buffer_bsy_wait

	mov R2, #0xC
 	strb R2, [R6, #LCD_ALL]

lcd_send_buffer_loop:
	cmp R1, #0
	beq lcd_send_buffer_loop_end

 	ldrb R2, [R0], #1
 	strb R2, [R5, #SSI_DATA]
 	sub R1, #1

lcd_send_buffer_bsy_wait2:
 	ldr R2, [R5, #SSI_SR]
 	tst R2, #0x02 ; FIFO Full bit
 	beq lcd_send_buffer_bsy_wait2

 	b lcd_send_buffer_loop
lcd_send_buffer_loop_end:
	bx LR

lcd_clear:
	push {LR}

	mov R1, #0
	mov R0, #0x80
	bl lcd_send

	mov R0, #0x40
	bl lcd_send

	mov R0, #0x00
	mov R3, #84*6
lcd_clear_loop:
	bl lcd_send_data
	subs R3, #1
	bne lcd_clear_loop

	pop {LR}
	bx LR

init_lcd:
	push {LR}

	mov R1, #0
	mov R0, #0x21 ; Tell LCD extended commands follow
	bl lcd_send

	mov R0, #0xBF ; Set LCD Vop (Contrast) 0xB1
	bl lcd_send

	mov R0, #0x04 ; Set Temp coefficent
	bl lcd_send

	mov R0, #0x14 ; LCD bias mode 1:48 (try 0x13)
	bl lcd_send

	mov R0, #0x20 ; vertical stream
	bl lcd_send

	mov R0, #0x0C ; Set display control, normal mode.
	bl lcd_send

	pop {LR}
	bx LR

; setups ports A and F
init_ports:
	ldr R6, SYSTEM_CONTROL
	mov R0, #0x21
	strb R0, [R6, #RCGCGPIO]
	strb R0, [R6, #GPIOHBCTL] ; enable high performance bus

	bx LR

; setups gpio pins at port F
; 1, 2, 3, 4 for output
init_gpio:
	ldr R6, PORT_F
	mov R0, #0x1E
	strb R0, [R6, #GPIODIR]
	strb R0, [R6, #GPIODEN]

	bx LR


; setups SSI0 on port A
init_ssi0:
	; enable SSI module 0
	ldr R6, SYSTEM_CONTROL
	; ldr R6, RCGCSSI
	mov R0, #0x01
	strb R0, [R6, #RCGCSSI]

	; select special function for port A, pins 2, 3, 5
	ldr R6, PORT_A
	mov R0, #0x2C
	strb R0, [R6, #GPIOAFSEL]
	strb R0, [R6, #GPIODIR] ; set pins 2,3,5 for output
	strb R0, [R6, #GPIODEN] ; enable pins 2,3,5

	mov R0, #0x04
	strb R0, [R6, #GPIOPUR] ; enable pull-up on pin 2 CLK

	ldr R6, SSI_0
	mov R0, #0x00
	str R0, [R6, #SSI_CR1]

	; clock signal configuration
	;mov R0, #0xFF
	;strb R0, [R6, #SSI_CPSR]

	mov R0, #0x00C7
	str R0, [R6, #SSI_CR0]

	mov R0, #0x02
	str R0, [R6, #SSI_CR1]

	bx LR
