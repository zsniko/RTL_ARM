@@@@@@@@@@@@@ PGCD OK @@@@@@@@@@@@@@

	.text
	.globl	_start

_start:
	/* 0x00 Reset Interrupt vector address */
	b	startup

	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	MOV r0, #15
	MOV r1, #9

while:
	CMP r0, r1
	BEQ _good 
	SUBGT r0, r0, r1
	SUBLE r1, r1, r0
	B while

_bad :
	nop
	nop

_good :
	nop
	nop

AdrStack:  .word 0x80000000

@ 	.text
@ 	.globl	_start

@ _start:
@ 	/* 0x00 Reset Interrupt vector address */
@ 	b	startup

@ 	/* 0x04 Undefined Instruction Interrupt vector address */
@ 	b	_bad

@ startup:
@ 	MOV r0, #15
@ 	MOV r1, #9

@ while:
@ 	CMP r0, r1
@ 	BEQ _good 
@ 	BGT _supR1
@ 	SUB r1, r1, r0
@ 	B while

@ _supR1:
@ 	SUB r0, r0, r1
@ 	B while

@ _bad :
@ 	nop
@ 	nop

@ _good :
@ 	nop
@ 	nop

@ AdrStack:  .word 0x80000000
