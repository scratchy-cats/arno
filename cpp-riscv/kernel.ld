/*
  The C compilation model and Linked Scripts :

  (1) The Clang compiler takes your source (.c / .cpp) file and generates a CPU architecture
    specific human readable assembly (.s) file.
    NOTE: Optionally, from the source file, you can first generate a LLVM IR (.ll) file which shows
    you - how your sourcecode is getting optimized by LLVM. Then using llc, you can generate the
    assembly file from that LLVM IR file.

  (2) The Assembler then generates an object (.o) file from that assembly file. The object file
    contains binary code split across different sections (like .text, .bss, .rodata etc).
    It also has information about - which symbols are declared in it and which symbols are defined
    in it.

  (3) The Linker then takes multiple object files and generates the executable (.out) (which is also
    an object file - but with resolved symbol definitions). It resolves each symbol declaration by
    finding the corresponding definition in all those input object files.
    Linking process explained in detail : https://www.youtube.com/watch?v=cpkDQaYttR4.

    The main purpose of the Linker Script is to describe how the sections in the input object files
    should be mapped into the output executable file, and to control the memory layout of the
    executable file. Most Linker Scripts do nothing more than this.

    The Linker always uses a Linker Script. If you do not supply one yourself, the Linker will use a
    default script that is compiled into the Linker executable.

    Linker Script official docs : https://home.cs.colorado.edu/~main/cs1300/doc/gnu/ld_3.html

  Reference : https://mcyoung.xyz/2021/06/01/linker-script/.
*/

/* The input and output object files should be based on the RISCV CPU architecture. */
OUTPUT_ARCH("riscv")

/* First instruction to execute in the program. */
ENTRY(_enter)

/* How to map input sections to output sections. And how to place the output sections in-memory. */
SECTIONS {

  /* QEMU expects the entrypoint of the kernel code to be loaded at 0x80000000 */
  . = 0x80000000;

  /*
    This is a section definition. A section definition specifies the properties of an output section :
    its location, alignment, contents, fill pattern, and target memory region. Most of these
    specifications are optional.
  */
  .text = {
    /* Put contents of all .text and .text.* named sections here */
    *(.text, .text.*)

    /* Aligns the location counter to the beginning of the next 4KB boundary */
    . = ALIGN(0x1000);

    /* Starting the _trampoline section */
    _trampoline = .;
    *(trampsec)
    . = ALIGN(0x1000);
    ASSERT(. - _trampoline == 0x1000, "error: _trampoline section size larger than one page");

    /* Marks end of the text section */
    PROVIDE(etext = .);
  }

  .rodata = {
    . = ALIGN(16);
    *(.srodata .srodata.*)
    . = ALIGN(16);
    *(.rodata .rodata.*)
  }

  .data : {
    . = ALIGN(16);
    *(.sdata .sdata.*)
    . = ALIGN(16);
    *(.data .data.*)
  }

  .bss : {
    . = ALIGN(16);
    *(.sbss .sbss.*)
    . = ALIGN(16);
    *(.bss .bss.*)
  }

  PROVIDE(end = .);
}