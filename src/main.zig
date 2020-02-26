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

pub fn main() !void {
    // TODO, check for a file-path argument, and read that to stream if present.

    // Get the stdin as a stream.
    var stdin = std.io.getStdIn().inStream().stream;

    try scan(&stdin);
}

fn scan(stream: *std.io.InStream(std.os.ReadError)) !void {
    // Pre-allocate one kibibyte.
    var pre_alloc: [BUFFER_LENGTH]u8 = undefined;
    var buf = pre_alloc[0..pre_alloc.len];

    // Pre-allocate one byte for last char of previous buffer.
    var prev_char: u8 = ' ';

    // Pre-allocate for last token of previous buf.
    var prev_token: Token = Token{ .START = undefined };

    // Keep track of indent across buffers. (Would prefer to keep this contained
    // in the print function, see below.)
    var indent: usize = 0;

    // Loop through stream.
    var bytes_read: usize = try stream.read(buf);
    while (bytes_read > 0) : ({
        bytes_read = try stream.read(buf);
    }) {
        // std.debug.warn("{}", .{bytes_read});
        // TODO: I'd prefer to return a stream rather than nest printing under
        // scanning, if that's possible.
        const last_token = scanBuf(buf, prev_char, prev_token, &indent);
        prev_char = buf[BUFFER_LENGTH - 1];
        prev_token = last_token;
    }

    // End with newline.
    std.debug.warn("\n", .{});
}

fn scanBuf(buf: []u8, prev_char: u8, prev_token: Token, indent: *usize) Token {
    const end = BUFFER_LENGTH;
    var pos: usize = 0;
    var start: usize = undefined;
    var current_token: Token = undefined;

    while (pos != end) {
        const c = buf[pos];
        switch (c) {
            '{' => {
                current_token = Token{ .LBRACE = undefined };
                printToken(current_token, indent);
                pos += 1;
            },
            '}' => {
                current_token = Token{ .RBRACE = undefined };
                printToken(current_token, indent);
                pos += 1;
            },
            '[' => {
                current_token = Token{ .LBRACKET = undefined };
                printToken(current_token, indent);
                pos += 1;
            },
            ']' => {
                current_token = Token{ .RBRACKET = undefined };
                printToken(current_token, indent);
                pos += 1;
            },
            ':' => {
                current_token = Token{ .COLON = undefined };
                printToken(current_token, indent);
                pos += 1;
            },
            ',' => {
                current_token = Token{ .COMMA = undefined };
                printToken(current_token, indent);
                pos += 1;
            },
            '"' => {
                start = pos;
                pos += 1;
                while (!isEndOfStr(buf[pos], if (pos == 0) prev_char else buf[pos - 1])) {
                    pos += 1;
                }
                // Consume closing quotes.
                pos += 1;
                current_token = Token{ .STRING = buf[start..pos] };
                printToken(current_token, indent);
            },
            else => {
                pos += 1;
            },
        }
    }

    return current_token;
}

fn printToken(token: Token, indent: *usize) void {
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

fn printIndent(n: usize) void {
    const tab = "  ";
    var i = n;
    while (i > 0) : ({
        i -= 1;
    }) {
        std.debug.warn(tab, .{});
    }
}

fn isEndOfStr(char: u8, prev_char: u8) bool {
    if (char == '"') {
        if (prev_char == '\\') return false;
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
