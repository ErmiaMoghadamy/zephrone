const glfw = @import("zglfw");
const std = @import("std");
const zm = @import("zmath");
const event = @import("core/event.zig");
const Window = @import("core/window.zig").Window;
const Input = @import("core/input.zig").InputManager;
const Time = @import("core/time.zig").Time;

pub fn App(comptime GameType: type) type {
    return struct {
        game: GameType,
        time: Time,
        window: *Window,
        allocator: std.mem.Allocator,
        io: std.Io,

        const Self = @This();

        pub fn init(io: std.Io, allocator: std.mem.Allocator) !*Self {
            const app = try allocator.create(Self);

            const window = try Window.init(allocator, .{
                .title = "Zephrone Egnine",
                .width = null,
                .height = null,
            });

            errdefer window.deinit(allocator);

            const init_aspect = @as(f32, @floatFromInt(window.data.width)) / @as(f32, @floatFromInt(window.data.height));

            app.* = Self{
                .game = try GameType.init(io, allocator, init_aspect),
                .time = Time.init(),
                .window = window,
                .allocator = allocator,
                .io = io,
            };

            window.setEventCallback(app, Self.eventCallback);

            return app;
        }

        pub fn deinit(self: *Self) void {
            std.log.warn("shutting down app instance", .{});

            self.game.deinit();
            self.window.deinit(self.allocator);
            self.allocator.destroy(self);
        }

        pub fn eventCallback(self: *Self, ev: event.ZEvent) void {
            Input.Update(ev);
            Input.Clear();

            _ = self;

            std.log.info("Event: {s}", .{@tagName(ev)});
        }

        pub fn run(self: *Self) !void {
            try self.game.bootstrap();

            while (!self.window.shouldCloseWindow()) {
                Window.HandleInput();

                self.time.update(@floatCast(Window.GetTime()));

                const aspect = @as(f32, @floatFromInt(self.window.data.width)) / @as(f32, @floatFromInt(self.window.data.height));
                try self.game.update(self.time.delta_time, aspect);

                try self.game.render();

                self.window.swapBuffers();
            }
        }
    };
}
