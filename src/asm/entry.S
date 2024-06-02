// fix release mode: https://github.com/rust-lang/rust/issues/80608
.attribute arch, "rv64gc"

.option arch, -c // disable c-extension ?!

.equ STACK_SIZE, 4096
.equ MPP_M, 3 << 11
.equ MPP_S, 1 << 11

.section .init
.global  _start

_start:
	// disable linker relaxation,
	// and setup the global pointer.
	// also known as "gp relaxation"
	.option push
	.option norelax
	la      gp, __global_pointer$
	.option pop

	// setup the thread pointer
	csrr a3, mhartid
	mv   tp, a3

	// setup the stack pointer
	// based on the number of harts
	addi a0, a3, 1
	li   a1, STACK_SIZE
	mul  a0, a0, a1
	la   sp, __stack_top$
	add  sp, sp, a0

	// clear the "previous" mode in MPP,
	// and set it to supervisor mode
	li   a0, MPP_M
	csrc mstatus, a0
	li   a0, MPP_S
	csrs mstatus, a0

	// load the address of main into the
	// machine exception program counter.
	la   a0, main
	csrw mepc, a0

	// ensure supervisor address translation and protection,
	// is disabled, before switching to supervisor mode
	csrw satp, zero

	// allow the supervisor mode to access the entire
	// address space, by setting -1 on the priviledge
	// more protection registers
	li   a0, ~0
	csrw pmpaddr0, a0
	csrw pmpcfg0, a0

	// TODO: setup the trap handler

	// at this point MPP and MEPC are set such
	// mret will return to the adress in MEPC, with
	// the priviledge level in MPP (supervisor mode)
	mret

halt:
	wfi
	j halt
