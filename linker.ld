/* we want risv64 with little endian alignment */
OUTPUT_FORMAT(elf64-littleriscv);
OUTPUT_ARCH(riscv:rv64);

/* the entry with the the standard _start symbol. This is defined in entry.S */
ENTRY(_start);

/* there are no real variables in a linker script. This defines actually a
 * global symbol that can been seen everwhere. Hence I used double underscore
 * since this cant be used by the user, when writing c, afaik. */
__NUM_HART = 1;

/* see https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c#L70 some
 * regions are commeted as they use macros. Also not that it sets rwx for all,
 * which is probably not correct. For our purposes, only DRAM seems to be
 * important. */
MEMORY
{
    VIRT_DEBUG (rwx) : ORIGIN = 0x0, LENGTH = 0x100
    VIRT_MROM (rwx) : ORIGIN = 0x1000, LENGTH = 0xf000
    VIRT_TEST (rwx) : ORIGIN = 0x100000, LENGTH = 0x1000
    VIRT_RTC (rwx) : ORIGIN = 0x101000, LENGTH = 0x1000
    VIRT_CLINT (rwx) : ORIGIN = 0x2000000, LENGTH = 0x10000
    VIRT_ACLINT_SSWI (rwx) : ORIGIN = 0x2F00000, LENGTH = 0x4000
    VIRT_PCIE_PIO (rwx) : ORIGIN = 0x3000000, LENGTH = 0x10000
    VIRT_PLATFORM_BUS (rwx) : ORIGIN = 0x4000000, LENGTH = 0x2000000
    /*VIRT_PLIC (rwx) : ORIGIN = 0xc000000, LENGTH = VIRT_PLIC_SIZE(VIRT_CPUS_MAX * 2)*/
    /*VIRT_APLIC_M (rwx) : ORIGIN = 0xc000000, LENGTH = APLIC_SIZE(VIRT_CPUS_MAX)*/
    /*VIRT_APLIC_S (rwx) : ORIGIN = 0xd000000, LENGTH = APLIC_SIZE(VIRT_CPUS_MAX)*/
    VIRT_UART0 (rwx) : ORIGIN = 0x10000000, LENGTH = 0x100
    VIRT_VIRTIO (rwx) : ORIGIN = 0x10001000, LENGTH = 0x1000
    VIRT_FW_CFG (rwx) : ORIGIN = 0x10100000, LENGTH = 0x18
    VIRT_FLASH (rwx) : ORIGIN = 0x20000000, LENGTH = 0x4000000
    /*VIRT_IMSIC_M (rwx) : ORIGIN = 0x24000000, LENGTH = VIRT_IMSIC_MAX_SIZE*/
    /*VIRT_IMSIC_S (rwx) : ORIGIN = 0x28000000, LENGTH = VIRT_IMSIC_MAX_SIZE*/
    VIRT_PCIE_ECAM (rwx) : ORIGIN = 0x30000000, LENGTH = 0x10000000
    VIRT_PCIE_MMIO (rwx) : ORIGIN = 0x40000000, LENGTH = 0x40000000
    VIRT_DRAM (rwx) : ORIGIN = 0x80000000, LENGTH = 256M
}

/* the name of the sections has been taken from various sources including:
 * https://github.com/mit-pdos/xv6-riscv/blob/riscv/kernel/kernel.ld. Init
 * comes from here https://wiki.osdev.org/RISC-V_Bare_Bones. Currently when
 * doing objdump, some of them do show up, notably sdata, next to the standard
 * text and data. */
SECTIONS {
  .text     : ALIGN(4K) { *(.text    .text*   ); } > VIRT_DRAM
  .srodata  : ALIGN(4K) { *(.srodata .srodata*); } > VIRT_DRAM
  .rodata   : ALIGN(4K) { *(.rodata  .rodata* ); } > VIRT_DRAM
  .sdata    : ALIGN(4K) { *(.sdata   .sdata*  ); } > VIRT_DRAM
  .data     : ALIGN(4K) { *(.data    .data*   ); } > VIRT_DRAM

  .bss : ALIGN(4K) {
    /* unitialized data */
    PROVIDE(bss_start = .);
    *(.bss);
    . = ALIGN(4K);

    /* the stack lives here, 4k per hart */
    PROVIDE(stack0 = .);
    . += 4K * __NUM_HART;

    /* the global pointer marks the start of the place to look for global
     * variables. adding 4K to it, is not required but I am doing it anyway so
     * that we get a portion of zero initialized data for the global variables
     */
    PROVIDE(gptr = .);
    . += 4K;

    PROVIDE(bss_end = .);
  } > VIRT_DRAM
}
