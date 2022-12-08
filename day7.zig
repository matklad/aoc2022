const std = @import("std");
const stdx = @import("./stdx.zig");

const MAX_DIRS = 100_000;
const Dir = struct {
    parent: usize,
    size: u64,
};
var dirs = std.mem.zeroes([MAX_DIRS]Dir);

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buf: [1024]u8 = undefined;
    var curr: usize = 0;
    var free: usize = 1;
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line.len == 0) continue;
        var rest = line;
        if (stdx.cut(&rest, "$ ") != null) {
            if (stdx.cut(&rest, "ls") != null) {
                // nothing to do for ls.
            } else {
                if (stdx.cut(&rest, "cd ") == null) return error.BadCommand;
                if (std.mem.eql(u8, rest, "..")) {
                    dirs[dirs[curr].parent].size += dirs[curr].size;
                    curr = dirs[curr].parent;
                } else {
                    dirs[free].parent = curr;
                    curr = free;
                    free += 1;
                }
            }
        } else {
            if (stdx.cut(&rest, "dir") != null) {
                // nothing to do for a dir
            } else {
                const size_s = stdx.cut(&rest, " ") orelse return error.BadFile;
                const size = try std.fmt.parseInt(u64, size_s, 10);
                dirs[curr].size += size;
            }
        }
    }
    while (curr != 0) {
        dirs[dirs[curr].parent].size += dirs[curr].size;
        curr = dirs[curr].parent;
    }
    const cutoff = 30_000_000 - (70_000_000 - dirs[0].size);
    var total: u64 = std.math.maxInt(u64);
    for (dirs[0..free]) |dir| {
        if (dir.size > cutoff and dir.size < total) total = dir.size;
    }
    try stdout.print("{}\n", .{total});
}
