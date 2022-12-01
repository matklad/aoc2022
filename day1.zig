const std = @import("std");

const N = 3;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [32]u8 = undefined;
    var curr: u32 = 0;
    var top: [N]u32 = .{0, 0, 0};
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line.len == 0) {
            add(&top, curr);
            curr = 0;
            continue;
        }
        const cal = try std.fmt.parseInt(u32, line, 10);
        curr += cal;
    }
    add(&top, curr);
    var sum: u32 = 0;
    for(top) |val| sum += val;
    try stdout.print("{}\n", .{sum});
}

fn add(top: *[N]u32, val: u32) void {
    if (val > top[0]) {
        top[0] = val;
        comptime var i: u32 = 0;
        inline while (i < N - 1) : (i += 1) {
            if (top[i] > top[i + 1]) {
                std.mem.swap(u32, &top[i], &top[i + 1]);
            }
        }
    }
}
