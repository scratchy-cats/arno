// qemus riscv virt machine places UART at this address
unsigned char *uart = (unsigned char *)0x10000000;

void putchar(char c) {
  *uart = c;
  return;
}

void print(const char *str) {
  while (*str != '\0') {
    putchar(*str);
    str++;
  }
  return;
}

void println(const char *str) {
  while (*str != '\0') {
    putchar(*str);
    str++;
  }
  putchar('\n');
  putchar('\r');
  return;
}
