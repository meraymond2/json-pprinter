const std = @import("std");
const Token = @import("tokens.zig").Token;

const tab = "  ";

fn printIndent(n: usize) void {
    var i = n;
    while (i > 0) : ({
        i -= 1;
    }) {
        std.debug.warn(tab, .{});
    }
}

pub fn pprint(tokens: []Token) void {
    var indent: usize = 0;
    for (tokens) |t| {
        switch (t) {
            Token.STRING => |s| std.debug.warn("\"{}\"", .{s}),
            Token.NUMBER => |n| std.debug.warn("{}", .{n}),
            Token.TRUE => std.debug.warn("{}", .{"true"}),
            Token.FALSE => std.debug.warn("{}", .{"false"}),
            Token.NULL => std.debug.warn("{}", .{"null"}),
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
            Token.LSQUARE => {
                indent += 1;
                std.debug.warn("[\n", .{});
                printIndent(indent);
            },
            Token.RBRACE => {
                indent -= 1;
                std.debug.warn("\n", .{});
                printIndent(indent);
                std.debug.warn("}}", .{});
            },
            Token.RSQUARE => {
                indent -= 1;
                std.debug.warn("\n", .{});
                printIndent(indent);
                std.debug.warn("]", .{});
            },
            Token.EMPTY_OBJ => {
                std.debug.warn("{{}}", .{});
            },
            Token.EMPTY_ARR => {
                std.debug.warn("[]", .{});
            },
            else => {
                std.debug.warn("?", .{});
            },
        }
    }
    std.debug.warn("\n", .{});
}
