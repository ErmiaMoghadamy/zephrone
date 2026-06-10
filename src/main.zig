const std = @import("std");
const zephrone = @import("zephrone");

pub fn main(init: std.process.Init) !void {
    try zephrone.run(init.io);
}
