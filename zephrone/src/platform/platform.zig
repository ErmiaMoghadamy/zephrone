const std = @import("std");
const event = @import("./event.zig");
const glfw = @import("zglfw");
const Window = @import("./window.zig").Window;
const WindowParams = @import("./window.zig").WindowParams;
const Time = @import("./time.zig").Time;
const InputService = @import("../services/input.zig").InputService;

pub const FrameContext = struct { dt: f32, aspect: f32 };

pub const PlatformConfig = struct {
    title: []const u8,
    width: u32,
    height: u32,
};

pub const Platform = struct {
    window: *Window,
    time: Time,
    allocator: std.mem.Allocator,
    event_queue: std.ArrayList(event.ZEvent),

    pub fn init(allocator: std.mem.Allocator, params: WindowParams) !*Platform {
        const platform = try allocator.create(Platform);

        const window = try Window.init(allocator, params);
        errdefer window.deinit(allocator);

        platform.* = .{
            .window = window,
            .time = Time.init(),
            .allocator = allocator,
            .event_queue = .empty,
        };

        window.setEventCallback(platform, eventCallback);
        try window.window.setInputMode(.cursor, .disabled);

        return platform;
    }

    pub fn deinit(self: *Platform, allocator: std.mem.Allocator) void {
        std.log.warn("Destroying Platform Instance", .{});

        self.window.deinit(allocator);
        allocator.destroy(self);
    }

    pub fn pump(self: *Platform) void {
        Window.HandleInput();
        self.time.update(@floatCast(Window.GetTime()));
    }

    pub fn flush(self: *Platform) void {
        self.window.swapBuffers();
        InputService.Clear();
    }

    pub fn alive(self: *Platform) bool {
        return !self.window.shouldCloseWindow();
    }

    pub fn context(self: *Platform) FrameContext {
        const w = @as(f32, @floatFromInt(self.window.data.width));
        const h = @as(f32, @floatFromInt(self.window.data.height));
        return .{
            .dt = self.time.delta_time,
            .aspect = if (h > 0) w / h else 1.0,
        };
    }

    pub fn eventCallback(self: *Platform, ev: event.ZEvent) void {
        InputService.Update(ev);

        if (InputService.IsKeyReleased(.escape)) {
            std.log.err("Escape key pressed", .{});
            glfw.setWindowShouldClose(self.window.window, true);
        }

        // self.event_queue.append(self.allocator, ev) catch |err| {
        //     std.log.err("Failed to queue event: {}", .{err});
        // };
    }
};
