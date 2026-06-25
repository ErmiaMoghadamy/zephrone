const std = @import("std");
const zm = @import("zephrone_runtime").zmath;
const Input = @import("zephrone_runtime").services.InputService;
const Renderer = @import("zephrone_runtime").graphics.Renderer;
const Camera = @import("zephrone_runtime").scene.Camera;
const Shader = @import("zephrone_runtime").graphics.Shader;
const Texture = @import("zephrone_runtime").graphics.Texture;
const VBO = @import("zephrone_runtime").graphics.buffer.VertexBuffer;
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
    items: std.ArrayList(Block),

    pub fn init(io: std.Io, allocator: std.mem.Allocator, initial_aspect: f32) !GameScene {
        return GameScene{
            .camera1 = Camera.init(initial_aspect),
            .lamp1 = try Lamp.init(),
            .shader1 = try Shader.init(@embedFile("shaders/lit.vert.glsl"), @embedFile("shaders/lit.frag.glsl")),
            .texture1 = try Texture.init(io, allocator, "../assets/dirt.png", 0),
            .model1 = try Model.load_glb(io, allocator, "../assets/box.glb"),
            .model2 = try Model.load_glb(io, allocator, "../assets/teapot.glb"),
            .items = .empty,
        };
    }

    pub fn deinit(self: *GameScene, allocator: std.mem.Allocator) void {
        self.items.deinit(allocator);
        self.shader1.deinit();
        self.lamp1.deinit();
    }

    pub fn bootstrap(self: *GameScene, allocator: std.mem.Allocator) !void {
        for (0..32) |i| {
            for (0..32) |k| {
                for (0..1) |j| {
                    var block = Block.init();
                    block.transform.position[0] += 2 * (@as(f32, @floatFromInt(i)) - 16);
                    block.transform.position[1] += -2 * (@as(f32, @floatFromInt(j)));
                    block.transform.position[2] += 2 * (@as(f32, @floatFromInt(k)) - 16);
                    try self.items.append(allocator, block);
                }
            }
        }
    }

    pub fn update(self: *GameScene, dt: f32, aspect: f32) void {
        const delta = Input.GetMouseMoveDelta();

        self.camera1.rotateByMouse(delta.x, delta.y);

        const amp: f32 = 8.0;

        if (Input.IsKeyHeld(.w)) self.camera1.moveZ(-amp * dt);
        if (Input.IsKeyHeld(.s)) self.camera1.moveZ(amp * dt);
        if (Input.IsKeyHeld(.a)) self.camera1.moveX(-amp * dt);
        if (Input.IsKeyHeld(.d)) self.camera1.moveX(amp * dt);

        if (Input.IsKeyHeld(.e)) self.camera1.yaw += (amp / 3 * dt);
        if (Input.IsKeyHeld(.q)) self.camera1.yaw += (-amp / 3 * dt);

        if (Input.IsKeyHeld(.left_control)) self.camera1.moveY(-amp * dt);
        if (Input.IsKeyHeld(.space)) self.camera1.moveY(amp * dt);

        self.camera1.updateAspect(aspect);
        self.camera1.updateView();
        self.camera1.updateProjection();

        if (Input.IsKeyHeld(.z)) self.lamp1.transform.position[0] += -amp * dt;
        if (Input.IsKeyHeld(.x)) self.lamp1.transform.position[0] += amp * dt;

        if (Input.IsKeyHeld(.f)) self.lamp1.transform.position[1] += -amp * dt;
        if (Input.IsKeyHeld(.g)) self.lamp1.transform.position[1] += amp * dt;
    }

    pub fn draw(self: *GameScene) void {
        Renderer.clear();

        self.lamp1.mesh.bind();
        self.lamp1.shader.bind();
        self.lamp1.shader.set_mat("u_view", @bitCast(self.camera1.view));
        self.lamp1.shader.set_mat("u_projection", @bitCast(self.camera1.projection));
        self.lamp1.shader.set_mat("u_model", @bitCast(self.lamp1.transform.getModel()));
        self.lamp1.shader.set_vec4("u_light", @bitCast(self.lamp1.light_color));
        Renderer.drawMesh(&self.model1.meshes[0]);

        self.shader1.bind();

        self.shader1.set_mat("u_view", @bitCast(self.camera1.view));
        self.shader1.set_mat("u_projection", @bitCast(self.camera1.projection));

        self.shader1.set_vec4("u_light", @bitCast(self.lamp1.light_color));
        self.shader1.set_vec4("u_light_pos", @bitCast(self.lamp1.transform.position));
        self.shader1.set_vec4("u_camera_pos", @bitCast(self.camera1.position));

        self.texture1.bind();

        for (self.items.items) |*item| {
            self.shader1.set_mat("u_model", @bitCast(item.transform.getModel()));
            Renderer.drawMesh(&self.model1.meshes[0]);
        }
    }
};
