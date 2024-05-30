pub inline fn hang() noreturn {
    while (true) {
        asm volatile ("wfi");
    }
}

pub inline fn load_gp() void {
    asm volatile (
        \\.option push
        \\.option norelax
        \\la gp, gptr
        \\.option pop
    );
}

pub inline fn load_sp() void {
    asm volatile (
        \\la   sp, stack0
        \\li   a0, 4096
        \\csrr a1, mhartid
        \\addi a1, a1, 1
        \\mul  a0, a0, a1
        \\add  sp, sp, a0
    );
}

pub inline fn csrr(r: []const u8) usize {
    return asm volatile ("csrr a0, " ++ r
        : [ret] "={a0}" (-> usize),
    );
}

pub inline fn csrw(r: []const u8, x: usize) void {
    asm volatile ("csrw " ++ r ++ ", a0"
        :
        : [x] "a0" (x),
    );
}
