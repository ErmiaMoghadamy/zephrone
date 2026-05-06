const std = @import("std");
const App = @import("app.zig").App;

pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        std.debug.assert(status == .ok);
        std.debug.print("[WARN] No leak detected! probably false positive\n", .{});
    }
    const allocator = gpa.allocator();

    var app = try App.init(allocator);

    defer app.deinit();

    try app.run();
}
