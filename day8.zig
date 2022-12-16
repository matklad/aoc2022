const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buf: [1024]u8 = undefined;

    var map = try std.BoundedArray(u8, 65536).init(0);
    var score = try std.BoundedArray(isize, 65536).init(0);
    var x_dim: isize = 0;
    var y_dim: isize = 0;
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line.len == 0) break;
        y_dim += 1;
        x_dim = @intCast(isize, line.len);
        for (line) |char| {
            map.appendAssumeCapacity(char - '0' + 1);
            score.appendAssumeCapacity(1);
        }
    }

    var t: isize = 0;
    while (t < x_dim + y_dim) : (t += 1) {
        var i_lim: isize = undefined;
        var x_start: isize = undefined;
        var y_start: isize = undefined;
        var x_step: isize = undefined;
        var y_step: isize = undefined;
        const back_and_forth = [2]bool{ false, true };
        for (back_and_forth) |forth| {
            if (t < x_dim) {
                i_lim = y_dim;
                x_start = t;
                x_step = 0;
                y_start = if (forth) 0 else y_dim - 1;
                y_step = if (forth) 1 else -1;
            } else {
                i_lim = x_dim;
                x_start = if (forth) 0 else x_dim - 1;
                x_step = if (forth) 1 else -1;
                y_start = t - x_dim;
                y_step = 0;
            }

            var i: isize = 0;
            var s_pos: [65536]isize = undefined;
            var s_height: [65536]u8 = undefined;
            var s_len: usize = 0;
            while (i < i_lim) : (i += 1) {
                const x = x_start + i * x_step;
                const y = y_start + i * y_step;
                var index = @intCast(usize, x + y * x_dim);
                const height = map.slice()[index];
                while (s_len > 0 and s_height[s_len - 1] < height) {
                    s_len -= 1;
                }
                if (s_len == 0) {
                    score.slice()[index] *= i;
                } else {
                    score.slice()[index] *= i - s_pos[s_len - 1];
                }
                s_pos[s_len] = i;
                s_height[s_len] = height;
                s_len += 1;
            }
        }
    }

    var max: isize = 0;
    for (score.slice()) |v, i| {
        // if (i % @intCast(usize, x_dim) == 0) std.debug.print("\n", .{});
        // std.debug.print("{}", .{v});
        _ = i;
        max = std.math.max(max, v);
    }
    try stdout.print("\n{}\n", .{max});
}
