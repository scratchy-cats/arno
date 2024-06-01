/* The C compilation model and Linker Scripts explained :
 * https://github.com/scratchy-cats/operating-system/wiki/C-Compilation-Model-and-Linker-Scripts */

/* The output object file (in ELF64 binary format) is meant for 64 bit RISCV CPU architecture and
 * Little Endian byte ordering.
 *
 * ELF file format explained : https://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis.
 * Little vs Big Endian explained : https://youtu.be/T1C9Kj_78ek. */
OUTPUT_FORMAT(elf64-littleriscv);
OUTPUT_ARCH(riscv:rv64)

/* Entrypoint symbol '_entry' is defined in ./src/asm/entry.S */
ENTRY(_entry)

/* Defining how to map input sections to output sections and how those output sections will be placed
 * in-memory. */
SECTIONS {
  /* QEMU expects the ELF file's text section to start from 0x80000000 in memory.
   * Reference : https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c#L70 */
  . = 0x80000000;

  .text : {
    *(.text)
  }

  /* Meaning of ALIGN(4K) : Let's say the .text section ends at 10 KB. We want the .rodata section
   * to start from the next 4KB boundary (i.e. from 12 KB mark).
   *
   * TODO : Explain why it's required. */
  .rodata : ALIGN(4K) {
    *(.rodata .rodata.*)
  }

  .data : ALIGN(4K) {
    *(.data .data.*)
  }

  .bss : ALIGN(4K) {
    *(.bss .bss.*)
    *(.sbss* .sbss.*)
  }

  PROVIDE(end = .);
}
