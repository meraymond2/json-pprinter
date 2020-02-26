const std = @import("std");

const BUFFER_LENGTH = 8;

const TokenTag = enum {
    START,
    STRING,
    LBRACE,
    RBRACE,
    LBRACKET,
    RBRACKET,
    COLON,
    COMMA,
};

pub const Token = union(TokenTag) {
    START: void,
    STRING: []u8,
    LBRACE: void,
    RBRACE: void,
    LBRACKET: void,
    RBRACKET: void,
    COLON: void,
    COMMA: void,
};

// Pre-allocate one kibibyte.
var pre_alloc: [BUFFER_LENGTH]u8 = undefined;
var buf = pre_alloc[0..pre_alloc.len];

// Pre-allocate one byte for last char of previous buffer.
var prev_char: u8 = ' ';

// Pre-allocate for last token of previous buf.
// Not necessary until I want to do error handling.
var prev_token: Token = Token{ .START = undefined };

// Current indent level.
var indent: usize = 0;

pub fn main() !void {
    // TODO, check for a file-path argument, and read that to stream if present.

    // Get the stdin as a stream.
    var stdin = std.io.getStdIn().inStream().stream;

    try scan(&stdin);
}

fn scan(stream: *std.io.InStream(std.os.ReadError)) !void {
    // Loop through stream.
    var bytes_read: usize = try stream.read(buf);
    while (bytes_read > 0) : (bytes_read = try stream.read(buf)) {
        const last_token = scanBuf();
        prev_char = buf[BUFFER_LENGTH - 1];
        prev_token = last_token;
    }

    // End with newline.
    std.debug.warn("\n", .{});
}

fn scanBuf() Token {
    const end = BUFFER_LENGTH;
    var pos: usize = 0;
    var start: usize = undefined;
    var current_token: Token = undefined;

    while (pos != end) {
        const c = buf[pos];
        switch (c) {
            '{' => {
                current_token = Token{ .LBRACE = undefined };
                printToken(current_token);
                pos += 1;
            },
            '}' => {
                current_token = Token{ .RBRACE = undefined };
                printToken(current_token);
                pos += 1;
            },
            '[' => {
                current_token = Token{ .LBRACKET = undefined };
                printToken(current_token);
                pos += 1;
            },
            ']' => {
                current_token = Token{ .RBRACKET = undefined };
                printToken(current_token);
                pos += 1;
            },
            ':' => {
                current_token = Token{ .COLON = undefined };
                printToken(current_token);
                pos += 1;
            },
            ',' => {
                current_token = Token{ .COMMA = undefined };
                printToken(current_token);
                pos += 1;
            },
            '"' => {
                start = pos;
                pos += 1;

                while (!(pos == end) and !isEndOfStr(buf[pos], if (pos == 0) prev_char else buf[pos - 1])) {
                    pos += 1;
                }
                if (pos == end) {
                    current_token = Token{ .STRING = buf[start..pos] };
                    printToken(current_token);
                } else {
                    // Consume closing quotes.
                    pos += 1;
                    current_token = Token{ .STRING = buf[start..pos] };
                    printToken(current_token);
                }
            },
            else => {
                pos += 1;
            },
        }
    }

    return current_token;
}

fn printToken(token: Token) void {
    switch (token) {
        Token.START => undefined,
        Token.STRING => |s| std.debug.warn("{}", .{s}),
        Token.LBRACE => std.debug.warn("{{", .{}),
        Token.RBRACE => std.debug.warn("}}", .{}),
        Token.LBRACKET => std.debug.warn("]", .{}),
        Token.RBRACKET => std.debug.warn("[", .{}),
        Token.COLON => std.debug.warn(": ", .{}),
        Token.COMMA => std.debug.warn(",", .{}),
        else => std.debug.warn("", .{}),
    }
}

fn printIndent() void {
    const tab = "  ";
    var i = n;
    while (i > 0) : ({
        i -= 1;
    }) {
        std.debug.warn(tab, .{});
    }
}

fn isEndOfStr(char: u8, prev: u8) bool {
    if (char == '"') {
        if (prev == '\\') return false;
        return true;
    }
    return false;
}

// '"' => {
//     start = pos;
//     pos += 1;
//     while (!(pos == end) and !isEndOfStr(buf[pos], if (pos == 0) prev_char else buf[pos - 1])) {
//         pos += 1;
//     }
//     if (pos == end) {
//         current_token = Token{ .STRING_PART = buf[start..pos] };
//         printToken(current_token, indent);
//     } else {
//         // Consume closing quotes.
//         pos += 1;
//         current_token = Token{ .STRING = buf[start..pos] };
//         printToken(current_token, indent);
//     }
// },
