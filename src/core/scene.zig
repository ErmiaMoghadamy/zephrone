const glfw = @import("zglfw");
const std = @import("std");
const zm = @import("zmath");
const gl = @import("zopengl").bindings;
const Object = @import("../objects/object.zig").Object;
const BlockMesh = @import("../objects/block_mesh.zig").BlockMesh;
const Renderer = @import("../core/renderer.zig").Renderer;
const Camera = @import("../core/camera.zig").Camera;
const Shader = @import("../graphics/shader.zig").Shader;
const Mesh = @import("../graphics/mesh.zig").Mesh;
const Texture = @import("../graphics/texture.zig").Texture;
const Lamp = @import("../objects/lamp.zig").Lamp;

pub const Scene = struct {
    allocator: std.mem.Allocator,
    camera: Camera,
    objects: std.ArrayList(Object),
    cmesh: Mesh,
    ctex: Texture,
    shader: Shader,

    lamp: Lamp,

    pub fn init(allocator: std.mem.Allocator, initial_aspect: f32) !Scene {
        return Scene{
            .allocator = allocator,
            .camera = Camera.init(initial_aspect),
            .objects = try std.ArrayList(Object).initCapacity(allocator, 0),
            .cmesh = BlockMesh.init().mesh,

            .ctex = try Texture.init(allocator, "assets/diamond.png", 1),
            .shader = try Shader.init(@embedFile("../shaders/block.vert.glsl"), @embedFile("../shaders/block.frag.glsl")),

            .lamp = try Lamp.init(),
        };
    }

    pub fn deinit(self: *Scene) void {
        self.ctex.deinit();
        self.shader.deinit();
        self.cmesh.deinit();
        self.lamp.deinit();

        for (self.objects.items) |*object| {
            object.deinit();
        }

        self.objects.deinit(self.allocator);
    }

    pub fn bootstrap(self: *Scene) !void {
        for (0..8) |i| {
            for (0..8) |j| {
                var object = try Object.init();

                object.transform.position[0] = (@as(f32, @floatFromInt(i)) - 4) * 4;
                object.transform.position[2] = (@as(f32, @floatFromInt(j)) - 4) * 4;
                // object.transform.rotation[2] = 0.96;
                // object.transform.rotation[0] = 0.96;

                try self.objects.append(self.allocator, object);
            }
        }

        for (0..32) |i| {
            for (0..32) |j| {
                var object = try Object.init();
                object.transform.position[0] = @as(f32, @floatFromInt(i)) - 16;
                object.transform.position[1] = -1.0;
                object.transform.position[2] = @as(f32, @floatFromInt(j)) - 16;

                try self.objects.append(self.allocator, object);
            }
        }
    }

    pub fn update(self: *Scene) !void {
        _ = self;
    }

    pub fn draw(self: *Scene) !void {
        Renderer.clearScreen();

        self.lamp.bindToCamera(&self.camera);

        Renderer.drawMesh(&self.lamp.mesh, &self.lamp.shader);

        if (self.objects.items.len == 0) {
            return;
        }

        self.ctex.bind();
        self.shader.bind();
        self.shader.set_int("u_texture", self.ctex.slot);
        self.shader.set_vec4("u_light", @bitCast(self.lamp.light_color));
        self.shader.set_vec4("u_light_pos", @bitCast(self.lamp.transform.position));
        self.shader.set_vec4("u_camera_pos", @bitCast(self.camera.position));

        for (self.objects.items) |object| {
            self.shader.set_mat("u_model", @bitCast(object.transform.getModel()));
            self.shader.set_mat("u_view", @bitCast(self.camera.view));
            self.shader.set_mat("u_projection", @bitCast(self.camera.projection));

            Renderer.drawMesh(&self.cmesh, &self.shader);
        }
    }

    pub fn run(self: *Scene) !void {
        try self.update();
        try self.draw();
    }

    pub fn addCube(self: *Scene) !void {
        const X: f32 = @as(f32, @floatFromInt(@mod(std.crypto.random.int(i32), 32))) - 16;
        const Z: f32 = @as(f32, @floatFromInt(@mod(std.crypto.random.int(i32), 32))) - 16;

        for (self.objects.items) |object| {
            if (object.transform.position[0] == X and object.transform.position[2] == Z) {
                return;
            }
        }

        var object = try Object.init();
        object.transform.position = .{ X, 0.0, Z, 1.0 };
        try self.objects.append(self.allocator, object);
    }

    pub fn handleControls(self: *Scene, window: *glfw.Window) !void {
        const amp: f32 = 1.4;

        if (window.getKey(.e) == .press) {
            self.lamp.transform.position[2] += 0.08 * amp;
            self.lamp.transform.position[0] += 0.08 * amp;
        }

        if (window.getKey(.q) == .press) {
            self.lamp.transform.position[2] -= 0.08 * amp;
            self.lamp.transform.position[0] -= 0.08 * amp;
        }

        if (window.getKey(.z) == .press) {
            self.lamp.transform.position[1] += 0.08 * amp;
        }

        if (window.getKey(.x) == .press) {
            self.lamp.transform.position[1] -= 0.08 * amp;
        }

        if (window.getKey(.w) == .press) {
            self.camera.moveZ(-0.08 * amp);
        }

        if (window.getKey(.s) == .press) {
            self.camera.moveZ(0.08 * amp);
        }

        if (window.getKey(.a) == .press) {
            self.camera.moveX(-0.08 * amp);
        }

        if (window.getKey(.d) == .press) {
            self.camera.moveX(0.08 * amp);
        }

        if (window.getKey(.space) == .press) {
            self.camera.moveY(0.06 * amp);
        }

        if (window.getKey(.left_control) == .press) {
            self.camera.moveY(-0.06 * amp);
        }

        if (window.getKey(.g) == .press) {
            try self.addCube();
        }

        if (window.getKey(.h) == .press) {
            _ = self.objects.pop();
        }
    }
};
