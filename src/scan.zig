const std = @import("std");
const ArrayList = std.ArrayList;
const Token = @import("tokens.zig").Token;

fn whitespace(char: u8) bool {
    return char == ' ' or char == '\r' or char == '\t' or char == '\n';
}

pub fn scan(allocator: *std.mem.Allocator, js: []const u8) !ArrayList(Token) {
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
                if (pos >= end_of_input) {
                    std.debug.warn("Bleh, {}\n", .{pos});
                    @panic("noooo!!!!!");
                }
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
                    std.debug.warn("?{}", .{pos});
                    pos += 1;
                }
            },
        }
    }
    return al;
}
