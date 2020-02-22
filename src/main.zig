const std = @import("std");
const io = std.io;
const ArrayList = std.ArrayList;

const tab = "  ";

const TokenTag = enum {
    LBRACE, RBRACE, LSQUARE, RSQUARE, COLON, COMMA, STRING, NUMBER, TRUE, FALSE
};
const Token = union(TokenTag) {
    LBRACE: void, RBRACE: void, LSQUARE: void, RSQUARE: void, COLON: void, COMMA: void, STRING: []const u8, NUMBER: f64, TRUE: void, FALSE: void
};

pub fn main() !void {
    // Uncomment this when I can get the arena allocator to stop seg-faulting :(
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // var allocator = arena.allocator;
    var allocator = std.heap.page_allocator;

    // For now, keep it all in memory. Maybe later,
    // think about streaming it.

    // Initialise a buffer, length pulled out of a hat.
    var a: [5000]u8 = undefined;
    var buf = a[0..a.len];

    // Get the stdin as a stream.
    var stdin = std.io.getStdIn().inStream().stream;


    var bytes_read = try stdin.read(buf);
    const first_chunk_slice = try allocator.alloc(u8, bytes_read);
    std.mem.copy(u8, first_chunk_slice, buf[0..bytes_read]);

    // Loop through stream until everything is read.
    var full_input = buf[0..0];
    while (bytes_read > 0) : ({ bytes_read = try stdin.read(buf); }) {
        full_input = try std.fmt.allocPrint(allocator, "{}{}", .{full_input, buf[0..bytes_read]});
    }

    // Scan
    const tokens = try scan(allocator, full_input);

    // Print
    pprint(tokens.toSlice());

    // Profit $$
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
