const std = @import("std");
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
