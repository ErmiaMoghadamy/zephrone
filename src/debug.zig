const zm = @import("zmath");
const zgui = @import("zgui");
const glfw = @import("zglfw");
const std = @import("std");
const Scene = @import("core/scene.zig").Scene;

pub const DebugPane = struct {
    pub fn init() DebugPane {
        return DebugPane{};
    }

    pub fn bootstrap(allocator: std.mem.Allocator, window: *glfw.Window) !void {
        zgui.init(allocator);
        errdefer zgui.deinit();

        zgui.backend.init(window);
        errdefer zgui.backend.deinit();
    }

    pub fn deinit(self: *DebugPane) void {
        _ = self;
        zgui.backend.deinit();
        zgui.deinit();
    }

    pub fn run(self: *DebugPane, scene: *Scene, last_w: i32, last_h: i32) !void {
        zgui.backend.newFrame(@intCast(last_w), @intCast(last_h));

        _ = zgui.begin("Debug", .{});

        _ = self;
        _ = scene;

        zgui.end();
        zgui.render();
        zgui.backend.draw();
    }
};
