const std = @import("std");
const stdx = @import("./stdx.zig");

const MAX = 64;
const Stack = std.BoundedArray(u8, MAX);
const Stacks = [MAX]Stack;

const Move = struct {
    from: u32,
    to: u32,
    count: u32,

    fn parse(line: []u8) !Move {
        var rest = line;
        _ = stdx.cut(&rest, "move ") orelse return error.BadInput;
        const count_str = stdx.cut(&rest, " ") orelse return error.BadInput;
        _ = stdx.cut(&rest, "from ") orelse return error.BadInput;
        const from_str = stdx.cut(&rest, " ") orelse return error.BadInput;
        _ = stdx.cut(&rest, "to ") orelse return error.BadInput;
        const to_str = rest;
        return Move{
            .from = (try std.fmt.parseInt(u32, from_str, 10)) - 1,
            .to = (try std.fmt.parseInt(u32, to_str, 10)) - 1,
            .count = try std.fmt.parseInt(u32, count_str, 10),
        };
    }
};
const Moves = std.ArrayList(Move);

const Pos = struct {
    stack: usize,
    offset: usize,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var lines = stdx.StdinLines.new();
    const stdout = std.io.getStdOut().writer();

    var stacks: Stacks = undefined;
    std.mem.set(Stack, &stacks, Stack.init(0) catch unreachable);
    var moves = Moves.init(allocator);

    while (true) {
        const line = try lines.next();
        if (std.mem.indexOf(u8, line, "[") == null) break;
        var i: usize = 0;
        while (i < line.len) : (i += 4) {
            const item = line[i + 1];
            if (item != ' ') stacks[i / 4].addOneAssumeCapacity().* = item;
        }
    }

    const stack_count = blk: {
        var count: usize = 0;
        var it = std.mem.tokenize(u8, lines.curr, " ");
        while (it.next() != null) count += 1;
        break :blk count;
    };

    {
        const line = try lines.next();
        if (line.len != 0) return error.BadInput;
    }

    while (try lines.next_opt()) |line| {
        const move = try Move.parse(line);
        (try moves.addOne()).* = move;
    }

    var states: [MAX]Pos = undefined;
    for (states) |*s, i| s.* = Pos{ .stack = i, .offset = 0 };

    {
        var i: usize = moves.items.len;
        while (i > 0) {
            i -= 1;
            const move = moves.items[i];
            std.debug.assert(move.from != move.to);
            for (states) |*s| {
                if (s.stack == move.from) {
                    s.offset += move.count;
                }
                if (s.stack == move.to) {
                    if (s.offset < move.count) {
                        s.stack = move.from;
                        // s.offset = move.count - s.offset - 1;
                    } else {
                        s.offset -= move.count;
                    }
                }
            }
        }
    }

    var result = std.BoundedArray(u8, MAX).init(stack_count) catch unreachable;
    for (result.slice()) |*slot, i| {
        const pos = states[i];
        const stack = stacks[pos.stack].slice();
        slot.* = stack[pos.offset];
    }
    try stdout.print("{s}\n", .{result.slice()});
}
