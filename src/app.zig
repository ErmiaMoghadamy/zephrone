const std = @import("std");
const zgui = @import("zgui");
const glfw = @import("zglfw");
const zm = @import("zmath");
const zgl = @import("zopengl");
const gl = zgl.bindings;
const Mesh = @import("graphics/mesh.zig").Mesh;
const Shader = @import("graphics/shader.zig").Shader;
const Scene = @import("core/scene.zig").Scene;
const Renderer = @import("core/renderer.zig").Renderer;
const DebugPane = @import("debug.zig").DebugPane;

pub const App = struct {
    const width = 1080;
    const height = 720;

    allocator: std.mem.Allocator,
    window: *glfw.Window,
    scene: Scene,
    debug_pane: DebugPane,

    last_w: i32 = 0,
    last_h: i32 = 0,

    mouse_first: bool = true,
    mouse_last_x: f64 = 0,
    mouse_last_y: f64 = 0,
    mouse_dx: f32 = 0,
    mouse_dy: f32 = 0,

    pub fn init(allocator: std.mem.Allocator) !App {
        try glfw.init();
        errdefer glfw.terminate();

        var window = try glfw.createWindow(width, height, "Zigl", null, null);
        errdefer window.destroy();

        glfw.makeContextCurrent(window);
        glfw.swapInterval(1);

        try zgl.loadCoreProfile(glfw.getProcAddress, 3, 3);

        gl.viewport(0, 0, width, height);
        gl.enable(gl.DEPTH_TEST);
        gl.enable(gl.CULL_FACE);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

        try DebugPane.bootstrap(allocator, window);

        return App{
            .window = window,
            .allocator = allocator,
            .scene = try Scene.init(allocator, @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height))),
            .debug_pane = DebugPane.init(),
        };
    }

    pub fn deinit(self: *App) void {
        self.scene.deinit();

        self.debug_pane.deinit();

        self.window.destroy();
        glfw.terminate();
    }

    fn handleResize(self: *App) void {
        const shape = self.window.getFramebufferSize();

        if (shape[0] == self.last_w and shape[1] == self.last_h) return;

        gl.viewport(0, 0, shape[0], shape[1]);

        const aspect = @as(f32, @floatFromInt(shape[0])) / @as(f32, @floatFromInt(shape[1]));
        self.scene.camera.updateAspect(aspect);

        self.last_w = shape[0];
        self.last_h = shape[1];
    }

    pub fn handleInput(self: *App) !void {
        try self.handleKeyboard();
        self.handleMouseMove();
    }

    pub fn handleMouseMove(self: *App) void {
        if (!self.window.getAttribute(.focused)) {
            return;
        }
        const pos = self.window.getCursorPos();

        const dx: f32 = @floatCast(pos[0] - self.mouse_last_x);
        const dy: f32 = @floatCast(self.mouse_last_y - pos[1]);

        self.scene.camera.rotateByMouse(dx, dy);

        self.mouse_last_x = pos[0];
        self.mouse_last_y = pos[1];
    }

    pub fn handleKeyboard(self: *App) !void {
        if (self.window.getKey(.escape) == .press) {
            self.window.setShouldClose(true);
        }

        try self.scene.handleControls(self.window);
    }

    pub fn run(self: *App) !void {
        try self.scene.bootstrap();

        try self.window.setInputMode(.cursor, .disabled);

        while (!self.window.shouldClose()) {
            glfw.pollEvents();

            self.handleResize();
            try self.handleInput();
            try self.scene.run();
            try self.debug_pane.run(&self.scene, self.last_w, self.last_h);

            self.window.swapBuffers();
        }
    }
};
