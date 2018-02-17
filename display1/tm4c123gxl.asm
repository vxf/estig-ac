; configuration registers
SYSTEM_CONTROL:	.word 0x400FE000
GPIOHBCTL	.equ 0x06C ; GPIO High-Performance Bus Control
RCGCGPIO	.equ 0x608 ; General-Purpose Input/Output Run Mode Clock Gating Control
RCGCSSI		.equ 0x61C ; Synchronous Serial Interface Run Mode Clock Gating Control

; GPIO pin
PORT_A: .word 0x40058000
PORT_E: .word 0x4005C000
PORT_F: .word 0x4005D000

; port register offsets
GPIODATA	.equ 0x000 ; GPIO Data (empty mask)
GPIODIR		.equ 0x400 ; GPIO Direction
GPIOAFSEL	.equ 0x420 ; GPIO Alternate Function Select
GPIOPUR		.equ 0x510 ; GPIO Pull-Up Select
GPIODEN		.equ 0x51C ; GPIO Digital Enable

; pin address masks
PIN0 .equ 0x04
PIN1 .equ 0x08
PIN2 .equ 0x10
PIN3 .equ 0x20
PIN4 .equ 0x40

; SSI0 registers
SSI_0:		.word	0x40008000
SSI_CR0		.equ	0x00
SSI_CR1		.equ	0x04
SSI_DATA	.equ	0x08
SSI_SR		.equ	0x0C
SSI_CPSR	.equ	0x10
