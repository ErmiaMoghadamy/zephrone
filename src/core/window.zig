const std = @import("std");
const glfw = @import("zglfw");
const zgl = @import("zopengl");
const gl = zgl.bindings;
// const event = @import("event.zig");


pub const WindowData = struct {
    width: u32,
    height: u32,
};

pub const WindowParams = struct {
    width: ?u32,
    height: ?u32,
    title: []const u8,
};

fn getDefaultWidth() !u32 {
    const monitor = glfw.getPrimaryMonitor() orelse return error.NoPrimaryMonitor;
    const video = try glfw.getVideoMode(monitor);
    const full_width: u32 = @intCast(video.width);

    return @intFromFloat(@as(f32, @floatFromInt(full_width)));
}

fn getDefaultHeight() !u32 {
    const monitor = glfw.getPrimaryMonitor() orelse return error.NoPrimaryMonitor;
    const video = try glfw.getVideoMode(monitor);
    const full_height: u32 = @intCast(video.height);

    return @intFromFloat(@as(f32, @floatFromInt(full_height)));
}


pub const Window = struct {
    window: *glfw.Window,
    data: WindowData,

    pub fn init(allocator: std.mem.Allocator, params: WindowParams) !*Window {
        std.log.info("starting up app", .{});

        try glfw.init();
        errdefer glfw.terminate();

        const title = try allocator.dupeZ(u8, params.title);
        defer allocator.free(title);

        const width = if(params.width) |w| w else try getDefaultWidth();
        const height = if(params.height) |h| h else try getDefaultHeight();

        var window = try glfw.createWindow(@intCast(width), @intCast(height), title, null, null);
        errdefer window.destroy();


        glfw.makeContextCurrent(window);
        // Window.SetVsync(true);



        try zgl.loadCoreProfile(glfw.getProcAddress, 3, 3);

        const win = try allocator.create(Window);

        win.* = .{
            .window = window,
            .data = .{
                .width = width,
                .height = height,
            },
        };

        return win;
    }

    pub fn deinit(self: *Window, allocator: std.mem.Allocator) void {
        glfw.terminate();
        glfw.destroyWindow(self.window);
        allocator.destroy(self);
    }

    pub fn shouldCloseWindow(self: *Window) bool {
        return glfw.windowShouldClose(self.window);
    }

    pub fn HandleInput() void {
        glfw.pollEvents();
    }

    pub fn swapBuffers(self: *Window) void {
        glfw.swapBuffers(self.window);
    }
};
