#include <stddef.h>
#include <stdint.h>

#include "crt0.h"
#include "tty.h"

static void hang(void) {
  for (;;) {
    asm("wfi");
  }
}

void kmain(void) {
  println("setup kernel");
  println("setup complete");
  hang();
}
