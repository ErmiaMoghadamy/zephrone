const Mesh = @import("../graphics/mesh.zig").Mesh;
const Vertex = @import("../graphics/vertex_array.zig").Vertex;

pub const BlockMesh = struct {
    mesh: Mesh,

    pub fn init() BlockMesh {
        var vertices: [24]Vertex = comptime blk: {
            const w: f32 = 3.0; // 6.0/2
            const h: f32 = 0.5; // 1.0/2
            const d: f32 = 3.0; // 6.0/2
            const tileXZ: f32 = 3.0;
            const tileY: f32 = 0.5;

            break :blk .{
                // --- TOP FACE ---
                .{ .position = .{ -w, h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, tileXZ }, .normals = .{ 0, 1, 0 } },
                .{ .position = .{ -w, h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0, 1, 0 } },
                .{ .position = .{ w, h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, 0.0 }, .normals = .{ 0, 1, 0 } },
                .{ .position = .{ w, h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, tileXZ }, .normals = .{ 0, 1, 0 } },

                // --- FRONT FACE ---
                .{ .position = .{ -w, -h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0, 0, 1 } },
                .{ .position = .{ w, -h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, 0.0 }, .normals = .{ 0, 0, 1 } },
                .{ .position = .{ w, h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, tileY }, .normals = .{ 0, 0, 1 } },
                .{ .position = .{ -w, h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, tileY }, .normals = .{ 0, 0, 1 } },

                // --- BACK FACE ---
                .{ .position = .{ -w, -h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, 0.0 }, .normals = .{ 0, 0, -1 } },
                .{ .position = .{ -w, h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, tileY }, .normals = .{ 0, 0, -1 } },
                .{ .position = .{ w, h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, tileY }, .normals = .{ 0, 0, -1 } },
                .{ .position = .{ w, -h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0, 0, -1 } },

                // --- LEFT FACE ---
                .{ .position = .{ -w, -h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ -1, 0, 0 } },
                .{ .position = .{ -w, -h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, 0.0 }, .normals = .{ -1, 0, 0 } },
                .{ .position = .{ -w, h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, tileY }, .normals = .{ -1, 0, 0 } },
                .{ .position = .{ -w, h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, tileY }, .normals = .{ -1, 0, 0 } },

                // --- RIGHT FACE ---
                .{ .position = .{ w, -h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, 0.0 }, .normals = .{ 1, 0, 0 } },
                .{ .position = .{ w, h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, tileY }, .normals = .{ 1, 0, 0 } },
                .{ .position = .{ w, h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, tileY }, .normals = .{ 1, 0, 0 } },
                .{ .position = .{ w, -h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 1, 0, 0 } },

                // --- BOTTOM FACE ---
                .{ .position = .{ -w, -h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, tileXZ }, .normals = .{ 0, -1, 0 } },
                .{ .position = .{ w, -h, -d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, tileXZ }, .normals = .{ 0, -1, 0 } },
                .{ .position = .{ w, -h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ tileXZ, 0.0 }, .normals = .{ 0, -1, 0 } },
                .{ .position = .{ -w, -h, d }, .color = .{ 1, 1, 1, 1 }, .texture_coords = .{ 0.0, 0.0 }, .normals = .{ 0, -1, 0 } },
            };
        };

        const indices = comptime blk: {
            var list: [36]u32 = undefined;
            for (0..6) |face| {
                const base = @as(u32, @intCast(face * 4));
                list[face * 6 + 0] = base + 0;
                list[face * 6 + 1] = base + 1;
                list[face * 6 + 2] = base + 2;
                list[face * 6 + 3] = base + 2;
                list[face * 6 + 4] = base + 3;
                list[face * 6 + 5] = base + 0;
            }
            break :blk list;
        };

        return BlockMesh{
            .mesh = Mesh.init(&vertices, &indices),
        };
    }
};
