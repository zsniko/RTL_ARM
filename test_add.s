
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
@ //           test add        	.text
	.globl	_start                                    //
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


	
	.text
	.globl	_start 

_start:
	mov r0, #5
	mov r1, #3

while:
	cmp r0, r1 
	BEQ end 
	SUBGT r1, r1, r0
	SUBLE r0, r0, r1 
	B while 
end:
	B _good

_bad :
	nop
	nop
_good :
	nop
	nop


