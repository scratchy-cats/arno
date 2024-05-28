const tty = @import("tty.zig");
const cpu = @import("cpu.zig");

export fn main() noreturn {
    tty.println("setup kernel");
    tty.println("setup complete");
    cpu.hang();
}
