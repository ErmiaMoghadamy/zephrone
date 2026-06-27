const std = @import("std");
const zm = @import("zmath");
const event = @import("platform/root.zig").event;
const Window = @import("platform/root.zig").Window;
const Platform = @import("platform/root.zig").Platform;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Debugger = @import("debug/debugger.zig").Debugger;
const zgui = @import("zgui");

pub fn App(comptime GameType: type) type {
    return struct {
        allocator: std.mem.Allocator,
        io: std.Io,
        game: GameType,
        platform: *Platform,
        renderer: Renderer,
        debugger: Debugger,

        const Self = @This();

        pub fn init(io: std.Io, allocator: std.mem.Allocator) !Self {
            const platform = try Platform.init(allocator, .{
                .title = "Zephrone Egnine",
                .width = null,
                .height = null,
            });

            const init_aspect = @as(f32, @floatFromInt(platform.window.data.width)) / @as(f32, @floatFromInt(platform.window.data.height));

            const app = Self{
                .platform = platform,
                .game = try GameType.init(io, allocator, init_aspect),
                .renderer = Renderer.init(),
                .allocator = allocator,
                .io = io,
                .debugger = Debugger.init(allocator, platform.window.window)
            };

            return app;
        }

        pub fn deinit(self: *Self) void {
            std.log.warn("Destroying App Instance", .{});

            self.debugger.deinit();
            self.game.deinit(self.allocator);
            self.renderer.deinit();
            self.platform.deinit(self.allocator);
        }

        pub fn run(self: *Self) !void {
            try self.game.bootstrap(self.allocator);

            while (self.platform.alive()) {
                self.platform.pump();

                const ctx = self.platform.context();

                try self.game.update(ctx);
                try self.game.render(&self.renderer);

                const size = self.platform.window.getSize();

                self.debugger.debugFrame(ctx, size);

                self.platform.flush();
            }
        }
    };
}
