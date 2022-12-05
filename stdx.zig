const std = @import("std");

pub const StdinLines = struct {
    const Self = @This();
    rdr: std.fs.File.Reader,
    buf: [1024]u8,
    curr: []u8,

    pub fn new() StdinLines {
        return Self{
            .rdr = std.io.getStdIn().reader(),
            .buf = undefined,
            .curr= &.{},
        };
    }

    pub fn next_opt(self: *Self) !?[]u8 {
        const line_opt = try self.rdr.readUntilDelimiterOrEof(self.buf[0..], '\n');
        if (line_opt) |line| self.curr = line;
        return line_opt;
    }
    pub fn next(self: *Self) ![]u8 {
        const result = try self.next_opt();
        return result orelse return error.UnexpectedEof;
    }
};

pub fn cut(src: *[]const u8, sep: []const u8) ?[]const u8 {
    const index = std.mem.indexOf(u8, src.*, sep) orelse return null;
    const result = src.*[0..index];
    src.* = src.*[index + sep.len..];
    return result;
}
