const zm = @import("zmath");

pub const Transform = struct {
    position: zm.Vec = zm.f32x4(0, 0, 0, 1),
    rotation: zm.Vec = zm.f32x4(0, 0, 0, 0),
    scale: zm.Vec = zm.f32x4(1, 1, 1, 1),

    model: zm.Mat = undefined,
    dirty: bool = true,

    pub fn init() Transform {
        var t = Transform{};
        t.markDirty();
        return t;
    }

    pub fn setPosition(self: *Transform, p: zm.Vec) void {
        self.position = p;
        self.dirty = true;
    }

    pub fn setRotation(self: *Transform, r: zm.Vec) void {
        self.rotation = r;
        self.dirty = true;
    }

    pub fn setScale(self: *Transform, s: zm.Vec) void {
        self.scale = s;
        self.dirty = true;
    }

    pub fn translate(self: *Transform, delta: zm.Vec) void {
        self.position += delta;
        self.dirty = true;
    }

    pub fn rotate(self: *Transform, delta: zm.Vec) void {
        self.rotation += delta;
        self.dirty = true;
    }

    pub fn scaleBy(self: *Transform, s: zm.Vec) void {
        self.scale *= s;
        self.dirty = true;
    }

    pub fn getModel(self: *Transform) zm.Mat {
        if (!self.dirty) return self.model;

        const rX = zm.rotationX(self.rotation[0]);
        const rY = zm.rotationY(self.rotation[1]);
        const rZ = zm.rotationZ(self.rotation[2]);

        const R = zm.mul(rZ, zm.mul(rX, rY));
        const T = zm.translationV(self.position);
        const S = zm.scalingV(self.scale);

        self.model = zm.mul(S, zm.mul(R, T));
        self.dirty = false;

        return self.model;
    }

    fn markDirty(self: *Transform) void {
        self.dirty = true;
    }
};
