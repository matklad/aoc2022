const std = @import("std");

fn order(comptime T: type) fn (void, T, T) std.math.Order {
    return struct {
        fn inner(_: void, lhs: T, rhs: T) std.math.Order {
            return std.math.order(lhs, rhs);
        }
    }.inner;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [1024]u8 = undefined;
    var total: u32 = 0;
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line1| {
        if (line1.len == 0) break;
        const line2 = try stdin.readUntilDelimiter(buf[line1.len..], '\n');
        const line3 = try stdin.readUntilDelimiter(buf[line1.len + line2.len ..], '\n');
        std.sort.sort(u8, line1, {}, comptime std.sort.asc(u8));
        std.sort.sort(u8, line2, {}, comptime std.sort.asc(u8));
        outer:
        for (line3) |c| {
            for ([_][]u8{ line1, line2 }) |line| {
                const pos = std.sort.binarySearch(u8, c, line, {}, comptime order(u8));
                if (pos == null) continue :outer;
            }
            total += try score(c);
            break :outer;
        }
    }
    try stdout.print("{}\n", .{total});
}

fn score(c: u8) !u32 {
    return switch (c) {
        'a'...'z' => 1 + c - 'a',
        'A'...'Z' => 27 + c - 'A',
        else => error.BadItem,
    };
}
