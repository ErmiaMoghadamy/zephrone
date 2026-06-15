const gl = @import("zopengl").bindings;
const Mesh = @import("mesh.zig").Mesh;

pub const Renderer = struct {
    pub fn init() !Renderer {
        return Renderer{};
    }

    pub fn deinit(self: *Renderer) void {
        _ = self;
    }

    pub fn clear() void {
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }

    pub fn drawMesh(mesh: *Mesh) void {
        mesh.bind();
        gl.drawElements(gl.TRIANGLES, mesh.index_count, gl.UNSIGNED_INT, null);
    }
};
