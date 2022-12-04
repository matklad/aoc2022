const std = @import("std");

const Segment = struct {
    start: u32,
    end: u32,

    fn parse(s: []const u8) !Segment {
        var rest = s;
        const l = cut(&rest, "-") orelse return error.BadSegment;
        const r = rest;
        return Segment{
            .start = try std.fmt.parseInt(u32, l, 10),
            .end = try std.fmt.parseInt(u32, r, 10),
        };
    }
    fn is_before(self: Segment, them: Segment) bool {
        return self.end < them.start;
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [1024]u8 = undefined;
    var total: u32 = 0;
    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line.len == 0) break;
        var rest = line;
        const ls = cut(&rest, ",") orelse return error.TooShort;
        const rs = rest;
        const l = try Segment.parse(ls);
        const r = try Segment.parse(rs);
        if (!(l.is_before(r) or r.is_before(l))) total += 1;
     }
    try stdout.print("{}\n", .{total});
}

fn cut(src: *[]const u8, sep: []const u8) ?[]const u8 {
    const index = std.mem.indexOf(u8, src.*, sep) orelse return null;
    const result = src.*[0..index];
    src.* = src.*[index + sep.len..];
    return result;
}
