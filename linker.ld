/*
  1. The Clang compiler takes your source (.c / .cpp) file and generates a CPU architecture specific
     human readable assembly `.s` file.
     Optionally, from the source file, you can first generate a LLVM IR (.ll) file which shows you -
     how your sourcecode is getting optimized by LLVM. Then using llc, you can generate the assembly
     file from that LLVM IR file.

  2. The Assembler then generates an object (.o) file from that assembly file. The object file contains
     binary code split across different sections (like .text, .bss, .rodata etc). It also has
     information about - which symbols are declared in it and which symbols are defined in it.

  3. The Linker then takes multiple object files and generates the executable (.out) (which is also
     an object file - but with resolved symbol definitions). It resolves each symbol declaration by
     finding the corresponding definition in all those input object files.

    The main purpose of the Linker Script is to describe how the sections in the input object files
    should be mapped into the output executable file, and to control the memory layout of the
    executable file. Most Linker Scripts do nothing more than this.

    The Linker always uses a Linker Script. If you do not supply one yourself, the Linker will use a
    default script that is compiled into the Linker executable.
*/

/* The output object file (in ELF64 binary format) is meant for 64 bit RISCV CPU architecture and
 * Little Endian byte ordering.
 *
 * ELF file format explained : https://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis.
 * Little vs Big Endian explained : https://youtu.be/T1C9Kj_78ek. */
OUTPUT_FORMAT(elf64-littleriscv);
OUTPUT_ARCH(riscv:rv64);

/* _entry is defined in ./src/asm/entry.S */
ENTRY(_entry);

MEMORY {
  /* REFER : https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c#L70 */
  CLINT (r)  : ORIGIN = 0x02000000, LENGTH = 0x00010000
  UART (rw)  : ORIGIN = 0x10000000, LENGTH = 0x00001000
  DRAM (rwx) : ORIGIN = 0x80000000, LENGTH = 0x06400000
}

/* Defining how to map input sections to output sections and how those output sections will be placed
 * in-memory. */
SECTIONS {
  . = ORIGIN(DRAM);

  /* Contains executable instructions. */
  .text : ALIGN(4K) {
    *(.init .init*);
    *(.text .text*);
  } > DRAM

  /*
    Contains static constants.

    The .srodata contains small data which can be accessed using shorter instructions (that may only
    be able to access a certain range of addresses).

    Meaning of ALIGN(4K) : Let's say the .text section ends at 10 KB. We want the .rodata section to
    start from the next 4KB boundary (i.e. from 12KB mark). This optimizes reading from the memory
    for the CPU.
  */
  .rodata : ALIGN(4K) {
    *(.srodata .srodata*);
    *(.rodata .rodata*);
  } > DRAM

  /*
    Contains initialized static variables (global and static local variables). The size of this
    segment is determined by the size of the values in the program's source code, and does not
    change at run time.
    In contrast to the rodata segment, the data segment is read/write, since the values of variables
    can be altered at run time.
  */
  .data : ALIGN(4K) {
    *(.sdata .sdata*);
    *(.data .data*);
  } > DRAM

  /*
    Contains statically allocated variables that are declared but have not been assigned a value yet.
    Typically only the length of the bss section, but no data, is stored in the object file. The
    program loader allocates memory for the bss section when it loads the program. By placing
    variables with no value in the .bss section, instead of the .data or .rodata section which
    require initial value data, the size of the object file is reduced.
  */
  .bss : ALIGN(4K) {
    *(.sbss .sbss*);
    *(.bss .bss*);
  } > DRAM
}