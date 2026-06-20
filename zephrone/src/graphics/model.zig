const std = @import("std");
const gl = @import("zopengl").bindings;
const buffer_mod = @import("buffer.zig");
const VertexBuffer = buffer_mod.VertexBuffer;
const IndexBuffer = buffer_mod.IndexBuffer;
const va_mod = @import("vertex_array.zig");
const VertexArray = va_mod.VertexArray;
const Vertex = va_mod.Vertex;

// Grab your unmodified Mesh struct
pub const Mesh = @import("mesh.zig").Mesh;

pub const Model = struct {
    meshes: []Mesh,
    allocator: std.mem.Allocator,

    const GltfSchema = struct {
        bufferViews: []struct {
            byteOffset: ?usize = 0,
            byteLength: usize,
        },
        accessors: []struct {
            bufferView: ?usize = null,
            byteOffset: ?usize = 0,
            componentType: u32,
            count: usize,
            type: []const u8,
        },
        meshes: []struct {
            primitives: []struct {
                attributes: struct {
                    POSITION: ?usize = null,
                    NORMAL: ?usize = null,
                    TEXCOORD_0: ?usize = null,
                    COLOR_0: ?usize = null,
                },
                indices: ?usize = null,
            },
        },
    };

    /// Pure, format-agnostic container initialization
    pub fn init(allocator: std.mem.Allocator, meshes: []Mesh) Model {
        return Model{
            .meshes = meshes,
            .allocator = allocator,
        };
    }

    /// Dedicated GLB pipeline handler
    pub fn load_glb(io: std.Io, allocator: std.mem.Allocator, filepath: []const u8) !Model {
        // Match the file-reading signature used by Zig 0.16.0 Io systems
        const file_bytes = try std.Io.Dir.readFileAlloc(
            std.Io.Dir.cwd(),
            io,
            filepath,
            allocator,
            .limited(50 * 1024 * 1024),
        );
        defer allocator.free(file_bytes);

        if (file_bytes.len < 20) return error.InvalidGlbFile;
        if (!std.mem.eql(u8, file_bytes[0..4], "glTF")) return error.NotAGlbFile;

        // Extract JSON chunk details
        const json_len = std.mem.readInt(u32, file_bytes[12..16], .little);
        const json_bytes = file_bytes[20 .. 20 + json_len];

        // Extract Binary chunk details
        const bin_start = 20 + json_len + 8;
        const bin_bytes = file_bytes[bin_start..];

        // Parse JSON hierarchy tree
        var parsed_json = try std.json.parseFromSlice(GltfSchema, allocator, json_bytes, .{ .ignore_unknown_fields = true });
        defer parsed_json.deinit();

        var mesh_list: std.ArrayList(Mesh) = .empty;
        errdefer {
            for (mesh_list.items) |*m| m.deinit();
            mesh_list.deinit(allocator);
        }

        for (parsed_json.value.meshes) |gltf_mesh| {
            for (gltf_mesh.primitives) |primitive| {
                const pos_idx = primitive.attributes.POSITION orelse return error.MissingPositions;
                const idx_idx = primitive.indices orelse return error.MissingIndices;

                // 1. Get raw binary views
                const pos_acc = parsed_json.value.accessors[pos_idx];
                const pos_view = parsed_json.value.bufferViews[pos_acc.bufferView.?];
                const pos_offset = (pos_view.byteOffset orelse 0) + (pos_acc.byteOffset orelse 0);
                const raw_positions = std.mem.bytesAsSlice([3]f32, bin_bytes[pos_offset .. pos_offset + (pos_acc.count * 12)]);

                // 2. Extract Indices and normalize to u32 slice for your Mesh.init
                const idx_acc = parsed_json.value.accessors[idx_idx];
                const idx_view = parsed_json.value.bufferViews[idx_acc.bufferView.?];
                const idx_offset = (idx_view.byteOffset orelse 0) + (idx_acc.byteOffset orelse 0);

                var parsed_indices = try allocator.alloc(u32, idx_acc.count);
                defer allocator.free(parsed_indices);

                if (idx_acc.componentType == 5123) { // GL_UNSIGNED_SHORT
                    const raw_shorts = std.mem.bytesAsSlice(u16, bin_bytes[idx_offset .. idx_offset + (idx_acc.count * 2)]);
                    for (raw_shorts, 0..) |s, i| parsed_indices[i] = @intCast(s);
                } else if (idx_acc.componentType == 5125) { // GL_UNSIGNED_INT
                    const raw_ints = std.mem.bytesAsSlice(u32, bin_bytes[idx_offset .. idx_offset + (idx_acc.count * 4)]);
                    @memcpy(parsed_indices, raw_ints);
                } else return error.UnsupportedIndexType;

                // 3. Assemble vertices into your engine's exact Vertex layout
                var parsed_vertices = try allocator.alloc(Vertex, pos_acc.count);
                defer allocator.free(parsed_vertices);

                const raw_normals = if (primitive.attributes.NORMAL) |norm_idx| blk: {
                    const norm_acc = parsed_json.value.accessors[norm_idx];
                    const norm_view = parsed_json.value.bufferViews[norm_acc.bufferView.?];
                    const norm_offset = (norm_view.byteOffset orelse 0) + (norm_acc.byteOffset orelse 0);
                    break :blk std.mem.bytesAsSlice([3]f32, bin_bytes[norm_offset .. norm_offset + (norm_acc.count * 12)]);
                } else null;

                const raw_uvs = if (primitive.attributes.TEXCOORD_0) |uv_idx| blk: {
                    const uv_acc = parsed_json.value.accessors[uv_idx];
                    const uv_view = parsed_json.value.bufferViews[uv_acc.bufferView.?];
                    const uv_offset = (uv_view.byteOffset orelse 0) + (uv_acc.byteOffset orelse 0);
                    break :blk std.mem.bytesAsSlice([2]f32, bin_bytes[uv_offset .. uv_offset + (uv_acc.count * 8)]);
                } else null;

                const raw_colors = if (primitive.attributes.COLOR_0) |col_idx| blk: {
                    const col_acc = parsed_json.value.accessors[col_idx];
                    const col_view = parsed_json.value.bufferViews[col_acc.bufferView.?];
                    const col_offset = (col_view.byteOffset orelse 0) + (col_acc.byteOffset orelse 0);
                    break :blk std.mem.bytesAsSlice([4]f32, bin_bytes[col_offset .. col_offset + (col_acc.count * 16)]);
                } else null;

                for (0..pos_acc.count) |i| {
                    parsed_vertices[i] = .{
                        .position = raw_positions[i],
                        .color = if (raw_colors) |c| c[i] else [4]f32{ 1.0, 1.0, 1.0, 1.0 },
                        .texture_coords = if (raw_uvs) |u| u[i] else [2]f32{ 0.0, 0.0 },
                        .normals = if (raw_normals) |n| n[i] else [3]f32{ 0.0, 1.0, 0.0 },
                    };
                }

                const mesh_obj = Mesh.init(parsed_vertices, parsed_indices);
                try mesh_list.append(allocator, mesh_obj);
            }
        }

        const final_meshes = try mesh_list.toOwnedSlice(allocator);
        return Model.init(allocator, final_meshes);
    }

    pub fn deinit(self: *Model, allocator: std.mem.Allocator) void {
        for (self.meshes) |mesh| {
            var mutable_mesh = mesh;
            mutable_mesh.deinit();
        }
        if (self.meshes.len != 0) {
            allocator.free(self.meshes);
            self.meshes = &[_]Mesh{};
        }
    }

    pub fn draw(self: Model) void {
        for (self.meshes) |mesh| {
            mesh.bind();
            gl.drawElements(gl.TRIANGLES, mesh.index_count, gl.UNSIGNED_INT, null);
            mesh.unbind();
        }
    }
};
