.section .data
  .align 4
  /* Since we don't have the crt0 runtime, we need to create a stack explicitly. Each CPU core
   * (hardware thread) will get 16 KB from this stack. */
  stack0:
    .space 16384*8

.section .text
  .global _entry
  _entry:
    // stack-pointer = address(stack0) + ((current hardware-thread id + 1) * STACK_MEMORY_PER_CPU)
    //
    la sp, stack0     // (l)oad (a)ddress of stack0 to stack-pointer.
    li a0, 16384      // (l)oad (i)mmediate: a0 = STACK_MEMORY_PER_CPU.
    csrr a1, mhartid  // (r)ead: a1 = current (har)dware(t)hread id.
    addi a1, a1, 1    // (a)dd (i)mmediate: a1 = hartid + 1
    mul a0, a0, a1    // (m)ultiply: a0 = a0 * STACK_MEMORY_PER_CPU
    add sp, sp, a0    // (a)dd: sp = sp + a0

    call start // start( ) is defined in ../main.rs.