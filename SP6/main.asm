;Programa matriz

	.global  main		; makes main accessible from outside this file.
    .thumb			; use thumb
    .data			; set memory location to ram
    				; put your variables here

    .text				; set memory location to flash

main:
	vmov.f32 s0, #9.0
	bl sqrt


	vmov.f32 s0, #1.0
	vldr s1, prec
	vmov.f32 s2, #-1.0
	bl roots

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

; roots(float a, float b, float c)
; s0 -> a
; s1 -> b
; s2 -> c
; s0 -> raiz 1
; s1 -> raiz 2
; raizes invalidas???
roots:
	vmov.f32 s3, #4.0
	vmul.f32 s4, s1, s1		; b^2
	vmul.f32 s3, s3, s0, ; 4*a
	vmul.f32 s3, s3, s2 ; s4 = 4*a*c
	vsub.f32 s2, s4, s3 ; s4 = b^2-4*a*c

	vcmp.f32 s2, #0.0
	vmrs APSR_nzcv, FPSCR

	blt complex_roots

    push {LR}
	vpush {s0, s1}
	vmov.f32 s0, s2
	bl sqrt
	vmov.f32 s2, s0
	vpop {s0, s1}
    pop {LR}

    ; s0 -> a
    ; s1 -> b
    ; s2 -> sqrt(b^2-4*a*c)

	vmov.f32 s3, #2.0
	vmul.f32 s3, s3, s0		; 2*a
	vneg.f32 s1, s1			; -b

	vadd.f32 s0, s1, s2		;
	vdiv.f32 s0, s0, s3

	vsub.f32 s1, s1, s2		;
	vdiv.f32 s1, s1, s3

	bx LR

complex_roots:


	bx LR

	.end
