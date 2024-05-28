// qemu's virt machine type places uart at this adress.
const uart: *volatile u8 = @ptrFromInt(0x10000000);

pub fn print(str: []const u8) void {
    for (str) |c| {
        uart.* = c;
    }
}

pub fn println(str: []const u8) void {
    print(str);
    print("\n\r");
}
