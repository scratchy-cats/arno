AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
CC = riscv64-unknown-elf-gcc
QEMU = qemu-system-riscv64

CFLAGS = -march=rv64g -mabi=lp64 -static -mcmodel=medany $\
		-fvisibility=hidden -nostdlib -nostartfiles -Isifive_u

QFLAGS = -display none -serial stdio -machine sifive_u -bios none

run: boot
	$(QEMU) $(QFLAGS) -kernel $<

boot: linker.ld boot.S
	$(CC) $(CFLAGS) -o $@ -T $^

clean:
	rm -f boot *.o
