const std = @import("std");

const BUFFER_LENGTH = 1024;

const TokenTag = enum {
    START,
    LBRACE,
    RBRACE,
    LBRACKET,
    RBRACKET,
    COLON,
    COMMA,
};

pub const Token = union(TokenTag) {
    START: void,
    LBRACE: void,
    RBRACE: void,
    LBRACKET: void,
    RBRACKET: void,
    COLON: void,
    COMMA: void,
};


pub fn main() void {
    // TODO, check for a file-path argument, and read that to stream if present.

    // Get the stdin as a stream.
    var stdin = std.io.getStdIn().inStream().stream;

    scan(&stdin);
}

fn scan(stream: &InStream): void {
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
    while (bytes_read > 0) : ({ bytes_read = try stdin.read(buf); }) {
        // TODO: I'd prefer to return a stream rather than nest printing under
        // scanning, if that's possible.
        const last_token = scanBuf(buf, prev, current_token, &indent);
        prev = buf[BUFFER_LENGTH - 1];
        prev_token = last_token;
    }

    // End with newline.
    std.debug.warn("\n");
}

fn scanBuf(buf: []u8, prev_char: u8, prev_token: Token, indent: *usize) void {
    const end = BUFFER_LENGTH;
    var pos: usize = 0;
    var start: usize = undefined;
    var current_token: Token = undefined;

    while (pos != end) {
        const c = buf[pos];
        switch(c) {
            '}' => {
                current_token = Token{ .RBRACE = undefined };
                printToken(current_token, &indent);
                pos += 1;
            },
            ']' => {
                current_token = Token{ .RBRACKET = undefined };
                printToken(current_token, &indent);
                pos += 1;
            },
            ':' => {
                current_token = Token{ .COLON = undefined }
                printToken(current_token, &indent);
                pos += 1;
            },
            ',' => {
                current_token = Token{ .COMMA = undefined };
                printToken(current_token, &indent);
                pos += 1;
            },
            else => {
                pos +=1;
            }
        }
    }

    return current_token;
}

fn printToken(token: Token, indent: *usize) void {
    switch(token) {
        START => void,
        Token.COLON => std.debug.warn(": ", .{}),
        Token.COMMA => {
            std.debug.warn(",\n", .{});
            printIndent(indent);
        }
         else => {
                std.debug.warn("", .{});
            },
    }
}

fn printIndent(n: usize) void {
    var i = n;
    while (i > 0) : ({
        i -= 1;
    }) {
        std.debug.warn(tab, .{});
    }
}
