set confirm off
set architecture riscv:rv64
target remote 127.0.0.1:1234
symbol-file kernel.elf
set disassemble-next-line auto
set riscv use-compressed-breakpoints yes
set breakpoint pending on
break _start
break kmain
break hang

