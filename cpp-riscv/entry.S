/*
  RISCV assembly cheatsheet -
    https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf.

  NOTE : The file extension is .S. It's used for files that contain assembly code that must still pass
  through a pre-processor.
*/

.section .text

  global _entry
  _entry:

    /* Divide the stack between CPUs. Each CPU gets 4KB. */
    la sp, stack0
    li a0, 1024*4
    csrr a1, mhartid
    addi a1, a1, 1
    mul a0, a0, a1
    add sp, sp, a0

    /* start( ) is defined in start.c */
    call start

  spin:
    j spin