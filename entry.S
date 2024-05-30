.section .text
.global  _start

// crs = (c)oprocessor (s)system (r) registers

_start:
	csrw    satp, zero  // (w)rite: (s)econdary (a)ddress (t)ranslation (p)age register = 0
	la      sp, stack0  // (l)oad (a)ddress of stack0 to stack pointer
	csrr    a0, mhartid // (r)ead: current (har)dware(t)hread id
	li      a1, 4096    // (l)oad (i)mmediate: a1 = 4096
	addi    a2, a0, 1   // (a)dd (i)mmediate: a2 = hartid + 1
	mul     a2, a2, a1  // (m)ultiply: a2 = (hartid + 1) * 4096
	add     sp, sp, a2  // (a)dd: sp = sp + a2
	bnez    a0, halt    // (b)ranch (n)ot (e)qual (z)ero: halt nonzero harts
	.option push        // save current options
	.option norelax     // disable relaxation
	la      gp, gptr    // (l)oad (a)ddress: (g)lobal (p)ointer = gptr
	.option pop         // restore saved options
	tail    machine     // (j)ump: machine

halt:
	wfi    // (w)ait (f)or (i)nterrupt
	j halt // (j)ump: loop
