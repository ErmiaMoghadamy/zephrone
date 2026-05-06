const std = @import("std");
const zm = @import("zmath");
const Mesh = @import("../graphics/mesh.zig").Mesh;
const Shader = @import("../graphics/shader.zig").Shader;
const Renderer = @import("../graphics/renderer.zig").Renderer;
const Texture = @import("../graphics/texture.zig").Texture;
const Transform = @import("../graphics/transform.zig").Transform;
const RenderContext = @import("../graphics/render_context.zig").RenderContext;

pub const Cube = struct {
    mesh: Mesh,
    shader: *Shader,
    texture: *Texture,
    transform: Transform,

    pub fn init(texture: *Texture, shader: *Shader) !Cube {
        const vertices = [_]f32{
            -0.5, -0.5, 0.5,  0.0, 0.0,
            0.5,  -0.5, 0.5,  1.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            -0.5, 0.5,  0.5,  0.0, 1.0,
            -0.5, -0.5, -0.5, 1.0, 0.0,
            -0.5, 0.5,  -0.5, 1.0, 1.0,
            0.5,  0.5,  -0.5, 0.0, 1.0,
            0.5,  -0.5, -0.5, 0.0, 0.0,
            -0.5, -0.5, -0.5, 0.0, 0.0,
            -0.5, -0.5, 0.5,  1.0, 0.0,
            -0.5, 0.5,  0.5,  1.0, 1.0,
            -0.5, 0.5,  -0.5, 0.0, 1.0,
            0.5,  -0.5, -0.5, 1.0, 0.0,
            0.5,  0.5,  -0.5, 1.0, 1.0,
            0.5,  0.5,  0.5,  0.0, 1.0,
            0.5,  -0.5, 0.5,  0.0, 0.0,
            -0.5, -0.5, -0.5, 0.0, 1.0,
            0.5,  -0.5, -0.5, 1.0, 1.0,
            0.5,  -0.5, 0.5,  1.0, 0.0,
            -0.5, -0.5, 0.5,  0.0, 0.0,
            -0.5, 0.5,  -0.5, 0.0, 0.0,
            -0.5, 0.5,  0.5,  0.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            0.5,  0.5,  -0.5, 1.0, 0.0,
        };

        const indices = [_]u32{
            0,  1,  2,  2,  3,  0,
            4,  5,  6,  6,  7,  4,
            8,  9,  10, 10, 11, 8,
            12, 13, 14, 14, 15, 12,
            16, 17, 18, 18, 19, 16,
            20, 21, 22, 22, 23, 20,
        };

        const layout = [_]u32{ 3, 2 };

        return Cube{
            .transform = Transform.init(),
            .mesh = Mesh.init(&vertices, &indices, &layout),
            .shader = shader,
            .texture = texture,
        };
    }

    pub fn deinit(self: *Cube) void {
        self.mesh.deinit();
    }

    pub fn getModel(self: Cube) zm.Mat {
        return self.transform.matrix();
    }

    pub fn update(self: *Cube, dt: f64) void {
        _ = self;
        _ = dt;
    }

    pub fn draw(self: *Cube, renderer: *Renderer, context: RenderContext) void {
        self.shader.bind();
        self.texture.bind();
        self.mesh.bind();

        self.shader.use_texture(self.texture.slot);

        context.applyTransform(self.shader, self.getModel());
        renderer.drawMesh(&self.mesh);
    }
};
