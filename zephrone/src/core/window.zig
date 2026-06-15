const std = @import("std");
const glfw = @import("zglfw");
const zgl = @import("zopengl");
const gl = zgl.bindings;
const event = @import("event.zig");


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
    event_fn: *const fn(*anyopaque, event.ZEvent) void = undefined,
    event_ctx: *anyopaque = undefined,

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
        Window.SetVsync(true);


        try zgl.loadCoreProfile(glfw.getProcAddress, 3, 3);

        gl.enable(gl.CULL_FACE);
        gl.enable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

        const win = try allocator.create(Window);

        win.* = .{
            .window = window,
            .data = .{
                .width = width,
                .height = height,
            },
        };

        var fb_width: c_int = undefined;
        var fb_height: c_int = undefined;
        glfw.getFramebufferSize(window, &fb_width, &fb_height);
        gl.viewport(0, 0, fb_width, fb_height);


        return win;
    }

    pub fn deinit(self: *Window, allocator: std.mem.Allocator) void {
        glfw.terminate();
        glfw.destroyWindow(self.window);
        allocator.destroy(self);
    }

    pub fn GetTime() f32 {
        return @floatCast(glfw.getTime());
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

    pub fn SetVsync(value: bool) void {
        glfw.swapInterval(@intFromBool(value));
    }

    pub fn setSize(self: *Window, width: u32, height: u32) void {
        self.data.width = width;
        self.data.height = height;
    }

    pub fn dispatchEvent(self: *Window, ev: event.ZEvent) void {
        self.event_fn(self.event_ctx, ev);
    }

    pub fn setEventCallback(self: *Window, context: anytype, comptime callback: fn (@TypeOf(context), event.ZEvent) void) void {
        const Ctx = @TypeOf(context);
        self.event_fn = struct {
            fn dispatch(ctx: *anyopaque, ev: event.ZEvent) void {
                callback(@as(Ctx, @ptrCast(@alignCast(ctx))), ev);
            }
        }.dispatch;

        self.event_ctx = @ptrCast(context);
        glfw.setWindowUserPointer(self.window, @ptrCast(self));
        _ = glfw.setMouseButtonCallback(self.window, event.mouseButtonCallback);
        _ = glfw.setKeyCallback(self.window, event.keyButtonCallback);
        _ = glfw.setCharCallback(self.window, event.charCallback);
        _ = glfw.setWindowSizeCallback(self.window, event.windowResizeCallback);
        _ = glfw.setFramebufferSizeCallback(self.window, event.frameBufferSizeCallback);
        _ = glfw.setWindowContentScaleCallback(self.window, event.contentScaleCallback);
        _ = glfw.setWindowCloseCallback(self.window, event.windowCloseCallback);
        _ = glfw.setCursorPosCallback(self.window, event.cursorPosCallback);
    }
};
