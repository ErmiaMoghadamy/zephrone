const std = @import("std");
const zgui = @import("zgui");
const zglfw = @import("zglfw");
const zm = @import("zmath");
const zstbi = @import("zstbi");

pub fn genRandom() i32 {
    const rand = std.crypto.random;

    const e: i32 = @mod(rand.int(i32), 32) - 16;

    return e;
}

pub fn mat2arr(mat: zm.Mat) [16]f32 {
    var arr: [16]f32 = undefined;
    zm.storeMat(&arr, mat);
    return arr;
}

pub const RgbaImage = struct {
    width: u32,
    height: u32,
    pixels: []u8, // RGBA8, len = width * height * 4
};

pub fn loadPngRgba8(allocator: std.mem.Allocator, path: []const u8) !RgbaImage {
    zstbi.init(allocator);
    defer zstbi.deinit();

    // set flip vertically
    zstbi.setFlipVerticallyOnLoad(true);

    const zpath = try std.mem.concatWithSentinel(allocator, u8, &.{path}, 0);
    defer allocator.free(zpath);

    var img = try zstbi.Image.loadFromFile(zpath, 4);
    defer img.deinit();

    const w: u32 = @intCast(img.width);
    const h: u32 = @intCast(img.height);

    const out: []u8 = try allocator.dupe(u8, img.data);

    return .{ .width = w, .height = h, .pixels = out };
}
