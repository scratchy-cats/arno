// text is placed first by the linker
.section .text

// disable C compression extension ?!
// see https://github.com/llvm/llvm-project/commit/bca0c3cdb6d49822dbfbcac0bd2719e17e08f309
.option norvc

.type   _start, @function
.global _start

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

	// set the Supervisor Address Translation and Protection register to 0. this
	// 64 bit field is used for virtual page tables and memory protection.
	// setting it to zero disables virtual paging, meaning that virtual addresses
	// are directly mapped to physical addresses without any translation.
	csrw satp, zero

	// setup the stack with a 4096-byte stack per CPU.
	// sp = stack0 + (hartid * 4096)
	la   sp, stack0
	li   a0, 4096
	csrr a1, mhartid
	addi a1, a1, 1
	mul  a0, a0, a1
	add  sp, sp, a0

	// Clear the BSS section. This is not strictly required but is might be good
	// from a security persepective. It ensures all the uninitialized data is set
	// to zero, so no old data is left.
	la t5, bss_start
	la t6, bss_end

bss_clear:
	sd   zero, (t5)
	addi t5, t5, 8
	bltu t5, t6, bss_clear

	// jump to the kernel
	la   t0, main
	csrw mepc, t0
	tail main

	// if main returns, which it should not, just spin
spin:
	j spin

	.cfi_endproc

	.end
