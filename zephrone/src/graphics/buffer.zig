const gl = @import("zopengl").bindings;

pub const Vertex = struct {
    position: [3]f32,
    color: [4]f32,
    texture_coords: [2]f32,
    normals: [3]f32,
};

pub const VertexArray = struct {
    id: u32,

    pub fn init() VertexArray {
        var vao = VertexArray{ .id = 0 };

        gl.genVertexArrays(1, &vao.id);
        gl.bindVertexArray(vao.id);

        vao.setup_layout();

        return vao;
    }

    pub fn deinit(self: *VertexArray) void {
        gl.deleteVertexArrays(1, &self.id);
        self.id = 0;
    }

    pub fn setup_layout(self: *VertexArray) void {
        const strides: c_int = @sizeOf(Vertex);

        gl.bindVertexArray(self.id);

        gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, strides, @ptrFromInt(0));
        gl.enableVertexAttribArray(0);

        gl.vertexAttribPointer(1, 4, gl.FLOAT, gl.FALSE, strides, @ptrFromInt(@offsetOf(Vertex, "color")));
        gl.enableVertexAttribArray(1);

        gl.vertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, strides, @ptrFromInt(@offsetOf(Vertex, "texture_coords")));
        gl.enableVertexAttribArray(2);

        gl.vertexAttribPointer(3, 3, gl.FLOAT, gl.FALSE, strides, @ptrFromInt(@offsetOf(Vertex, "normals")));
        gl.enableVertexAttribArray(3);
    }

    pub fn bind(self: VertexArray) void {
        gl.bindVertexArray(self.id);
    }

    pub fn unbind(self: VertexArray) void {
        _ = self;
        gl.bindVertexArray(0);
    }
};

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
