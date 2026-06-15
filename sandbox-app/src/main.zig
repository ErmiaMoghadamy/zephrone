const std = @import("std");
const sandbox = @import("sandbox_app");
const App = @import("zephrone_runtime").App;
const Game = @import("game.zig").Game;

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};

    defer _ = gpa.allocator();

    const RuntimeApp = App(Game);

    var app = try RuntimeApp.init(init.io, gpa.allocator());
    defer app.deinit();

    try app.run();
}
