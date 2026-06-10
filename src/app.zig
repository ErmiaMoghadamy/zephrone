const std = @import("std");
const Window = @import("core/window.zig").Window;


pub const App = struct {
    window: *Window,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*App {
        const app = try allocator.create(App);

        const window = try Window.init(allocator, .{
            .title = "Zephrone",
            .width = null,
            .height = null,
        });

        app.* = App{
            .window = window,
            .allocator = allocator,
        };

        // window.setEventCallback(app, eventCallback);

        return app;
    }

    pub fn deinit(self: *App) void {
        std.log.warn("shutting down app", .{});
        self.window.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn run(self: *App) void {
        while (!self.window.shouldCloseWindow()) {
            Window.HandleInput();
            // Renderer.clear();

            self.window.swapBuffers();
        }

    }
};
