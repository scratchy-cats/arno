pub inline fn hang() noreturn {
    while (true) {
        asm volatile ("wfi");
    }
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
