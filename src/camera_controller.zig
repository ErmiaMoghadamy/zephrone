const glfw = @import("zglfw");
const Camera = @import("camera.zig").Camera;

pub const CameraController = struct {
    move_speed_z: f32 = 6.0,
    move_speed_x: f32 = 6.0,
    move_speed_y: f32 = 6.0,
    yaw_speed: f32 = 6.0,
    pitch_speed: f32 = 6.0,

    pub fn update(self: CameraController, window: *glfw.Window, camera: *Camera, dt: f32) void {
        if (window.getKey(.w) == .press) {
            camera.moveZ(-self.move_speed_z * dt);
        }

        if (window.getKey(.s) == .press) {
            camera.moveZ(self.move_speed_z * dt);
        }

        if (window.getKey(.a) == .press) {
            camera.moveX(-self.move_speed_x * dt);
        }

        if (window.getKey(.d) == .press) {
            camera.moveX(self.move_speed_x * dt);
        }

        if (window.getKey(.space) == .press) {
            camera.moveY(self.move_speed_y * dt);
        }

        if (window.getKey(.left_control) == .press) {
            camera.moveY(-self.move_speed_y * dt);
        }

        if (window.getKey(.q) == .press) {
            camera.rotateY(-self.yaw_speed * dt);
        }

        if (window.getKey(.e) == .press) {
            camera.rotateY(self.yaw_speed * dt);
        }

        if (window.getKey(.z) == .press) {
            camera.rotateV(-self.pitch_speed * dt);
        }

        if (window.getKey(.x) == .press) {
            camera.rotateV(self.pitch_speed * dt);
        }
    }
};
