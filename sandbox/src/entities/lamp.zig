const zm = @import("zephrone_runtime").zmath;
const Transform = @import("zephrone_runtime").core.Transform;
const Shader = @import("zephrone_runtime").graphics.Shader;
const Mesh = @import("zephrone_runtime").graphics.Mesh;
const Camera = @import("zephrone_runtime").scene.Camera;
const BlockMesh = @import("block.zig").BlockMesh;

pub const Lamp = struct {
    light_color: zm.Vec,
    shader: Shader,
    transform: Transform,
    mesh: Mesh,

    pub fn init() !Lamp {
        var transform = Transform.init();
        transform.position[1] = 5.0;

        return Lamp{
            .light_color = zm.f32x4(1.0, 1.0, 1.0, 1.0),
            .mesh = BlockMesh.init().mesh,
            .shader = try Shader.init(@embedFile("../shaders/lamp.vert.glsl"), @embedFile("../shaders/lamp.frag.glsl")),
            .transform = transform,
        };
    }

    pub fn deinit(self: *Lamp) void {
        self.mesh.deinit();
        self.shader.deinit();
    }

    pub fn bind(self: *Lamp) void {
        self.shader.bind();
        self.shader.set_mat("u_model", @bitCast(self.transform.getModel()));
    }

    pub fn bindToCamera(self: *Lamp, camera: *Camera) void {
        self.shader.bind();
        self.shader.set_mat("u_model", @bitCast(self.transform.getModel()));
        self.shader.set_mat("u_view", @bitCast(camera.view));
        self.shader.set_mat("u_projection", @bitCast(camera.projection));
        self.shader.set_vec4("u_light", self.light_color);
    }
};
