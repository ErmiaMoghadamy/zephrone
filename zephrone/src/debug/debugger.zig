const std = @import("std");
const zgui = @import("zgui");
const zglfw = @import("zglfw");
const FrameContext = @import("../platform/platform.zig").FrameContext;
const WindowData = @import("../platform/window.zig").WindowData;

pub const Debugger = struct {
    enabled: bool = true,
    fps: f32 = 0.0,
    dt: f32 = 0.0,

    pub fn init(allocator: std.mem.Allocator, window: *zglfw.Window) Debugger {
        zgui.init(allocator);
        zgui.backend.init(window);

        return .{};
    }

    pub fn deinit(self: *Debugger) void {
        _ = self;
        std.log.warn("Destroying Debugger Instance", .{});
        zgui.backend.deinit();
        zgui.deinit();
    }

    pub fn debugFrame(_: *Debugger, ctx: FrameContext, wdata: WindowData) void {
        const w = @max(wdata.width, 1);
        const h = @max(wdata.height, 1);

        zgui.backend.newFrame(@intCast(w), @intCast(h));

        if (zgui.begin("Engine Debug", .{})) {
            zgui.bulletText(
                "Average :  {d:.3} ms/frame ({s} fps)",
                .{ ctx.dt, "Khar" },
            );            zgui.end();
        }

        zgui.render();
        zgui.backend.draw(); // <-- Fixed to match the backend struct
    }

};
