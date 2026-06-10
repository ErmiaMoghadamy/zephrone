const std = @import("std");

pub const App = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*App {
        const app = try allocator.create(App);

        app.* = App{
            .allocator = allocator,
        };

        return app;
    }

    pub fn deinit(self: *App) void {
        // self.window.deinit(self.allocator); @TODO
        self.allocator.destroy(self); // only if app is on heap!
    }

    pub fn run(self: *App) void {
        // while (!self.window.shouldCloseWindow()) {
        //     Window.HandleInput();
        //     Renderer.clear();

        //     self.window.swapBuffers();
        // }

        _ = self;
        while (true) {
            std.log.warn("unduck", .{});
        }

    }
};
