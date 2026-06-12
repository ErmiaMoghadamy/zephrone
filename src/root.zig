const std = @import("std");
const App = @import("app.zig").App;

pub fn run(io: std.Io) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    var app = try App.init(io, gpa.allocator());
    defer app.deinit();

    app.run();
}
