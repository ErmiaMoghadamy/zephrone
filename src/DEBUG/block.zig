const Mesh = @import("../graphics/mesh.zig").Mesh;
const Vertex = @import("../graphics/buffer.zig").Vertex;

pub const BlockMesh = struct {
    mesh: Mesh,

    pub fn init() BlockMesh {
        var vertices = comptime blk: {
            var list: [24]Vertex = undefined;
            var idx: usize = 0;

            const color = [_]f32{0.1, 0.2, 0.3, 0};

            const faces = [_][3]f32{
                .{ 0, 0, 1 },   // front
                .{ 0, 0, -1 },  // back
                .{ -1, 0, 0 },  // left
                .{ 1, 0, 0 },   // right
                .{ 0, -1, 0 },  // bottom
                .{ 0, 1, 0 },   // top
            };

            for (faces) |n| {
                for (0..4) |v| {
                    const sx: f32 = if (v == 0 or v == 3) -0.5 else 0.5;
                    const sy: f32 = if (v == 0 or v == 1) -0.5 else 0.5;

                    // Better: use normal to decide which axis is constant
                    var x = sx; var y = sy; var z: f32 = 0.5;
                    if (n[0] != 0) { x = n[0] * 0.5; y = sy; z = sx; }  // left/right: constant X, vary Y and Z
                    if (n[1] != 0) { y = n[1] * 0.5; x = sx; z = sy; }  // top/bottom: constant Y, vary X and Z
                    if (n[2] != 0) { z = n[2] * 0.5; x = sx; y = sy; }  // front/back: constant Z, vary X and Y

                    list[idx] = Vertex{
                        .position = .{ x, y, z },
                        .color = color,
                        .texture_coords = .{
                            if (v == 0 or v == 3) 0.0 else 1.0,
                            if (v == 0 or v == 1) 0.0 else 1.0,
                        },
                        .normals = n,
                    };
                    idx += 1;
                }
            }

            break :blk list;
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
