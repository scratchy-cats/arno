#include <stddef.h>
#include <stdint.h>

#include "crt0.h"
#include "tty.h"

extern char *bss0;
extern char *stack0;

static void hang(void) {
  for (;;) {
    asm("wfi");
  }
}

void kmain(void) {
  println("setup kernel");

  // we clear from bss0 to stack0 because the stack is inside bss but we already
  // started using it by calling kmain. So we only zero out the non stack
  // portion of bss.
  println("clear bss");
  memset(bss0, 0, stack0 - bss0);

  println("setup complete");
  hang();
}
