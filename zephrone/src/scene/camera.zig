const std = @import("std");
const zm = @import("zmath");

pub const Camera = struct {
    const UP = zm.f32x4(0.0, 1.0, 0.0, 0.0);
    const INIT_FOV = 1.0;
    const INIT_NEAR = 0.1;
    const INIT_FAR = 100.0;

    position: zm.Vec,
    target: zm.Vec,
    view: zm.Mat,
    projection: zm.Mat,

    yaw: f32 = -std.math.pi / 2.0,
    pitch: f32 = 0.0,
    look_dist: f32 = 1.0,
    sensitivity: f32 = 0.0030,

    fov: f32,
    near: f32,
    far: f32,
    aspect: f32,

    pub fn init(initial_aspect: f32) Camera {
        const pos = zm.f32x4(0.0, 2.0, 5.0, 1.0);
        const forward = zm.f32x4(0.0, 0.0, -1.0, 0.0);

        var camera = Camera{
            .position = pos,
            .target = pos + forward,
            .view = undefined,
            .projection = undefined,
            .aspect = initial_aspect,
            .fov = INIT_FOV,
            .near = INIT_NEAR,
            .far = INIT_FAR,
        };

        camera.updateView();
        camera.updateProjection();
        return camera;
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
        const cy = @cos(self.yaw);
        const sy = @sin(self.yaw);
        const cp = @cos(self.pitch);
        const sp = @sin(self.pitch);

        const forward = zm.normalize3(zm.f32x4(
            cy * cp,
            sp,
            sy * cp,
            0.0,
        ));

        const dist = zm.f32x4(self.look_dist, self.look_dist, self.look_dist, 0.0);
        self.target = self.position + (forward * dist);

        self.view = zm.lookAtRh(self.position, self.target, UP);
    }

    pub fn updateAspect(self: *Camera, aspect: f32) void {
        self.aspect = aspect;
        self.updateProjection();
    }

    pub fn updateFov(self: *Camera, fov: f32) void {
        self.fov = fov;
        self.updateProjection();
    }

    pub fn rotateByMouse(self: *Camera, dx: f32, dy: f32) void {
        const invert_y: bool = false;

        self.yaw += dx * self.sensitivity;

        const two_pi = std.math.pi * 2.0;
        self.yaw = @mod(self.yaw, two_pi);
        if (self.yaw < 0.0) {
            self.yaw += two_pi;
        }

        if (invert_y) {
            self.pitch += dy * self.sensitivity;
        } else {
            self.pitch -= dy * self.sensitivity;
        }

        const max_pitch_rad = 89.0 * (std.math.pi / 180.0);

        if (std.math.isNan(self.pitch)) {
            self.pitch = 0.0;
        } else {
            self.pitch = std.math.clamp(self.pitch, -max_pitch_rad, max_pitch_rad);
        }

        self.updateView();
    }

    pub fn moveZ(self: *Camera, amount: f32) void {
        const forward = zm.normalize3(self.target - self.position);

        const right = zm.normalize3(zm.cross3(forward, UP));

        const forward_level = zm.normalize3(zm.cross3(UP, right));

        const movement = forward_level * @as(zm.Vec, @splat(-amount));

        self.position += movement;
        self.target += movement;

        self.updateView();
    }

    pub fn moveX(self: *Camera, amount: f32) void {
        const forward = zm.normalize3(self.target - self.position);
        const right = zm.normalize3(zm.cross3(forward, UP));

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
};
