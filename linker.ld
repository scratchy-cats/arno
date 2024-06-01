OUTPUT_FORMAT(elf64-littleriscv);
OUTPUT_ARCH(riscv:rv64);
ENTRY(_start);

__num_harts$ = 2;

MEMORY
{
    /* see https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c#L70 */
    CLINT (r)  : ORIGIN = 0x02000000, LENGTH = 0x00010000
    UART (rw)  : ORIGIN = 0x10000000, LENGTH = 0x00001000
    DRAM (rwx) : ORIGIN = 0x80000000, LENGTH = 0x06400000
}

SECTIONS {
  . = ORIGIN(DRAM);

  .text : ALIGN(4K) {
    *(.init .init*);
    *(.text .text*);
  } > DRAM

  .rodata : ALIGN(4K) {
    *(.srodata .srodata*);
    *(.rodata .rodata*);
  } > DRAM

  .data : ALIGN(4K) {
    *(.sdata .sdata*);
    *(.data .data*);
  } > DRAM

  .bss : ALIGN(4K) {
    *(.bss);
    . = ALIGN(4K);
    PROVIDE(__stack_top$ = .);
    . += __num_harts$ * 4K;
    PROVIDE(__global_pointer$ = .);
  } > DRAM
}
