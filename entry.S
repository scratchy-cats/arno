/* This is based on xv6's entrypoint:
https://github.com/mit-pdos/xv6-riscv/blob/riscv/kernel/entry.S. Howerver,
in https://wiki.osdev.org/RISC-V_Bare_Bones, they also load the global
pointer and clear bss, before entering c code. This may have to do with the
way stack0 is provided, but I dont think so.*/
.section .text
.global  _start

_start:
# with a 4096-byte stack per CPU.
# sp = stack0 + (hartid * 4096)
la   sp, stack0
li   a0, 4096
csrr a1, mhartid
addi a1, a1, 1
mul  a0, a0, a1
add  sp, sp, a0

# jump to kmain() in kernel.c
call kmain

spin:
	j spin

