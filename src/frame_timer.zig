const std = @import("std");

pub const FrameTimer = struct {
    timer: std.time.Timer,
    last_time_ns: u64,

    dt_ns: u64 = 0,
    fps_inst: f32 = 0,
    fps_avg: f32 = 0,
    fps_smooth: f32 = 0,
    fps_accum_ns: u64 = 0,
    fps_frames: u32 = 0,

    pub fn init() !FrameTimer {
        var timer = try std.time.Timer.start();
        return .{
            .timer = timer,
            .last_time_ns = timer.read(),
        };
    }

    pub fn tick(self: *FrameTimer) void {
        const now_ns: u64 = self.timer.read();
        const dt_ns: u64 = now_ns - self.last_time_ns;
        self.last_time_ns = now_ns;
        self.dt_ns = dt_ns;

        if (dt_ns > 0) {
            const dt_s: f32 = @as(f32, @floatFromInt(dt_ns)) / 1_000_000_000.0;
            self.fps_inst = 1.0 / dt_s;

            const alpha: f32 = 0.1;
            self.fps_smooth = self.fps_smooth * (1.0 - alpha) + self.fps_inst * alpha;
        }

        self.fps_accum_ns += dt_ns;
        self.fps_frames += 1;

        if (self.fps_accum_ns >= 1_000_000_000) {
            const accum_s: f32 = @as(f32, @floatFromInt(self.fps_accum_ns)) / 1_000_000_000.0;
            self.fps_avg = @as(f32, @floatFromInt(self.fps_frames)) / accum_s;
            self.fps_accum_ns -= 1_000_000_000;
            self.fps_frames = 0;
        }
    }

    pub fn deltaSeconds(self: FrameTimer) f64 {
        return @as(f64, @floatFromInt(self.dt_ns)) / 1_000_000_000.0;
    }
};
