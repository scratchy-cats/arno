ARCH=riscv64
TARGET=$(ARCH)-unknown-elf

AS = $(TARGET)-as
LD = $(TARGET)-ld
CC = $(TARGET)-gcc
CFLAGS = -march=rv64g -mabi=lp64 -static -mcmodel=medany $\
		-fvisibility=hidden -nostdlib -nostartfiles -Isifive_u

QEMU = qemu-system-$(ARCH)
QFLAGS = -display none -serial stdio -machine sifive_u -bios none

ifeq ($(DEBUG),1)
CFLAGS += -g
QFLAGS += -s -S
endif

run: boot
	$(QEMU) $(QFLAGS) -kernel $<

debug: gdb.txt
	$(TARGET)-gdb -x gdb.txt

boot: linker.ld boot.S
	$(CC) $(CFLAGS) -o $@ -T $^

clean:
	rm -f boot *.o
