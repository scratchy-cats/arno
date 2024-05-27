NUM_HART=1

CC = zig cc -target riscv64-freestanding
CFLAGS = -Wall -Wextra

QEMU = qemu-system-riscv64 -machine virt
QFLAGS = -display none -serial stdio -bios none -smp $(NUM_HART)

ifeq ($(DEBUG),1)
	CFLAGS += -g
	QFLAGS += -s -S
endif

C_SRCS=$(wildcard *.c)
C_OBJS=$(C_SRCS:.c=.c.o)

S_SRCS=$(wildcard *.S)
S_OBJS=$(S_SRCS:.S=.s.o)

run: kernel.elf
	$(QEMU) $(QFLAGS) -kernel $<

kernel.elf: linker.ld $(addprefix .cache/,$(S_OBJS)) $(addprefix .cache/,$(C_OBJS))
	$(CC) -nostdlib -o $@ -T $^

.cache/%.c.o: %.c | .cache
	$(CC) $(CFLAGS) -c -mcmodel=medany -ffreestanding -o $@ $^

.cache/%.s.o: %.S | .cache
	$(CC) -c -o $@ $^

clean:
	rm -rf .cache kernel.elf

.cache:
	mkdir -p .cache
