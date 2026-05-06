const zstbi = @import("zstbi");
const std = @import("std");
const gl = @import("zopengl").bindings;

const RgbaImage = struct {
    width: u32,
    height: u32,
    pixels: []u8, // RGBA8, len = width * height * 4
};

pub const Texture = struct {
    id: u32,
    filepath: []const u8,
    width: u32,
    height: u32,
    bpp: u32,

    // cpu buffer
    localBuffer: []u8 = &[_]u8{},
    allocator: std.mem.Allocator,

    slot: i32,

    pub fn init(allocator: std.mem.Allocator, filepath: []const u8, ts: i32) !Texture {
        var t = Texture{
            .id = 0,
            .allocator = allocator,
            .localBuffer = undefined,
            .filepath = filepath,
            .width = 0,
            .height = 0,
            .bpp = 0,
            .slot = ts,
        };

        try t.post_init();
        errdefer t.deinit();

        return t;
    }

    pub fn deinit(self: *Texture) void {
        if (self.id != 0) {
            gl.deleteTextures(1, &self.id);
            self.id = 0;
        }
        if (self.localBuffer.len != 0) {
            self.allocator.free(self.localBuffer);
            self.localBuffer = &[_]u8{};
        }
    }

    pub fn post_init(self: *Texture) !void {
        // load image cpu buffer

        const img = try Texture.loadPngRgba8(self.allocator, self.filepath);
        self.width = @intCast(img.width);
        self.height = @intCast(img.height);
        self.localBuffer = img.pixels;

        // gl buffer
        gl.genTextures(1, &self.id);
        gl.bindTexture(gl.TEXTURE_2D, self.id);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, @intCast(self.width), @intCast(self.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, self.localBuffer.ptr);

        gl.generateMipmap(gl.TEXTURE_2D);

        gl.bindTexture(gl.TEXTURE_2D, 0);
    }

    pub fn getWidth(self: Texture) u32 {
        return self.width;
    }

    pub fn getHeight(self: Texture) u32 {
        return self.height;
    }

    pub fn bind(self: Texture) void {
        const slot_enum: c_uint = switch (self.slot) {
            0 => gl.TEXTURE0,
            1 => gl.TEXTURE1,
            2 => gl.TEXTURE2,
            3 => gl.TEXTURE3,
            4 => gl.TEXTURE4,
            5 => gl.TEXTURE5,
            6 => gl.TEXTURE6,
            7 => gl.TEXTURE7,
            8 => gl.TEXTURE8,
            9 => gl.TEXTURE9,
            10 => gl.TEXTURE10,
            11 => gl.TEXTURE11,
            12 => gl.TEXTURE12,
            13 => gl.TEXTURE13,
            14 => gl.TEXTURE14,
            15 => gl.TEXTURE15,
            else => 0,
        };

        gl.activeTexture(slot_enum);
        gl.bindTexture(gl.TEXTURE_2D, self.id);
    }

    pub fn unbind(self: Texture) void {
        _ = self;
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }

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
};
