const std = @import("std");
const N = 14;
pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buf: [65536]u8 = undefined;
    const line = (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')).?;

    var i: u32 = N;
    while (i <= line.len) : (i += 1) {
        if (packet_start(line[i - N ..][0..N].*)) {
            try stdout.print("{}\n", .{i});
            break;
        }
    }
}

fn packet_start(token: [N]u8) bool {
    for (token) |c, i| {
        var j: usize = i;
        while (j > 0) {
            j -= 1;
            if (c == token[j]) return false;
        }
    }
    return true;
}
