const std = @import("std");
const zm = @import("zephrone_runtime").zmath;
const Input = @import("zephrone_runtime").Input;
const Renderer = @import("zephrone_runtime").Renderer;
const Camera = @import("zephrone_runtime").Camera;
const Shader = @import("zephrone_runtime").Shader;
const Texture = @import("zephrone_runtime").Texture;
const Lamp = @import("entities/lamp.zig").Lamp;
const BlockMesh = @import("entities/block.zig").BlockMesh;

pub const GameScene = struct {
    mesh1: BlockMesh,
    shader1: Shader,
    texture1: Texture,
    lamp1: Lamp,
    camera1: Camera,

    pub fn init(io: std.Io, allocator: std.mem.Allocator, initial_aspect: f32) !GameScene {
        return GameScene{
            .camera1 = Camera.init(initial_aspect),
            .mesh1 = BlockMesh.init(),
            .shader1 = try Shader.init(@embedFile("shaders/lit.vert.glsl"), @embedFile("shaders/lit.frag.glsl")),
            .texture1 = try Texture.init(io, allocator, "../assets/floor.png", 0),
            .lamp1 = try Lamp.init(),
        };
    }

    pub fn deinit(self: *GameScene) void {
        self.shader1.deinit();
        self.mesh1.mesh.deinit();
        self.lamp1.deinit();
    }

    pub fn update(self: *GameScene, dt: f32, aspect: f32) void {
        const amp: f32 = 8.0;

        if (Input.IsKeyHeld(.w)) self.camera1.moveZ(-amp * dt);
        if (Input.IsKeyHeld(.s)) self.camera1.moveZ(amp * dt);

        if (Input.IsKeyHeld(.a)) self.camera1.moveX(-amp * dt);
        if (Input.IsKeyHeld(.d)) self.camera1.moveX(amp * dt);

        self.camera1.updateAspect(aspect);
        self.camera1.updateView();
        self.camera1.updateProjection();
    }

    pub fn draw(self: *GameScene) void {
        Renderer.clear();

        self.lamp1.mesh.bind();
        self.lamp1.shader.bind();
        self.lamp1.shader.set_mat("u_view", @bitCast(self.camera1.view));
        self.lamp1.shader.set_mat("u_projection", @bitCast(self.camera1.projection));
        self.lamp1.shader.set_mat("u_model", @bitCast(self.lamp1.transform.getModel()));
        self.lamp1.shader.set_vec4("u_light", @bitCast(self.lamp1.light_color));
        Renderer.drawMesh(&self.lamp1.mesh);


        self.shader1.bind();

        self.shader1.set_mat("u_view", @bitCast(self.camera1.view));
        self.shader1.set_mat("u_projection", @bitCast(self.camera1.projection));
        self.shader1.set_mat("u_model", @bitCast(zm.identity()));

        self.shader1.set_vec4("u_light", @bitCast(self.lamp1.light_color));
        self.shader1.set_vec4("u_light_pos", @bitCast(self.lamp1.transform.position));
        self.shader1.set_vec4("u_camera_pos", @bitCast(self.camera1.position));

        self.texture1.bind();


        self.mesh1.mesh.bind();
        Renderer.drawMesh(&self.mesh1.mesh);
    }
};
