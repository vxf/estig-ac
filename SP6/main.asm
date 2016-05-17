;Programa matriz

	.global  main		; makes main accessible from outside this file.
    .thumb			; use thumb
    .data			; set memory location to ram
    				; put your variables here

    .text				; set memory location to flash

main:
	vmov.f32 s0, #9.0

	bl sqrt

fim_main:	b fim_main

prec: .float 1.0e-5
; float sqrt(float R0)
; s0 -> x
; return s0
sqrt:
	vmov.f32 s4, #2.0
	vmov.f32 s1, #1.0 ; y0
	vldr s6, prec

sqrt_cycle:
	vdiv.f32 s3, s0, s1
	vadd.f32 s3, s3, s1

	vdiv.f32 s3, s3, s4 ; / 2
						; s3 = y(n+1)
						; s1 = y(n)
	vsub.f32 s5, s3, s1 ; s5 = y(n+1) - y(n)
	vabs.f32 s5, s5     ; s5 = |s5|

	vcmp.f32 s5, s6
	vmov.f32 s1, s3
	vmrs APSR_nzcv, FPSCR
	bge sqrt_cycle

	vmov.f32 s0, s1

	bx LR


	.end
