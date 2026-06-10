const std = @import("std");
const Window = @import("core/window.zig").Window;
const event = @import("core/event.zig");

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

        window.setEventCallback(app, eventCallback);

        return app;
    }

    pub fn deinit(self: *App) void {
        std.log.warn("shutting down app", .{});
        self.window.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn eventCallback(self: *const App, ev: event.ZEvent) void {
        _ = self;

        switch (ev) {
            .MouseMove => |me| {
                std.log.debug("x={d} y={d}", .{me.x, me.y});
            },
            .MouseScroll => |x| {
                _ = x;
            },
            .MouseReleased => |x| {
                _ = x;
            },
            .KeyPressed => |x| {
                _ = x;
            },
            .KeyRepeated => |x| {
                _ = x;
            },
            .KeyReleased => |x| {
                _ = x;
            },
            .MousePressed => |x| {
                _ = x;
            },
            .CharInput => |x| {
                _ = x;
            },
            .ContentScaleChange => |x| {
                _ = x;
            },
            .FramebufferResize => |x| {
                _ = x;
            },
            .WindowClose => |x| {
                _ = x;
            },
            .WindowResize => |x| {
                _ = x;
            }
        }

        std.log.info("Event: {s}", .{@tagName(ev)});
    }

    pub fn run(self: *App) void {
        while (!self.window.shouldCloseWindow()) {
            Window.HandleInput();
            // Renderer.clear();

            self.window.swapBuffers();
        }

    }
};
