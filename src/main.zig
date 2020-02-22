const std = @import("std");
const io = std.io;
const ArrayList = std.ArrayList;
const scan = @import("scan.zig").scan;
const pprint = @import("print.zig").pprint;

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
