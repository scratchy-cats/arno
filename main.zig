const tty = @import("tty.zig");
const cpu = @import("cpu.zig");
const str = @import("str.zig");

export fn machine() noreturn {
    tty.println("machine mode, setup");

    cpu.csrw("mepc", @intFromPtr(&supervisor));
    tty.log("mepc", str.btoax(cpu.csrr("mepc")));

    asm volatile ("mret");
    unreachable;
}

export fn supervisor() noreturn {
    tty.println("supervisor mode, setup");
    cpu.hang();
}
