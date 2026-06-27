const zm = @import("zmath");
const gl = @import("zopengl").bindings;
const Mesh = @import("mesh.zig").Mesh;
const VertexBuffer = @import("buffer.zig").VertexBuffer;
const RendererContext = @import("./context.zig").RenderContext;
const Transform = @import("../core/transform.zig").Transform;

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

    pub fn drawMeshInstanced(self: *Renderer, mesh: *Mesh, transforms: []Transform) void {
        const count = transforms.len;
        if (count == 0) return;

        mesh.bind();
        mesh.vao.bind();
        self.context.instance_buffer.bind();

        // 1. Setup layout attributes dynamically on the active VAO
        // (This moves the bootstrap code out of your GameScene)
        const loc = 4;
        const stride: isize = @sizeOf([16]f32);
        inline for (0..4) |i| {
            gl.enableVertexAttribArray(loc + i);
            gl.vertexAttribPointer(loc + i, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(@sizeOf([4]f32) * i));
            gl.vertexAttribDivisor(loc + i, 1);
        }

        // 2. Stream the transforms matrix cache efficiently without stack exhaustion
        // Use a lightweight temp loop/buffer or glMapBufferRange if avoiding copying.
        // For simplicity with your current approach, upload matrix array directly if packed.
        // If your Transform has a helper function `getModel()`, map it directly:

        // Mapping directly prevents having to allocate huge stack arrays like models[100000]
        const gpu_ptr = gl.mapBufferRange(gl.ARRAY_BUFFER, 0, @as(isize, @intCast(@sizeOf([16]f32) * count)), gl.MAP_WRITE_BIT | gl.MAP_INVALIDATE_BUFFER_BIT);

        if (gpu_ptr) |ptr| {
            var matrix_slice: [*][16]f32 = @ptrCast(@alignCast(ptr));
            for (transforms, 0..) |*transform, i| {
                matrix_slice[i] = @bitCast(transform.getModel());
            }
            _ = gl.unmapBuffer(gl.ARRAY_BUFFER);
        }

        gl.drawElementsInstanced(
            gl.TRIANGLES,
            mesh.index_count,
            gl.UNSIGNED_INT,
            null,
            @intCast(count),
        );
    }
};
