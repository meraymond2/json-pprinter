const std = @import("std");
const ArrayList = std.ArrayList;
const input = @import("inp.zig").input;

const tab = "  ";

const TokenTag = enum {
    LBRACE, RBRACE, LSQUARE, RSQUARE, COLON, COMMA, STRING, NUMBER, TRUE, FALSE
};
const Token = union(TokenTag) {
    LBRACE: void, RBRACE: void, LSQUARE: void, RSQUARE: void, COLON: void, COMMA: void, STRING: []const u8, NUMBER: f64, TRUE: void, FALSE: void
};

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // var allocator = arena.allocator;
    var allocator = std.heap.page_allocator;
    const tokens = try scan(allocator, input);
    pprint(tokens.toSlice());
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
                try al.append(Token{ .LBRACE = undefined });
                pos += 1;
            },
            '}' => {
                try al.append(Token{ .RBRACE = undefined });
                pos += 1;
            },
            '[' => {
                try al.append(Token{ .LSQUARE = undefined });
                pos += 1;
            },
            ']' => {
                try al.append(Token{ .RSQUARE = undefined });
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

fn printIndent(n: usize) void {
    var i = n;
    while (i > 0) : ({
        i -= 1;
    }) {
        std.debug.warn(tab, .{});
    }
}

fn pprint(tokens: []Token) void {
    var indent: usize = 0;
    for (tokens) |t| {
        switch (t) {
            Token.STRING => |s| std.debug.warn("\"{}\"", .{s}),
            Token.COLON => std.debug.warn(": ", .{}),
            Token.COMMA => {
                std.debug.warn(",\n", .{});
                printIndent(indent);
            },
            Token.LBRACE => {
                indent += 1;
                std.debug.warn("{{\n", .{});
                printIndent(indent);
            },
            Token.RBRACE => {
                indent -= 1;
                std.debug.warn("\n", .{});
                printIndent(indent);
                std.debug.warn("}}", .{});
            },
            else => {
                std.debug.warn("?", .{});
            },
        }
    }
    std.debug.warn("\n", .{});
}
