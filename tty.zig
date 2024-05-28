const std = @import("std");

const uart: *volatile u8 = @ptrFromInt(0x10000000);

pub fn putchar(c: u8) void {
    uart.* = c;
}

pub fn print(str: [*]const u8) void {
    var i: usize = 0;
    while (str[i] != 0) {
        putchar(str[i]);
        i += 1;
    }
}

pub fn println(str: [*]const u8) void {
    print(str);
    putchar('\n');
    putchar('\r');
}
