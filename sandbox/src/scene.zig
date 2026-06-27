const std = @import("std");
const gl = @import("zephrone_runtime").gl;
const zm = @import("zephrone_runtime").zmath;
const Input = @import("zephrone_runtime").services.InputService;
const Renderer = @import("zephrone_runtime").graphics.Renderer;
const Camera = @import("zephrone_runtime").scene.Camera;
const Shader = @import("zephrone_runtime").graphics.Shader;
const Texture = @import("zephrone_runtime").graphics.Texture;
const InstanceBuffer = @import("zephrone_runtime").graphics.buffer.InstanceBuffer;
const Vertex = @import("zephrone_runtime").graphics.buffer.Vertex;
const Lamp = @import("entities/lamp.zig").Lamp;
const BlockMesh = @import("entities/block.zig").BlockMesh;
const Block = @import("entities/block.zig").Block;
const Model = @import("zephrone_runtime").core.Model;
const Transform = @import("zephrone_runtime").core.Transform;

pub const GameScene = struct {
    shader1: Shader,
    texture1: Texture,
    lamp1: Lamp,
    camera1: Camera,
    model1: Model,
    model2: Model,
    items: std.ArrayList(Transform),
    instance_vbo: InstanceBuffer,

    pub fn init(io: std.Io, allocator: std.mem.Allocator, initial_aspect: f32) !GameScene {
        return GameScene{
            .camera1 = Camera.init(initial_aspect),
            .lamp1 = try Lamp.init(),
            .shader1 = try Shader.init(@embedFile("shaders/lit_instanced.vert.glsl"), @embedFile("shaders/lit_instanced.frag.glsl")),
            .texture1 = try Texture.init(io, allocator, "../assets/dirt.png", 0),
            .model1 = try Model.load_glb(io, allocator, "../assets/box.glb"),
            .model2 = try Model.load_glb(io, allocator, "../assets/teapot.glb"),
            .items = .empty,
            .instance_vbo = InstanceBuffer.init(),
        };
    }

    pub fn deinit(self: *GameScene, allocator: std.mem.Allocator) void {
        self.items.deinit(allocator);
        self.shader1.deinit();
        self.lamp1.deinit();
    }

    pub fn bootstrap(self: *GameScene, allocator: std.mem.Allocator) !void {
        for (0..32) |i| {
            for (0..64) |k| {
                for (0..18) |j| {
                    var block = Transform.init();
                    block.position[0] += 2 * (@as(f32, @floatFromInt(i)) - 16);
                    block.position[1] += -2 * (@as(f32, @floatFromInt(j)));
                    block.position[2] += 2 * (@as(f32, @floatFromInt(k)) - 16);
                    try self.items.append(allocator, block);
                }
            }
        }
    }

    pub fn update(self: *GameScene, dt: f32, aspect: f32) void {
        const delta = Input.GetMouseMoveDelta();

        self.camera1.rotateByMouse(delta.x, delta.y);
        self.camera1.fov += Input.GetMouseMoveScroll().y * 0.05;
        self.camera1.fov = std.math.clamp(self.camera1.fov, 0.1, 120.0);

        const amp: f32 = 12.0;

        if (Input.IsKeyHeld(.w)) self.camera1.moveZ(-amp * dt);
        if (Input.IsKeyHeld(.s)) self.camera1.moveZ(amp * dt);
        if (Input.IsKeyHeld(.a)) self.camera1.moveX(-amp * dt);
        if (Input.IsKeyHeld(.d)) self.camera1.moveX(amp * dt);

        if (Input.IsKeyHeld(.one)) self.lamp1.transform.rotate(zm.f32x4(6*dt, 0.0, 0.0, 0.0));
        if (Input.IsKeyHeld(.two)) self.lamp1.transform.rotate(zm.f32x4(-6*dt, 0.0, 0.0, 0.0));
        if (Input.IsKeyHeld(.three)) self.lamp1.transform.rotate(zm.f32x4(0.0, 6*dt, 0.0, 0.0));
        if (Input.IsKeyHeld(.four)) self.lamp1.transform.rotate(zm.f32x4(0.0, -6*dt, 0.0, 0.0));
        if (Input.IsKeyHeld(.five)) self.lamp1.transform.rotate(zm.f32x4(0.0, 0.0, 6*dt, 0.0));
        if (Input.IsKeyHeld(.six)) self.lamp1.transform.rotate(zm.f32x4(0.0, 0.0, -6*dt, 0.0));

        if (Input.IsKeyHeld(.left_control)) self.camera1
        .moveY(-amp * dt);
        if (Input.IsKeyHeld(.space)) self.camera1.moveY(amp * dt);

        self.camera1.updateAspect(aspect);
        self.camera1.updateView();
        self.camera1.updateProjection();

        if (Input.IsKeyHeld(.z)) self.lamp1.transform.translate(zm.f32x4(amp*dt, 0.0, 0.0, 0.0));
        if (Input.IsKeyHeld(.x)) self.lamp1.transform.translate(zm.f32x4(-amp*dt, 0.0, 0.0, 0.0));

        if (Input.IsKeyHeld(.f)) self.lamp1.transform.translate(zm.f32x4(0.0, amp*dt, 0.0, 0.0));
        if (Input.IsKeyHeld(.g)) self.lamp1.transform.translate(zm.f32x4(0.0, -amp*dt, 0.0, 0.0));
    }

    pub fn draw(self: *GameScene, renderer: *Renderer) void {
        Renderer.clear();

        self.lamp1.mesh.bind();
        self.lamp1.shader.bind();
        self.lamp1.shader.set_mat("u_view", @bitCast(self.camera1.view));
        self.lamp1.shader.set_mat("u_projection", @bitCast(self.camera1.projection));
        self.lamp1.shader.set_mat("u_model", @bitCast(self.lamp1.transform.getModel()));
        self.lamp1.shader.set_vec4("u_light", @bitCast(self.lamp1.light_color));
        Renderer.drawMesh(&self.model2.meshes[0]);

        self.shader1.bind();

        self.shader1.set_mat("u_view", @bitCast(self.camera1.view));
        self.shader1.set_mat("u_projection", @bitCast(self.camera1.projection));

        self.shader1.set_vec4("u_light", @bitCast(self.lamp1.light_color));
        self.shader1.set_vec4("u_light_pos", @bitCast(self.lamp1.transform.position));
        self.shader1.set_vec4("u_camera_pos", @bitCast(self.camera1.position));

        self.texture1.bind();


        self.model1.meshes[0].bind();
        self.shader1.bind();


        renderer.drawMeshInstanced(&self.model1.meshes[0], self.items.items);

    }
};
