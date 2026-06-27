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
    items: std.ArrayList(Block),
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
        const loc = 4;

        self.model1.meshes[0].bind();
        self.model1.meshes[0].vao.bind();
        self.instance_vbo.bind();

        const stride: isize = @sizeOf([16]f32);

        // column 0
        gl.enableVertexAttribArray(loc + 0);
        gl.vertexAttribPointer(loc + 0, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(0));
        gl.vertexAttribDivisor(loc + 0, 1);

        // column 1
        gl.enableVertexAttribArray(loc + 1);
        gl.vertexAttribPointer(loc + 1, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(@sizeOf([4]f32)));
        gl.vertexAttribDivisor(loc + 1, 1);

        // column 2
        gl.enableVertexAttribArray(loc + 2);
        gl.vertexAttribPointer(loc + 2, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(@sizeOf([8]f32)));
        gl.vertexAttribDivisor(loc + 2, 1);

        // column 3
        gl.enableVertexAttribArray(loc + 3);
        gl.vertexAttribPointer(loc + 3, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(@sizeOf([12]f32)));
        gl.vertexAttribDivisor(loc + 3, 1);

        const max_instances = 100000;
        gl.bufferData(
            gl.ARRAY_BUFFER,
            @sizeOf([16]f32) * max_instances,
            null,
            gl.DYNAMIC_DRAW
        );

        for (0..32) |i| {
            for (0..64) |k| {
                for (0..18) |j| {
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

    pub fn draw(self: *GameScene, _: *Renderer) void {
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


        var models: [100000][16]f32 = undefined;

        const count = self.items.items.len;

        for (self.items.items, 0..) |*item, i| {
            models[i] = @bitCast(item.transform.getModel());
        }

        self.instance_vbo.bind();


        gl.bufferSubData(
            gl.ARRAY_BUFFER,
            0,
            @as(isize, @intCast(@sizeOf([16]f32) * count)),
            @ptrCast(&models[0]),
        );

        self.model1.meshes[0].bind();
        self.shader1.bind();

        gl.drawElementsInstanced(
            gl.TRIANGLES,
            self.model1.meshes[0].index_count,
            gl.UNSIGNED_INT,
            null,
            @intCast(count),
        );

    }
};
