const std = @import("std");
const zm = @import("zmath");

pub const Camera = struct {
    position: zm.Vec,
    target: zm.Vec,
    view: zm.Mat,
    projection: zm.Mat,

    fov: f32,
    aspect: f32,
    near: f32,
    far: f32,

    pub fn init(aspect: f32) Camera {
        const pos = zm.f32x4(0.0, 0.0, 5.0, 1.0);
        const forward = zm.f32x4(0.0, 0.0, -1.0, 0.0);

        var camera = Camera{
            .position = pos,
            .target = pos + forward,
            .view = undefined,
            .projection = undefined,

            .fov = 1.5,
            .aspect = aspect,
            .near = 0.1,
            .far = 100.0,
        };

        camera.updateProjection();
        camera.updateView();

        camera.moveY(2.0);
        camera.moveZ(-2.0);

        return camera;
    }

    pub fn updateFov(self: *Camera, fov: f32) void {
        self.fov = fov;
        self.updateProjection();
    }

    pub fn updateProjection(self: *Camera) void {
        self.projection = zm.perspectiveFovRh(
            self.fov,
            self.aspect,
            self.near,
            self.far,
        );
    }

    pub fn updateView(self: *Camera) void {
        self.view = zm.lookAtRh(
            self.position,
            self.target, // look at origin
            zm.f32x4(0.0, 1.0, 0.0, 0.0), // up
        );
    }

    pub fn setAspect(self: *Camera, aspect: f32) void {
        self.aspect = aspect;
        self.updateProjection();
    }

    pub fn moveZ(self: *Camera, amount: f32) void {
        const world_up = zm.f32x4(0.0, 1.0, 0.0, 0.0);

        const forward = zm.normalize3(self.target - self.position);

        const right = zm.normalize3(zm.cross3(forward, world_up));

        const forward_level = zm.normalize3(zm.cross3(world_up, right));

        const movement = forward_level * @as(zm.Vec, @splat(-amount));

        self.position += movement;
        self.target += movement;

        self.updateView();
    }

    pub fn moveX(self: *Camera, amount: f32) void {
        const world_up = zm.f32x4(0.0, 1.0, 0.0, 0.0);

        const forward = zm.normalize3(self.target - self.position);
        const right = zm.normalize3(zm.cross3(forward, world_up));

        const movement = right * @as(zm.Vec, @splat(amount));

        self.position += movement;
        self.target += movement;

        self.updateView();
    }

    pub fn moveY(self: *Camera, amount: f32) void {
        const world_up = zm.f32x4(0.0, 1.0, 0.0, 0.0);
        const movement = world_up * @as(zm.Vec, @splat(amount));

        self.position += movement;
        self.target += movement;

        self.updateView();
    }

    pub fn rotateY(self: *Camera, angle: f32) void {
        const to_target = self.target - self.position;

        // current distance to target (preserve it)
        const dist = std.math.sqrt(
            to_target[0] * to_target[0] +
                to_target[1] * to_target[1] +
                to_target[2] * to_target[2],
        );

        // current forward direction (unit)
        const forward = zm.normalize3(to_target);

        const cosA = std.math.cos(angle);
        const sinA = std.math.sin(angle);

        // rotate forward around world Y
        const rotated_forward = zm.f32x4(
            forward[0] * cosA - forward[2] * sinA,
            forward[1],
            forward[0] * sinA + forward[2] * cosA,
            0.0,
        );

        // keep same distance
        self.target = self.position + rotated_forward * @as(zm.Vec, @splat(dist));
        self.updateView();
    }

    pub fn rotateV(self: *Camera, angle: f32) void {
        const to_target = self.target - self.position;

        const dist = std.math.sqrt(
            to_target[0] * to_target[0] +
                to_target[1] * to_target[1] +
                to_target[2] * to_target[2],
        );

        const forward = zm.normalize3(to_target);

        const yaw = std.math.atan2(forward[0], -forward[2]);
        var pitch = std.math.asin(forward[1]);

        const limit: f32 = 1.55334306; // ~89 degrees
        pitch = std.math.clamp(pitch + angle, -limit, limit);

        const cp = std.math.cos(pitch);
        const sp = std.math.sin(pitch);
        const cy = std.math.cos(yaw);
        const sy = std.math.sin(yaw);

        const new_forward = zm.f32x4(cp * sy, sp, -cp * cy, 0.0);

        self.target = self.position + new_forward * @as(zm.Vec, @splat(dist));
        self.updateView();
    }
};
