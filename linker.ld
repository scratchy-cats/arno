/* we want risv64 with little endian alignment */
OUTPUT_FORMAT(elf64-littleriscv);
OUTPUT_ARCH(riscv:rv64);

/* the entry with the the standard _start symbol. This is defined in entry.S */
ENTRY(_start);

/* there are no real variables in a linker script. This defines actually a
 * global symbol that can been seen everwhere. Hence I used double underscore
 * since this cant be used by the user, when writing c, afaik. */
__NUM_HART = 2;

/* # tag::memory[] */
/* see https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c#L70 */
MEMORY
{
    VIRT_DRAM (rwx) : ORIGIN = 0x80000000, LENGTH = 0x6400000
}
/* # end::memory[] */

/* sections maps the different parts of the program like instructions and
 * variables to different locations. We are placing everything in DRAM.
 * # tag::sections[] */
SECTIONS {
  . = ORIGIN(VIRT_DRAM);

  .text : ALIGN(4K) {
    *(.text .text*);
  } > VIRT_DRAM

  .rodata : ALIGN(4K) {
    *(.srodata .srodata*);
    *(.rodata .rodata*);
  } > VIRT_DRAM

  .data : ALIGN(4K) {
    *(.sdata .sdata*);
    *(.data .data*);
  } > VIRT_DRAM

  /* bss is a bit more interesting than the other sections. It "provides"
   * serveral symbol holding a memory adress as value. These symbols, are used
   * by other parts of the system, to load certain registers. for example sp
   * the stack pointer, and gp the global pointer. */
  .bss : ALIGN(4K) {
    PROVIDE(bss_start = .);
    *(.bss);
    . = ALIGN(4K);
    /* the stack gets 4k per hardware thread */
    PROVIDE(stack0 = .);
    . += 4K * __NUM_HART;
    /* the global pointer helds to locate global variables */
    PROVIDE(gptr = .);
    PROVIDE(bss_end = .);
  } > VIRT_DRAM
}
/* end::sections[] */
