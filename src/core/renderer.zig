const gl = @import("zopengl").bindings;
const Mesh = @import("../graphics/mesh.zig").Mesh;
const Shader = @import("../graphics/shader.zig").Shader;

pub const Renderer = struct {
    pub fn init() Renderer {
        return Renderer{};
    }

    pub fn clearScreen() void {
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }

    pub fn drawMesh(mesh: *Mesh, shader: *Shader) void {
        mesh.bind();
        shader.bind();
        gl.drawElements(gl.TRIANGLES, mesh.index_count, gl.UNSIGNED_INT, null);
    }
};
