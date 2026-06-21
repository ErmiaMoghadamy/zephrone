const zm = @import("zmath");

pub const Transform = struct {
    position: zm.Vec = zm.f32x4(0, 0, 0, 1),
    rotation: zm.Vec = zm.f32x4(0, 0, 0, 0),
    scale: zm.Vec = zm.f32x4(1, 1, 1, 1),

    pub fn init() Transform {
        return Transform{};
    }

    pub fn getModel(self: Transform) zm.Mat {
        const rX = zm.rotationX(self.rotation[0]);
        const rY = zm.rotationY(self.rotation[1]);
        const rZ = zm.rotationZ(self.rotation[2]);

        const R = zm.mul(rZ, zm.mul(rX, rY));
        const T = zm.translationV(self.position);
        const S = zm.scalingV(self.scale);

        return zm.mul(S, zm.mul(R, T));
    }
};
