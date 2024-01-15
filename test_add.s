
@ /*----------------------------------------------------------------
@ //           test add                                           //
@ ----------------------------------------------------------------*/
@ 	.text
@ 	.globl	_start 
@ _start:               
@ 	/* 0x00 Reset Interrupt vector address */
@ 	b	startup
	
@ 	/* 0x04 Undefined Instruction Interrupt vector address */
@ 	b	_bad

@ startup:
@ 	mov r0, #0
@ 	adds r1, r0, r0
@ 	bne _bad
@ 	movs r0, #0x80000000
@ 	bpl _bad
@ 	subs r0, r0, #1
@ 	bmi _bad
@ 	b _good

@ _bad :
@ 	nop
@ 	nop
@ _good :
@ 	nop
@ 	nop
@ AdrStack:  .word 0x80000000










@ /*----------------------------------------------------------------
@ //           test add                                           //
@ ----------------------------------------------------------------*/
@ 	.text
@ 	.globl	_start 
@ _start:               
@ 	/* 0x00 Reset Interrupt vector address */
@ 	b	startup
	
@ 	/* 0x04 Undefined Instruction Interrupt vector address */
@ 	b	_bad

@ startup:
@ 	MOV r0, #12
@ 	MOV r1, #8 
@ 	ADD r0, r0, r1 
@ 	ADD r1, r1, r1 
@ 	B   _bh 
@ 	ADD r0, r0, #0
@ 	ADD r0, r0, #0
@ 	ADD r0, r0, #0

@ _bh:
@ 	ADD r1, r1, #2
@ 	B _good

@ _bad :
@ 	nop
@ 	nop
@ _good :
@ 	nop
@ 	nop
@ AdrStack:  .word 0x80000000


	
	mov r0, #7
	mov r1, #3
	nop
	subs r2, r0, r1
while:
	subhs r0, r0, r1
	submi r1, r1, r0
	nop
	subs r2, r0, r1
	bne while
	nop
	nop
	mov r3, r0
	nop
	nop
	nop

