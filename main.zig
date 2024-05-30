const tty = @import("tty.zig");
const cpu = @import("cpu.zig");
const str = @import("str.zig");

comptime {
    asm (".option norvc");
}

export fn _start() callconv(.Naked) noreturn {
    cpu.load_gp();
    cpu.load_sp();
    asm volatile ("tail machine");
}

export fn machine() noreturn {
    cpu.csrw("satp", 0);
    cpu.csrw("mepc", @intFromPtr(&supervisor));
    asm volatile ("mret");
    unreachable;
}

export fn supervisor() noreturn {
    cpu.hang();
}
