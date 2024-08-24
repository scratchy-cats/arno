.attribute arch, "rv64gc"
.option    arch, -c       // Disable c-extension.

.equ MAX_HARTS, 2 // HART (hardware thread) is equivalent to CPU core.
.equ STACK_MEMORY_PER_HART, 4096

.section .bss
  .align 4
  // Since we don't have the crt0 runtime, we need to create a stack explicitly. Each CPU core
  // (hardware thread) will get 4 KB from this stack.
  stack0:
    .space STACK_MEMORY_PER_HART*MAX_HARTS

.section .init
  .global _entry
    _entry:
      // stack-pointer = address(stack0) + ((current hart-id + 1) * STACK_MEMORY_PER_HART)
      //
      la sp, stack0                 // (l)oad (a)ddress of stack0 to stack-pointer.
      li a0, STACK_MEMORY_PER_HART  // (l)oad (i)mmediate: a0 = STACK_MEMORY_PER_HART.
      csrr a1, mhartid              // (r)ead: a1 = current (har)dware(t)hread id.
      addi a1, a1, 1                // (a)dd (i)mmediate: a1 = hartid + 1
      mul a0, a0, a1                // (m)ultiply: a0 = a0 * STACK_MEMORY_PER_HART
      add sp, sp, a0                // (a)dd: sp = sp + a0

      call start                    // start( ) is defined in ../start.rs.

  // NOTE : csr = (c)ontrol and (s)tatus (r)egister.
