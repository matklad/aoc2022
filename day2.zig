const std = @import("std");

pub fn main() !void {

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [32]u8 = undefined;
    var score: u32 = 0;
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line.len == 0) continue;
        if (line.len != 3) return error.BadLen;
        const l = line[0] - 'A';
        const o = line[2] - 'X';
        const r = (3 + l + o - 1) % 3;
        score += ([_]u8{0, 3, 6})[o] + ([_]u8{1, 2, 3})[r];
    }
    try stdout.print("{}\n", .{score});
}
