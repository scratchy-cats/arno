const tty = @import("tty.zig");

export fn main() noreturn {
    tty.println("setup kernel");
    tty.println("setup complete");
    hang();
}

fn hang() noreturn {
    while (true) {
        asm volatile ("wfi");
    }
}
