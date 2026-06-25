const std = @import("std");
const zm = @import("zmath");
const event = @import("platform/root.zig").event;
const Window = @import("platform/root.zig").Window;
const Platform = @import("platform/root.zig").Platform;

pub fn App(comptime GameType: type) type {
    return struct {
        game: GameType,
        platform: *Platform,
        allocator: std.mem.Allocator,
        io: std.Io,

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
                .allocator = allocator,
                .io = io,
            };

            return app;
        }

        pub fn deinit(self: *Self) void {
            std.log.warn("Destroying App Instance", .{});

            self.game.deinit(self.allocator);
            self.platform.deinit(self.allocator);
        }

        pub fn run(self: *Self) !void {
            try self.game.bootstrap(self.allocator);

            while (self.platform.alive()) {
                self.platform.pump();

                try self.game.update(self.platform.context());
                try self.game.render();

                self.platform.flush();
            }
        }
    };
}
