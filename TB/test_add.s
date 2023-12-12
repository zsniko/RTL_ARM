
/*----------------------------------------------------------------
//           test add                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #0
	adds r1, r0, r0
	bne _bad
	movs r0, #0x80000000
	bpl _bad
	subs r0, r0, #1
	bmi _bad
	b _good

_bad :
	nop
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
