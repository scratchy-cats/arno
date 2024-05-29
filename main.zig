const tty = @import("tty.zig");
const cpu = @import("cpu.zig");
const str = @import("str.zig");

export fn main() noreturn {
    tty.println("setup kernel");

    tty.println("disable addr translation");
    cpu.csrw("satp", 0);
    tty.println(str.btoax(cpu.csrr("satp")));

    tty.println("set machine exception program counter to s_entry");
    cpu.csrw("mepc", @intFromPtr(&s_entry));
    tty.println(str.btoax(cpu.csrr("mepc")));

    tty.println("setup complete");
    cpu.hang();
}

/// supervisor entry point, should be entered via mret after early
/// inizalization
export fn s_entry() void {}
