const std = @import("std");


pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var total = 0;
    var buf: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line.len == 0) continue;
        total += 1;
    }
    try stdout.print("{}\n", .{total});
}
