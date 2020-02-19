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
    const tokens = try scan(allocator, input);
    print(tokens.toSlice());
}

fn scan(allocator: *std.mem.Allocator, js: []const u8) !ArrayList(Token) {
    var al = ArrayList(Token).init(allocator);
    const end_of_input = js.len;
    var pos: usize = 0;
    var start: usize = undefined;
    while (pos != end_of_input) {
        const c = js[pos];
        switch (c) {
            '{' => {
                try al.append(Token{ .LEFT_CURLY = undefined });
                pos += 1;
            },
            '}' => {
                try al.append(Token{ .RIGHT_CURLY = undefined });
                pos += 1;
            },
            '[' => {
                try al.append(Token{ .LEFT_SQUARE = undefined });
                pos += 1;
            },
            ']' => {
                try al.append(Token{ .RIGHT_SQUARE = undefined });
                pos += 1;
            },
            ':' => {
                try al.append(Token{ .COLON = undefined });
                pos += 1;
            },
            ',' => {
                try al.append(Token{ .COMMA = undefined });
                pos += 1;
            },
            '"' => {
                pos += 1;
                start = pos;
                while (js[pos] != '"' and js[pos - 1] != '\\') {
                    pos += 1;
                }
                const str_len = pos - start;
                const str_literal = try allocator.alloc(u8, str_len);
                std.mem.copy(u8, str_literal, js[start..pos]);
                try al.append(Token{ .STRING = str_literal });
                pos += 1;
            },
            else => {
                if (whitespace(c)) {
                    pos += 1;
                } else {
                    std.debug.warn("?{}\n", .{js[pos]});
                    pos += 1;
                }
            },
        }
    }
    return al;
}

fn whitespace(char: u8) bool {
    return char == ' ' or char == '\r' or char == '\t' or char == '\n';
}

fn print(tokens: []Token) void {
    for (tokens) |t| {
        switch (t) {
            Token.LEFT_CURLY => std.debug.warn("{{\n", .{}),
            Token.RIGHT_CURLY => std.debug.warn("\n}}", .{}),
            Token.COLON => std.debug.warn(":", .{}),
            Token.COMMA => std.debug.warn(",\n", .{}),
            Token.STRING => |s| std.debug.warn("\"{}\"", .{s}),
            else => {
                std.debug.warn("?", .{});
            },
        }
    }
    std.debug.warn("\n", .{});
}
