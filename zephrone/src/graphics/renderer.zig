const zm = @import("zmath");
const gl = @import("zopengl").bindings;
const Mesh = @import("mesh.zig").Mesh;
const VertexBuffer = @import("buffer.zig").VertexBuffer;
const RendererContext = @import("./context.zig").RenderContext;

pub const Renderer = struct {
    context: RendererContext,

    pub fn init() Renderer {
        return Renderer{
            .context = RendererContext.init(),
        };
    }

    pub fn deinit(self: *Renderer) void {
        self.context.deinit();
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
