pub inline fn hang() noreturn {
    while (true) {
        wait_for_interupt();
    }
}

pub inline fn wait_for_interupt() void {
    asm volatile ("wfi");
}
