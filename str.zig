pub fn reverse(s: []const u8) []const u8 {
    var r: [16]u8 = undefined;
    for (0..s.len) |i| {
        r[i] = s[s.len - i - 1];
    }
    return r[0..s.len];
}

pub fn btoax(val: u64) []const u8 {
    var res: [18]u8 = undefined;
    var i: u32 = 0;
    var v = val;

    while (v > 0) {
        const d = v % 16;
        res[i] = hexd(@truncate(d));
        v /= 16;
        i += 1;
    }

    res[i] = 'x';
    res[i + 1] = '0';

    return reverse(res[0 .. i + 2]);
}

inline fn hexd(d: u8) u8 {
    if (d < 10) {
        return '0' + d;
    } else {
        return 'a' + (d - 10);
    }
}
