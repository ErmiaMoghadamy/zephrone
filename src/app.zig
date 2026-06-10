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

    pub const App = struct {
        window: *Window,
        allocator: std.mem.Allocator,
        io: std.Io,
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
                .camera1 = Camera.init(@as(f32, @floatFromInt(window.data.width)) / @as(f32, @floatFromInt(window.data.height))),
                .mesh1 = BlockMesh.init(),
                .shader1 = try Shader.init(
                    @embedFile("shaders/lit.vert.glsl"),
                    @embedFile("shaders/lit.frag.glsl"),
                ),
                .texture1 = try Texture.init(io, allocator, "assets/floor.png", 0),
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
                    const speed: f32 = 0.1;

                    switch (x) {
                        glfw.Key.w => self.camera1.moveZ(-speed),
                        glfw.Key.s => self.camera1.moveZ(speed),
                        glfw.Key.a => self.camera1.moveX(-speed),
                        glfw.Key.d => self.camera1.moveX(speed),
                        else => {},
                    }
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
                    const aspect = @as(f32, @floatFromInt(x.width)) / @as(f32, @floatFromInt(x.height));
                    self.camera1.updateAspect(aspect);
                    self.camera1.updateProjection();
                    self.camera1.updateView();
                }
            }

            std.log.info("Event: {s}", .{@tagName(ev)});
        }

        pub fn tempShit(self: *App) void {
            const amp: f32 = 1.4;

            if (self.window.window.getKey(.e) == .press) {
                self.lamp1.transform.position[2] += 0.08 * amp;
                self.lamp1.transform.position[0] += 0.08 * amp;
            }

            if (self.window.window.getKey(.q) == .press) {
                self.lamp1.transform.position[2] -= 0.08 * amp;
                self.lamp1.transform.position[0] -= 0.08 * amp;
            }

            if (self.window.window.getKey(.z) == .press) {
                self.lamp1.transform.position[1] += 0.08 * amp;
            }

            if (self.window.window.getKey(.x) == .press) {
                self.lamp1.transform.position[1] -= 0.08 * amp;
            }

            if (self.window.window.getKey(.w) == .press) {
                self.camera1.moveZ(-0.08 * amp);
            }

            if (self.window.window.getKey(.s) == .press) {
                self.camera1.moveZ(0.08 * amp);
            }

            if (self.window.window.getKey(.a) == .press) {
                self.camera1.moveX(-0.08 * amp);
            }

            if (self.window.window.getKey(.d) == .press) {
                self.camera1.moveX(0.08 * amp);
            }

            if (self.window.window.getKey(.space) == .press) {
                self.camera1.moveY(0.06 * amp);
            }

            if (self.window.window.getKey(.left_control) == .press) {
                self.camera1.moveY(-0.06 * amp);
            }

        }

        pub fn run(self: *App) void {
            while (!self.window.shouldCloseWindow()) {
                self.tempShit();
                Window.HandleInput();
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

                self.window.swapBuffers();
            }

        }
    };
