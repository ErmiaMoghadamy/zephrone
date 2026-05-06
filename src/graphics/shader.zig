const std = @import("std");
const gl = @import("zopengl").bindings;

pub const ShaderError = error{
    VertexShaderCreationFailed,
    FragmentShaderCreationFailed,
    VertexShaderCompilationFailed,
    FragmentShaderCompilationFailed,
    ProgramCreationFailed,
    ProgramLinkingFailed,
    OpenGlError,
};

pub const Shader = struct {
    id: u32,
    uniform_cache: std.StringHashMap(i32),

    pub fn init(vs_src: [*c]const u8, fs_src: [*c]const u8) ShaderError!Shader {
        const vs = gl.createShader(gl.VERTEX_SHADER);
        if (vs == 0) {
            return error.VertexShaderCreationFailed;
        }
        errdefer gl.deleteShader(vs);

        gl.shaderSource(vs, 1, &vs_src, null);
        gl.compileShader(vs);

        var vs_success: i32 = 0;
        gl.getShaderiv(vs, gl.COMPILE_STATUS, &vs_success);
        if (vs_success == 0) {
            var info_log: [1024]u8 = undefined;
            var log_len: gl.Sizei = 0;

            gl.getShaderInfoLog(vs, info_log.len, &log_len, &info_log[0]);
            std.debug.print("Vertex Shader Compilation Error: {s}\n", .{info_log[0..@intCast(log_len)]});

            return error.VertexShaderCompilationFailed;
        }

        const fs = gl.createShader(gl.FRAGMENT_SHADER);
        if (fs == 0) {
            return error.FragmentShaderCreationFailed;
        }
        errdefer gl.deleteShader(fs);

        gl.shaderSource(fs, 1, &fs_src, null);
        gl.compileShader(fs);

        var fs_success: i32 = 0;
        gl.getShaderiv(fs, gl.COMPILE_STATUS, &fs_success);
        if (fs_success == 0) {
            var info_log: [1024]u8 = undefined;
            var log_len: gl.Sizei = 0;
            gl.getShaderInfoLog(fs, info_log.len, &log_len, &info_log[0]);
            std.debug.print("Fragment shader error:\n{s}\n", .{info_log[0..@intCast(log_len)]});
            return error.FragmentShaderCompilationFailed;
        }

        const id = gl.createProgram();

        if (id == 0) {
            return error.ProgramCreationFailed;
        }
        errdefer gl.deleteProgram(id);

        gl.attachShader(id, vs);
        gl.attachShader(id, fs);

        gl.linkProgram(id);

        var link_success: i32 = 0;
        gl.getProgramiv(id, gl.LINK_STATUS, &link_success);
        if (link_success == 0) {
            var info_log: [1024]u8 = undefined;
            var log_len: gl.Sizei = 0;
            gl.getProgramInfoLog(id, info_log.len, &log_len, &info_log[0]);
            std.debug.print("Program Linking Error: {s}\n", .{info_log[0..@intCast(log_len)]});
            return ShaderError.ProgramLinkingFailed;
        }

        gl.deleteShader(vs);
        gl.deleteShader(fs);

        return Shader{
            .id = id,
            .uniform_cache = std.StringHashMap(i32).init(std.heap.page_allocator),
        };
    }

    pub fn deinit(self: *Shader) void {
        self.uniform_cache.deinit();
        gl.deleteProgram(self.id);
        self.id = 0;
    }

    pub fn getUniformLoc(self: *Shader, name: [:0]const u8) i32 {
        if (self.uniform_cache.get(name)) |loc| {
            return loc;
        }

        const location = gl.getUniformLocation(self.id, name.ptr);
        self.uniform_cache.put(name, location) catch unreachable;
        return location;
    }

    pub fn set_vec3(self: Shader, name: [:0]const u8, vec: [3]f32) void {
        self.bind();

        const location = gl.getUniformLocation(self.id, name.ptr);

        gl.uniform3fv(location, 1, &vec);
    }

    pub fn set_vec4(self: Shader, name: [:0]const u8, vec: [4]f32) void {
        self.bind();

        const location = gl.getUniformLocation(self.id, name.ptr);

        gl.uniform4fv(location, 1, &vec);
    }

    pub fn set_mat(self: Shader, name: [:0]const u8, mat: [16]f32) void {
        self.bind();

        const location = gl.getUniformLocation(self.id, name.ptr);

        gl.uniformMatrix4fv(location, 1, 0, &mat);
    }

    pub fn set_int(self: Shader, name: [:0]const u8, value: i32) void {
        self.bind();

        const location = gl.getUniformLocation(self.id, name.ptr);

        gl.uniform1i(location, value);
    }

    pub fn bind(self: Shader) void {
        gl.useProgram(self.id);
    }

    pub fn unbind(self: Shader) void {
        _ = self;
        gl.useProgram(0);
    }
};
