_machine:
	// disable supervirsor address
	// translation and protection. The
	// actual kernel should set this up.
	csrw satp, zero

	// configure the lowest PMP registers
	// to allow the supervirsor to access
	// all memory. PMP is used to check is
	// a given mode is allowed to access a
	// given memory region. cfg is 8bit
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
