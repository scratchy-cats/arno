# RISC-V Kernel

Get the [instruction set manuals](https://riscv.org/technical/specifications/).

## Getting Started

Build the kernel and run it with qemu. Output goes to the console.

```bash
zig build run
```

## Debugging

Qemu will start a debug server and wait for gdb to attach, in the background.
After debugging, use `fg` and `ctrl-c` to stop qemu.

```bash
nohup zig build run -- -s -S > /dev/null &
riscv64-unknown-elf-gdb -x .gdbinit
```

## Roadmap

- [x] **Set up the stack**. The stack pointer is set to provide a memory
  region for local variables and function call  management.
- [x] **Set up the global pointer**. The global pointer provides efficient
  access  to global variables in the RISC-V application.
- [x] **Clear the BSS section**. The BSS (Block Started by Symbol) section
  contains uninitialized global variables, which have been cleared to ensure a
  clean start.
- [ ] **Configure the privilege level registers**. The `mstatus` register is
  set to configure the current privilege level (machine mode).
- [ ] **Set up the exception handling mechanism**. The `mtvec` register is
  configured to point to the exception vector table, and the necessary
  exception handling routines are implemented.
- [ ] **Implement memory management (if required)**. If the system requires
  virtual memory, the page table structures are set up, and the `satp` register
  is configured accordingly.
- [ ] **Perform kernel-level initialization tasks**. Device drivers, system
  services, and other kernel-level components are initialized.
- [ ] **Prepare the user mode environment** The user stack is set up, the user
  program is loaded, and any necessary user-level registers or state are
  configured.
- [ ] **Perform the ecall to switch to user mode**. The `ecall` instruction is
  executed to transition from machine mode to user mode and start executing
  user-level code.
