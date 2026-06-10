const Mesh = @import("../graphics/mesh.zig").Mesh;
const Vertex = @import("../graphics/vertex_array.zig").Vertex;

pub const BlockMesh = struct {
    mesh: Mesh,

    pub fn init() BlockMesh {
        var vertices = [_]Vertex{
            // 0..3  front (0,0,1)
            Vertex{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0.0, 0.0, 1.0 } },
            Vertex{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 0.0 }, .normals = .{ 0.0, 0.0, 1.0 } },
            Vertex{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 1.0 }, .normals = .{ 0.0, 0.0, 1.0 } },
            Vertex{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 1.0 }, .normals = .{ 0.0, 0.0, 1.0 } },

            // 4..7  back (0,0,-1)
            Vertex{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 1.0 }, .normals = .{ 0.0, 0.0, -1.0 } },
            Vertex{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 1.0 }, .normals = .{ 0.0, 0.0, -1.0 } },
            Vertex{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0.0, 0.0, -1.0 } },
            Vertex{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 0.0 }, .normals = .{ 0.0, 0.0, -1.0 } },

            // 8..11 left (-1,0,0)
            Vertex{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ -1.0, 0.0, 0.0 } },
            Vertex{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 0.0 }, .normals = .{ -1.0, 0.0, 0.0 } },
            Vertex{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 1.0 }, .normals = .{ -1.0, 0.0, 0.0 } },
            Vertex{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 1.0 }, .normals = .{ -1.0, 0.0, 0.0 } },

            // 12..15 right (1,0,0)
            Vertex{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 0.0 }, .normals = .{ 1.0, 0.0, 0.0 } },
            Vertex{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 1.0 }, .normals = .{ 1.0, 0.0, 0.0 } },
            Vertex{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 1.0 }, .normals = .{ 1.0, 0.0, 0.0 } },
            Vertex{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 1.0, 0.0, 0.0 } },

            // 16..19 bottom (0,-1,0)
            Vertex{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 1.0 }, .normals = .{ 0.0, -1.0, 0.0 } },
            Vertex{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 1.0 }, .normals = .{ 0.0, -1.0, 0.0 } },
            Vertex{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 0.0 }, .normals = .{ 0.0, -1.0, 0.0 } },
            Vertex{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0.0, -1.0, 0.0 } },

            // 20..23 top (0,1,0)
            Vertex{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0.0, 1.0, 0.0 } },
            Vertex{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 0.0, 1.0 }, .normals = .{ 0.0, 1.0, 0.0 } },
            Vertex{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 1.0 }, .normals = .{ 0.0, 1.0, 0.0 } },
            Vertex{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0, 0, 0, 0 }, .texture_coords = .{ 1.0, 0.0 }, .normals = .{ 0.0, 1.0, 0.0 } },
        };

        const indices = [_]u32{
            0,  1,  2,  2,  3,  0,
            4,  5,  6,  6,  7,  4,
            8,  9,  10, 10, 11, 8,
            12, 13, 14, 14, 15, 12,
            16, 17, 18, 18, 19, 16,
            20, 21, 22, 22, 23, 20,
        };

        return BlockMesh{
            .mesh = Mesh.init(&vertices, &indices),
        };
    }
};
