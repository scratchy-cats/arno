set confirm off
set architecture riscv:rv64
target remote 127.0.0.1:1234
symbol-file target/riscv64gc-unknown-none-elf/debug/arno
set disassemble-next-line auto
set riscv use-compressed-breakpoints yes
set breakpoint pending on
break _start
break arno::main
break arno::panic
break arno::trap_handler
tui enable
layout reg
c
