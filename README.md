# RISC-V Kernel

## Setup

Get the [instruction set manuals](https://riscv.org/technical/specifications/).

Install the [toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain),
and make sure to pass `--enable-qemu` to the `configure` script.

Then use the [Makefile](./Makefile), to build and run the project.

You may want to watch this [riscv and qemu
video](https://www.youtube.com/watch?v=xlb6g8w01fc), to get started with
debugging and read the [qemu docs on the `sifive_u`
board](https://qemu.eu/doc/6.0/system/riscv/sifive_u.html).

## Development

```bash
nohup make run DEBUG=1 & # run qemu gdb server in background
make debug # attach gdb instance
ni # next instruction
ctrl-o # repeat previous command (ni)
```
