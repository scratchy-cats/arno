.section .text
.option  norvc
.type    _start, @function
.global  _start

_start:
	// The CFI directives are used for debugging. It allows the debugger to
	// unwind a stack. I guess alternatively one could discard eh frame ?
	.cfi_startproc

	// the global pointer gp, points to a region in memory, where global
	// variables are stored. This is typically somewhere in bss. note that
	// relaxation is disabled for this instruction. As i understand, we want to
	// disable gp relaxation, to avoid problems with relative adressing.
	// https://riscv.org/wp-content/uploads/2019/03/11.15-Shiva-Chen-Compiler-Support-For-Linker-Relaxation-in-RISC-V-2019-03-13.pdf
	// https://maskray.me/blog/2021-03-14-the-dark-side-of-riscv-linker-relaxation
	.option push
	.option norelax
	la      gp, gptr
	.option pop

	// setup the stack with a 4096-byte stack per CPU.
	// sp = stack0 + (hartid * 4096)
	la   sp, stack0
	li   a0, 4096
	csrr a1, mhartid
	addi a1, a1, 1
	mul  a0, a0, a1
	add  sp, sp, a0

	// jump to main with tco
	tail main

	// deadlock loop, if main returns, which it should not.
deadlock:
	wfi
	j deadlock

	.cfi_endproc
	.end
