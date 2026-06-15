const glfw = @import("zglfw");
const std = @import("std");
const zm = @import("zmath");
const Window = @import("core/window.zig").Window;
const event = @import("core/event.zig");
const BlockMesh = @import("DEBUG/block.zig").BlockMesh;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Shader = @import("graphics/shader.zig").Shader;
const Camera = @import("core/camera.zig").Camera;
const Texture = @import("graphics/texture.zig").Texture;
const Lamp = @import("DEBUG/lamp.zig").Lamp;
const Input = @import("core/input.zig").InputManager;
const Time = @import("core/time.zig").Time;


pub const App = struct {
    window: *Window,
    allocator: std.mem.Allocator,
    io: std.Io,
    time: Time,

    mesh1: BlockMesh,
    shader1: Shader,
    camera1: Camera,
    texture1: Texture,
    lamp1: Lamp,

    pub fn init(io: std.Io, allocator: std.mem.Allocator) !*App {
        const app = try allocator.create(App);

        const window = try Window.init(allocator, .{
            .title = "Zephrone",
            .width = null,
            .height = null,
        });

        app.* = App{
            .window = window,
            .allocator = allocator,
            .io = io,
            .time = Time.init(),
            .camera1 = Camera.init(@as(f32, @floatFromInt(window.data.width)) / @as(f32, @floatFromInt(window.data.height))),
            .mesh1 = BlockMesh.init(),
            .shader1 = try Shader.init(
                @embedFile("shaders/lit.vert.glsl"),
                @embedFile("shaders/lit.frag.glsl"),
            ),
            .texture1 = try Texture.init(io, allocator, "../assets/floor.png", 0),
            .lamp1 = try Lamp.init(),
        };

        window.setEventCallback(app, eventCallback);

        return app;
    }

    pub fn deinit(self: *App) void {
        std.log.warn("shutting down app", .{});
        self.texture1.deinit();
        self.shader1.deinit();
        self.mesh1.mesh.deinit();
        self.window.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn eventCallback(self: *App, ev: event.ZEvent) void {
        Input.Update(ev);
        Input.Clear();

        switch (ev) {
            .MouseMove => |me| {
                std.log.debug("x={d} y={d}", .{ me.x, me.y });
            },
            .WindowResize => |x| {
                const aspect = @as(f32, @floatFromInt(x.width)) / @as(f32, @floatFromInt(x.height));
                self.camera1.updateAspect(aspect);
                self.camera1.updateProjection();
                self.camera1.updateView();
            },
            else => {}
        }

        std.log.info("Event: {s}", .{@tagName(ev)});
    }

    pub fn tempShit(self: *App) void {
        const amp: f32 = 8;

        if (Input.IsKeyHeld(.w)) self.camera1.moveZ(-amp * self.time.delta_time);

        if (Input.IsKeyHeld(.s)) self.camera1.moveZ(amp * self.time.delta_time);

        if (Input.IsKeyHeld(.a)) self.camera1.moveX(-amp * self.time.delta_time);

        if (Input.IsKeyHeld(.d)) self.camera1.moveX(amp * self.time.delta_time);

        if (Input.IsKeyHeld(.q)) self.camera1.yaw += -amp*0.3 * self.time.delta_time;

        if (Input.IsKeyHeld(.e)) self.camera1.yaw += amp*0.3 * self.time.delta_time;

        self.camera1.updateView();
        self.camera1.updateProjection();


    }

    pub fn run(self: *App) void {
        while (!self.window.shouldCloseWindow()) {
            Window.HandleInput();

            self.time.update(@floatCast(Window.GetTime()));

            self.tempShit();

            // START:   Scene
            Renderer.clear();

            self.lamp1.bindToCamera(&self.camera1);
            self.lamp1.shader.bind();
            Renderer.drawMesh(&self.lamp1.mesh);

            self.mesh1.mesh.bind();
            self.shader1.bind();
            self.texture1.bind();

            self.shader1.set_mat("u_view", @bitCast(self.camera1.view));
            self.shader1.set_mat("u_projection", @bitCast(self.camera1.projection));
            self.shader1.set_mat("u_model", @bitCast(zm.identity()));
            self.shader1.set_int("u_texture", 0);

            self.shader1.set_vec4("u_light", @bitCast(self.lamp1.light_color));
            self.shader1.set_vec4("u_light_pos", @bitCast(self.lamp1.transform.position));
            self.shader1.set_vec4("u_camera_pos", @bitCast(self.camera1.position));

            Renderer.drawMesh(&self.mesh1.mesh);
            // END:     Scene

            self.window.swapBuffers();
        }
    }
};
