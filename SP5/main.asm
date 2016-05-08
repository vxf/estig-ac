;Programa matriz

	.global  main		; makes main accessible from outside this file.
    .thumb			; use thumb
    .data			; set memory location to ram
    				; put your variables here
calc_addr: .word case_0, case_1, case_2, case_3
calc_ops: .word case_add, case_sub, case_mul, case_div
    				
A:	.word 1, 23, 45, 37, 51, 2
C:	.space 4*10         ; 10 inteiros 32 bit

array:	.word 10, -24, -2, 67, 31, 27
pares:	.space 4*6

    .text				; set memory location to flash
ptA:	.field A, 32
dimA:	.word 6

ptcalc_addr: .word calc_addr
ptcalc_ops: .word calc_ops
ptArray: .word array
dimArray: .word 6
ptPares: .word pares

main:
	; 1)
	mov R0, #1	; f
	mov R1, #2	; g
	mov R2, #3	; h
	mov R3, #4	; i
	mov R4, #5	; j
	mov R5, #2	; k
	mov R6, #4

	cmp R5, #0
	it lt
	blt switch_end
	cmp R5, R6
	it ge
	bge switch_end
	ldr R7, ptcalc_addr
	ldr R7, [R7, R5, LSL #2]
	bx R7
case_0:
	add R0, R3, R4
	b switch_end
case_1:
	add R0, R1, R2
	b switch_end
case_2:
	sub R0, R1, R2
	b switch_end
case_3:
	sub R0, R3, R4
	b switch_end

switch_end:
	
	mov R0, #3
	mov R1, #2
	mov R2, #2 ; mul
	bl calc		; 2

	mov R0, #3
	mov R1, #2
	mov R2, #1
	bl max3		; 4)
	
	mov R0, #12
	mov R1, #8
	bl mdc		; 5)
	
	ldr R0, ptArray
	ldr R1, dimArray
	bl mean		; 6)
	
	ldr R0, ptArray
	ldr R1, dimArray
	mov R2, #31
	bl find		; 7)
	
	ldr R0, ptArray
	ldr R1, dimArray
	bl biggest	; 8)
	
	ldr R0, ptArray
	ldr R1, dimArray
	ldr R2, ptPares
	bl CopyEvenOnly	; 9)

fim_main:	b fim_main

; 2)
; int calc(int a, int b, int op)
; a R0
; b R1
; op R2
; return R0
calc:
	cmp R2, #0
	it lt
	blt calc_end
	cmp R2, #4
	it ge
	bge calc_end
	
	ldr R3, ptcalc_ops
	ldr R3, [R3, R2, LSL #2]
	bx R3

case_add:
	add R0, R0, R1
	b calc_end
case_sub:
	sub R0, R0, R1
	b calc_end
case_mul:
	mul R0, R0, R1
	b calc_end
case_div:
	sdiv R0, R0, R1
	
calc_end:
	bx LR

; 3)
sum_a:
	mov R1, #0
sum_a_for:
	cmp R0, #0
	beq sum_a_end
	add R1, R0
	sub R0, #1
	b sum_a_for
	
sum_a_end:
	mov R0, R1
	bx LR
	
sum_b:
	mla R0, R0, R0, R0
	lsr R0, #1
	bx LR
	
sum_n:
	push {LR}
sum_n_for:
	cmp R1, #0
	beq sum_n_end
	
	push {R0, R1}
	ldr R0, [R0, #4]
	bl sum_b
	
	; do something with values here
	
	pop {R0, R1}

	sub R1, #1
	b sum_n_for
	
sum_n_end:
	pop {LR}
	bx LR

; 4)
; int max3(int a, int b, int c) 
; a R0
; b R1
; c R2
; return R0
max3:
	push {LR}
	push {R0}
	mov R0, R1
	mov R1, R2
	bl max
	mov R1, R0
	pop {R0}
	bl max
	pop {LR}
	bx LR

; int max(int a, int b)
; a R0
; b R1
; return R0
max:
	cmp R0, R1
	it lt
	movlt R0, R1
	bx LR

; 5)
; double mdc(int a, int b)
; a R0
; b R1
; return R0
mdc:
	cmp R0, #0
	it eq
	moveq R0, R1
	it eq
	bxeq LR
	
	push {LR}
	
mdc_cycle:

	cmp R1, #0
	beq mdc_end
	
	cmp R0, R1
	it gt
	blgt sub_1
	bgt mdc_cond_2
	
	mov R2, R1
	mov R1, R0
	mov R0, R2
	bl sub_1
	mov R2, R1
	mov R1, R0
	mov R0, R2

mdc_cond_2:
	b mdc_cycle
	
mdc_end:
	pop {LR}
	bx LR
	
; double sub(int c, int d)
; c R0
; d R1
; return R0
sub_1:
	sub R0, R0, R1
	bx LR

; 6)
; int mean(ptArray, dimArray)
; ptArray R0
; dimArray R1
; return R0
mean:
	push {R4}
	mov R2, #0
	mov R3, #0
	
mean_cycle:
	cmp R3, R1
	bge mean_end
	ldr R4, [R0], #4
	add R2, R2, R4 
	add R3, #1
	b mean_cycle
	
mean_end:
	sdiv R0, R2, R1
	pop {R4}
	bx LR

; 7)
; int find(int &list, int n, int x)
; &list R0
; n R1
; x R2
; return R0
find:
	cmp R1, #0
	it eq
	moveq R0, #0
	beq find_end
	
	ldr R3, [R0], #4
	cmp R2, R3
	it eq
	moveq R0, #1
	beq find_end
	sub R1, #1
	b find
	
find_end:
	bx LR
	
; 8)
; int biggest(int &array, int n)
; &array R0
; n R1
; return R0
biggest:
	ldr R2, [R0], #4

biggest_while:	
	subs R1, #1
	beq biggest_end
	
	ldr R3, [R0],  #4
	cmp R2, R3
	it lt
	movlt R2, R3
	b biggest_while
	
biggest_end:
	mov R0, R2
	bx LR

; 9)
; int CopyEvenOnly(int &array, int n, int &pares)
; &array R0
; n R1
; &pares R2
; return R0
CopyEvenOnly:
	push {R4}
	mov R4, #0
CopyEvenOnly_for:
	cmp R1, #0
	beq CopyEvenOnly_end
	
	ldr R3, [R0], #4
	tst	R3, #1
	itt eq
	streq R3, [R2], #4
	addeq R4, #1
	
	sub R1, #1
	b CopyEvenOnly_for
CopyEvenOnly_end:
	mov R0, R4
	pop {R4}
	bx LR

	.end
