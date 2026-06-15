const std = @import("std");
const gl = @import("zopengl").bindings;
const glfw = @import("zglfw");
const zypher = @import("zypher");
const Window = @import("window.zig").Window;

pub const ZEvent = union(enum) {
    WindowClose,
    WindowResize: struct { width: u32, height: u32 },
    FramebufferResize: struct { width: u32, height: u32 },
    ContentScaleChange: struct { x: f32, y: f32 },
    KeyPressed: glfw.Key,
    KeyReleased: glfw.Key,
    KeyRepeated: glfw.Key,
    CharInput: u32,
    MouseScroll: struct { x: f32, y: f32 },
    MouseMove: struct { x: f32, y: f32 },
    MousePressed: glfw.MouseButton,
    MouseReleased: glfw.MouseButton,
};

inline fn getWindowFromGLFW(window: *glfw.Window) *Window {
    const ptr = glfw.getWindowUserPointer(window, anyopaque).?;
    return @ptrCast(@alignCast(ptr));
}

pub fn mouseButtonCallback(window: *glfw.Window, btn: glfw.MouseButton, action: glfw.Action, mods: glfw.Mods) callconv(.c) void {
    _ = mods;

    const isPress = action == .press;
    const isRelease = action == .release;

    if (!isPress and !isRelease) {
        return;
    }

    const win = getWindowFromGLFW(window);
    const ev: ZEvent = if (isPress)
        ZEvent{ .MousePressed = btn }
    else
        ZEvent{ .MouseReleased = btn };

    win.dispatchEvent(ev);
}

pub fn keyButtonCallback(window: *glfw.Window, key: glfw.Key, scancode: c_int, action: glfw.Action, mods: glfw.Mods) callconv(.c) void {
    _ = mods;
    _ = scancode;

    const win = getWindowFromGLFW(window);

    if (key == .unknown) {
        std.log.warn("Unknown {s}\n", .{@tagName(key)});
    }

    var ev: ZEvent = undefined;
    if (action == glfw.Action.press) {
        ev = ZEvent{ .KeyPressed = key };
    } else if (action == glfw.Action.repeat) {
        ev = ZEvent{ .KeyRepeated = key };
    } else if (action == glfw.Action.release) {
        ev = ZEvent{ .KeyReleased = key };
    }

    win.dispatchEvent(ev);
}

pub fn windowResizeCallback(window: *glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    const win = getWindowFromGLFW(window);
    win.setSize(@intCast(width), @intCast(height));

    const ev = ZEvent{ .WindowResize = .{
        .height = @intCast(height),
        .width = @intCast(width),
    } };

    win.dispatchEvent(ev);
}

pub fn frameBufferSizeCallback(window: *glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    gl.viewport(0, 0, width, height);
    const win = getWindowFromGLFW(window);

    const ev = ZEvent{ .FramebufferResize = .{
        .height = @intCast(height),
        .width = @intCast(width),
    } };

    win.dispatchEvent(ev);
}

pub fn contentScaleCallback(window: *glfw.Window, xscale: f32, yscale: f32) callconv(.c) void {
    const win = getWindowFromGLFW(window);

    const ev = ZEvent{ .ContentScaleChange = .{ .x = xscale, .y = yscale } };
    win.dispatchEvent(ev);
}

pub fn windowCloseCallback(window: *glfw.Window) callconv(.c) void {
    const win = getWindowFromGLFW(window);
    const ev = .WindowClose;

    win.dispatchEvent(ev);
}

pub fn cursorPosCallback(window: *glfw.Window, x: f64, y: f64) callconv(.c) void {
    const win = getWindowFromGLFW(window);
    const ev = ZEvent{ .MouseMove = .{ .x = @floatCast(x), .y = @floatCast(y) } };
    win.dispatchEvent(ev);
}

pub fn charCallback(window: *glfw.Window, codepoint: c_uint) callconv(.c) void {
    const win = getWindowFromGLFW(window);
    const ev = ZEvent{ .CharInput = @intCast(codepoint) };

    win.dispatchEvent(ev);
}
