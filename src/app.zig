const std = @import("std");
const zm = @import("zmath");
const Window = @import("core/window.zig").Window;
const event = @import("core/event.zig");
const BlockMesh = @import("DEBUG/block.zig").BlockMesh;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Shader = @import("graphics/shader.zig").Shader;
const Camera = @import("core/camera.zig").Camera;

pub const App = struct {
    window: *Window,
    allocator: std.mem.Allocator,
    mesh1: BlockMesh,
    shader1: Shader,
    camera1: Camera,

    pub fn init(allocator: std.mem.Allocator) !*App {
        const app = try allocator.create(App);

        const window = try Window.init(allocator, .{
            .title = "Zephrone",
            .width = null,
            .height = null,
        });


        app.* = App{
            .window = window,
            .allocator = allocator,
            .mesh1 = BlockMesh.init(),
            .shader1 = try Shader.init(
                @embedFile("shaders/common.vert.glsl"),
                @embedFile("shaders/common.frag.glsl"),
            ),
            .camera1 = Camera.init(@as(f32, @floatFromInt(window.data.width)) / @as(f32, @floatFromInt(window.data.height))),
        };



        window.setEventCallback(app, eventCallback);

        return app;
    }

    pub fn deinit(self: *App) void {
        std.log.warn("shutting down app", .{});
        self.window.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn eventCallback(self: *const App, ev: event.ZEvent) void {
        _ = self;

        switch (ev) {
            .MouseMove => |me| {
                std.log.debug("x={d} y={d}", .{me.x, me.y});
            },
            .MouseScroll => |x| {
                _ = x;
            },
            .MouseReleased => |x| {
                _ = x;
            },
            .KeyPressed => |x| {
                _ = x;
            },
            .KeyRepeated => |x| {
                _ = x;
            },
            .KeyReleased => |x| {
                _ = x;
            },
            .MousePressed => |x| {
                _ = x;
            },
            .CharInput => |x| {
                _ = x;
            },
            .ContentScaleChange => |x| {
                _ = x;
            },
            .FramebufferResize => |x| {
                _ = x;
            },
            .WindowClose => |x| {
                _ = x;
            },
            .WindowResize => |x| {
                _ = x;
            }
        }

        std.log.info("Event: {s}", .{@tagName(ev)});
    }

    pub fn run(self: *App) void {
        while (!self.window.shouldCloseWindow()) {
            Window.HandleInput();
            Renderer.clear();

            self.mesh1.mesh.bind();
            self.shader1.bind();

            self.shader1.set_mat("u_view", @bitCast(self.camera1.view));
            self.shader1.set_mat("u_projection", @bitCast(self.camera1.projection));
            self.shader1.set_mat("u_model", @bitCast(zm.identity()));


            Renderer.drawMesh(&self.mesh1.mesh);

            self.window.swapBuffers();
        }

    }
};
