const std = @import("std");
const glfw = @import("zglfw");
const event = @import("../platform/event.zig");

pub const Position = struct {
    x: f32,
    y: f32,
};

pub const InputService = struct {
    mouse_pos: Position,
    mouse_delta: Position,
    mouse_scroll: Position,

    pressed_keys: [512]bool,
    released_keys: [512]bool,
    held_keys: [512]bool,

    pressed_buttons: [8]bool,
    released_buttons: [8]bool,
    held_buttons: [8]bool,

    var instance: ?InputService = null;

    inline fn getInstance() *InputService {
        if (instance == null) {
            instance = InputService{
                .mouse_pos = .{ .x = 0.0, .y = 0.0 },
                .mouse_delta = .{ .x = 0.0, .y = 0.0 },
                .mouse_scroll = .{ .x = 0.0, .y = 0.0 },

                .pressed_keys = [_]bool{false} ** 512,
                .released_keys = [_]bool{false} ** 512,
                .held_keys = [_]bool{false} ** 512,

                .pressed_buttons = [_]bool{false} ** 8,
                .released_buttons = [_]bool{false} ** 8,
                .held_buttons = [_]bool{false} ** 8,
            };
        }
        return &instance.?;
    }

    pub fn Clear() void {
        const self = getInstance();
        @memset(&self.pressed_keys, false);
        @memset(&self.released_keys, false);
        @memset(&self.pressed_buttons, false);
        @memset(&self.released_buttons, false);
        self.mouse_scroll = .{ .x = 0.0, .y = 0.0 };
        self.mouse_delta = .{ .x = 0.0, .y = 0.0 };
    }

    pub fn Update(ev: event.ZEvent) void {
        const self = getInstance();

        switch (ev) {
            .MouseMove => |move_event| {
                self.mouse_delta.x = move_event.x - self.mouse_pos.x;
                self.mouse_delta.y = move_event.y - self.mouse_pos.y;
                self.mouse_pos.x = move_event.x;
                self.mouse_pos.y = move_event.y;
            },
            .MouseScroll => |scroll_event| {
                self.mouse_scroll.x += scroll_event.x;
                self.mouse_scroll.y += scroll_event.y;
            },
            .KeyPressed => |key_event| {
                const key: usize = @intCast(@intFromEnum(key_event));
                self.pressed_keys[key] = true;
                self.held_keys[key] = true;
            },
            .KeyRepeated => |key_event| {
                const key: usize = @intCast(@intFromEnum(key_event));
                self.pressed_keys[key] = true;
                self.held_keys[key] = true;
            },
            .KeyReleased => |key_event| {
                const key: usize = @intCast(@intFromEnum(key_event));
                self.released_keys[key] = true;
                self.held_keys[key] = false;
            },
            .MousePressed => |mouse_event| {
                const button: usize = @intCast(@intFromEnum(mouse_event));
                self.pressed_buttons[button] = true;
                self.held_buttons[button] = true;
            },
            .MouseReleased => |mouse_event| {
                const button: usize = @intCast(@intFromEnum(mouse_event));
                self.pressed_buttons[button] = true;
                self.held_buttons[button] = false;
            },
            else => {},
        }
    }

    pub fn GetMousePos() Position {
        const self = getInstance();
        return self.mouse_pos;
    }

    pub fn IsKeyPressed(key: glfw.Key) bool {
        const self = getInstance();
        const k: usize = @intCast(@intFromEnum(key));
        return self.pressed_keys[k];
    }

    pub fn IsKeyReleased(key: glfw.Key) bool {
        const self = getInstance();
        const k: usize = @intCast(@intFromEnum(key));
        return self.released_keys[k];
    }

    pub fn IsKeyHeld(key: glfw.Key) bool {
        const self = getInstance();
        const k: usize = @intCast(@intFromEnum(key));
        return self.held_keys[k];
    }



    pub fn IsButtonPressed(key: glfw.MouseButton) bool {
        const self = getInstance();
        const b: usize = @intCast(@intFromEnum(key));
        return self.pressed_buttons[b];
    }

    pub fn IsButtonReleased(key: glfw.MouseButton) bool {
        const self = getInstance();
        const b: usize = @intCast(@intFromEnum(key));
        return self.released_buttons[b];
    }

    pub fn IsButtonHeld(key: glfw.MouseButton) bool {
        const self = getInstance();
        const b: usize = @intCast(@intFromEnum(key));
        return self.held_buttons[b];
    }



    pub fn IsScrollingY() bool {
        const self = getInstance();
        return self.mouse_scroll.y != 0;
    }

    pub fn IsScrollingX() bool {
        const self = getInstance();
        return self.mouse_scroll.x != 0;
    }

    pub fn GetMouseMoveDelta() Position {
        const self = getInstance();
        return self.mouse_delta;
    }

    pub fn GetMouseMoveScroll() Position {
        const self = getInstance();
        return self.mouse_delta;
    }
};


test "InputService Initialization" {
    InputService.Clear();

    const self = InputService.getInstance();

    try std.testing.expectEqual(@as(f32, 0.0), self.mouse_pos.x);
    try std.testing.expectEqual(@as(f32, 0.0), self.mouse_pos.y);
    try std.testing.expectEqual(@as(f32, 0.0), self.mouse_scroll.x);
    try std.testing.expectEqual(@as(f32, 0.0), self.mouse_scroll.y);

    for (self.pressed_keys) |key| {
        try std.testing.expect(!key);
    }

    for (self.released_keys) |key| {
        try std.testing.expect(!key);
    }

    for (self.held_keys) |key| {
        try std.testing.expect(!key);
    }

    for (self.pressed_buttons) |key| {
        try std.testing.expect(!key);
    }

    for (self.released_buttons) |key| {
        try std.testing.expect(!key);
    }
}

test "InputService keypress detection" {
    InputService.Clear();

    const ez = event.ZEvent{ .KeyPressed = glfw.Key.a };

    InputService.Update(ez);

    try std.testing.expect(InputService.IsKeyPressed(.a));
    try std.testing.expect(InputService.IsKeyHeld(.a));
    try std.testing.expect(!InputService.IsKeyReleased(.a));
    try std.testing.expect(!InputService.IsKeyPressed(.b));
}


test "InputService kerelease detection" {
    InputService.Clear();

    const press_event = event.ZEvent{ .KeyPressed = glfw.Key.a };
    InputService.Update(press_event);
    try std.testing.expect(InputService.IsKeyPressed(.a));


    InputService.Clear();
    const release_event = event.ZEvent{ .KeyReleased = glfw.Key.a };
    InputService.Update(release_event);
    try std.testing.expect(InputService.IsKeyReleased(.a));
}

test "released key cannot be pressed simultaneously" {
    InputService.Clear();

    const key = glfw.Key.a;

    InputService.Update(.{ .KeyPressed = key });
    InputService.Update(.{ .KeyReleased = key });

    try std.testing.expect(!InputService.IsKeyPressed(key));
    try std.testing.expect(InputService.IsKeyReleased(key));
    try std.testing.expect(!InputService.IsKeyHeld(key));
}
