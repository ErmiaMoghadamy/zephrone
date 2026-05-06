const zm = @import("zmath");
const Shader = @import("../graphics/shader.zig").Shader;
const Mesh = @import("../graphics/mesh.zig").Mesh;
const Transform = @import("../graphics/transform.zig").Transform;
const Camera = @import("../core/camera.zig").Camera;

pub const Object = struct {
    transform: Transform,

    pub fn init() !Object {
        return Object{
            .transform = Transform.init(),
        };
    }

    pub fn deinit(self: *Object) void {
        _ = self;
    }

    pub fn update(self: *Object) !void {
        _ = self;
    }

    pub fn moveZ(self: *Object, camera: *Camera) void {
        const UP = zm.f32x4(0.0, 1.0, 0.0, 0.0);
        // Camera forward
        const forward = zm.normalize3(camera.target - camera.position);

        // Build a "level" forward (projected onto XZ plane) using cross products
        const right = zm.normalize3(zm.cross3(forward, UP));
        const forward_level = zm.normalize3(zm.cross3(UP, right));

        // Desired offset: 2 blocks forward, 1 block down
        const offset = forward_level * @as(zm.Vec, @splat(3.0)) + UP * @as(zm.Vec, @splat(-2.0));

        // Stick cube to that position relative to the camera
        self.transform.position = camera.position + offset;
    }
};
