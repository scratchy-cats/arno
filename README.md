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
