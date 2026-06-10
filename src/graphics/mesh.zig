const gl = @import("zopengl").bindings;
const VertexBuffer = @import("buffer.zig").VertexBuffer;
const IndexBuffer = @import("buffer.zig").IndexBuffer;
const VertexArray = @import("vertex_array.zig").VertexArray;
const Vertex = @import("vertex_array.zig").Vertex;

pub const Mesh = struct {
    vbo: VertexBuffer,
    ebo: IndexBuffer,
    vao: VertexArray,
    index_count: c_int,

    pub fn init(vertices: []Vertex, indices: []const u32) Mesh {
        return Mesh{
            .vbo = VertexBuffer.init(vertices),
            .ebo = IndexBuffer.init(indices),
            .vao = VertexArray.init(),
            .index_count = @intCast(indices.len),
        };
    }

    pub fn deinit(self: *Mesh) void {
        self.vao.deinit();
        self.vbo.deinit();
        self.ebo.deinit();
    }

    pub fn bind(self: Mesh) void {
        self.vao.bind();
        self.ebo.bind();
    }

    pub fn unbind(self: Mesh) void {
        self.vao.unbind();
        self.ebo.unbind();
    }
};
