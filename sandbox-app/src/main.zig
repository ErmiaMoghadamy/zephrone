const std = @import("std");
const Io = std.Io;

const zp = @import("zephrone_runtime");

pub fn main(init: std.process.Init) !void {
    try zp.run(init.io);
}
