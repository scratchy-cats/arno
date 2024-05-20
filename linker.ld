/* this is a basic example from:
 *  https://github.com/noteed/riscv-hello-asm/blob/main/sifive_u/hello.ld
 * a more advanced example can be found here:
 *  https://github.com/sifive/freedom-e-sdk/blob/master/bsp/sifive-hifive-unleashed/metal.default.lds
 */
OUTPUT_ARCH("riscv")
OUTPUT_FORMAT("elf64-littleriscv")
ENTRY(_start)
SECTIONS
{
  /* sifive_u starts here */
  . = 0x80000000;

  .text : {
    *(.text)
  }

  .gnu_build_id : {
    *(.note.gnu.build-id)
  }

  .data : {
    *(.data)
  }

  .rodata : {
    *(.rodata)
  }

  .sdata : {
    *(.sdata)
  }

  .debug : {
    *(.debug)
  }

  . += 0x8000;
  stack_top = .;
  _end = .;
}
