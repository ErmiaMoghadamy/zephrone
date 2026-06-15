const std = @import("std");

pub const Time = struct {
    delta_time: f32,
    last_frame: f32,

    pub fn init() Time {
        return .{
            .delta_time = 0.0,
            .last_frame = 0.0
        };
    }

    pub fn update(self: *Time, current_time: f32) void {
        self.delta_time = current_time - self.last_frame;
        self.last_frame = current_time;
    }
};


test "Time Initialization" {
    const time = Time.init();
    try std.testing.expectEqual(@as(f32, 0.0), time.delta_time);
    try std.testing.expectEqual(@as(f32, 0.0), time.last_frame);
}

test "Time Update" {
    var time = Time.init();
    time.update(0.016);

    try std.testing.expectApproxEqAbs(@as(f32, 0.016), time.delta_time, 0.0001);
}
