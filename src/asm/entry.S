// set some attributes and options to
// help any cc, to understand how this
// is supposed to be compiled. it
// would be nice if we didnt have to
// do it, but from my expxierence when
// using langauges such as rust or
// zig, they dont always get it right.
.attribute arch, "rv64gc"
.option    arch, -c

.equ STACK_SIZE, 1096 * 16
.equ MPP_MASK, 3 << 11
.equ MPP_S, 1 << 11

.section .init
.global  _start

// help the debugger
.type _start, @function

_start:
	// set the global pointer and make
	// sure the linker will not optimize
	// this away, by is disabled linker
	// relaxation. also known as "gp
	// releaxation".
	.option push
	.option norelax
	la      gp, __global_pointer$
	.option pop

	// put hartid in a3 and keep it, for
	// the next intructions.
	csrr a3, mhartid

	// set the thread pointer. This helps
	// to identify the current thread,
	// later.
	mv tp, a3

	// offset each harts sp, by
	// hartid*size. this creates a
	// seperate stack for each hart. with
	// 16kb in size.
	addi a0, a3, 1
	li   a1, STACK_SIZE
	mul  a0, a0, a1
	la   sp, __stack_top$
	add  sp, sp, a0

	// disable supervirsor address
	// translation and protection. The
	// actual kernel should set this up.
	csrw satp, zero

	// configure the lowest PMP registers
	// to allow the supervirsor to access
	// all memory. PMP is used to check is
	// a given mode is allowed to access a
	// given memory region.. cfg is 8bit
	// and addr is xlen bit. The lowest
	// register have priority.
	la   a0, ~0
	csrw pmpaddr0, a0
	csrw pmpcfg0, a0

	// bit 11-12 in mstatus are for the
	// privilege mode. from 0 user, 1
	// supervisor, 3 machine. mret will
	// use this to set the privilege mode.
	// clear the current status and set it
	// to supervisor.
	la   a0, MPP_MASK
	csrc mstatus, a0
	la   a0, MPP_S
	csrs mstatus, a0

	// when calling mret, the the machine
	// exception program counter,
	// determines where the hart will jump
	// to. This is the address of the next
	// instruction.
	la   a0, main
	csrw mepc, a0

	// at this point MPP and MEPC are set
	// such mret will return to the adress
	// in MEPC, with the priviledge level
	// in MPP (supervisor mode)
	mret

	// deadlock guard, in case the
	// instruction pointer moves past mret
	// for some reason
_deadlock:
	wfi
	j _deadlock

	// help the debugger
	.size _start, .- _start
