const gl = @import("zopengl").bindings;
const Vertex = @import("vertex_array.zig").Vertex;

pub const VertexBuffer = struct {
    id: u32,

    pub fn init(vertices: []Vertex) VertexBuffer {
        var vbo = VertexBuffer{ .id = 0 };
        gl.genBuffers(1, &vbo.id);
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo.id);
        gl.bufferData(gl.ARRAY_BUFFER, @as(c_int, @intCast(vertices.len * @sizeOf(Vertex))), vertices.ptr, gl.STATIC_DRAW);
        return vbo;
    }

    pub fn deinit(self: *VertexBuffer) void {
        gl.deleteBuffers(1, &self.id);
        self.id = 0;
    }

    pub fn bind(self: VertexBuffer) void {
        gl.bindBuffer(gl.ARRAY_BUFFER, self.id);
    }

    pub fn unbind(self: VertexBuffer) void {
        _ = self;
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    }
};

pub const IndexBuffer = struct {
    id: u32,
    count: usize,

    pub fn init(indices: []const u32) IndexBuffer {
        var ibo = IndexBuffer{ .id = 0, .count = indices.len };

        gl.genBuffers(1, &ibo.id);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo.id);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), indices.ptr, gl.STATIC_DRAW);

        return ibo;
    }

    pub fn deinit(self: *IndexBuffer) void {
        gl.deleteBuffers(1, &self.id);
        self.id = 0;
    }

    pub fn bind(self: IndexBuffer) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }

    pub fn unbind(self: IndexBuffer) void {
        _ = self;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }
};
