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
                // Can I do look-aheads if streaming? Need a different way of finding EOF...
                // This needs to ignore whitespace.
                if (!(pos + 1 == end_of_input) and js[pos + 1] == '}') {
                    try al.append(Token{ .EMPTY_OBJ = undefined });
                    pos += 2;
                } else {
                    try al.append(Token{ .LBRACE = undefined });
                    pos += 1;
                }
            },
            '}' => {
                try al.append(Token{ .RBRACE = undefined });
                pos += 1;
            },
            '[' => {
                // This needs to ignore whitespace.
                if (!(pos + 1 == end_of_input) and js[pos + 1] == ']') {
                    try al.append(Token{ .EMPTY_ARR = undefined });
                    pos += 2;
                } else {
                    try al.append(Token{ .LSQUARE = undefined });
                    pos += 1;
                }
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
                pos += 1; // skip the quote itself
                start = pos;
                // TODO: handle unterminated strings
                while (!isEndOfStr(js[pos], js[pos - 1])) {
                    pos += 1;
                }
                const str_len = pos - start;
                const str_literal = try allocator.alloc(u8, str_len);
                std.mem.copy(u8, str_literal, js[start..pos]);
                try al.append(Token{ .STRING = str_literal });
                pos += 1; // skip closing quote
            },
            't' => {
                const expected_end = pos + 4;
                if (expected_end >= end_of_input) @panic("unterminated literal!!");
                if (!std.mem.eql(u8, js[pos..expected_end], "true")) @panic("invalid literal");
                try al.append(Token{ .TRUE = undefined });
                pos = expected_end;
            },
            'f' => {
                const expected_end = pos + 5;
                if (expected_end >= end_of_input) @panic("unterminated literal!!");
                if (!std.mem.eql(u8, js[pos..expected_end], "false")) @panic("invalid literal");
                try al.append(Token{ .FALSE = undefined });
                pos = expected_end;
            },
            'n' => {
                const expected_end = pos + 4;
                if (expected_end >= end_of_input) @panic("unterminated literal!!");
                if (!std.mem.eql(u8, js[pos..expected_end], "null")) @panic("invalid literal");
                try al.append(Token{ .NULL = undefined });
                pos = expected_end;
            },
            else => {
                if (whitespace(c)) {
                    pos += 1;
                } else if (numeric(c) or c == '-') {
                    start = pos;
                    pos += 1;
                    // TODO: Handle other number formats.
                    // TODO: Should I do number validation? 10.0.2?
                    while (numeric(js[pos]) or js[pos] == '.') {
                        pos += 1;
                    }
                    const num_len = pos - start;
                    const num_literal = try allocator.alloc(u8, num_len);
                    std.mem.copy(u8, num_literal, js[start..pos]);
                    try al.append(Token{ .NUMBER = num_literal });
                } else {
                    std.debug.warn("?{}", .{pos});
                    pos += 1;
                }
            },
        }
    }
    return al;
}

fn numeric(char: u8) bool {
    return char >= 48 and char <= 57;
}

fn isEndOfStr(char: u8, prevChar: u8) bool {
    if (char == '"') {
        if (prevChar == '\\') return false;
        return true;
    }
    return false;
}
