const std = @import("std");
const ArrayList = std.ArrayList;

const input = "{\"cas\":\"cat\",\"luna\":\"bee\"}";
const expected = "{\n\t\"cas\": \"cat\",\n\t\"luna\": \"bee\"\n}";

const TokenTag = enum {
    LEFT_CURLY, RIGHT_CURLY, LEFT_SQUARE, RIGHT_SQUARE, COLON, COMMA, STRING, NUMBER, TRUE, FALSE
};
const Token = union(TokenTag) {
    LEFT_CURLY: void, RIGHT_CURLY: void, LEFT_SQUARE: void, RIGHT_SQUARE: void, COLON: void, COMMA: void, STRING: []const u8, NUMBER: f64, TRUE: void, FALSE: void
};

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // var allocator = arena.allocator;
    var allocator = std.heap.page_allocator;

    // std.debug.warn("{}\n", .{input});
    // std.debug.warn("{}\n", .{expected});

    var al = ArrayList(Token).init(allocator);

    // std.debug.warn("{}\n", .{al.at(0)});
    // std.debug.warn("{}\n", .{al.at(0)});
    for (input) |c| {
        switch (c) {
            '{' => {
                try al.append(Token{ .LEFT_CURLY = undefined });
            },
            '}' => {
                try al.append(Token{ .RIGHT_CURLY = undefined });
            },
            '[' => {
                try al.append(Token{ .LEFT_SQUARE = undefined });
            },
            ']' => {
                try al.append(Token{ .RIGHT_SQUARE = undefined });
            },
            ':' => {
                try al.append(Token{ .COLON = undefined });
            },
            ',' => {
                try al.append(Token{ .COMMA = undefined });
            },
            else => {
                const arr: [1]u8 = [1]u8{c};
                const res = try allocator.alloc(u8, 1);
                std.mem.copy(u8, res, arr[0..]);
                std.debug.warn("{}\n", .{res});
                try al.append(Token{ .STRING = res });
            },
        }
    }
    std.debug.warn("{}\n", .{al.capacity()});
    std.debug.warn("{}\n", .{al.at(0)});
    std.debug.warn("{}\n", .{al.at(1)});
    std.debug.warn("{}\n", .{al.at(2)});
    std.debug.warn("{}\n", .{al.at(25)});
}
